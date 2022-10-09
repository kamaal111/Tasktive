//
//  TasksClient.swift
//  Backend
//
//  Created by Kamaal M Farah on 28/09/2022.
//

import Skypiea
import Logster
import CDPersist
import Foundation
import SharedModels
import ShrimpExtensions

private let logger = Logster(from: TasksClient.self)

// swiftlint:disable type_body_length
/// Client to handle all tasks store modifications.
public class TasksClient {
    private let store = TasksStore()
    private let contextStore = TasksFetchedContextStore()
    private let persistenceController: PersistenceController
    private let skypiea: Skypiea

    /// Initializer of ``TasksClient``
    /// - Parameter preview: Whether to return static preview data or not.
    public init(preview: Bool) {
        if !preview {
            self.persistenceController = .shared
            self.skypiea = .shared
        } else {
            self.persistenceController = .preview
            self.skypiea = .preview
        }
    }

    /// Get last fetched date and data sources.
    /// - Returns: Last fetched date and data sources.
    public func getLastFetchedForContext() async -> (date: Date, sources: [DataSource])? {
        guard let context = await contextStore.store.last else { return .none }

        return (context.date, context.dataSources)
    }

    // - MARK: Create

    /// Creates a task using the given arguments on the given `DataSource`.
    /// - Parameters:
    ///   - arguments: The arguments used to create a task.
    ///   - source: Where to create the tasks on.
    /// - Returns: A result either containing the created task on success or ``Errors`` on failure.
    public func create(with arguments: TaskArguments, on source: DataSource) async -> Result<AppTask, Errors> {
        let result = await _create(with: arguments, on: source)
        let task: AppTask
        switch result {
        case let .failure(failure):
            return .failure(failure)
        case let .success(success):
            task = success
        }

        await store.add(task)
        return .success(task)
    }

    // - MARK: Read

    /// List all tasks.
    /// - Parameters:
    ///   - sources: Where to get the tasks from.
    ///   - updateNotCompleted: Whether to update not completed tasks from the previous days.
    ///   - forceFetch: Fetch without looking in to cache.
    /// - Returns: A result either containing an array with all tasks on success or ``Errors`` on failure.
    public func list(
        from sources: [DataSource],
        updateNotCompleted: Bool,
        forceFetch: Bool
    ) async -> (tasks: [AppTask]?, errors: Errors?) {
        await filter(from: sources, for: nil, updateNotCompleted: updateNotCompleted, forceFetch: forceFetch)
    }

    /// Get filtered tasks by the given date.
    /// - Parameters:
    ///   - sources: Where to get the tasks from.
    ///   - date: The due date for tasks.
    ///   - updateNotCompleted: Whether to update not completed tasks from the previous days.
    ///   - forceFetch: Fetch without looking in to cache.
    /// - Returns: A result either containing an array with filtered tasks on success or ``Errors`` on failure.
    public func filter(
        from sources: [DataSource],
        for date: Date?,
        updateNotCompleted: Bool,
        forceFetch: Bool
    ) async -> (tasks: [AppTask]?, errors: Errors?) {
        var queryString: String?
        if let date {
            let startDate = date.hashed
            let newLastFetchedContext = TasksFetchedContext(date: startDate, dataSources: sources)

            if forceFetch {
                logger.info("using force fetch to fetch tasks for \(startDate)")
            }

            guard await shouldFetchTasks(newContext: newLastFetchedContext, forceFetch: forceFetch) else {
                logger.info("getting cached tasks for \(startDate)")
                let previouslyFetchedForTasks = await store.get(date)
                return (previouslyFetchedForTasks, .none)
            }

            logger.info("fetching tasks for \(startDate)")

            let endDate = startDate.incrementByDays(1).hashed.incrementBySeconds(-1)
            queryString = NSPredicate(
                format: "(dueDate >= %@) AND (dueDate <= %@)",
                startDate.asNSDate,
                endDate.asNSDate
            ).predicateFormat
        } else {
            logger.info("fetching all tasks")
        }

        var appTasks: [AppTask] = []

        var maybeError: Errors?
        for source in sources {
            let tasksResult: Result<[AppTask], Errors>
            if let queryString {
                tasksResult = await _filter(from: source, by: queryString)
            } else {
                tasksResult = await _list(from: source)
            }

            switch tasksResult {
            case let .failure(failure):
                maybeError = failure
            case let .success(success):
                appTasks.append(contentsOf: success)
            }
        }

        if updateNotCompleted {
            appTasks = await updateDueDateOfTasksIfNeeded(appTasks, sources: sources)
        }

        let tasksSet = await store.add(appTasks)

        if maybeError != nil {
            await contextStore.pop()
        }

        guard let date else { return (tasksSet, maybeError) }

        let tasksForSearchedForDate = await store.get(date)
        return (tasksForSearchedForDate, maybeError)
    }

    // - MARK: Update

    /// Update the given task.
    /// - Parameters:
    ///   - task: The task to update.
    ///   - arguments: The arguments used to update the task.
    ///   - newSource: The source of the updated task.
    /// - Returns: A result either containing the updated task on success or ``Errors`` on failure.
    public func update(
        _ task: AppTask,
        with arguments: TaskArguments,
        on newSource: DataSource
    ) async -> Result<AppTask, Errors> {
        let validationResult = validateTaskArguments(arguments)
        switch validationResult {
        case let .failure(failure):
            return .failure(failure)
        case .success:
            break
        }

        let sourceHasChanged = task.source != newSource
        if sourceHasChanged {
            let deleteResult = await delete(task)
            switch deleteResult {
            case let .failure(failure):
                return .failure(failure)
            case .success:
                break
            }

            let createResult = await create(with: arguments, on: newSource)
            let createdTask: AppTask
            switch createResult {
            case let .failure(failure):
                return .failure(failure)
            case let .success(success):
                createdTask = success
            }

            logger.info("successfully changed the source from \(task.source) -> \(newSource)")
            return .success(createdTask)
        }

        let argumentsHaveChanged = task.arguments != arguments
        guard argumentsHaveChanged else {
            logger.info("arguments have not changed")
            return .success(task)
        }

        let updateResult = await _update(on: task.source, by: task.id, with: arguments)
        let updatedTask: AppTask
        switch updateResult {
        case let .failure(failure):
            return .failure(failure)
        case let .success(success):
            updatedTask = success
        }

        await store.update(updatedTask, fromDate: task.dueDate)
        return .success(updatedTask)
    }

    // - MARK: Delete

    /// Delete the given task.
    /// - Parameter task: The task to delete.
    /// - Returns: A result either containing nothing(`Void`) on success or ``Errors`` on failure.
    public func delete(_ task: AppTask) async -> Result<Void, Errors> {
        let result = await _delete(on: task.source, by: task.id)
        switch result {
        case let .failure(failure):
            return .failure(failure)
        case .success:
            break
        }

        await store.remove(task, fromDate: task.dueDate)
        return .success(())
    }

    // - MARK: Errors

    /// Task failures.
    public enum Errors: Error {
        /// Failure while saving.
        case saveFailure(context: Error?)
        /// Failure while fetching.
        case fetchFailure(context: Error?)
        /// Failure while updating.
        case updateFailure(context: Error?)
        /// Failure while deleting.
        case deleteFailure(context: Error?)
        /// Failure while updating many tasks.
        case updateManyFailure(context: Error?)
        /// Failure while clearing tasks.
        case clearFailure(context: Error?)
        /// Task is not found.
        case notFound
        /// Unknown error.
        case generalFailure(message: String)
        /// iCloud is disabled by user.
        case iCloudDisabledByUser
        /// Invalid title provided.
        case invalidTitle
        /// Failure on creating a reminder.
        case reminderCreationFailure(context: Error)
    }

    // - MARK: Private methods

    /// Update the task by id.
    /// - Parameters:
    ///   - source: Where to create the tasks on.
    ///   - id: The search id.
    ///   - arguments: The arguments used to update the task.
    /// - Returns:  A result either containing the updated task on success or ``Errors`` on failure.
    private func _update(
        on source: DataSource,
        by id: UUID,
        with arguments: TaskArguments
    ) async -> Result<AppTask, Errors> {
        switch source {
        case .coreData:
            let foundTask: CoreTask
            let findResult = findCoreTask(by: id)
            switch findResult {
            case let .failure(failure):
                return .failure(failure)
            case let .success(success):
                foundTask = success
            }

            return await foundTask.update(with: arguments, on: persistenceController.context)
                .mapError(mapCoreTaskErrors)
                .map(\.asAppTask)
        case .iCloud:
            let foundTask: CloudTask
            let findResult = await findCloudTask(by: id)
            switch findResult {
            case let .failure(failure):
                return .failure(failure)
            case let .success(success):
                foundTask = success
            }

            return await foundTask.update(with: arguments, on: skypiea)
                .mapError(mapCloudTaskErrors)
                .map(\.asAppTask)
        }
    }

    /// Delete the task by id.
    /// - Parameters:
    ///   - source: Where to create the tasks on.
    ///   - id: The search id.
    /// - Returns: A result either containing nothing (`Void`) on success or ``Errors`` on failure.
    private func _delete(on source: DataSource, by id: UUID) async -> Result<Void, Errors> {
        switch source {
        case .coreData:
            let foundTask: CoreTask
            let findResult = findCoreTask(by: id)
            switch findResult {
            case let .failure(failure):
                return .failure(failure)
            case let .success(success):
                foundTask = success
            }

            logger.info("deleted local task; \(foundTask)")
            return foundTask.delete(on: persistenceController.context)
                .mapError(mapCoreTaskErrors)
        case .iCloud:
            let foundTask: CloudTask
            let findResult = await findCloudTask(by: id)
            switch findResult {
            case let .failure(failure):
                return .failure(failure)
            case let .success(success):
                foundTask = success
            }

            logger.info("deleted cloud task; \(foundTask)")
            return await foundTask.delete(on: skypiea)
                .mapError(mapCloudTaskErrors)
        }
    }

    /// Update many due dates on tasks by date.
    /// - Parameters:
    ///   - tasks: The tasks to update.
    ///   - source: Where to create the tasks on.
    ///   - date: The new due date.
    /// - Returns: A result either containing nothing (`Void`) on success or ``Errors`` on failure.
    private func updateManyDates(
        _ tasks: [AppTask],
        from source: DataSource,
        date: Date
    ) async -> Result<Void, Errors> {
        switch source {
        case .coreData:
            return CoreTask.updateManyDates(tasks, date: date, on: persistenceController.context)
                .mapError(mapCoreTaskErrors)
        case .iCloud:
            return await CloudTask.updateManyDates(tasks, date: date, on: skypiea)
                .mapError(mapCloudTaskErrors)
        }
    }

    /// Creates a task using the given arguments on the given `DataSource`.
    /// - Parameters:
    ///   - source: Where to create the tasks on.
    ///   - arguments: The arguments used to create a task.
    /// - Returns: A result either containing the created task on success or ``Errors`` on failure.
    private func _create(with arguments: TaskArguments, on source: DataSource) async -> Result<AppTask, Errors> {
        switch source {
        case .coreData:
            return CoreTask.create(with: arguments, from: persistenceController.context)
                .mapError(mapCoreTaskErrors)
                .map(\.asAppTask)
        case .iCloud:
            return await CloudTask.create(with: arguments, from: skypiea)
                .mapError(mapCloudTaskErrors)
                .map(\.asAppTask)
        }
    }

    /// List all tasks from the given `DataSource`.
    /// - Parameter source: Where to get the tasks from.
    /// - Returns: A result either containing an array with all tasks on success or ``Errors`` on failure.
    private func _list(from source: DataSource) async -> Result<[AppTask], Errors> {
        switch source {
        case .coreData:
            return CoreTask.list(from: persistenceController.context)
                .mapError(mapCoreTaskErrors)
                .map { $0.map(\.asAppTask) }
        case .iCloud:
            return await CloudTask.list(from: skypiea)
                .mapError(mapCloudTaskErrors)
                .map { $0.map(\.asAppTask) }
        }
    }

    /// Filters tasks using the given query from the given `DataSource`.
    /// - Parameters:
    ///   - source: Where to get the tasks from.
    ///   - queryString: The query to filters tasks with.
    ///   - limit: The maximum amount of tasks to return, if this value is kepts nil then there is no limit.
    /// - Returns: A result either containing an array with filtered tasks on success or ``Errors`` on failure.
    private func _filter(
        from source: DataSource,
        by queryString: String,
        limit: Int? = nil
    ) async -> Result<[AppTask], Errors> {
        let predicate = NSPredicate(format: queryString)

        switch source {
        case .coreData:
            return CoreTask.filter(by: predicate, limit: limit, from: persistenceController.context)
                .mapError(mapCoreTaskErrors)
                .map { $0.map(\.asAppTask) }
        case .iCloud:
            return await CloudTask.filter(by: predicate, limit: limit, from: skypiea)
                .mapError(mapCloudTaskErrors)
                .map { $0.map(\.asAppTask) }
        }
    }

    private func validateTaskArguments(_ arguments: TaskArguments) -> Result<Void, Errors> {
        guard !arguments.title.trimmingByWhitespacesAndNewLines.isEmpty else { return .failure(.invalidTitle) }

        return .success(())
    }

    private func updateDueDateOfTasksIfNeeded(_ tasks: [AppTask], sources: [DataSource]) async -> [AppTask] {
        let now = Date()
        let today = now.hashed.asNSDate
        let tasksIDs = tasks.map(\.id.nsString).uniques()
        let predicate = NSPredicate(format: "(dueDate < %@) AND ticked == NO AND NOT(id in %@)", today, tasksIDs)

        var updatedTasks: [AppTask] = []
        for source in sources {
            let outdatedTasksResult = await _filter(from: source, by: predicate.predicateFormat)
            let outdatedTasks: [AppTask]
            switch outdatedTasksResult {
            case let .failure(failure):
                logger.error(label: "failed to fetch outdated tasks", error: failure)
                continue
            case let .success(success):
                outdatedTasks = success
            }

            let updateManyDatesResult = await updateManyDates(outdatedTasks, from: source, date: now)
            switch updateManyDatesResult {
            case let .failure(failure):
                updatedTasks.append(contentsOf: outdatedTasks)
                logger.error(label: "failed update tasks by date", error: failure)
                continue
            case .success:
                break
            }

            updatedTasks.append(contentsOf: outdatedTasks.map { task in
                var mutableTask = task
                mutableTask.dueDate = now
                return mutableTask
            })
        }

        if !updatedTasks.isEmpty {
            logger.info("updated tasks; \(updatedTasks)")
        }

        return tasks + updatedTasks
    }

    private func shouldFetchTasks(newContext: TasksFetchedContext, forceFetch: Bool) async -> Bool {
        let fetchedContexts = await contextStore.store

        let fetchedContextWithSameDateIndex = fetchedContexts.findIndex(by: \.date, is: newContext.date)

        if forceFetch {
            if let fetchedContextWithSameDateIndex {
                await contextStore.moveToEnd(fetchedContextWithSameDateIndex)
            }
            return true
        }

        if let fetchedContextWithSameDateIndex,
           let fetchedContextWithSameDate = fetchedContexts.at(fetchedContextWithSameDateIndex) {
            if fetchedContextWithSameDate.dataSources != newContext.dataSources {
                await contextStore.remove(at: fetchedContextWithSameDateIndex)
            }
        }

        if await contextStore.contains(newContext) {
            if let fetchedContextWithSameDateIndex {
                await contextStore.moveToEnd(fetchedContextWithSameDateIndex)
            } else {
                #if DEBUG
                fatalError("could not unwrap fetchedContextWithSameDateIndex")
                #else
                logger.warning("could not unwrap fetchedContextWithSameDateIndex")
                #endif
            }
            return false
        }

        await contextStore.append(newContext)
        return true
    }

    private func findCoreTask(by id: UUID) -> Result<CoreTask, Errors> {
        let predicate = NSPredicate(format: "id == %@", id.nsString)

        let foundTask: CoreTask
        let findResult = CoreTask.find(by: predicate, from: persistenceController.context)
            .mapError(mapCoreTaskErrors)
        switch findResult {
        case let .failure(failure):
            return .failure(failure)
        case let .success(success):
            guard let success else { return .failure(.notFound) }
            foundTask = success
        }

        return .success(foundTask)
    }

    private func findCloudTask(by id: UUID) async -> Result<CloudTask, Errors> {
        let predicate = NSPredicate(format: "id == %@", id.nsString)

        let foundTask: CloudTask
        let findResult = await CloudTask.find(by: predicate, from: skypiea)
            .mapError(mapCloudTaskErrors)
        switch findResult {
        case let .failure(failure):
            return .failure(failure)
        case let .success(success):
            guard let success else { return .failure(.notFound) }
            foundTask = success
        }

        return .success(foundTask)
    }

    private func mapCoreTaskErrors(_ error: CoreTask.CrudErrors) -> Errors {
        switch error {
        case let .saveFailure(context):
            return .saveFailure(context: context)
        case let .fetchFailure(context):
            return .fetchFailure(context: context)
        case let .clearFailure(context):
            return .clearFailure(context: context)
        case let .deletionFailure(context):
            return .deleteFailure(context: context)
        case let .updateManyFailure(context):
            return .updateManyFailure(context: context)
        case let .generalFailure(message):
            return .generalFailure(message: message)
        case let .reminderCreationFailure(context: context):
            return .reminderCreationFailure(context: context)
        }
    }

    private func mapCloudTaskErrors(_ error: CloudTask.CrudErrors) -> Errors {
        switch error {
        case let .saveFailure(context):
            return mapCloudTaskContextError(context) ?? .saveFailure(context: context)
        case let .fetchFailure(context):
            return mapCloudTaskContextError(context) ?? .fetchFailure(context: context)
        case let .updateManyFailure(context):
            return mapCloudTaskContextError(context) ?? .updateManyFailure(context: context)
        case let .updateFailure(context):
            return mapCloudTaskContextError(context) ?? .updateFailure(context: context)
        case let .deleteFailure(context):
            return mapCloudTaskContextError(context) ?? .deleteFailure(context: context)
        case let .generalFailure(message):
            return .generalFailure(message: message)
        }
    }

    private func mapCloudTaskContextError(_ error: Error?) -> Errors? {
        guard let error, let cloudErrors = error as? CloudableErrors else { return .none }

        switch cloudErrors {
        case .iCloudDisabledByUser:
            return .iCloudDisabledByUser
        }
    }
}

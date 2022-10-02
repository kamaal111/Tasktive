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
            let startDate = getHashDate(from: date)
            let newLastFetchedContext = TasksFetchedContext(date: startDate, dataSources: sources)

            guard await shouldFetchTasks(newContext: newLastFetchedContext, forceFetch: forceFetch) else {
                let previouslyFetchedForTasks = await store.get(date)
                return (previouslyFetchedForTasks, .none)
            }

            logger.info("fetching tasks for \(startDate)")

            let endDate = getHashDate(from: startDate.incrementByDays(1)).incrementBySeconds(-1)
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
                tasksResult = await filter(from: source, by: queryString)
            } else {
                tasksResult = await list(from: source)
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

        let groupedTasks = Dictionary(grouping: appTasks, by: {
            getHashDate(from: $0.dueDate)
        })

        var tasksSet: [AppTask] = []
        for (date, tasks) in groupedTasks {
            if let previouslyFetchedTasks = await store.get(date) {
                let tasks: [AppTask] = tasks
                    .concat(previouslyFetchedTasks)
                    .reduce([]) { result, task in
                        if !result.contains(where: { $0.id == task.id }) {
                            return result.appended(task)
                        }

                        return result
                    }
                await store.set(tasks, forDate: date)
                tasksSet.append(contentsOf: tasks)
            } else {
                await store.set(tasks, forDate: date)
                tasksSet.append(contentsOf: tasks)
            }
        }

        if maybeError != nil {
            await contextStore.pop()
        }

        guard let date else { return (tasksSet, maybeError) }

        let startDate = getHashDate(from: date)
        let tasksForSearchedForDate = await store.get(startDate)
        return (tasksForSearchedForDate, maybeError)
    }

    /// Update the task by id.
    /// - Parameters:
    ///   - source: Where to create the tasks on.
    ///   - id: The search id.
    ///   - arguments: The arguments used to update the task.
    /// - Returns:  A result either containing the updated task on success or ``Errors`` on failure.
    public func update(
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
    public func delete(on source: DataSource, by id: UUID) async -> Result<Void, Errors> {
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

            return await foundTask.delete(on: persistenceController.context)
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
    public func updateManyDates(_ tasks: [AppTask], from source: DataSource, date: Date) async -> Result<Void, Errors> {
        switch source {
        case .coreData:
            return CoreTask.updateManyDates(tasks, date: date, on: persistenceController.context)
                .mapError(mapCoreTaskErrors)
        case .iCloud:
            return await CloudTask.updateManyDates(tasks, date: date, on: skypiea)
                .mapError(mapCloudTaskErrors)
        }
    }

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
    private func list(from source: DataSource) async -> Result<[AppTask], Errors> {
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
    private func filter(
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

    private func updateDueDateOfTasksIfNeeded(_ tasks: [AppTask], sources: [DataSource]) async -> [AppTask] {
        let now = Date()
        let today = getHashDate(from: now).asNSDate
        let tasksIDs = tasks.map(\.id.nsString)
        let predicate = NSPredicate(format: "(dueDate < %@) AND ticked == NO AND NOT(id in %@)", today, tasksIDs)

        var updatedTasks: [AppTask] = []
        for source in sources {
            let outdatedTasksResult = await filter(from: source, by: predicate.predicateFormat)
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

        return tasks + updatedTasks
    }

    private func shouldFetchTasks(newContext: TasksFetchedContext, forceFetch: Bool) async -> Bool {
        if forceFetch {
            await contextStore.append(newContext)

            return true
        }

        var fetchedContexts = await contextStore.store
        if let fetchedContextIndexWithSameDate = fetchedContexts.findIndex(by: \.date, is: newContext.date),
           let fetchedContextWithSameDate = fetchedContexts.at(fetchedContextIndexWithSameDate) {
            if fetchedContextWithSameDate.dataSources != newContext.dataSources {
                fetchedContexts.remove(at: fetchedContextIndexWithSameDate)
            }
        }

        if fetchedContexts.contains(newContext) {
            await contextStore.replaceStore(with: fetchedContexts.appended(newContext))
        } else {
            await contextStore.append(newContext)
        }

        return true
    }

    private func getHashDate(from date: Date) -> Date {
        let dateComponents = Calendar.current.dateComponents([.day, .year, .month], from: date)
        return Calendar.current.date(from: dateComponents) ?? Date()
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

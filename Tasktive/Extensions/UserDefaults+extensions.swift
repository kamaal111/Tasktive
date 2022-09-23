//
//  UserDefaults+extensions.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 10/08/2022.
//

import Logster
import Foundation
import SettingsUI

extension UserDefaults {
    @UserDefaultObject(key: .appColor, container: .appGroup)
    static var appColor: AppColor?
    @UserDefaultObject(key: .lastChosenDataSource, container: .appGroup)
    static var lastChosenDataSource: DataSource?
    @UserDefaultValue(key: .iCloudSyncingIsEnabled, container: .appGroup)
    static var iCloudSyncingIsEnabled: Bool?

    private static let appGroup = UserDefaults(suiteName: Constants.appGroupIdentifier)
}

@propertyWrapper
struct UserDefaultValue<Value> {
    let key: Keys
    let container: UserDefaults?

    private let logger = Logster(from: Self.self)

    init(key: Keys, container: UserDefaults? = .standard) {
        self.key = key
        self.container = container
    }

    enum Keys: String {
        case iCloudSyncingIsEnabled
    }

    var wrappedValue: Value? {
        get {
            guard let container = container
            else {
                logger.warning("container not found")
                return nil
            }

            let data: Value?
            if container != .standard,
               let standardValue = UserDefaults.standard.object(forKey: constructedKey) as? Value {
                container.setValue(standardValue, forKey: constructedKey)
                UserDefaults.standard.removeObject(forKey: constructedKey)

                data = standardValue
            } else {
                data = container.object(forKey: constructedKey) as? Value
            }

            return data
        }
        set {
            guard let container = container
            else {
                logger.warning("container not found")
                return
            }
            if container != .standard, UserDefaults.standard.object(forKey: constructedKey) as? Value != nil {
                UserDefaults.standard.removeObject(forKey: constructedKey)
            }

            container.set(newValue, forKey: constructedKey)
        }
    }

    var projectedValue: UserDefaultValue { self }

    func removeValue() {
        container?.removeObject(forKey: constructedKey)
    }

    private var constructedKey: String {
        "\(Constants.bundleIdentifier).UserDefaults.\(key.rawValue)"
    }
}

@propertyWrapper
struct UserDefaultObject<Value: Codable> {
    let key: Keys
    let container: UserDefaults?

    private let logger = Logster(from: Self.self)

    init(key: Keys, container: UserDefaults? = .standard) {
        self.key = key
        self.container = container
    }

    enum Keys: String {
        case appColor
        case lastChosenDataSource
    }

    var wrappedValue: Value? {
        get {
            guard let container = container
            else {
                logger.warning("container not found")
                return nil
            }

            let data: Data?
            if container != .standard,
               let standardValue = UserDefaults.standard.object(forKey: constructedKey) as? Data {
                container.setValue(standardValue, forKey: constructedKey)
                UserDefaults.standard.removeObject(forKey: constructedKey)

                data = standardValue
            } else {
                data = container.object(forKey: constructedKey) as? Data
            }

            guard let data = data else { return nil }

            return try? JSONDecoder().decode(Value.self, from: data)
        }
        set {
            guard let container = container
            else {
                logger.warning("container not found")
                return
            }
            if container != .standard, UserDefaults.standard.object(forKey: constructedKey) as? Data != nil {
                UserDefaults.standard.removeObject(forKey: constructedKey)
            }

            guard let data = try? JSONEncoder().encode(newValue) else { return }

            container.set(data, forKey: constructedKey)
        }
    }

    var projectedValue: UserDefaultObject { self }

    func removeValue() {
        container?.removeObject(forKey: constructedKey)
    }

    private var constructedKey: String {
        "\(Constants.bundleIdentifier).UserDefaults.\(key.rawValue)"
    }
}

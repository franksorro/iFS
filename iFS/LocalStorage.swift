//
//  LocalStorage.swift
//  iFS
//
//  Created by Francesco Sorrentino on 21/09/18.
//  Copyright © 2018 Francesco Sorrentino. All rights reserved.
//

import Foundation

extension FsManager {

    public class LocalStorage: NSObject {

        public static let shared: LocalStorage = LocalStorage()

        private override init() {}

        public func read(_ keyName: String, type: Types.LocalStorageKeys) -> Any? {
            let defaults = UserDefaults.standard
            switch type {
            case .int: return defaults.integer(forKey: keyName)
            case .double: return defaults.double(forKey: keyName)
            case .float: return defaults.float(forKey: keyName)
            case .data: return defaults.data(forKey: keyName)
            case .string: return defaults.string(forKey: keyName)
            case .bool: return defaults.bool(forKey: keyName)
            case .array: return defaults.array(forKey: keyName)
            case .url: return defaults.url(forKey: keyName)
            case .any: return defaults.object(forKey: keyName)
            }
        }

        public func save(_ keyName: String, value: Any) {
            let defaults = UserDefaults.standard
            defaults.set(value, forKey: keyName)
            defaults.synchronize()
        }
    }
}

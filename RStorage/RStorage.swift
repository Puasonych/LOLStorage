//
//  RStorage.swift
//  RStorage
//
//  Created by Eric Basargin on 03/03/2019.
//  Copyright © 2019 Three-man army. All rights reserved.
//

import Foundation

open class RStorage<Manager: RStorageManagerProtocol>: RStorageProtocol, RStorageInternalProtocol {
    private enum UserDefaultType {
        case standard
        case custom
    }
    
    internal var domain: String
    internal var defaults: UserDefaults
    
    internal lazy var cache: [String: Data] = [:]

    private init?(defaultsType: UserDefaultType) {
        switch defaultsType {
        case UserDefaultType.standard:
            guard let bundleIdentifier = Bundle.main.bundleIdentifier else { return nil }
            self.domain = bundleIdentifier
            self.defaults = UserDefaults.standard
            
        case UserDefaultType.custom:
            self.domain = "\(type(of: self))"
            guard let userDefaults = UserDefaults(suiteName: self.domain) else { return nil }
            self.defaults = userDefaults
        }
    }
    
    public static var standard: RStorage<Manager> {
        guard let storage = RStorage<Manager>(defaultsType: UserDefaultType.standard) else {
            fatalError("Budle Main Identifier not found")
        }
        
        return storage
    }
    
    public static var instance: RStorage<Manager> {
        guard let storage = RStorage<Manager>(defaultsType: UserDefaultType.custom) else {
            fatalError("Unable to creae RStorage")
        }
        return storage
    }

    public func save<T>(key: Key<T, Manager>, value: T) throws where T : Codable {
        let keyName = key.manager.name + key.manager.suffix
        assert(key.manager.useCache || key.manager.usePersistentStorage,
               "The data \(keyName) is not cached; check the information in RStorageManagerProtocol")
        
        let data: Data = try key.manager.jsonEncoder.encode(RootJsonObject(value: value))
        
        if key.manager.useCache {
            self.cache[keyName] = data
        }
        
        if key.manager.usePersistentStorage {
            self.defaults.set(data, forKey: keyName)
        }
    }
    
    public func load<T>(key: Key<T, Manager>) throws -> T? where T : Codable {
        let keyName = key.manager.name + key.manager.suffix
        assert(key.manager.useCache || key.manager.usePersistentStorage,
               "The data \(keyName) is not cached; check the information in RStorageManagerProtocol")
        
        if key.manager.useCache, let cachedData = self.cache[keyName] {
            let data = try key.manager.jsonDecoder.decode(RootJsonObject<T>.self, from: cachedData)
            return data.value
        }
        
        if key.manager.usePersistentStorage {
            guard let data = self.defaults.data(forKey: keyName),
                let value = try? key.manager.jsonDecoder.decode(RootJsonObject<T>.self, from: data).value
                else { return nil }
            
            if key.manager.useCache { self.cache[keyName] = data }
            
            return value
        }
        
        return nil
    }
    
    public func isExists<T>(key: Key<T, Manager>) -> Bool where T : Codable {
        let keyName = key.manager.name + key.manager.suffix
        assert(key.manager.useCache || key.manager.usePersistentStorage,
               "The data \(keyName) is not cached; check the information in RStorageManagerProtocol")
        
        if key.manager.useCache, self.cache[keyName] != nil { return true }
        
        if key.manager.usePersistentStorage, let data = self.defaults.data(forKey: keyName) {
            if key.manager.useCache { self.cache[keyName] = data }
            
            return true
        }
        
        return false
    }
    
    public func remove<T>(key: Key<T, Manager>) where T : Codable {
        let keyName = key.manager.name + key.manager.suffix
        assert(key.manager.useCache || key.manager.usePersistentStorage,
               "The data \(keyName) is not cached; check the information in RStorageManagerProtocol")
        
        if key.manager.useCache {
            self.cache.removeValue(forKey: keyName)
        }
        
        if key.manager.usePersistentStorage {
            self.defaults.removeObject(forKey: keyName)
        }
    }
    
    public func removeAll(without: Manager...) {
        if without.isEmpty {
            self.cache = [:]
            self.defaults.removePersistentDomain(forName: self.domain)
            return
        }
        
        var withoutSet: Set<String> = Set()
        for key in without { withoutSet.insert(key.name + key.suffix) }
        
        for key in self.getAllUsedKeys() where !withoutSet.contains(key)  {
            self.cache[key] = nil
            self.defaults.removeObject(forKey: key)
        }
    }

    func getAllUsedKeys() -> Set<String> {
        var result: Set<String> = Set()
        
        for (key, _) in self.cache { result.insert(key) }

        guard let keys = self.defaults.persistentDomain(forName: self.domain) else { return result }

        for (key, _) in keys { result.insert(key) }

        return result
    }
}

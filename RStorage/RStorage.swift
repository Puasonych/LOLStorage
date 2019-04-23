//
//  RStorage.swift
//  RStorage
//
//  Created by Eric Basargin on 03/03/2019.
//  Copyright © 2019 Three-man army. All rights reserved.
//

import Foundation

open class RStorage<Manager: RStorageManagerProtocol>: RStorageProtocol, RStorageInternalProtocol {
    private let jsonEncoder: JSONEncoder
    private let jsonDecoder: JSONDecoder

    internal var domain: String
    internal var defaults: UserDefaults
    
    internal lazy var cache: [String: Data] = [:]
    
    public init?(jsonEncoder: JSONEncoder = JSONEncoder(), jsonDecoder: JSONDecoder = JSONDecoder()) {
        self.domain = "\(type(of: self))"
        guard let userDefaults = UserDefaults(suiteName: self.domain) else { return nil }
        
        self.defaults = userDefaults
        self.jsonEncoder = jsonEncoder
        self.jsonDecoder = jsonDecoder
    }

    public init?(domain: String, jsonEncoder: JSONEncoder = JSONEncoder(), jsonDecoder: JSONDecoder = JSONDecoder()) {
        self.domain = domain
        guard let userDefaults = UserDefaults(suiteName: self.domain) else { return nil }
        
        self.defaults = userDefaults
        self.jsonEncoder = jsonEncoder
        self.jsonDecoder = jsonDecoder
    }

    public func save<T>(key: Key<T, Manager>, value: T) throws where T : Codable {
        assert(key.manager.useCache || key.manager.usePersistentStorage,
               "The data \(key.manager.name) is not cached; check the information in RStorageManagerProtocol")
        
        let data: Data = try self.jsonEncoder.encode(RootJsonObject(value: value))
        
        if key.manager.useCache {
            self.cache[key.manager.name] = data
        }
        
        if key.manager.usePersistentStorage {
            self.defaults.set(data, forKey: key.manager.name)
        }
    }
    
    public func load<T>(key: Key<T, Manager>) throws -> T? where T : Codable {
        assert(key.manager.useCache || key.manager.usePersistentStorage,
               "The data \(key.manager.name) is not cached; check the information in RStorageManagerProtocol")
        
        if key.manager.useCache, let cachedData = self.cache[key.manager.name] {
            let data = try self.jsonDecoder.decode(RootJsonObject<T>.self, from: cachedData)
            return data.value
        }
        
        if key.manager.usePersistentStorage {
            guard let data = self.defaults.data(forKey: key.manager.name),
                let value = try? self.jsonDecoder.decode(RootJsonObject<T>.self, from: data).value
                else { return nil }
            
            if key.manager.useCache { self.cache[key.manager.name] = data }
            
            return value
        }
        
        return nil
    }
    
    public func isExists<T>(key: Key<T, Manager>) -> Bool where T : Codable {
        assert(key.manager.useCache || key.manager.usePersistentStorage,
               "The data \(key.manager.name) is not cached; check the information in RStorageManagerProtocol")
        
        if key.manager.useCache, self.cache[key.manager.name] != nil { return true }
        
        if key.manager.usePersistentStorage, let data = self.defaults.data(forKey: key.manager.name) {
            if key.manager.useCache { self.cache[key.manager.name] = data }
            
            return true
        }
        
        return false
    }
    
    public func remove<T>(key: Key<T, Manager>) where T : Codable {
        assert(key.manager.useCache || key.manager.usePersistentStorage,
               "The data \(key.manager.name) is not cached; check the information in RStorageManagerProtocol")
        
        if key.manager.useCache {
            self.cache.removeValue(forKey: key.manager.name)
        }
        
        if key.manager.usePersistentStorage {
            self.defaults.removeObject(forKey: key.manager.name)
        }
    }
    
    public func removeAll(without: Manager...) {
        if without.isEmpty {
            self.cache = [:]
            self.defaults.removePersistentDomain(forName: self.domain)
            return
        }

        for key in self.getAllKeys().symmetricDifference(without.map({ return $0.name })) {
            self.cache[key] = nil
            self.defaults.removeObject(forKey: key)
        }
    }

    func getAllKeys() -> Set<String> {
        var result: Set<String> = Set()
        
        for key in Manager.allCases { result.insert(key.name) }

        guard let otherKeys = self.defaults.persistentDomain(forName: self.domain) else { return result }

        for (key, _) in otherKeys { result.insert(key) }

        return result
    }
}

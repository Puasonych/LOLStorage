//
//  RStorage.swift
//  RStorage
//
//  Created by Eric Basargin on 03/03/2019.
//  Copyright © 2019 Three-man army. All rights reserved.
//

import Foundation

open class RStorage<Manager: RStorageManagerProtocol>: RStorageProtocol {
    private let defaults: UserDefaults
    private let jsonEncoder: JSONEncoder
    private let jsonDecoder: JSONDecoder

    private lazy var cache: [String: Data] = [:]
    
    public init(defaults: UserDefaults = UserDefaults(), jsonEncoder: JSONEncoder = JSONEncoder(), jsonDecoder: JSONDecoder = JSONDecoder()) {
        self.defaults = defaults
        self.jsonEncoder = jsonEncoder
        self.jsonDecoder = jsonDecoder
    }
    
    public func save<T>(key: Key<T, Manager>, value: T) throws where T : Codable {
        let data: Data = try self.jsonEncoder.encode(value)
        
        if key.manager.useCache {
            self.cache[key.manager.name] = data
        }
        
        if key.manager.usePersistentStorage {
            self.defaults.set(data, forKey: key.manager.name)
        }
        
        assert(key.manager.useCache || key.manager.usePersistentStorage,
               "The data \(key.manager.name) is not cached; check the information in RStorageManagerProtocol")
    }
    
    public func load<T>(key: Key<T, Manager>) throws -> T? where T : Codable {
        if key.manager.useCache, let cachedData = self.cache[key.manager.name] {
            return try self.jsonDecoder.decode(T.self, from: cachedData)
        }
        
        if key.manager.usePersistentStorage {
            guard let data = self.defaults.data(forKey: key.manager.name),
                let value = try? self.jsonDecoder.decode(T.self, from: data)
                else { return nil }
            
            if key.manager.useCache { self.cache[key.manager.name] = data }
            
            return value
        }
        
        assert(key.manager.useCache || key.manager.usePersistentStorage,
               "The data \(key.manager.name) is not cached; check the information in RStorageManagerProtocol")
        return nil
    }
    
    public func isExists<T>(key: Key<T, Manager>) -> Bool where T : Codable {
        if key.manager.useCache { return self.cache[key.manager.name] != nil }
        
        if key.manager.usePersistentStorage {
            return self.defaults.data(forKey: key.manager.name) != nil
        }
        
        assert(key.manager.useCache || key.manager.usePersistentStorage,
               "The data \(key.manager.name) is not cached; check the information in RStorageManagerProtocol")
        return false
    }
    
    public func remove<T>(key: Key<T, Manager>) where T : Codable {
        if key.manager.useCache {
            self.cache.removeValue(forKey: key.manager.name)
        }
        
        if key.manager.usePersistentStorage {
            self.defaults.removeObject(forKey: key.manager.name)
        }
        
        assert(key.manager.useCache || key.manager.usePersistentStorage,
               "The data \(key.manager.name) is not cached; check the information in RStorageManagerProtocol")
    }
    
    public func removeAll(without: Manager...) {
        for row in Manager.allCases {
            if without.contains(where: { $0.name == row.name }) { continue }
            
            if row.useCache {
                _ = self.cache.removeValue(forKey: row.name)
            }
            
            if row.usePersistentStorage {
                self.defaults.removeObject(forKey: row.name)
            }
            
            assert(row.useCache || row.usePersistentStorage,
                   "The data \(row.name) is not cached; check the information in RStorageManagerProtocol")
        }
    }
}

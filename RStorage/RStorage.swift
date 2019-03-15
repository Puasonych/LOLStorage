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
    
    public init(defaults: UserDefaults = UserDefaults.standard, jsonEncoder: JSONEncoder = JSONEncoder(), jsonDecoder: JSONDecoder = JSONDecoder()) {
        self.defaults = defaults
        self.jsonEncoder = jsonEncoder
        self.jsonDecoder = jsonDecoder
    }
    
    public func save<T>(key: Key<T, Manager>, value: T) throws where T : Codable {
        assert(key.manager.useCache || key.manager.usePersistentStorage,
               "The data \(key.manager.name) is not cached; check the information in RStorageManagerProtocol")
        
        let data: Data = try self.jsonEncoder.encode(value)
        
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
            return try self.jsonDecoder.decode(T.self, from: cachedData)
        }
        
        if key.manager.usePersistentStorage {
            guard let data = self.defaults.data(forKey: key.manager.name),
                let value = try? self.jsonDecoder.decode(T.self, from: data)
                else { return nil }
            
            if key.manager.useCache { self.cache[key.manager.name] = data }
            
            return value
        }
        
        return nil
    }
    
    public func isExists<T>(key: Key<T, Manager>) -> Bool where T : Codable {
        assert(key.manager.useCache || key.manager.usePersistentStorage,
               "The data \(key.manager.name) is not cached; check the information in RStorageManagerProtocol")
        
        if key.manager.useCache { return self.cache[key.manager.name] != nil }
        
        if key.manager.usePersistentStorage {
            return self.defaults.data(forKey: key.manager.name) != nil
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
        for row in Manager.allCases {
            assert(row.useCache || row.usePersistentStorage,
                   "The data \(row.name) is not cached; check the information in RStorageManagerProtocol")
            
            if without.contains(where: { $0.name == row.name }) { continue }
            
            if row.useCache {
                self.cache[row.name] = nil
            }
            
            if row.usePersistentStorage {
                self.defaults.removeObject(forKey: row.name)
            }
        }
    }
}

//
//  LOLStorage.swift
//  LOLStorage
//
//  Created by Eric Basargin on 03/03/2019.
//  Copyright © 2019 Three-man army. All rights reserved.
//

import Foundation

open class LOLStorage: LOLStorageProtocol {
    private let defaults: UserDefaults
    private let jsonEncoder: JSONEncoder
    private let jsonDecoder: JSONDecoder
    
    private weak var manager: LOLStorageManagerProtocol!
    
    private lazy var cache: [String: Data] = [:]
    
    public init(manager: LOLStorageManagerProtocol, defaults: UserDefaults = UserDefaults(), jsonEncoder: JSONEncoder = JSONEncoder(), jsonDecoder: JSONDecoder = JSONDecoder()) {
        self.manager = manager
        self.defaults = defaults
        self.jsonEncoder = jsonEncoder
        self.jsonDecoder = jsonDecoder
    }
    
    public func save<T>(value: T) where T : Codable {
        let key = T.self
        let stringKey = String(describing: key)
        
        if !self.manager.supportedTypes.contains(stringKey) {
            assert(false, "Trying to save unregistered type")
            return
        }
        
        guard let data: Data = try? self.jsonEncoder.encode(value) else { return }
        
        if self.manager.usePersistentStorage(key: key) {
            self.defaults.set(data, forKey: stringKey)
            self.defaults.synchronize()
        }
        
        if self.manager.useCache(key: key) {
            self.cache[stringKey] = data
        }
    }
    
    public func load<T>(key: T.Type) -> T? where T : Codable {
        let stringKey = String(describing: key)
        
        if !self.manager.supportedTypes.contains(stringKey) {
            assert(false, "Trying to load unregistered type")
            return nil
        }
        
        if self.manager.useCache(key: key), let cachedData = self.cache[stringKey] {
            guard let value = try? self.jsonDecoder.decode(key, from: cachedData) else { return nil }
            return value
        }
        
        guard let data = self.defaults.data(forKey: stringKey),
            let value = try? self.jsonDecoder.decode(key, from: data)
            else { return nil }
        
        self.cache[stringKey] = data
        
        return value
    }
    
    public func isExists<T: Codable>(key: T.Type) -> Bool {
        let stringKey = String(describing: key)
        
        if !self.manager.supportedTypes.contains(stringKey) { return false }
        
        if self.manager.useCache(key: key) { return self.cache[stringKey] != nil }
        
        if self.manager.usePersistentStorage(key: key) {
            return self.defaults.data(forKey: stringKey) != nil
        }
        
        assert(false, "The data type \(stringKey) is not cached; check the information in LocalStorageManagerProtocol")
        return false
    }
    
    public func remove<T: Codable>(key: T.Type) {
        let stringKey = String(describing: key)
        
        if !self.manager.supportedTypes.contains(stringKey) { return }
        
        if self.manager.useCache(key: key) {
            self.cache.removeValue(forKey: stringKey)
        }
        
        if self.manager.usePersistentStorage(key: key) {
            self.defaults.removeObject(forKey: stringKey)
        }
    }
    
    public func removeAll(without: Codable.Type...) {
        for stringKey in self.manager.supportedTypes {
            if without.contains(where: { return stringKey == String(describing: $0)}) { continue }
            self.defaults.removeObject(forKey: stringKey)
        }
        self.defaults.synchronize()
        self.cache = [:]
    }
}

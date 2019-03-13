//
//  RStorageProtocol.swift
//  RStorage
//
//  Created by Eric Basargin on 03/03/2019.
//  Copyright © 2019 Three-man army. All rights reserved.
//

import Foundation

/// The protocol with functions for `RStorage`
public protocol RStorageProtocol: class {
    associatedtype Manager: RStorageManagerProtocol
    /**
     Save value with registered type
     
     - Parameter key: the key to save value
     - Parameter value: value to be saved
     */
    func save<T: Codable>(key: Key<T, Manager>, value: T) throws
    
    /**
     To load a value from persistent memory or cache for the specified key
     
     - Parameter key: registered key
     */
    func load<T: Codable>(key: Key<T, Manager>) throws -> T?
    
    /**
     Checking the existence of data on a given key in persistent memory or cache
     
     - Parameter key: registered key
     */
    func isExists<T: Codable>(key: Key<T, Manager>) -> Bool
    
    /**
     To remove the value of the registered key
     
     - Parameter key: registered key
     */
    func remove<T: Codable>(key: Key<T, Manager>)

    /**
     To remove all value except for certain keys

     - Parameter without: registered keys that will not be deleted
     */
    func removeAll(without: Manager...)
}

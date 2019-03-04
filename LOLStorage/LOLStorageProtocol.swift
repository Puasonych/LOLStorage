//
//  LOLStorageProtocol.swift
//  LOLStorage
//
//  Created by Eric Basargin on 03/03/2019.
//  Copyright © 2019 Three-man army. All rights reserved.
//

import Foundation

/// The protocol with functions for `LOLStorage`
public protocol LOLStorageProtocol: class {
    /**
     Save value with registered type
     
     - Parameter value: value to be saved
     */
    func save<T: Codable>(value: T)
    
    /**
     To load a value from persistent memory or cache for the specified type (key)
     
     - Parameter key: registered type
     */
    func load<T: Codable>(key: T.Type) -> T?
    
    /**
     Checking the existence of data on a given key in persistent memory or cache
     
     - Parameter key: registered type
     */
    func isExists<T: Codable>(key: T.Type) -> Bool
    
    /**
     To remove the value of the registered key
     
     - Parameter key: registered type
     */
    func remove<T: Codable>(key: T.Type)
    
    /**
     To remove all value except for certain keys
     
     - Parameter without: registered types that will not be deleted
     */
    func removeAll(without: Codable.Type...)
}

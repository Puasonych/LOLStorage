//
//  LOLStorageManagerProtocol.swift
//  LOLStorage
//
//  Created by Eric Basargin on 03/03/2019.
//  Copyright © 2019 Three-man army. All rights reserved.
//

import Foundation

/// The protocol used to define the specifications necessary for a `LOLStorage`.
public protocol LOLStorageManagerProtocol: class {
    /// This is a supported types
    var supportedTypes: Set<String> { get }
    
    /// Do caching in RAM
    func useCache<T: Codable>(key: T.Type) -> Bool
    
    /// Do save in UserDefaults
    func usePersistentStorage<T: Codable>(key: T.Type) -> Bool
}

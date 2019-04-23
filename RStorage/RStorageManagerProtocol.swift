//
//  RStorageManagerProtocol.swift
//  RStorage
//
//  Created by Eric Basargin on 03/03/2019.
//  Copyright © 2019 Three-man army. All rights reserved.
//

import Foundation

/// The protocol used to define the specifications necessary for a `RStorage`.
public protocol RStorageManagerProtocol {
    associatedtype SupportedKeys
    
    /// This is a supported keys
    static var keys: SupportedKeys { get }
    
    /// Do caching in RAM
    var useCache: Bool { get }
    
    /// Do save in UserDefaults
    var usePersistentStorage: Bool { get }
    
    /// Current cache name
    var name: String { get }
    
    /// Custom suffix for keys
    var suffix: String { get }
    
    /// Custom json encoder
    var jsonEncoder: JSONEncoder { get }
    
    /// Custom json decoder
    var jsonDecoder: JSONDecoder { get }
}

public extension RStorageManagerProtocol {
    var suffix: String { return "" }
    
    var jsonEncoder: JSONEncoder { return JSONEncoder() }
    
    var jsonDecoder: JSONDecoder { return JSONDecoder() }
}

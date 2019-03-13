//
//  RStorageManagerProtocol.swift
//  RStorage
//
//  Created by Eric Basargin on 03/03/2019.
//  Copyright © 2019 Three-man army. All rights reserved.
//

import Foundation

/// The protocol used to define the specifications necessary for a `RStorage`.
public protocol RStorageManagerProtocol: CaseIterable {
    associatedtype SupportedKeys
    
    /// This is a supported keys
    static var keys: SupportedKeys { get }
    
    /// Do caching in RAM
    var useCache: Bool { get }
    
    /// Do save in UserDefaults
    var usePersistentStorage: Bool { get }
    
    /// Current cache name
    var cacheName: String { get }
}

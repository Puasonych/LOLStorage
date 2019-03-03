//
//  LOLStorageProtocol.swift
//  LOLStorage
//
//  Created by Eric Basargin on 03/03/2019.
//  Copyright © 2019 Three-man army. All rights reserved.
//

import Foundation

public protocol LOLStorageProtocol: class {
    func save<T: Codable>(value: T)
    func load<T: Codable>(key: T.Type) -> T?
    func isExists<T: Codable>(key: T.Type) -> Bool
    func remove<T: Codable>(key: T.Type)
    func removeAll(without: Codable.Type...)
}

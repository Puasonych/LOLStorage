//
//  RootJsonObject.swift
//  RStorage
//
//  Created by Eric Basargin on 23/04/2019.
//  Copyright © 2019 Three-man army. All rights reserved.
//

import Foundation

public struct RootJsonObject<T: Codable>: Codable {
    let value: T
}

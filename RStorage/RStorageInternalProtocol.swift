//
//  RStorageInternalProtocol.swift
//  RStorage
//
//  Created by Eric Basargin on 18/03/2019.
//  Copyright © 2019 Three-man army. All rights reserved.
//

import Foundation

internal protocol RStorageInternalProtocol: class {
    var cache: [String: Data] { get set }
}

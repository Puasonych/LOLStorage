//
//  CommonTests.swift
//  RStorageTests
//
//  Created by Алексей Воронов on 20/03/2019.
//  Copyright © 2019 Three-man army. All rights reserved.
//

import XCTest
@testable import RStorage

class CommonTests: XCTestCase {
    // MARK: - Stubs
    private struct Struct1: Codable {
        let text: String
    }
    
    private struct Struct2: Codable {
        let name: String
    }
    
    private enum KeyManager: String, RStorageManagerProtocol {
        typealias SupportedKeys = (
            struct1: Key<Struct1, KeyManager>,
            struct2: Key<Struct2, KeyManager>
        )
        
        case struct1 = "__Struct1__"
        case struct2 = "__Struct2__"
        
        static var keys: SupportedKeys {
            return (
                Key(.struct1),
                Key(.struct2)
            )
        }
        
        var useCache: Bool { return true }
        var usePersistentStorage: Bool { return true }
        
        var name: String { return self.rawValue }
    }
    
    // MARK: - Tests
    func testExistsWithCachedData() {
        guard let storage: RStorage<KeyManager> = RStorage() else {
            XCTFail("Can not create RStorage")
            return
        }
        
        let data = "{\"text\": \"This record exists\"}".data(using: String.Encoding.utf8)
        
        storage.cache[KeyManager.struct1.name] = data
        
        storage.defaults.set(data, forKey: KeyManager.struct1.name)
        
        XCTAssertTrue(storage.isExists(key: KeyManager.keys.struct1), "Record must exist in storage")

        storage.defaults.removePersistentDomain(forName: storage.domain)
    }
    
    func testExistsWithoutCachedData() {
        guard let storage: RStorage<KeyManager> = RStorage() else {
            XCTFail("Can not create RStorage")
            return
        }
        
        let data = "{\"text\": \"This record exists\"}".data(using: String.Encoding.utf8)
        
        storage.defaults.set(data, forKey: KeyManager.struct1.name)
        
        XCTAssertTrue(storage.isExists(key: KeyManager.keys.struct1), "Record must exist in storage")
        
        storage.defaults.removePersistentDomain(forName: storage.domain)
    }
}

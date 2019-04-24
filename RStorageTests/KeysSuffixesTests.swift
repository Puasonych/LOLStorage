//
//  KeysSuffixesTests.swift
//  RStorageTests
//
//  Created by Алексей Воронов on 23/04/2019.
//  Copyright © 2019 Three-man army. All rights reserved.
//

import XCTest
@testable import RStorage

class KeysSuffixesTests: XCTestCase {
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
        
        var useCache: Bool { return false }
        var usePersistentStorage: Bool { return true }
        
        var name: String { return self.rawValue }
        
        var suffix: String {
            switch self {
            case .struct1:
                return "-123"
            default:
                return ""
            }
        }
    }
    
    // MARK: - Tests
    func testSavingDataWithSuffix() {
        let storage: RStorage = RStorage<KeyManager>.instance
        
        try! storage.save(key: KeyManager.keys.struct1, value: Struct1(text: "TestText"))
        
        XCTAssertNotNil(storage.defaults.data(forKey: "\(KeyManager.struct1.name)\(KeyManager.struct1.suffix)"))
        XCTAssertNil(storage.defaults.data(forKey: "\(KeyManager.struct1.name)"))
        
        storage.removeAll()
    }
    
    func testLoadingDataWithSuffix() {
        let storage: RStorage = RStorage<KeyManager>.instance
        
        try! storage.save(key: KeyManager.keys.struct1, value: Struct1(text: "TestText"))
        
        guard let struct1 = try? storage.load(key: KeyManager.keys.struct1) else {
            XCTFail("Data must be loaded")
            return
        }
        
        XCTAssertEqual(struct1.text, Struct1(text: "TestText").text)
        
        storage.remove(key: KeyManager.keys.struct1)
        
        XCTAssertNil(try! storage.load(key: KeyManager.keys.struct1))
    }
    
    func testRemovingDataWithSuffix() {
        let storage: RStorage = RStorage<KeyManager>.instance
        
        try! storage.save(key: KeyManager.keys.struct1, value: Struct1(text: "TestText"))
        try! storage.save(key: KeyManager.keys.struct2, value: Struct2(name: "TestName"))
        
        storage.removeAll(without: KeyManager.struct2)
        
        XCTAssertNil(try! storage.load(key: KeyManager.keys.struct1))
        XCTAssertNotNil(try! storage.load(key: KeyManager.keys.struct2))
        
        storage.removeAll()
    }
    
    func testRemovingDataWithoutSuffix() {
        let storage: RStorage = RStorage<KeyManager>.instance
        
        try! storage.save(key: KeyManager.keys.struct1, value: Struct1(text: "TestText"))
        try! storage.save(key: KeyManager.keys.struct2, value: Struct2(name: "TestName"))
        
        storage.removeAll(without: KeyManager.struct1)
        
        XCTAssertNotNil(try! storage.load(key: KeyManager.keys.struct1))
        XCTAssertNil(try! storage.load(key: KeyManager.keys.struct2))
        
        storage.removeAll()
    }
}

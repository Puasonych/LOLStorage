//
//  SimpleTests.swift
//  SimpleTests
//
//  Created by Eric Basargin on 03/03/2019.
//  Copyright © 2019 Three-man army. All rights reserved.
//

import XCTest
@testable import RStorage

class CacheTests: XCTestCase {
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
            struct2: Key<Struct2, KeyManager>,
            struct3: Key<Struct1, KeyManager>
        )
        
        case struct1 = "__Struct1__"
        case struct2 = "__Struct2__"
        case struct3 = "__Struct3__"
        
        static var keys: SupportedKeys {
            return (
                Key(.struct1),
                Key(.struct2),
                Key(.struct3)
            )
        }
        
        var useCache: Bool { return true }
        var usePersistentStorage: Bool { return false }
        
        var name: String { return self.rawValue }
    }
    
    // MARK: - Tests
    func testSavingToCache() {
        let storage: RStorage<KeyManager> = RStorage()
        
        XCTAssertNoThrow(try storage.save(key: KeyManager.keys.struct1, value: Struct1(text: "Example Text")),
                         "Storage must save data")
        
        XCTAssertFalse(storage.cache.isEmpty, "Storage empty after save")
    }
    
    func testLoadingFromCache() {
        let storage: RStorage<KeyManager> = RStorage()
        
        storage.cache[KeyManager.struct1.name] = "{\"text\": \"Hello, Cache!\"}".data(using: String.Encoding.utf8)
        
        guard let data1 = try? storage.load(key: KeyManager.keys.struct1), let struct1 = data1 else {
            XCTFail("Can not load from storage")
            return
        }
        
        XCTAssertEqual(struct1.text, "Hello, Cache!", "Text must be equal in cache and loaded struct")
    }
    
    func testExistsInStorage() {
        let storage: RStorage<KeyManager> = RStorage()
        
        storage.cache[KeyManager.struct1.name] = "{\"text\": \"This record exists\"}".data(using: String.Encoding.utf8)
        
        XCTAssertTrue(storage.isExists(key: KeyManager.keys.struct1), "Record must exist in storage")
    }
    
    func testRemoveFromStorage() {
        let storage: RStorage<KeyManager> = RStorage()
        
        storage.cache[KeyManager.struct1.name] = "{\"text\": \"Record for removal\"}".data(using: String.Encoding.utf8)
        
        storage.remove(key: KeyManager.keys.struct1)
        
        XCTAssert(storage.cache.isEmpty, "Record must be removed from storage")
    }
    
    func testRemoveAll() {
        let storage: RStorage<KeyManager> = RStorage()
        
        storage.cache[KeyManager.struct1.name] = "{\"text\": \"Record for removal\"}}".data(using: String.Encoding.utf8)
        storage.cache[KeyManager.struct2.name] = "{\"name\": \"Removal Name\"}}".data(using: String.Encoding.utf8)
        
        storage.removeAll()
        
        XCTAssertNil(storage.cache[KeyManager.struct1.name], "\(KeyManager.struct1.name) must be removed from storage")
        XCTAssertNil(storage.cache[KeyManager.struct2.name], "\(KeyManager.struct2.name) must be removed from storage")
    }
    
    func testRemoveExcept() {
        let storage: RStorage<KeyManager> = RStorage()
        
        storage.cache[KeyManager.struct1.name] = "{\"text\": \"Record for removal\"}}".data(using: String.Encoding.utf8)
        storage.cache[KeyManager.struct2.name] = "{\"name\": \"Removal Name\"}}".data(using: String.Encoding.utf8)

        storage.removeAll(without: KeyManager.struct2)
        
        XCTAssertNil(storage.cache[KeyManager.struct1.name], "\(KeyManager.struct1.name) must be removed from storage")
        XCTAssertNotNil(storage.cache[KeyManager.struct2.name], "\(KeyManager.struct2.name) must stay in storage")
    }
    
    func testSaveOneTypeForManyKeys() {
        let storage: RStorage<KeyManager> = RStorage()
        
        XCTAssertNoThrow(try storage.save(key: KeyManager.keys.struct1, value: Struct1(text: "Example Text 1")),
                         "Storage must save data")
        XCTAssertNoThrow(try storage.save(key: KeyManager.keys.struct3, value: Struct1(text: "Example Text 2")),
                         "Storage must save data")
        
        let data1 = storage.cache[KeyManager.struct1.name]
        let data2 = storage.cache[KeyManager.struct3.name]
        
        XCTAssertNotNil(data1, "Storage empty after save")
        XCTAssertNotNil(data2, "Storage empty after save")
        XCTAssertNotEqual(data1, data2, "When saving data of the same type something went wrong")
    }
    
    func testLoadingOneTypeForManyKeys() {
        let storage: RStorage<KeyManager> = RStorage()
        
        storage.cache[KeyManager.struct1.name] = "{\"text\": \"Hello, Cache, 1!\"}".data(using: String.Encoding.utf8)
        storage.cache[KeyManager.struct3.name] = "{\"text\": \"Hello, Cache, 2!\"}".data(using: String.Encoding.utf8)

        guard let data1 = try? storage.load(key: KeyManager.keys.struct1), let struct1 = data1 else {
            XCTFail("Can not load from storage")
            return
        }
        
        guard let data2 = try? storage.load(key: KeyManager.keys.struct3), let struct3 = data2 else {
            XCTFail("Can not load from storage")
            return
        }
        
        XCTAssertEqual(struct1.text, "Hello, Cache, 1!", "Text must be equal in defaults and loaded struct")
        XCTAssertEqual(struct3.text, "Hello, Cache, 2!", "Text must be equal in defaults and loaded struct")
    }
}

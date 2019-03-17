//
//  PersistenceTests.swift
//  RStorageTests
//
//  Created by Кирилл Салтыков on 17/03/2019.
//  Copyright © 2019 Three-man army. All rights reserved.
//

import XCTest
@testable import RStorage

class PersistenceStorage: XCTestCase {
    
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
                Key(manager: .struct1),
                Key(manager: .struct2),
                Key(manager: .struct3)
            )
        }
        
        var useCache: Bool { return false }
        var usePersistentStorage: Bool { return true }
        
        var name: String { return self.rawValue }
    }
    
    // MARK: - Tests
    func testSavingToDefaults() {
        guard let defaults = UserDefaults(suiteName: "BasicSavigTest") else {
            XCTFail("Can not create defaults for tests")
            return
        }
        
        let storage: RStorage<KeyManager> = RStorage(defaults: defaults)
        
        XCTAssertNoThrow(try storage.save(key: KeyManager.keys.struct1, value: Struct1(text: "Example Text")),
                         "Storage must save data")
        
        let data = defaults.data(forKey: "__Struct1__")
        
        XCTAssertNotNil(data, "Storage empty after save")
        
        defaults.removeSuite(named: "BasicSavigTest")
    }
    
    func testLoadingFromDefaults() {
        guard let defaults = UserDefaults(suiteName: "BasicLoadingTest") else {
            XCTFail("Can not create defaults for tests")
            return
        }
        
        let storage: RStorage<KeyManager> = RStorage(defaults: defaults)
        
        defaults.set("{\"text\": \"Hello, Defaults!\"}".data(using: String.Encoding.utf8), forKey: "__Struct1__")
        
        guard let data1 = try? storage.load(key: KeyManager.keys.struct1), let struct1 = data1 else {
            XCTFail("Can not load from storage")
            return
        }
        
        XCTAssertEqual(struct1.text, "Hello, Defaults!", "Text must be equal in defaults and loaded struct")
        
        defaults.removeSuite(named: "BasicLoadingTest")
    }
    
    func testExistsInStorage() {
        guard let defaults = UserDefaults(suiteName: "ExistingTest") else {
            XCTFail("Can not create defaults for tests")
            return
        }
        
        let storage: RStorage<KeyManager> = RStorage(defaults: defaults)
        
        defaults.set("{\"text\": \"This record exists\"}".data(using: String.Encoding.utf8), forKey: "__Struct1__")
        
        XCTAssertTrue(storage.isExists(key: KeyManager.keys.struct1), "Record must exist in storage")
        
        defaults.removeSuite(named: "ExistingTest")
    }
    
    func testRemoveFromStorage() {
        guard let defaults = UserDefaults(suiteName: "RemovalTest") else {
            XCTFail("Can not create defaults for tests")
            return
        }
        
        let storage: RStorage<KeyManager> = RStorage(defaults: defaults)
        
        defaults.set("{\"text\": \"Record for removal\"}".data(using: String.Encoding.utf8), forKey: "__Struct1__")
        
        XCTAssertNotNil(defaults.data(forKey: "__Struct1__"), "Record must exists in storage")
        
        storage.remove(key: KeyManager.keys.struct1)
        
        XCTAssertNil(defaults.data(forKey: "__Struct1__"), "Record must be removed from storage")
        
        defaults.removeSuite(named: "RemovalTest")
    }
    
    func testRemoveAll() {
        guard let defaults = UserDefaults(suiteName: "RemovalAllTest") else {
            XCTFail("Can not create defaults for tests")
            return
        }
        
        let storage: RStorage<KeyManager> = RStorage(defaults: defaults)
        
        defaults.set("{\"text\": \"Record for removal\"}}".data(using: String.Encoding.utf8), forKey: "__Struct1__")
        defaults.set("{\"name\": \"Removal Name\"}}".data(using: String.Encoding.utf8), forKey: "__Struct2__")
        
        XCTAssertNotNil(defaults.value(forKey: "__Struct1__"), "Struct1 must exists in storage")
        XCTAssertNotNil(defaults.value(forKey: "__Struct2__"), "Struct2 must exists in storage")
        
        storage.removeAll()
        
        XCTAssertNil(defaults.value(forKey: "__Struct1__"), "Struct1 must be removed from storage")
        XCTAssertNil(defaults.value(forKey: "__Struct2__"), "Struct2 must be removed from storage")
        
        defaults.removeSuite(named: "RemovalAllTest")
    }
    
    func testRemoveExcept() {
        guard let defaults = UserDefaults(suiteName: "AdvancedRemovalTest") else {
            XCTFail("Can not create defaults for tests")
            return
        }
        
        let storage: RStorage<KeyManager> = RStorage(defaults: defaults)
        
        defaults.set("{\"text\": \"Record for removal\"}}".data(using: String.Encoding.utf8), forKey: "__Struct1__")
        defaults.set("{\"name\": \"Sample Name\"}}".data(using: String.Encoding.utf8), forKey: "__Struct2__")
        
        XCTAssertNotNil(defaults.value(forKey: "__Struct1__"), "Struct1 must exists in storage")
        XCTAssertNotNil(defaults.value(forKey: "__Struct2__"), "Struct2 must exists in storage")
        
        storage.removeAll(without: .struct2)
        
        XCTAssertNil(defaults.value(forKey: "__Struct1__"), "Struct1 must be removed from storage")
        XCTAssertNotNil(defaults.value(forKey: "__Struct2__"), "Struct2 must stay in storage")
        
        defaults.removeSuite(named: "AdvancedRemovalTest")
    }
}

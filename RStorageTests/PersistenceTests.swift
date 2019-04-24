//
//  PersistenceTests.swift
//  RStorageTests
//
//  Created by Кирилл Салтыков on 17/03/2019.
//  Copyright © 2019 Three-man army. All rights reserved.
//

import XCTest
@testable import RStorage

class PersistenceTests: XCTestCase {
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
        
        var useCache: Bool { return false }
        var usePersistentStorage: Bool { return true }
        
        var name: String { return self.rawValue }
    }
    
    // MARK: - Tests
    func testSavingToDefaults() {
        let storage: RStorage = RStorage<KeyManager>.instance
        
        XCTAssertNoThrow(try storage.save(key: KeyManager.keys.struct1, value: Struct1(text: "Example Text")),
                         "Storage must save data")
        
        let data = storage.defaults.data(forKey: KeyManager.struct1.name)
        
        XCTAssertNotNil(data, "Storage empty after save")
        
        storage.defaults.removePersistentDomain(forName: storage.domain)
    }
    
    func testLoadingFromDefaults() {
        let storage: RStorage = RStorage<KeyManager>.instance
        
        storage.defaults.set(#"{"value": {"text": "Hello, Defaults!"}}"#.data(using: String.Encoding.utf8), forKey: KeyManager.struct1.name)
        
        guard let struct1 = try? storage.load(key: KeyManager.keys.struct1) else {
            XCTFail("Can not load from storage")
            return
        }
        
        XCTAssertEqual(struct1.text, "Hello, Defaults!", "Text must be equal in defaults and loaded struct")
        
        storage.defaults.removePersistentDomain(forName: storage.domain)
    }
    
    func testExistsInStorage() {
        let storage: RStorage = RStorage<KeyManager>.instance
        
        storage.defaults.set(#"{"value": {"text": "This record exists"}}"#.data(using: String.Encoding.utf8), forKey: KeyManager.struct1.name)
        
        XCTAssertTrue(storage.isExists(key: KeyManager.keys.struct1), "Record must exist in storage")

        storage.defaults.removePersistentDomain(forName: storage.domain)
    }
    
    func testRemoveFromStorage() {
        let storage: RStorage = RStorage<KeyManager>.instance
        
        storage.defaults.set(#"{"value": {"text": "Record for removal"}}"#.data(using: String.Encoding.utf8), forKey: KeyManager.struct1.name)
        
        XCTAssertNotNil(storage.defaults.data(forKey: KeyManager.struct1.name), "Record must exists in storage")
        
        storage.remove(key: KeyManager.keys.struct1)
        
        XCTAssertNil(storage.defaults.data(forKey: KeyManager.struct1.name), "Record must be removed from storage")

        storage.defaults.removePersistentDomain(forName: storage.domain)
    }
    
    func testRemoveAll() {
        let storage: RStorage = RStorage<KeyManager>.instance
        
        storage.defaults.set(#"{"value": {"text": "Record for removal"}}"#.data(using: String.Encoding.utf8), forKey: KeyManager.struct1.name)
        storage.defaults.set(#"{"value": {"text": "Removal Name"}}"#.data(using: String.Encoding.utf8), forKey: KeyManager.struct2.name)
        
        XCTAssertNotNil(storage.defaults.value(forKey: KeyManager.struct1.name), "\(KeyManager.struct1.name) must exists in storage")
        XCTAssertNotNil(storage.defaults.value(forKey: KeyManager.struct2.name), "\(KeyManager.struct2.name) must exists in storage")
        
        storage.removeAll()
        
        XCTAssertNil(storage.defaults.value(forKey: KeyManager.struct1.name), "\(KeyManager.struct1.name) must be removed from storage")
        XCTAssertNil(storage.defaults.value(forKey: KeyManager.struct2.name), "\(KeyManager.struct2.name) must be removed from storage")
        
        storage.defaults.removePersistentDomain(forName: storage.domain)
    }
    
    func testRemoveExcept() {
        let storage: RStorage = RStorage<KeyManager>.instance
        
        storage.defaults.set(#"{"value": {"text": "Record for removal"}}"#.data(using: String.Encoding.utf8), forKey: KeyManager.struct1.name)
        storage.defaults.set(#"{"value": {"text": "Sample Name"}}"#.data(using: String.Encoding.utf8), forKey: KeyManager.struct2.name)
        
        XCTAssertNotNil(storage.defaults.value(forKey: KeyManager.struct1.name), "\(KeyManager.struct1.name) must exists in storage")
        XCTAssertNotNil(storage.defaults.value(forKey: KeyManager.struct2.name), "\(KeyManager.struct2.name) must exists in storage")
        
        storage.removeAll(without: KeyManager.struct2)
        
        XCTAssertNil(storage.defaults.value(forKey: KeyManager.struct1.name), "\(KeyManager.struct1.name) must be removed from storage")
        XCTAssertNotNil(storage.defaults.value(forKey: KeyManager.struct2.name), "\(KeyManager.struct2.name) must stay in storage")

        storage.defaults.removePersistentDomain(forName: storage.domain)
    }
    
    func testSaveOneTypeForManyKeys() {
        let storage: RStorage = RStorage<KeyManager>.instance
        
        XCTAssertNoThrow(try storage.save(key: KeyManager.keys.struct1, value: Struct1(text: "Example Text 1")),
                         "Storage must save data")
        XCTAssertNoThrow(try storage.save(key: KeyManager.keys.struct3, value: Struct1(text: "Example Text 2")),
                         "Storage must save data")
        
        let data1 = storage.defaults.data(forKey: KeyManager.struct1.name)
        let data2 = storage.defaults.data(forKey: KeyManager.struct3.name)
        
        XCTAssertNotNil(data1, "Storage empty after save")
        XCTAssertNotNil(data2, "Storage empty after save")
        XCTAssertNotEqual(data1, data2, "When saving data of the same type something went wrong")
        
        storage.defaults.removePersistentDomain(forName: storage.domain)
    }
    
    func testLoadingOneTypeForManyKeys() {
        let storage: RStorage = RStorage<KeyManager>.instance
        
        storage.defaults.set(#"{"value": {"text": "Hello, Defaults, 1!"}}"#.data(using: String.Encoding.utf8), forKey: KeyManager.struct1.name)
        storage.defaults.set(#"{"value": {"text": "Hello, Defaults, 2!"}}"#.data(using: String.Encoding.utf8), forKey: KeyManager.struct3.name)
        
        guard let struct1 = try? storage.load(key: KeyManager.keys.struct1) else {
            XCTFail("Can not load from storage")
            return
        }
        
        guard let struct3 = try? storage.load(key: KeyManager.keys.struct3) else {
            XCTFail("Can not load from storage")
            return
        }
        
        XCTAssertEqual(struct1.text, "Hello, Defaults, 1!", "Text must be equal in defaults and loaded struct")
        XCTAssertEqual(struct3.text, "Hello, Defaults, 2!", "Text must be equal in defaults and loaded struct")

        storage.defaults.removePersistentDomain(forName: storage.domain)
    }
    
    func testInstanceStorageAndStandardStorageCompatibility() {
        let storage: RStorage = RStorage<KeyManager>.instance
        
        XCTAssertNoThrow(try storage.save(key: KeyManager.keys.struct1, value: Struct1(text: "Example Text 1")),
                         "Storage must save data")
        
        XCTAssertNil(UserDefaults.standard.data(forKey: KeyManager.struct1.name),
                     "Custom Rstorage identifier is crossing with UserDefaults.standard")
        
        storage.remove(key: KeyManager.keys.struct1)
    }
    
    func testStandardStoragesCompatibility() {
        let storage: RStorage = RStorage<KeyManager>.standard
        
        XCTAssertNoThrow(try storage.save(key: KeyManager.keys.struct1, value: Struct1(text: "Example Text 1")),
                         "Storage must save data")
        
        UserDefaults.standard.set(true, forKey: "TEST_BOOL")
        
        XCTAssertNotNil(UserDefaults.standard.data(forKey: KeyManager.struct1.name))
        
        storage.remove(key: KeyManager.keys.struct1)
        
        XCTAssertNil(UserDefaults.standard.data(forKey: KeyManager.struct1.name))
        XCTAssertNotNil(UserDefaults.standard.value(forKey: "TEST_BOOL"))
        
        storage.removeAll()

        XCTAssertNil(UserDefaults.standard.value(forKey: "TEST_BOOL"))
    }
}

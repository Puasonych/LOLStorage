//
//  LiteralTests.swift
//  RStorageTests
//
//  Created by Алексей Воронов on 19/04/2019.
//  Copyright © 2019 Three-man army. All rights reserved.
//

import XCTest
@testable import RStorage

class LiteralTests: XCTestCase {
    // MARK: - Stubs
    private enum KeyManager: String, RStorageManagerProtocol {
        typealias SupportedKeys = (
            myInt: Key<Int, KeyManager>,
            myBool: Key<Bool, KeyManager>,
            myDouble: Key<Double, KeyManager>,
            myFloat: Key<Float, KeyManager>,
            myUrl: Key<URL, KeyManager>
        )

        case myInt = "MY_INT"
        case myBool = "MY_BOOL"
        case myDouble = "MY_DOUBLE"
        case myFloat = "MY_FLOAT"
        case myUrl = "MY_URL"
        
        static var keys: SupportedKeys {
            return (
                Key(.myInt),
                Key(.myBool),
                Key(.myDouble),
                Key(.myFloat),
                Key(.myUrl)
            )
        }

        var useCache: Bool { return false }
        var usePersistentStorage: Bool { return true }

        var name: String { return self.rawValue }
    }
    
    // MARK: - Tests
    func testSavingInt() {
        guard let storage: RStorage<KeyManager> = RStorage() else {
            XCTFail("Can not create RStorage")
            return
        }
        
        XCTAssertNoThrow(try storage.save(key: KeyManager.keys.myInt, value: 7),
                         "Storage must save data")
        
        let data = storage.defaults.data(forKey: KeyManager.myInt.name)
        
        XCTAssertNotNil(data, "Storage empty after save")
        
        storage.defaults.removePersistentDomain(forName: storage.domain)
    }
    
    func testLoadingInt() {
        guard let storage: RStorage<KeyManager> = RStorage() else {
            XCTFail("Can not create RStorage")
            return
        }
        
        storage.defaults.set(#"{"value": 7}"#.data(using: String.Encoding.utf8), forKey: KeyManager.myInt.name)
        
        guard let value = try? storage.load(key: KeyManager.keys.myInt) else {
            XCTFail("Can not load from storage")
            return
        }
        
        XCTAssertEqual(value, 7, "Value must be equal in defaults and loaded struct")
        
        storage.defaults.removePersistentDomain(forName: storage.domain)
    }
    
    func testSavingBool() {
        guard let storage: RStorage<KeyManager> = RStorage() else {
            XCTFail("Can not create RStorage")
            return
        }
        
        XCTAssertNoThrow(try storage.save(key: KeyManager.keys.myBool, value: true),
                         "Storage must save data")
        
        let data = storage.defaults.data(forKey: KeyManager.myBool.name)
        
        XCTAssertNotNil(data, "Storage empty after save")
        
        storage.defaults.removePersistentDomain(forName: storage.domain)
    }
    
    func testLoadingBool() {
        guard let storage: RStorage<KeyManager> = RStorage() else {
            XCTFail("Can not create RStorage")
            return
        }
        
        storage.defaults.set(#"{"value": true}"#.data(using: String.Encoding.utf8), forKey: KeyManager.myBool.name)
        
        guard let value = try? storage.load(key: KeyManager.keys.myBool) else {
            XCTFail("Can not load from storage")
            return
        }
        
        XCTAssertEqual(value, true, "Value must be equal in defaults and loaded struct")
        
        storage.defaults.removePersistentDomain(forName: storage.domain)
    }
    
    func testSavingDouble() {
        guard let storage: RStorage<KeyManager> = RStorage() else {
            XCTFail("Can not create RStorage")
            return
        }
        
        XCTAssertNoThrow(try storage.save(key: KeyManager.keys.myDouble, value: Double.pi),
                         "Storage must save data")
        
        let data = storage.defaults.data(forKey: KeyManager.myDouble.name)
        
        XCTAssertNotNil(data, "Storage empty after save")
        
        storage.defaults.removePersistentDomain(forName: storage.domain)
    }
    
    func testLoadingDouble() {
        guard let storage: RStorage<KeyManager> = RStorage() else {
            XCTFail("Can not create RStorage")
            return
        }
        
        storage.defaults.set(#"{"value": \#(Double.pi)}"#.data(using: String.Encoding.utf8), forKey: KeyManager.myDouble.name)
        
        guard let value = try? storage.load(key: KeyManager.keys.myDouble) else {
            XCTFail("Can not load from storage")
            return
        }
        
        XCTAssertEqual(value, Double.pi, "Value must be equal in defaults and loaded struct")
        
        storage.defaults.removePersistentDomain(forName: storage.domain)
    }
    
    func testSavingFloat() {
        guard let storage: RStorage<KeyManager> = RStorage() else {
            XCTFail("Can not create RStorage")
            return
        }
        
        XCTAssertNoThrow(try storage.save(key: KeyManager.keys.myFloat, value: Float.pi),
                         "Storage must save data")
        
        let data = storage.defaults.data(forKey: KeyManager.myFloat.name)
        
        XCTAssertNotNil(data, "Storage empty after save")
        
        storage.defaults.removePersistentDomain(forName: storage.domain)
    }
    
    func testLoadingFloat() {
        guard let storage: RStorage<KeyManager> = RStorage() else {
            XCTFail("Can not create RStorage")
            return
        }
        
        storage.defaults.set(#"{"value": \#(Float.pi)}"#.data(using: String.Encoding.utf8), forKey: KeyManager.myFloat.name)
        
        guard let value = try? storage.load(key: KeyManager.keys.myFloat) else {
            XCTFail("Can not load from storage")
            return
        }
        
        XCTAssertEqual(value, Float.pi, "Value must be equal in defaults and loaded struct")
        
        storage.defaults.removePersistentDomain(forName: storage.domain)
    }
    
    func testSavingUrl() {
        guard let url = URL(string: "https://www.google.com") else {
            XCTFail("Can not create URL")
            return
        }
        
        guard let storage: RStorage<KeyManager> = RStorage() else {
            XCTFail("Can not create RStorage")
            return
        }
        
        XCTAssertNoThrow(try storage.save(key: KeyManager.keys.myUrl, value: url),
                         "Storage must save data")
        
        let data = storage.defaults.data(forKey: KeyManager.myUrl.name)
        
        XCTAssertNotNil(data, "Storage empty after save")
        
        storage.defaults.removePersistentDomain(forName: storage.domain)
    }
    
    func testLoadingUrl() {
        guard let url = URL(string: "https://www.google.com") else {
            XCTFail("Can not create URL")
            return
        }
        
        guard let storage: RStorage<KeyManager> = RStorage() else {
            XCTFail("Can not create RStorage")
            return
        }
        
        storage.defaults.set(#"{"value": "\#(url)"}"#.data(using: String.Encoding.utf8), forKey: KeyManager.myUrl.name)
        
        guard let value = try? storage.load(key: KeyManager.keys.myUrl) else {
            XCTFail("Can not load from storage")
            return
        }
        
        XCTAssertEqual(value, url, "Value must be equal in defaults and loaded struct")
        
        storage.defaults.removePersistentDomain(forName: storage.domain)
    }
}

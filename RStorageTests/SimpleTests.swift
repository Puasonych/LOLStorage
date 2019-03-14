//
//  SimpleTests.swift
//  SimpleTests
//
//  Created by Eric Basargin on 03/03/2019.
//  Copyright © 2019 Three-man army. All rights reserved.
//

import XCTest
@testable import RStorage

struct Struct1: Codable {
    let name: String
}

struct Struct2: Codable {
    let name: String
    let substruct: Struct1
}

enum KeyManager: String, RStorageManagerProtocol {
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

    var useCache: Bool {
        switch self {
        case .struct1: return true
        case .struct2: return true
        case .struct3: return true
        }
    }

    var usePersistentStorage: Bool {
        switch self {
        case .struct1: return false
        case .struct2: return false
        case .struct3: return false
        }
    }
    
    var name: String {
        return self.rawValue
    }
}

class SimpleTests: XCTestCase {
    let storage: RStorage<KeyManager> = RStorage()
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSimpleFlow() {
        XCTAssertNoThrow(try storage.save(key: KeyManager.keys.struct1, value: Struct1(name: "Struct1")),
                         "Something went wrong when encoding the object")
        
        guard let data = try? storage.load(key: KeyManager.keys.struct1), let object = data else {
            XCTAssert(false, "Something went wrong when decoding the object")
            return
        }
        
        XCTAssert(object.name == "Struct1", "Incorrect data returned")
        
        storage.remove(key: KeyManager.keys.struct1)
        
        guard let nilData = try? storage.load(key: KeyManager.keys.struct1) else {
            XCTAssert(false, "Something went wrong when decoding the object")
            return
        }
        
        XCTAssertNil(nilData, "The data remained in the cache")
    }
    
    func testSimpleFlowWithSameStructures() {
        XCTAssertNoThrow(try storage.save(key: KeyManager.keys.struct1, value: Struct1(name: "Struct1")),
                         "Save 'Struct1': Something went wrong when encoding the object")
        XCTAssertNoThrow(try storage.save(key: KeyManager.keys.struct3, value: Struct1(name: "Struct3")),
                         "Save 'Struct3': Something went wrong when encoding the object")
        
        guard let data1 = try? storage.load(key: KeyManager.keys.struct1), let struct1 = data1 else {
            XCTAssert(false, "Load 'Struct1': Something went wrong when decoding the object")
            return
        }
        
        guard let data2 = try? storage.load(key: KeyManager.keys.struct3), let struct3 = data2 else {
            XCTAssert(false, "Load 'Struct3': Something went wrong when decoding the object")
            return
        }
        
        XCTAssert(struct1.name == "Struct1", "'Struct1': Incorrect data returned")
        XCTAssert(struct3.name == "Struct3", "'Struct3': Incorrect data returned")
        
        storage.removeAll()
        
        guard let nilData1 = try? storage.load(key: KeyManager.keys.struct1) else {
            XCTAssert(false, "Load 'Struct1': Something went wrong when decoding the object")
            return
        }
        
        guard let nilData2 = try? storage.load(key: KeyManager.keys.struct3) else {
            XCTAssert(false, "Load 'Struct3': Something went wrong when decoding the object")
            return
        }
        
        XCTAssertNil(nilData1, "'Struct1': The data remained in the cache")
        XCTAssertNil(nilData2, "'Struct3': The data remained in the cache")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}

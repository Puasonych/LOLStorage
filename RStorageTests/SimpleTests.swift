//
//  SimpleTests.swift
//  SimpleTests
//
//  Created by Eric Basargin on 03/03/2019.
//  Copyright © 2019 Three-man army. All rights reserved.
//

import XCTest
@testable import RStorage

struct ExampleDto: Codable {
    let name: String
}

struct ExampleDtoTwo: Codable {
    let name: String
    let substruct: ExampleDto
}

enum KeyManager: String, RStorageManagerProtocol {
    typealias SupportedKeys = (
        exampleDto: Key<ExampleDto, KeyManager>,
        exampleDto2: Key<ExampleDtoTwo, KeyManager>
    )
    
    case exampleDto = "__EXAMPLE_DTO__"
    case exampleDto2 = "__EXAMPLE_DTO_2__"
    
    static var keys: SupportedKeys {
        return (
            Key(name: KeyManager.exampleDto.rawValue, manager: .exampleDto),
            Key(name: KeyManager.exampleDto2.rawValue, manager: .exampleDto2)
        )
    }

    var useCache: Bool {
        switch self {
        case .exampleDto: return true
        case .exampleDto2: return true
        }
    }

    var usePersistentStorage: Bool {
        switch self {
        case .exampleDto: return false
        case .exampleDto2: return false
        }
    }
    
    var cacheName: String {
        return self.rawValue
    }
}

class SimpleTests: XCTestCase {
    var exampleDto: ExampleDto = ExampleDto(name: "example")

    let storage: RStorage<KeyManager> = RStorage()
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSimpleFlow() {
        XCTAssertNoThrow(try storage.save(key: KeyManager.keys.exampleDto, value: ExampleDto(name: "SimpleStruct1")),
                         "Something went wrong when encoding the object")
        
        guard let data = try? storage.load(key: KeyManager.keys.exampleDto), let object = data else {
            XCTAssert(false, "Something went wrong when decoding the object")
            return
        }
        
        XCTAssert(object.name == "SimpleStruct1", "Incorrect data returned")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}

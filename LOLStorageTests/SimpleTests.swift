//
//  SimpleTests.swift
//  SimpleTests
//
//  Created by Eric Basargin on 03/03/2019.
//  Copyright © 2019 Three-man army. All rights reserved.
//

import XCTest
@testable import LOLStorage

struct ExampleDto: Codable {
    let name: String
}

class LocalStorageManager: LOLStorageManagerProtocol {
    var supportedTypes: Set<String> = [
        String(describing: ExampleDto.self)
    ]
    
    func useCache<T>(key: T.Type) -> Bool where T : Codable {
        return false
    }
    
    func usePersistentStorage<T>(key: T.Type) -> Bool where T : Codable {
        return key == ExampleDto.self
    }
}

let storageManager: LocalStorageManager = LocalStorageManager()

class SimpleTests: XCTestCase {
    var exampleDto: ExampleDto = ExampleDto(name: "example")

    let storage: LOLStorage = LOLStorage(manager: storageManager)
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSimpleSave() {
        storage.save(value: self.exampleDto)
        guard let data = storage.load(key: ExampleDto.self) else {
            XCTAssert(false, "Failed to load data")
            return
        }
        
        XCTAssert(data.name == "example", "Incorrect data returned")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}

# RStorage [![Build Status](https://travis-ci.com/ephedra-software/RStorage.svg?branch=master)](https://travis-ci.com/ephedra-software/RStorage) [![Version](https://img.shields.io/cocoapods/v/RStorage.svg?style=flat)](https://cocoapods.org/pods/RStorage) [![codebeat badge](https://codebeat.co/badges/b4d848ef-9276-4b4d-8ac2-8dcff3b4b7aa)](https://codebeat.co/projects/github-com-puasonych-rstorage-master) [![codecov](https://codecov.io/gh/Puasonych/RStorage/branch/master/graph/badge.svg)](https://codecov.io/gh/Puasonych/RStorage)

UserDefaults abstraction framework with caching

## Installation

### CocoaPods

For RStorage, use the following entry in your Podfile:

```rb
pod 'RStorage', '~> 1.2'
```

Then run `pod install`.

In any file you'd like to use RStorage in, don't forget to
import the framework with `import RStorage`.

## Usage

Using RStorage is really simple. You can access an API like this:

```swift
do {
    try storage.save(key: KeyManager.keys.keyOne, value: YourCodableStructureOne(name: "Struct1"))
    try storage.save(key: KeyManager.keys.keyTwo, value: YourCodableStructureTwo(name: "Struct2"))
    
    let data1 = try storage.load(key: KeyManager.keys.keyOne)
    let data2 = try storage.load(key: KeyManager.keys.keyTwo)
    
    print("Data1 name: \(data1?.name ?? "Not found data1")") // Data1 name: Struct1
    print("Data2 name: \(data2?.name ?? "Not found data2")") // Data2 name: Struct2
    
    storage.removeAll(without: KeyManager.keyOne)
} catch {
    print(error.localizedDescription)
}

do {
    let data1 = try storage.load(key: KeyManager.keys.keyOne)
    let data2 = try storage.load(key: KeyManager.keys.keyTwo)
    
    print("Data1 name: \(data1?.name ?? "Not found data1")") // Data1 name: Struct1
    print("Data2 name: \(data2?.name ?? "Not found data2")") // Data2 name: Not found data2
} catch {
    print(error.localizedDescription)
}
```

To do this, you must implement the following:

```swift
enum KeyManager: String, RStorageManagerProtocol {
    typealias SupportedKeys = (
        keyOne: Key<YourCodableStructureOne, KeyManager>,
        keyTwo: Key<YourCodableStructureTwo, KeyManager>
    )
    
    case keyOne = "__YourCodableStructureOne__"
    case keyTwo = "__YourCodableStructureTwo__"
    
    static var keys: SupportedKeys {
        return (
            Key(.keyOne),
            Key(.keyTwo)
        )
    }

    var useCache: Bool {
        switch self {
        case .keyOne: return true
        case .keyTwo: return true
        }
    }

    var usePersistentStorage: Bool {
        switch self {
        case .keyOne: return false
        case .keyTwo: return false
        }
    }
    
    var name: String {
        return self.rawValue
    }
}

let storage: RStorage<KeyManager> = RStorage()
```

## License

RStorage is released under an MIT license. See [LICENSE](https://github.com/ephedra-software/RStorage/blob/master/LICENSE) for more information.

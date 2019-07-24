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

### SwiftPM (Accio)

For install RStorage with Accio (or SwiftPM from Xcode 11) add this line to Package.swift
```swift
.package(url: "https://github.com/ephedra-software/RStorage.git", .upToNextMajor(from: "1.2.2"))
```

Then run `accio install` or `accio update`.

In any file you'd like to use RStorage in, don't forget to
import the framework with `import RStorage`.

## Usage

Using RStorage is really simple. You can access an API like this:

```swift
let storage: RStorage = RStorage<KeyManager>.instance

struct YourCodableStructure: Codable {
    let name: String
}

do {
    try storage.save(key: KeyManager.keys.keyOne, value: URL("https://www.google.com/")!)
    try storage.save(key: KeyManager.keys.keyTwo, value: YourCodableStructure(name: "Struct"))
    
    let data1 = try storage.load(key: KeyManager.keys.keyOne)
    let data2 = try storage.load(key: KeyManager.keys.keyTwo)
    
    print("Url: \(data1 ?? "Not found url")")                   // Url: https://www.google.com/
    print("Data name: \(data2?.name ?? "Not found data2")")     // Data name: Struct
} catch {
    print(error.localizedDescription)
}

storage.removeAll(without: KeyManager.keyOne)

do {
    let data1 = try storage.load(key: KeyManager.keys.keyOne)
    let data2 = try storage.load(key: KeyManager.keys.keyTwo)
    
    print("Url: \(data1 ?? "Not found url")")                   // Url: https://www.google.com/
    print("Data name: \(data2?.name ?? "Not found data2")")     // Data name: Not found data2
} catch {
    print(error.localizedDescription)
}
```

To do this, you must implement the following:

```swift
enum KeyManager: String, RStorageManagerProtocol {
    typealias SupportedKeys = (
        keyOne: Key<URL, KeyManager>,
        keyTwo: Key<YourCodableStructure, KeyManager>
    )
    
    case keyOne = "__DefaultType__"
    case keyTwo = "__YourCodableStructure__"
    
    static var keys: SupportedKeys {
        return (
            Key(.keyOne),
            Key(.keyTwo)
        )
    }

    var useCache: Bool {
        switch self {
        case .keyOne: return false
        case .keyTwo: return true
        }
    }

    var usePersistentStorage: Bool {
        switch self {
        case .keyOne: return true
        case .keyTwo: return true
        }
    }
    
    var name: String {
        return self.rawValue
    }
}
```

## License

RStorage is released under an MIT license. See [LICENSE](https://github.com/ephedra-software/RStorage/blob/master/LICENSE) for more information.

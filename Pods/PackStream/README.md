# PackStream implementation in Swift

PackStream is a binary message format very similar to [MessagePack](http://msgpack.org). It can be used stand-alone, but it has been built as a message format for use in the Bolt protocol to communicate between the Neo4j server and its clients.

This implementation is written in Swift, primarily as a dependency for the Swift Bolt implementation. That implementation will in turn provide [Theo](https://github.com/graphstory/neo4j-ios), the [Neo4j](https://neo4j.com) Swift driver, with Bolt support.

## Usage
Through PackStream you can encode Bool, Int, Float (Double in Swift lingo), String, List, Map and Structure. They all implement the `PackProtocol`, so if you want to have a collection of packable items, you can specify them as implementing PackProtocol. 

### Example
First, remember to
```swift
import PackStream
```

Then you can use it, like for instance so:

```swift
let map = Map(dictionary: [
    "alpha": 42,
    "beta": 39.3,
    "gamma": "☺",
    "delta": List(items: [1,2,3,4])
    ])
let result = try map.pack()
let restored = try Map.unpack(result)
```

A list of the numbers 1 to 40
```swift
let items = Array(Int8(1)...Int8(40))
let value = List(items: items)
```
gets encoded to the following bytes
```
D4:28:01:02:03:04:05:06:07:08:09:0A:0B:0C:0D:0E:0F:10:11:12:13:14:15:16:17:18:19:1A:1B:1C:1D:1E:1F:20:22:23:24:25:26:27:28
```

## Getting started

To use directly with Xcode, type "swift package generate-xcodeproj"


### Swift Package Manager
Add the following to your dependencies array in Package.swift:
```swift
.Package(url: "https://github.com/niklassaers/PackStream-swift.git",
 majorVersion: 0),
```
and you can now do a
```bash
swift build
```

### CocoaPods
Add the 
```ruby
pod "PackStream"
```
to your Podfile, and you can now do
```bash
pod install
```
to have PackStream included in your Xcode project via CocoaPods

### Carthage
Put 
```ogdl
github "niklassaers/PackStream-swift"
```
in your Cartfile. If this is your entire Cartfile, do
```bash
carthage bootstrap
```
If you have already done that, do
```bash
carthage update
```
instead.

Then do 
```bash
cd Carthage/Checkouts/PackStream-swift
swift package generate-xcodeproj
cd -
```

And Carthage is now set up. You can now do
```bash
carthage build
```
and you should find a build for macOS, iOS, tvOS and watchOS in Carthage/Build

## Protocol documentation
For reference, please see [driver.py](https://github.com/neo4j-contrib/boltkit/blob/master/boltkit/driver.py) in [Boltkit](https://github.com/neo4j-contrib/boltkit)
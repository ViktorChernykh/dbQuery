# DBQuery

[![Swift 6.0](https://img.shields.io/badge/Swift-6.0-orange.svg?style=flat)](ttps://developer.apple.com/swift/)
[![Vapor 4](https://img.shields.io/badge/vapor-4.102-blue.svg?style=flat)](https://vapor.codes)
[![Swift Package Manager](https://img.shields.io/badge/SPM-compatible-4BC51D.svg?style=flat)](https://swift.org/package-manager/)
[![Platforms OS X | Linux](https://img.shields.io/badge/Platforms-OS%20X%20%7C%20Linux%20-lightgray.svg?style=flat)](https://developer.apple.com/swift/)

## Overview

DBQuery an API for building and serializing SQL queries in Swift. DBQuery is a SQLKit wrapper that implements CRUD for Postgres. For database creation and migrations, use Fluent or SQLKit.

## Getting started

You need to add library to `Package.swift` file:

 - add package to dependencies:
```swift
.package(url: "https://github.com/ViktorChernykh/dbQuery.git", from: "1.0.0")
```

- and add product to your target:
```swift
.target(name: "App", dependencies: [
    . . .
    .product(name: "DBQuery", package: "dbQuery")
])
```

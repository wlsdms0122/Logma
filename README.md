# Logma

`Logma` is a convenient and customizable library for log processing.

It can write logs using the 5-levels of logging (Debug, Info, Notice, Error, and Fault) defined by the Apple OS log system.

- [Logma](#logma)
- [Requirements](#requirements)
- [Installation](#installation)
  - [Swift Package Manager](#swift-package-manager)
- [Getting Started](#getting-started)
  - [Custom Printer](#custom-printer)
- [Contribution](#contribution)
- [License](#license)

# Requirements
- iOS 14.0+

# Installation
## Swift Package Manager
```swift
dependencies: [
    .package(url: "https://github.com/wlsdms0122/Logma.git", .upToNextMajor("1.2.0"))
]
```

# Getting Started
<image src="https://github.com/wlsdms0122/Logger/assets/11141077/1d69d151-d516-4e95-82ba-d704bb763eaa" />

`Logma` is a library that wraps the log system for customization.

If you want to write logs in your app, you can use `Logma`'s basic API for printing.

To use `Logma`, you should configure the printers first:
```swift
Logma.configure([
    // Any printers.
])
```

`Printer` is a simple protocol for printing logs. You can define your own log printer or use the default printer `ConsolePrinter` provided by Logma:
```swift
protocol Printer {
    func print(_ message: Any, userInfo: [Logma.Key: Any], level: Logma.Level)
}
```

After configuring `Logma`, you can use the following 5-level log APIs:
```swift
static func debug(_:userInfo:)
static func info(_:userInfo:)
static func notice(_:userInfo:)
static func error(_:userInfo:)
static func fault(_:userInfo:)
```

## Custom Printer
For example, if you want to write log using Apple's [Logger](https://developer.apple.com/documentation/os/logger), you can define `LoggerPrinter` adopt `Printer` protocol.
```swift
// LoggerPrinter.swift
import OSLog

struct LoggerPrinter: Printer {
    let logger = Logger()

    func print(_ message: Any, userInfo: [Logma.Key: Any], level: Logma.Level) {
        let message = ...

        switch level {
        case .debug:
            logger.debug(message)
            ...
        }
        
    }
}
```

```swift
// AppDelegate.swift
import Logma

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    ...
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Logma.configure([
            LoggerPrinter()
        ])
        ...
    }
}
```

# Contribution
Any ideas, issues, opinions are welcome.

# License
`Logma` is available under the MIT license. See the LICENSE file for more info.

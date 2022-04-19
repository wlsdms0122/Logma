//
//  ConsolePrinter.swift
//  
//
//  Created by jsilver on 2021/06/27.
//

import Foundation

public struct ConsolePrinter: Printer {
    // MARK: - Property
    
    // MARK: - Initiailzer
    public init() {
        
    }
    
    // MARK: - Public
    public func print(_ message: Any, userInfo: [Logger.Key: Any], level: Logger.Level) {
        guard let date = userInfo[.date] as? String,
              let fileName = (userInfo[.fileName] as? NSString)?.lastPathComponent,
              let function = userInfo[.function] as? String,
              let line = userInfo[.line] as? Int else {
            Swift.print("Default user info object went wrong!")
            return
        }
        
        let marker = marker(from: level)
        var log = "\(marker) \(date) \(fileName)/\(function)/\(line) "
        if let category = userInfo[.category] as? String, !category.isEmpty {
            log.append("[\(category)] ")
        }
        
        Swift.print("\(log)\(message)")
    }
    
    // MARK: - Private
    private func marker(from level: Logger.Level) -> String {
        switch level {
        case .debug:
            return "🟢"
            
        case .info:
            return "🔵"
            
        case .notice:
            return "🟡"
            
        case .error:
            return "🟠"
            
        case .fault:
            return "🔴"
        }
    }
}

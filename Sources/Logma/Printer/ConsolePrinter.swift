//
//  ConsolePrinter.swift
//  
//
//  Created by jsilver on 2021/06/27.
//

import Foundation

public struct ConsolePrinter: Printer {
    // MARK: - Property
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
    // MARK: - Initiailzer
    public init() {
        
    }
    
    // MARK: - Lifecycle
    public func print(_ message: Any, userInfo: [Logma.Key: Any], level: Logma.Level) {
        guard let date = userInfo[.date] as? Date,
              let fileName = (userInfo[.fileName] as? NSString)?.lastPathComponent,
              let function = userInfo[.function] as? String,
              let line = userInfo[.line] as? Int else {
            Swift.print("Default user info object went wrong!")
            return
        }
        
        let marker = marker(from: level)
        var log = "\(marker) \(dateFormatter.string(from: date)) \(fileName)/\(function)/\(line) "
        if let category = userInfo[.category] as? String, !category.isEmpty {
            log.append("[\(category)] ")
        }
        
        Swift.print("\(log)\(message)")
    }
    
    // MARK: - Public
    
    // MARK: - Private
    private func marker(from level: Logma.Level) -> String {
        switch level {
        case .debug:
            "🟢"
            
        case .info:
            "🔵"
            
        case .notice:
            "🟡"
            
        case .error:
            "🟠"
            
        case .fault:
            "🔴"
        }
    }
}

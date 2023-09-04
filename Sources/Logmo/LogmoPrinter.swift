//
//  LogmoPrinter.swift
//  
//
//  Created by JSilver on 2023/07/01.
//

import Foundation
import Logma

public struct LogmoPrinter: Printer {
    // MARK: - Property
    
    // MARK: - Initiailzer
    public init() {
        
    }
    
    // MARK: - Lifecycle
    public func print(_ message: Any, userInfo: [Logma.Key: Any], level: Logma.Level) {
        guard let date = userInfo[.date] as? String,
              let fileName = (userInfo[.fileName] as? NSString)?.lastPathComponent,
              let function = userInfo[.function] as? String,
              let line = userInfo[.line] as? Int else {
            Logmo.shared.addLog(.init("Default user info object went wrong!", level: .error))
            return
        }
        
        var log = "\(date) \(fileName)/\(function)/\(line) "
        if let category = userInfo[.category] as? String, !category.isEmpty {
            log.append("[\(category)] ")
        }
        
        Logmo.shared.addLog(.init("\(log)\(message)", level: level))
    }
    
    // MARK: - Public
    
    // MARK: - Private
}

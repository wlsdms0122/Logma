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
        Task { @MainActor in
            guard let date = userInfo[.date] as? Date,
                  let fileName = (userInfo[.fileName] as? NSString)?.lastPathComponent,
                  let function = userInfo[.function] as? String,
                  let line = userInfo[.line] as? Int else {
                Logmo.shared.addLog(.init("Default user info object went wrong!", level: .error))
                return
            }
            
            var log = "\(dateFormatter.string(from: date)) \(fileName)/\(function)/\(line) "
            if let category = userInfo[.category] as? String, !category.isEmpty {
                log.append("[\(category)] ")
            }
            
            Logmo.shared.addLog(.init("\(log)\(message)", level: level))
        }
    }
    
    // MARK: - Public
    
    // MARK: - Private
}

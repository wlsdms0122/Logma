//
//  LogFile.swift
//
//
//  Created by jsilver on 1/14/24.
//

import UIKit

struct LogFile {
    private struct Environment: CustomStringConvertible {
        var exportDate: Date { Date() }
        
        var description: String {
            """
            Export Date         : \(exportDate)
            Version             : \(Env.version?.string() ?? "unknown")
            OS Version          : \(Env.osVersion ?? "unknown")
            Platform Name       : \(Env.platformName ?? "unknown")
            Device Name         : \(Env.deviceName)
            Region              : \(Env.region ?? "unknown")
            Bundle Identifier   : \(Env.bundleIdentifier ?? "unknown")
            Bundle Display Name : \(Env.bundleDisplayName ?? "unknown")
            """
        }
    }
    
    // MARK: - Property
    private let logs: [Log]
    let url: URL
    private let convert: (Log) -> String
    
    // MARK: - Initializer
    init(_ logs: [Log], path url: URL, convert: ((Log) -> String)? = nil) {
        self.logs = logs
        self.url = url
        self.convert = convert ?? { log in
            switch log.level {
            case .debug:
                "🟢 \(log.message)"
                
            case .info:
                "🔵 \(log.message)"
                
            case .notice:
                "🟡 \(log.message)"
                
            case .error:
                "🟠 \(log.message)"
                
            case .fault:
                "🔴 \(log.message)"
            }
        }
    }
    
    // MARK: - Public
    func create() throws {
        let messages = logs.map(convert)
            .joined(separator: "\n")
        
        let content: String = """
        \(messages)
        
        \(Environment())
        """
        
        try content.write(to: url, atomically: false, encoding: .utf8)
    }
    
    func remove() throws {
        try FileManager.default.removeItem(at: url)
    }
    
    // MARK: - Private
}

//
//  LogFile.swift
//
//
//  Created by jsilver on 1/14/24.
//

import UIKit

struct LogFile {
    private struct Environment: CustomStringConvertible {
        private var info: [String: Any] { Bundle.main.infoDictionary ?? [:] }
        
        var exportDate: Date { Date() }
        var version: String? { info["CFBundleShortVersionString"] as? String }
        var osVersion: String? { info["DTPlatformVersion"] as? String }
        var platformName: String? { info["DTPlatformName"] as? String }
        var deviceName: String {
            var systemInfo = utsname()
            uname(&systemInfo)
            let machineMirror = Mirror(reflecting: systemInfo.machine)
            let identifier = machineMirror.children.reduce("") { identifier, element in
                guard let value = element.value as? Int8, value != 0 else { return identifier }
                return identifier + String(UnicodeScalar(UInt8(value)))
            }
            
            return identifier
        }
        var region: String? { info["CFBundleDevelopmentRegion"] as? String }
        var bundleIdentifier: String? { info["CFBundleIdentifier"] as? String }
        var bundleName: String? { info["CFBundleName"] as? String }
        
        var description: String {
            """
            Export Date       : \(exportDate)
            Version           : \(version ?? "unknown")
            OS Version        : \(osVersion ?? "unknown")
            Platform Name     : \(platformName ?? "unknown")
            Device Name       : \(deviceName)
            Region            : \(region ?? "unknown")
            Bundle Identifier : \(bundleIdentifier ?? "unknown")
            Bundle Name       : \(bundleName ?? "unknown")
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

//
//  LogFile.swift
//
//
//  Created by jsilver on 1/14/24.
//

import UIKit

final class LogFile {
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
    private static let fileName = "%@.log"
    
    private let logs: [Log]
    let url: URL
    
    // MARK: - Initializer
    init(_ logs: [Log]) async throws {
        // Create a log file in a temporary directory.
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HHmmss"
        
        let path = String(format: LogFile.fileName, dateFormatter.string(from: Date()))
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(path, conformingTo: .log)
        
        self.logs = logs
        self.url = url
        
        await try createFile()
    }
    
    // MARK: - Public
    
    // MARK: - Private
    private func createFile() async throws {
        let logMessages = logs.map { log in logMessage(log) }
            .joined(separator: "\n")
        
        let content: String = """
        \(logMessages)
        
        \(Environment())
        """
        
        try content.write(to: url, atomically: false, encoding: .utf8)
    }
    
    private func removeFile() {
        try? FileManager.default.removeItem(at: url)
    }
    
    private func logMessage(_ log: Log) -> String {
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
    
    deinit {
        // Remove the generated log file.
        removeFile()
    }
}

//
//  Settings.swift
//
//
//  Created by JSilver on 2023/07/16.
//

import Foundation
import SwiftUI

protocol SettingsDelegate: AnyObject {
    func settings(_ settings: Settings, export file: LogFile) async
}

@MainActor
class Settings: ObservableObject {
    private static let logFileNameFormat = "%@.log"
    
    // MARK: - Property
    /// Title of `Logmo` view status bar.
    @Published
    private(set) var title: String = ""
    /// Logs.
    @Published
    private(set) var logs: [Log] = []
    /// Status of log file exporting.
    @Published
    private(set) var isExporting: Bool = false
    
    weak var delegate: (any SettingsDelegate)?
    
    // MARK: - Initializer
    init() { }
    
    // MARK: - Public
    func setTitle(_ title: String = "") {
        self.title = title
    }
    
    func addLog(_ log: Log) {
        logs.append(log)
    }
    
    func clear() {
        logs.removeAll()
    }
    
    func export() async {
        guard !isExporting else { return }
        
        isExporting = true
        
        // Create temporary path url.
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let path = String(format: Settings.logFileNameFormat, dateFormatter.string(from: Date()))
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(path, conformingTo: .log)
        
        do {
            // Create log file.
            let file = LogFile(logs, path: url)
            try file.create()
            
            // Delegate file exporting.
            await delegate?.settings(self, export: file)
            
            // Remove temporary  file.
            try file.remove()
            
            isExporting = false
        } catch {
            isExporting = false
        }
    }
    
    // MARK: - Private
}

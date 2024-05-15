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
    private static let settingSuite = "logmo"
    
    private static let showFiltersKey = "showFilters"
    private static let showSearchBarKey = "showSearchBar"
    
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
    
    /// Setting flag: show log filter bar.
    @Published
    var showFilters: Bool = true {
        didSet {
            userDefaults?.set(showFilters, forKey: "showFilters")
        }
    }
    /// Setting flag: show log search bar.
    @Published
    var showSearchBar: Bool = false {
        didSet {
            userDefaults?.set(showSearchBar, forKey: "showSearchBar")
        }
    }
    
    private let userDefaults: UserDefaults?
    
    weak var delegate: (any SettingsDelegate)?
    
    // MARK: - Initializer
    init() {
        let userDefaults = UserDefaults(suiteName: Settings.settingSuite)
        
        self._showFilters = .init(
            initialValue: userDefaults?.bool(forKey: Settings.settingSuite) ?? true
        )
        self._showSearchBar = .init(
            initialValue: userDefaults?.bool(forKey: Settings.showSearchBarKey) ?? true
        )
        
        self.userDefaults = userDefaults
    }
    
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
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
        
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

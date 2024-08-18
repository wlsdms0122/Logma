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
    private static let SUITE_NAME = "logmo"
    
    private static let filterPatternsKey = "filterPatterns"
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
    /// Filtered logs.
    @Published
    private(set) var filteredLogs: [Log] = []
    /// Status of log file exporting.
    @Published
    private(set) var isExporting: Bool = false
    
    /// Setting: logmo regex patterns
    @Published
    var filterPatterns: [String] = [] {
        didSet {
            userDefaults?.set(filterPatterns, forKey: Settings.filterPatternsKey)
        }
    }
    /// Setting flag: show log filter bar.
    @Published
    var showFilters: Bool = true {
        didSet {
            userDefaults?.set(showFilters, forKey: Settings.showFiltersKey)
        }
    }
    /// Setting flag: show log search bar.
    @Published
    var showSearchBar: Bool = false {
        didSet {
            userDefaults?.set(showSearchBar, forKey: Settings.showSearchBarKey)
        }
    }
    
    private let userDefaults: UserDefaults?
    
    weak var delegate: (any SettingsDelegate)?
    
    // MARK: - Initializer
    init() {
        let userDefaults = UserDefaults(suiteName: Settings.SUITE_NAME)
        
        self._filterPatterns = .init(
            initialValue: userDefaults?.object(forKey: Settings.filterPatternsKey) as? [String] ?? []
        )
        self._showFilters = .init(
            initialValue: userDefaults?.bool(forKey: Settings.showFiltersKey) ?? true
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
        
        guard filterPatterns.isEmpty || !filterPatterns.contains(where: { pattern in log.message.regex(pattern, regexOptions: [.dotMatchesLineSeparators]) }) else { return }
        filteredLogs.append(log)
    }
    
    func addFilterPattern(_ pattern: String) {
        guard !pattern.isEmpty && !filterPatterns.contains(pattern) else { return }
        filterPatterns.append(pattern)
    }
    
    func removeFilterPattern(_ pattern: String) {
        guard let index = filterPatterns.firstIndex(of: pattern) else { return }
        filterPatterns.remove(at: index)
    }
    
    func clear() {
        logs.removeAll()
        filterPatterns.removeAll()
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

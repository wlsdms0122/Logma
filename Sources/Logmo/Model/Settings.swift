//
//  Settings.swift
//
//
//  Created by JSilver on 2023/07/16.
//

import Foundation

class Settings: ObservableObject {
    // MARK: - Property
    @Published
    var showFilters: Bool = true {
        didSet {
            userDefaults?.set(showFilters, forKey: "showFilters")
        }
    }
    @Published
    var showSearchBar: Bool = false {
        didSet {
            userDefaults?.set(showSearchBar, forKey: "showSearchBar")
        }
    }
    
    private let userDefaults: UserDefaults?
    
    // MARK: - Initializer
    init() {
        let userDefaults = UserDefaults(suiteName: "logmo")
        
        self._showFilters = .init(initialValue: userDefaults?.bool(forKey: "showFilters") ?? true)
        self._showSearchBar = .init(initialValue: userDefaults?.bool(forKey: "showSearchBar") ?? true)
        
        self.userDefaults = userDefaults
    }
    
    // MARK: - Public
    
    // MARK: - Private
}

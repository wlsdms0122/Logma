//
//  Setting.swift
//
//
//  Created by JSilver on 2023/07/16.
//

import Foundation
import SwiftUI

@MainActor
class Setting: ObservableObject {
    // MARK: - Property
    /// Title of `Logmo` view status bar.
    @Published
    private(set) var title: String = ""
    
    // MARK: - Initializer
    init() { }
    
    // MARK: - Public
    func setTitle(_ title: String = "") {
        self.title = title
    }
    
    // MARK: - Private
}

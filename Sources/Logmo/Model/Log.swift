//
//  Log.swift
//  
//
//  Created by JSilver on 2023/07/01.
//

import Logma

public struct Log: Hashable {
    // MARK: - Property
    public let level: Logma.Level
    public let message: String
    
    // MARK: - Initializer
    public init(level: Logma.Level, message: String) {
        self.level = level
        self.message = message
    }
    
    // MARK: - Public
    
    // MARK: - Private
}

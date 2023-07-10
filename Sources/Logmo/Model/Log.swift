//
//  Log.swift
//  
//
//  Created by JSilver on 2023/07/01.
//

import Logma

public struct Log: Hashable {
    // MARK: - Property
    public let message: String
    public let level: Logma.Level
    
    // MARK: - Initializer
    public init(_ message: String, level: Logma.Level) {
        self.message = message
        self.level = level
    }
    
    // MARK: - Public
    
    // MARK: - Private
}

//
//  Haptic.swift
//
//
//  Created by JSilver on 2023/07/14.
//

import UIKit

class Haptic {
    // MARK: - Property
    
    // MARK: - Initializer
    private init() { }
    
    // MARK: - Public
    static func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    // MARK: - Private
}

//
//  Haptic.swift
//
//
//  Created by JSilver on 2023/07/14.
//

import UIKit

class Haptic {
    // MARK: - Property
    static let shared: Haptic = Haptic()
    
    // MARK: - Initializer
    private init() { }
    
    // MARK: - Public
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    // MARK: - Private
}

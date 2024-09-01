//
//  Color+Hex.swift
//  
//
//  Created by JSilver on 2023/06/29.
//

import UIKit
import SwiftUI

extension Color {
    init(
        @Clamp(0...255) red: Int,
        @Clamp(0...255) green: Int,
        @Clamp(0...255) blue: Int,
        @Clamp(0...1) alpha: Double = 1
    ) {
        self.init(UIColor(red: red, green: green, blue: blue, alpha: alpha))
    }
    
    init(hex: Int, alpha: CGFloat = 1) {
        self.init(UIColor(hex: hex, alpha: alpha))
    }
}

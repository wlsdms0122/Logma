//
//  UIColor+Hex.swift
//
//
//  Created by JSilver on 2022/07/28.
//
import UIKit

public extension UIColor {
    convenience init(
        @Range(0...255) red: Int,
        @Range(0...255) green: Int,
        @Range(0...255) blue: Int,
        @Range(0...1) alpha: CGFloat = 1
    ) {
        self.init(
            red: CGFloat(red) / 255,
            green: CGFloat(green) / 255,
            blue: CGFloat(blue) / 255,
            alpha: alpha
        )
    }
    
    convenience init(hex: Int, alpha: CGFloat = 1) {
        let rgb: [Int] = (0...2).map {
            (hex >> ($0 * 8)) & 0xFF
        }
        
        self.init(
            red: rgb[2],
            green: rgb[1],
            blue: rgb[0],
            alpha: alpha
        )
    }
}

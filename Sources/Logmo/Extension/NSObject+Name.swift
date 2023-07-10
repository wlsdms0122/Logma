//
//  NSObject+Name.swift
//  
//
//  Created by JSilver on 2023/07/07.
//

import Foundation

extension NSObject {
    static var name: String { String(describing: self) }
}

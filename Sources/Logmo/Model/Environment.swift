//
//  Environment.swift
//  
//
//  Created by JSilver on 2023/07/17.
//

import Foundation

typealias Env = Environment

enum Environment { }

extension Environment {
    static var license: String { "MIT" }
    static var licenseURL: URL? { URL(string: "https://github.com/wlsdms0122/Logma/blob/main/LICENSE") }
}

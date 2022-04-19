//
//  Printer.swift
//  
//
//  Created by jsilver on 2021/06/27.
//

import Foundation

public protocol Printer {
    func print(_ message: Any, userInfo: [Logger.Key: Any], level: Logger.Level)
}

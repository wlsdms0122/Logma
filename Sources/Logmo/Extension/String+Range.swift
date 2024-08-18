//
//  String+Range.swift
//  
//
//  Created by jsilver on 2022/01/31.
//

import Foundation

extension String {
    var nsRange: NSRange { (self as NSString).range(of: self) }
}

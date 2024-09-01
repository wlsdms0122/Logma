//
//  String+Regex.swift
//  
//
//  Created by jsilver on 2022/01/25.
//

import Foundation

extension String {
    func regex(
        _ pattern: String,
        regexOptions: NSRegularExpression.Options = [],
        matchingOptions: NSRegularExpression.MatchingOptions = []
    ) -> [NSTextCheckingResult] {
        guard nsRange.length > 0 else { return [] }
        
        guard let regex = try? NSRegularExpression(
            pattern: pattern,
            options: regexOptions
        ) else { return [] }
        
        return regex.matches(
            in: self,
            options: matchingOptions,
            range: nsRange
        )
    }
    
    func regex(
        _ pattern: String,
        regexOptions: NSRegularExpression.Options = [],
        matchingOptions: NSRegularExpression.MatchingOptions = []
    ) -> Bool {
        let match = regex(
            pattern,
            regexOptions: regexOptions,
            matchingOptions: matchingOptions
        )
            .first { $0.range == nsRange }
        
        return match != nil
    }
}

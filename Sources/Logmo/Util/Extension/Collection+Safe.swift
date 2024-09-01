//
//  Collection+Safe.swift
//
//
//  Created by JSilver on 2022/02/12.
//

import Foundation

extension Collection {
    subscript(safe index: Index) -> Element? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }
    
    subscript(safe range: Range<Index>) -> SubSequence? {
        guard range.lowerBound >= startIndex && range.upperBound <= endIndex else { return nil }
        return self[range]
    }
    
    subscript(safe range: ClosedRange<Index>) -> SubSequence? {
        guard range.lowerBound >= startIndex && range.upperBound <= endIndex else { return nil }
        return self[range]
    }
}

//
//  Range.swift
//
//
//  Created by JSilver on 2022/07/28.
//
import Foundation

@propertyWrapper
struct Range<T: Comparable> {
    // MARK: - Property
    var wrappedValue: T {
        didSet {
            wrappedValue = clamping(wrappedValue)
        }
    }
    
    private let clamping: (T) -> T
    
    // MARK: - Initializer
    init(wrappedValue: T, _ range: Swift.Range<T>) {
        let clamping: (T) -> T = { value in
            max(min(value, range.upperBound), range.lowerBound)
        }
        
        self.wrappedValue = clamping(wrappedValue)
        self.clamping = clamping
    }
    
    init(wrappedValue: T, _ range: Swift.ClosedRange<T>) {
        let clamping: (T) -> T = { value in
            max(min(value, range.upperBound), range.lowerBound)
        }
        
        self.wrappedValue = clamping(wrappedValue)
        self.clamping = clamping
    }
    
    // MARK: - Public
    
    // MARK: - Private
}

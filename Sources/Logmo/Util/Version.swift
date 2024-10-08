//
//  Version.swift
//
//
//  Created by JSilver on 2023/04/16.
//

import Foundation

struct Version: Comparable {
    // MARK: - Property
    let major: Int
    let minor: Int
    let patch: Int
    
    // MARK: - Initializer
    init(
        major: Int = 0,
        minor: Int = 0,
        patch: Int = 0
    ) {
        self.major = major
        self.minor = minor
        self.patch = patch
    }
    
    init?(_ string: String) {
        let components = string.split(separator: ".")
        
        guard let majorString = components[safe: 0],
              let major = Int(majorString)
        else {
            return nil
        }
        
        self.init(
            major: major,
            minor: Int(components[safe: 1] ?? "0") ?? 0,
            patch: Int(components[safe: 2] ?? "0") ?? 0
        )
    }
    
    // MARK: - Lifecycle
    static func <(lhs: Version, rhs: Version) -> Bool {
        if lhs.major != rhs.major {
            return lhs.major < rhs.major
        }
        
        if lhs.minor != rhs.minor {
            return lhs.minor < rhs.minor
        }
        
        return lhs.patch < rhs.patch
    }
    
    // MARK: - Public
    func string(ignoresZero: Bool = false) -> String {
        let versionString = [patch, minor, major].reduce("") { versionString, version in
            if ignoresZero && versionString.isEmpty && version == 0 {
                return versionString
            } else if versionString.isEmpty {
                return "\(version)"
            } else {
                return "\(version).\(versionString)"
            }
        }
        
        return versionString.isEmpty ? "0" : versionString
    }
    
    // MARK: - Private
}

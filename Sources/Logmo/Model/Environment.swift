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
    static var infoPlist: [String: Any]? { Bundle.main.infoDictionary }
    
    static var version: Version? {
        guard let versionString = infoPlist?["CFBundleShortVersionString"] as? String else { return nil }
        return Version(versionString)
    }
    
    static var build: String? {
        infoPlist?["CFBundleVersion"] as? String
    }
    
    static var osVersion: String? {
        infoPlist?["DTPlatformVersion"] as? String
    }
    
    static var platformName: String? {
        infoPlist?["DTPlatformName"] as? String
    }
    
    static var deviceName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        return identifier
    }
    
    static var productName: String? {
        infoPlist?["CFBundleName"] as? String
    }
    
    static var bundleIdentifier: String? {
        infoPlist?["CFBundleIdentifier"] as? String
    }
    
    static var bundleDisplayName: String? {
        infoPlist?["CFBundleDisplayName"] as? String
    }
    
    static var region: String? {
        infoPlist?["CFBundleDevelopmentRegion"] as? String
    }
}

extension Environment {
    static var license: String { "MIT" }
    static var licenseURL: URL? { URL(string: "https://github.com/wlsdms0122/Logma/blob/main/LICENSE") }
}

//
//  Logger.swift
//  
//
//  Created by jsilver on 2021/06/22.
//

import Foundation

public struct Logger {
    public struct Key: Hashable, Equatable {
        public typealias RawValue = String
        
        public static var date: Key { .init(rawValue: "date") }
        public static var fileName: Key { .init(rawValue: "fileName") }
        public static var function: Key { .init(rawValue: "function") }
        public static var line: Key { .init(rawValue: "line") }
        public static var subsystem: Key { .init(rawValue: "subsystem") }
        public static var category: Key { .init(rawValue: "category") }
        
        private let rawValue: RawValue
        
        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
    }
    
    public enum Level {
        case debug
        case info
        case notice
        case error
        case fault
    }
    
    // MARK: - Property
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
    private static var printers: [Printer] = []
    
    // MARK: - Initializer
    
    // MARK: - Public
    public static func configure(_ printers: [Printer] = []) {
        self.printers = printers
    }
    
    public static func debug(
        _ message: Any = "",
        userInfo: [Key: Any] = [:],
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(
            message,
            userInfo: userInfo,
            file: file,
            function: function,
            line: line,
            level: .debug
        )
    }
    
    public static func info(
        _ message: Any = "",
        userInfo: [Key: Any] = [:],
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(
            message,
            userInfo: userInfo,
            file: file,
            function: function,
            line: line,
            level: .info
        )
    }
    
    public static func notice(
        _ message: Any = "",
        userInfo: [Key: Any] = [:],
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(
            message,
            userInfo: userInfo,
            file: file,
            function: function,
            line: line,
            level: .notice
        )
    }
    
    public static func error(
        _ message: Any = "",
        userInfo: [Key: Any] = [:],
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(
            message,
            userInfo: userInfo,
            file: file,
            function: function,
            line: line,
            level: .error
        )
    }
    
    public static func fault(
        _ message: Any = "",
        userInfo: [Key: Any] = [:],
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(
            message,
            userInfo: userInfo,
            file: file,
            function: function,
            line: line,
            level: .fault
        )
    }
    
    private static func log(
        _ message: Any,
        userInfo: [Key: Any],
        file: String,
        function: String,
        line: Int,
        level: Level
    ) {
        let info: [Key: Any] = [
            .date: dateFormatter.string(from: Date()),
            .fileName: file,
            .function: function,
            .line: line
        ].merging(userInfo) { current, _ in current }
        
        printers.forEach {
            $0.print(
                message,
                userInfo: info,
                level: level
            )
        }
    }
    
    // MARK: - Private
}

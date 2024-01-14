//
//  LogItemSource.swift
//  
//
//  Created by jsilver on 1/14/24.
//

import Foundation
import LinkPresentation

final class LogItemSource: NSObject, UIActivityItemSource {
    // MARK: - Property
    private let title = "Export Logs"
    private let file: LogFile
    
    // MARK: - Initializer
    init(_ file: LogFile) {
        self.file = file
        super.init()
    }
    
    // MARK: - Lifecycle
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        title
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        file.url
    }
    
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metaData = LPLinkMetadata()
        metaData.title = title
        metaData.url = file.url
        metaData.originalURL = file.url
        metaData.iconProvider = NSItemProvider(contentsOf: file.url)
        
        return metaData
    }
    
    // MARK: - Public
    
    // MARK: - Private
}

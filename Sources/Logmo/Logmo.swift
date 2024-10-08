//
//  Logmo.swift
//  
//
//  Created by JSilver on 2023/06/29.
//

import UIKit
import SwiftUI
import Logma

@MainActor
public class Logmo {
    // MARK: - Property
    public static let shared = Logmo()
    
    private let settings: Settings
    
    private var window: UIWindow?
    public private(set) var viewController: UIViewController?
    
    // MARK: - Initializer
    private init() {
        self.settings = Settings()
        
        settings.delegate = self
    }
    
    // MARK: - Public
    public func show<Actions: View>(@ViewBuilder actions: () -> Actions = { EmptyView() }) {
        let windowScene = UIApplication.shared.connectedScenes.filter {
            $0.activationState == .foregroundActive
        }
            .compactMap { $0 as? UIWindowScene }
            .first
        
        guard let windowScene = windowScene else { return }
        
        let viewController = UIHostingController(
            rootView: LogmoView(settings: settings, actions: actions)
        )
        viewController.view.backgroundColor = .clear
        
        let window = ContentResponderWindow(windowScene: windowScene)
        window.rootViewController = viewController
        window.isHidden = false
        
        self.window = window
        self.viewController = viewController
    }
    
    public func hide() {
        window?.isHidden = true
        window = nil
    }
    
    public func setTitle(_ title: String = "") {
        settings.setTitle(title)
    }
    
    public func addLog(_ log: Log) {
        settings.addLog(log)
    }
    
    public func save(fileName: String? = nil) {
        let path = {
            if let fileName {
                return fileName
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
            
            return String(format: "%@.log", dateFormatter.string(from: Date()))
        }()
        
        guard let url = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent(path, conformingTo: .log)
        else { return }
        
        let file = LogFile(settings.logs, path: url)
        
        try? file.create()
    }
    
    // MARK: - Private
    private func topMostViewController() -> UIViewController? {
        var viewController = window?.rootViewController
        
        while let childViewController = viewController?.presentedViewController {
            viewController = childViewController
        }
        
        return viewController
    }
}

extension Logmo: SettingsDelegate {
    func settings(_ settings: Settings, export file: LogFile) async {
        await withCheckedContinuation { continuation in
            let viewController = UIActivityViewController(
                activityItems: [LogItemSource(file)],
                applicationActivities: nil
            )
            viewController.popoverPresentationController?.sourceView = topMostViewController()?.view
            viewController.completionWithItemsHandler = { activityType, completed, returnedItems, error in
                continuation.resume()
            }
            
            topMostViewController()?.present(viewController, animated: true)
        }
    }
}

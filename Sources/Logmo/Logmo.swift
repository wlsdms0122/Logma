//
//  Logmo.swift
//  
//
//  Created by JSilver on 2023/06/29.
//

import UIKit
import SwiftUI
import Logma

public class Logmo: Sendable {
    // MARK: - Property
    public static let shared = Logmo()
    
    private let settings: Settings
    private var customSettingContent: AnyView?
    
    private var window: UIWindow?
    
    // MARK: - Initializer
    private init() { 
        self.settings = Settings()
        
        settings.delegate = self
    }
    
    // MARK: - Public
    @MainActor
    public func show() {
        let windowScene = UIApplication.shared.connectedScenes.filter {
            $0.activationState == .foregroundActive
        }
            .compactMap { $0 as? UIWindowScene }
            .first
        
        guard let windowScene = windowScene else { return }
        
        let viewController = UIHostingController(
            rootView: LogmoView(settings: settings) { [weak self] in
                self?.customSettingContent
            }
        )
        viewController.view.backgroundColor = .clear
        
        let window = ContentResponderWindow(windowScene: windowScene)
        window.rootViewController = viewController
        window.isHidden = false
        
        self.window = window
    }
    
    @MainActor
    public func hide() {
        window?.isHidden = true
        window = nil
    }
    
    public func configure(@ViewBuilder customSetting content: () -> some View) {
        customSettingContent = AnyView(content())
    }
    
    public func setTitle(_ title: String = "") {
        Task { [weak self] in
            await self?.settings.setTitle(title)
        }
    }
    
    public func addLog(_ log: Log) {
        Task { [weak self] in
            await self?.settings.addLog(log)
        }
    }
    
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
    @MainActor
    func settings(_ settings: Settings, export file: LogFile) async {
        await withCheckedContinuation { continuation in
            let viewController = UIActivityViewController(
                activityItems: [LogItemSource(file)],
                applicationActivities: nil
            )
            viewController.popoverPresentationController?.sourceView = topMostViewController()?.view
            viewController.completionWithItemsHandler = { [weak self] activityType, completed, returnedItems, error in
                continuation.resume()
            }
            
            topMostViewController()?.present(viewController, animated: true)
        }
    }
}

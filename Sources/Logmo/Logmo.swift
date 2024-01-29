//
//  Logmo.swift
//  
//
//  Created by JSilver on 2023/06/29.
//

import UIKit
import SwiftUI
import Logma

public class Logmo: ObservableObject {
    // MARK: - Property
    public static let shared = Logmo()
    
    @Published
    private(set) var title: String = ""
    @Published
    private(set) var logs: [Log] = []
    
    @Published
    private(set) var isExporting: Bool = false
    
    private let settings = Settings()
    private var customSettingContent: AnyView?
    
    private var window: UIWindow?
    
    // MARK: - Initializer
    private init() { }
    
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
            rootView: LogmoView(
                self,
                settings: settings
            ) {
                customSettingContent
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
    
    @MainActor
    public func configure(@ViewBuilder setting content: () -> some View) {
        self.customSettingContent = AnyView(content())
    }
    
    @MainActor
    public func export() {
        guard !isExporting else { return }
        
        isExporting = true
        
        Task { [weak self] in
            guard let logs = self?.logs, let file = try? await LogFile(logs) else {
                self?.isExporting = false
                return
            }
            
            let viewController = UIActivityViewController(
                activityItems: [LogItemSource(file)],
                applicationActivities: nil
            )
            viewController.popoverPresentationController?.sourceView = self?.topMostViewController()?.view
            viewController.completionWithItemsHandler = { [weak self] activityType, completed, returnedItems, error in
                self?.isExporting = false
            }
            
            self?.topMostViewController()?.present(viewController, animated: true)
        }
    }
    
    public func setTitle(_ title: String = "") {
        run { [weak self] in
            self?.title = title
        }
    }
    
    public func addLog(_ log: Log) {
        run { [weak self] in
            self?.logs.append(log)
        }
    }
    
    public func clear() {
        run { [weak self] in
            self?.logs.removeAll()
        }
    }
    
    // MARK: - Private
    private func run(_ action: @MainActor @escaping () -> Void) {
        Task {
            await action()
        }
    }
    
    private func topMostViewController() -> UIViewController? {
        var viewController = window?.rootViewController
        
        while let childViewController = viewController?.presentedViewController {
            viewController = childViewController
        }
        
        return viewController
    }
}

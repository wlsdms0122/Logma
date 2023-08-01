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
public class Logmo: ObservableObject {
    // MARK: - Property
    public static let shared = Logmo()
    
    private var window: UIWindow?
    
    @Published
    private(set) var title: String = ""
    @Published
    private(set) var logs: [Log] = []
    
    private let settings = Settings()
    
    // MARK: - Initializer
    private init() { }
    
    // MARK: - Public
    public func show() {
        let windowScene = UIApplication.shared.connectedScenes.filter {
            $0.activationState == .foregroundActive
        }
            .compactMap { $0 as? UIWindowScene }
            .first
        
        guard let windowScene = windowScene else { return }
        
        let viewController = UIHostingController(
            rootView: LogmoView(self, settings: settings)
        )
        viewController.view.backgroundColor = .clear
        
        let window = ContentResponderWindow(windowScene: windowScene)
        window.rootViewController = viewController
        window.isHidden = false
        
        self.window = window
    }
    
    public func hide() {
        window?.isHidden = true
        window = nil
    }
    
    public nonisolated func setTitle(_ title: String = "") {
        run { [weak self] in
            self?.title = title
        }
    }
    
    public nonisolated func addLog(_ log: Log) {
        run { [weak self] in
            self?.logs.append(log)
        }
    }
    
    public nonisolated func clear() {
        run { [weak self] in
            self?.logs.removeAll()
        }
    }
    
    // MARK: - Private
    private nonisolated func run(_ action: @MainActor @escaping () -> Void) {
        Task {
            await action()
        }
    }
}

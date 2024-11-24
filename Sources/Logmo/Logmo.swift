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
    
    private let setting = Setting()
    
    private var window: UIWindow?
    public private(set) var viewController: UIViewController?
    
    // MARK: - Initializer
    private init() { }
    
    // MARK: - Public
    public func show<Actions: View>(@ViewBuilder actions: () -> Actions = { EmptyView() }) {
        let windowScene = UIApplication.shared.connectedScenes.filter {
            $0.activationState == .foregroundActive
        }
            .compactMap { $0 as? UIWindowScene }
            .first
        
        guard let windowScene = windowScene else { return }
        
        let view = LogmoView(setting: setting, actions: actions)
        let viewController = UIHostingController(rootView: view)
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
        setting.setTitle(title)
    }
    
    // MARK: - Private
}

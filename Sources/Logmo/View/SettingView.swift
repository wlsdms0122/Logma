//
//  SettingView.swift
//  
//
//  Created by JSilver on 2023/07/13.
//

import SwiftUI

struct SettingView: View {
    // MARK: - View
    var body: some View {
        NavigationView {
            List {
                InformationSection()
                AboutSection()
            }
                .navigationTitle("Setting")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            onClose()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary.opacity(0.6))
                        }
                    }
                }
        }
    }
    
    @ViewBuilder
    private func InformationSection() -> some View {
        Section {
            Navigation(symbol: "info.circle", title: "Information") {
                InformationView()
            }
        } header: {
            Text("Information")
        }
    }
    
    @ViewBuilder
    private func AboutSection() -> some View {
        Section {
            Item(
                symbol: "book.closed.fill",
                title: "License"
            ) {
                Button(Env.license) {
                    guard let url = Env.licenseURL else { return }
                    UIApplication.shared.open(url)
                }
                    .foregroundColor(.secondary.opacity(0.6))
            }
        } header: {
            Text("About")
        }
    }
    
    // MARK: - Property
    @StateObject
    private var setting: Setting
    
    private let onClose: () -> Void
    
    // MARK: - Initializer
    init(
        _ setting: Setting,
        onClose: @escaping () -> Void
    ) {
        self._setting = .init(wrappedValue: setting)
        self.onClose = onClose
    }
    
    // MARK: - Public
    
    // MARK: - Private
}

#if DEBUG
private struct Preview: View {
    var body: some View {
        SettingView(.init()) { }
    }
}

#Preview {
    Preview()
}
#endif

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
                SettingSection()
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
    private func SettingSection() -> some View {
        Section {
            Item(
                symbol: "square.and.arrow.up",
                title: "Export Logs"
            ) {
                Button {
                    Task {
                        await settings.export()
                    }
                } label: {
                    if settings.isExporting {
                        ProgressView()
                            .progressViewStyle(.circular)
                    } else {
                        EmptyView()
                    }
                }
            }
            Item(
                symbol: "trash",
                title: "Clean All Logs"
            ) {
                Button {
                    isShowCleanAllLogsAlert = true
                } label: {
                    EmptyView()
                }
            }
                .alert(isPresented: $isShowCleanAllLogsAlert) {
                    Alert(
                        title: Text("Clean All Logs"),
                        message: Text("Are you sure you want to clean all logs?"),
                        primaryButton: .cancel(),
                        secondaryButton: .destructive(Text("Clean")) {
                            settings.clear()
                        }
                    )
                }
        } header: {
            Text("Settings")
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
    @State
    private var isShowCleanAllLogsAlert: Bool = false
    
    @StateObject
    private var settings: Settings
    
    private let onClose: () -> Void
    
    // MARK: - Initializer
    init(
        _ settings: Settings,
        onClose: @escaping () -> Void
    ) {
        self._settings = .init(wrappedValue: settings)
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

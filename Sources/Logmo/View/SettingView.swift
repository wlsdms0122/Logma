//
//  SettingView.swift
//  
//
//  Created by JSilver on 2023/07/13.
//

import SwiftUI

struct SettingView<CustomContent: View>: View {
    // MARK: - View
    var body: some View {
        NavigationView {
            List {
                if let content = customSettingContent {
                    CustomSection(content: content)
                }
                LayoutSection()
                SettingSection()
                AboutSection()
            }
                .navigationTitle("Setting")
                .navigationBarTitleDisplayMode(.inline)
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
    private func CustomSection(content: some View) -> some View {
        Section {
            content
        } header: {
            Text("Custom")
        }
    }
    
    @ViewBuilder
    private func LayoutSection() -> some View {
        Section {
            Switch(
                symbol: "line.3.horizontal.decrease.circle",
                title: "Show Level Filters",
                isOn: $settings.showFilters
            )
            Switch(
                symbol: "magnifyingglass",
                title: "Show Search Bar",
                isOn: $settings.showSearchBar
            )
        } header: {
            Text("Layout")
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
                    logmo.export()
                } label: {
                    if logmo.isExporting {
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
                            logmo.clear()
                        }
                    )
                }
        } header: {
            Text("Setting")
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
            }
        } header: {
            Text("About")
        }
    }
    
    @ViewBuilder
    private func Switch(
        symbol name: String? = nil,
        title: String,
        isOn: Binding<Bool>
    ) -> some View {
        Item(symbol: name, title: title, label: {
            LToggle(isOn: isOn)
        })
    }
    
    @ViewBuilder
    private func Item(
        symbol name: String? = nil,
        title: String,
        @ViewBuilder label: () -> some View = { EmptyView() }
    ) -> some View {
        HStack {
            if let name {
                Image(systemName: name)
            }
            Text(title)
            Spacer()
            label()
                .foregroundColor(.secondary.opacity(0.6))
        }
    }
    
    // MARK: - Property
    @State
    private var isShowCleanAllLogsAlert: Bool = false
    
    @StateObject
    private var settings: Settings
    @StateObject
    private var logmo: Logmo
    
    private let customSettingContent: CustomContent?
    
    private let onClose: () -> Void
    
    // MARK: - Initializer
    init(
        _ settings: Settings,
        logmo: Logmo,
        @ViewBuilder customSetting content: () -> CustomContent? = { Optional<EmptyView>.none },
        onClose: @escaping () -> Void
    ) {
        self._settings = .init(wrappedValue: settings)
        self._logmo = .init(wrappedValue: logmo)
        self.customSettingContent = content()
        self.onClose = onClose
    }
    
    // MARK: - Public
    
    // MARK: - Private
}

#if DEBUG
private struct Preview: View {
    var body: some View {
        SettingView(
            .init(),
            logmo: .shared
        ) { }
    }
}

#Preview {
    Preview()
}
#endif

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
    private var logmo: Logmo
    @StateObject
    private var settings: Settings
    
    private let onClose: () -> Void
    
    // MARK: - Initializer
    init(_ logmo: Logmo, settings: Settings, onClose: @escaping () -> Void) {
        self._logmo = .init(wrappedValue: logmo)
        self._settings = .init(wrappedValue: settings)
        self.onClose = onClose
    }
    
    // MARK: - Public
    
    // MARK: - Private
}

#if DEBUG
struct SettingView_Preview: View {
    var body: some View {
        SettingView(.shared, settings: .init()) { }
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView_Preview()
    }
}
#endif

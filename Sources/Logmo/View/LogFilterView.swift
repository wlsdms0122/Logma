//
//  LogFilterView.swift
//
//
//  Created by jsilver on 8/16/24.
//

import SwiftUI

struct LogFilterView: View {
    // MARK: - View
    var body: some View {
        let canAddPattern = !pattern.isEmpty && !settings.filterPatterns.contains(pattern)
        
        List {
            Section {
                TextField("Regex Pattern", text: $pattern)
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
                Button {
                    settings.addFilterPattern(pattern)
                    pattern = ""
                } label: {
                    Text("Add Filter")
                }
                    .disabled(!canAddPattern)
            } footer: {
                Text("Filters logs that match the regex pattern.")
            }
            
            if !settings.filterPatterns.isEmpty {
                Section {
                    ForEach(settings.filterPatterns.reversed(), id: \.self) { pattern in
                        HStack {
                            Text(pattern)
                            Spacer()
                            Button {
                                shouldRemovePattern = pattern
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundColor(.primary)
                            }
                        }
                        .alert(isPresented: .init {
                            shouldRemovePattern != nil
                        } set: { isShow in
                            guard !isShow else { return }
                            shouldRemovePattern = nil
                        }) { [shouldRemovePattern] in
                            Alert(
                                title: Text("Remove filter pattern"),
                                message: Text("Are you sure you want to remove filter pattern?"),
                                primaryButton: .cancel(),
                                secondaryButton: .destructive(Text("Remove")) {
                                    guard let shouldRemovePattern else { return }
                                    settings.removeFilterPattern(shouldRemovePattern)
                                }
                            )
                        }
                    }
                } header: {
                    Text("Filters (\(settings.filterPatterns.count))")
                }
            }
        }
            .navigationTitle("Log Filter")
            .animation(.default, value: settings.filterPatterns)
    }
    
    // MARK: - Property
    @State
    private var shouldRemovePattern: String?
    
    @State
    private var pattern: String = ""
    @StateObject
    private var settings: Settings
    
    // MARK: - Initializer
    init(_ settings: Settings) {
        self._settings = .init(wrappedValue: settings)
    }
    
    // MARK: - Public
    
    // MARK: - Private
}

#if DEBUG
#Preview {
    LogFilterView(.init())
}
#endif

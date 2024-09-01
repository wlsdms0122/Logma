//
//  InformationView.swift
//
//
//  Created by jsilver on 9/1/24.
//

import SwiftUI

struct InformationView: View {
    // MARK: - View
    var body: some View {
        List {
            Section {
                Item(title: "Version", description: Env.version?.string() ?? "-")
                Item(title: "Build", description: Env.build ?? "-")
                Item(title: "Display Name", description: Env.bundleDisplayName ?? "-")
                Item(title: "Product Name", description: Env.productName ?? "-")
                Item(title: "Bundle Identifier", description: Env.bundleIdentifier ?? "-")
            } header: {
                Text("App")
            }
            
            Section {
                Item(title: "Platform", description: Env.platformName ?? "-")
                Item(title: "OS Version", description: Env.osVersion ?? "-")
                Item(title: "Device", description: Env.deviceName)
                Item(title: "Region", description: Env.region ?? "-")
            } header: {
                Text("System")
            }
        }
            .navigationTitle("Information")
    }
    
    // MARK: - Property
    
    // MARK: - Initializer
    
    // MARK: - Public
    
    // MARK: - Private
}

#if DEBUG
#Preview {
    InformationView()
}
#endif

//
//  Component.swift
//
//
//  Created by jsilver on 9/1/24.
//

import SwiftUI

@ViewBuilder
func Item(
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
    }
        .lineLimit(1)
}

@ViewBuilder
func Item(
    symbol name: String? = nil,
    title: String,
    description: String? = nil
) -> some View {
    Item(symbol: name, title: title) {
        if let description {
            Text(description)
                .foregroundColor(Color(UIColor.systemGray))
        }
    }
}

@ViewBuilder
func Navigation(
    symbol name: String? = nil,
    title: String,
    @ViewBuilder destination: () -> some View
) -> some View {
    NavigationLink {
        destination()
    } label: {
        Item(symbol: name, title: title)
    }
}

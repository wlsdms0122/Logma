//
//  Iterator.swift
//
//
//  Created by JSilver on 2023/03/23.
//

import SwiftUI

struct Iterator<Data, Content: View>: View {
    // MARK: - View
    var body: some View {
        let views = data.enumerated().map { content($0, $1) }
        ForEach(0..<views.count, id: \.self) {
            views[$0]
        }
    }
    
    // MARK: - Property
    private let data: [Data]
    private let content: (Int, Data) -> Content
    
    // MARK: - Initializer
    init(
        _ data: [Data],
        @ViewBuilder content: @escaping (Int, Data) -> Content
    ) {
        self.data = data
        self.content = content
    }
    
    // MARK: - Public
    
    // MARK: - Private
}

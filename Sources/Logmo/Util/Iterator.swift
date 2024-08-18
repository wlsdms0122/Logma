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
        ForEach(Array(data.enumerated()), id: \.offset) { offset, data in
            content(offset, data)
        }
    }
    
    // MARK: - Property
    private let data: [Data]
    private let content: (Int, Data) -> Content
    
    // MARK: - Initializer
    init(
        _ data: [Data],
        @ViewBuilder content: @escaping (_ offset: Int, _ data: Data) -> Content
    ) {
        self.data = data
        self.content = content
    }
    
    // MARK: - Public
    
    // MARK: - Private
}

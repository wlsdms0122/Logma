//
//  LToggle.swift
//  
//
//  Created by JSilver on 2023/07/17.
//

import SwiftUI

struct LToggle: View {
    // MARK: - View
    var body: some View {
        let backgroundColor: Color = isOn
            ? .green
            : .secondary.opacity(colorScheme == .light ? 0.16 : 0.32)
        
        ZStack {
            RoundedRectangle(cornerRadius: 100)
                .foregroundColor(backgroundColor)
                .animation(.linear(duration: 0.3), value: isOn)
                
            HStack {
                if isOn {
                    Spacer()
                }
                
                Circle()
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.04), radius: 1)
                    .shadow(color: .black.opacity(0.15), radius: 8, y: 3)
                    .shadow(color: .black.opacity(0.06), radius: 1, y: 3)
                    .frame(width: 27, height: 27)
                    .padding(2)
                
                if !isOn {
                    Spacer()
                }
            }
                .animation(.spring(response: 0.3, dampingFraction: 0.75), value: isOn)
        }
            .frame(width: 51, height: 31)
            .onTapGesture {
                isOn.toggle()
            }
    }
    
    // MARK: - Property
    @SwiftUI.Environment(\.colorScheme)
    private var colorScheme: ColorScheme
    
    @Binding
    private var isOn: Bool
    
    // MARK: - Initializer
    init(isOn: Binding<Bool>) {
        self._isOn = isOn
    }
    
    // MARK: - Public
    
    // MARK: - Private
}

#if DEBUG
struct LToggle_Preview: View {
    var body: some View {
        LToggle(isOn: $isOn)
    }
    
    @State
    private var isOn: Bool = false
}

struct LToggle_Previews: PreviewProvider {
    static var previews: some View {
        LToggle_Preview()
    }
}
#endif

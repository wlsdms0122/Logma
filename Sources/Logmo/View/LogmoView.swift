//
//  LogmoView.swift
//
//
//  Created by jsilver on 2022/07/24.
//

import Logma
import SwiftUI

struct LogmoView<Actions: View>: View {
    struct ActionButtonLayout: _VariadicView_MultiViewRoot {
        @Binding
        private var isExpand: Bool
        
        init(isExpand: Binding<Bool>) {
            self._isExpand = isExpand
        }
        
        @ViewBuilder
        func body(children: _VariadicView.Children) -> some View {
            GeometryReader { _ in
                VStack(spacing: 0) {
                    ForEach(children) { view in
                        view.frame(width: 34, height: 34)
                            .simultaneousGesture(
                                TapGesture()
                                    .onEnded {
                                        Haptic.impact(style: .rigid)
                                    }
                            )
                    }
                }
            }
                .background(Color(hex: 0x292929, alpha: 0.9))
                .frame(width: 34, height: isExpand ? 34 * CGFloat(children.count) : 34)
                .clipShape(.capsule(style: .circular))
                .animation(.spring(dampingFraction: 0.65), value: isExpand)
        }
    }
    
    // MARK: - View
    var body: some View {
        Content {
            Title()
            
            ActionButton {
                MenuButton()
                SettingButton()
                actions
            }
        }
            .sheet(isPresented: $isSettingPresented) {
                SettingView(setting) {
                    isSettingPresented = false
                }
            }
    }
    
    @ViewBuilder
    private func Content(@ViewBuilder content: () -> some View) -> some View {
        VStack {
            HStack(alignment: .top, spacing: 4) {
                content()
                    .shadow(color: Color(hex: 0x000000, alpha: 0.5), radius: 4, x: 0, y: 4)
            }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            
            Spacer()
        }
    }
    
    @ViewBuilder
    private func Title() -> some View {
        GeometryReader { _ in
            Text(setting.title)
                .lineLimit(1)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, 16)
            
            Image(systemName: "chevron.left")
                .foregroundColor(.white)
                .frame(width: 34, height: 34)
                .frame(maxWidth: .infinity, alignment: .leading)
                .opacity(isTitleExpand ? 0 : 1)
        }
            .frame(width: isTitleExpand ? nil : 34, height: 34)
            .frame(maxWidth: isTitleExpand ? .infinity : nil)
            .background(Color(hex: 0x292929, alpha: 0.9))
            .clipShape(.capsule(style: .circular))
            .gesture(
                DragGesture()
                    .onEnded { gesture in
                        guard gesture.velocity.width > 300 else { return }
                        
                        Haptic.impact(style: .rigid)
                        isTitleExpand = false
                    },
                including: isTitleExpand ? .gesture : .subviews
            )
            .gesture(
                TapGesture()
                    .onEnded { _ in
                        Haptic.impact(style: .rigid)
                        isTitleExpand = true
                    },
                including: !isTitleExpand ? .gesture : .subviews
            )
            .animation(.default, value: isTitleExpand)
    }
    
    @ViewBuilder
    private func ActionButton(@ViewBuilder content: () -> some View) -> some View {
        _VariadicView.Tree(ActionButtonLayout(isExpand: $isMenuExpand)) {
            content()
        }
            .onTapGesture { }
    }
    
    @ViewBuilder
    private func MenuButton() -> some View {
        Button {
            isMenuExpand.toggle()
        } label: {
            Image(systemName: "line.3.horizontal")
                .foregroundColor(.white)
        }
    }
    
    @ViewBuilder
    private func SettingButton() -> some View {
        Button {
            isSettingPresented = true
        } label: {
            Image(systemName: "gear")
                .foregroundColor(.white)
        }
    }
    
    // MARK: - Property
    @State
    private var isTitleExpand: Bool = true
    @State
    private var isMenuExpand: Bool = false
    
    @State
    private var isSettingPresented: Bool = false
    
    @Namespace
    private var namespace
    
    @StateObject
    private var setting: Setting
    private let actions: Actions
    
    // MARK: - Initializer
    init(
        setting: Setting,
        @ViewBuilder actions: () -> Actions = { EmptyView() }
    ) {
        self._setting = .init(wrappedValue: setting)
        self.actions = actions()
    }
    
    // MARK: - Public
    
    // MARK: - Private
}

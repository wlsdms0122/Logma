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
                .clipShape(Capsule())
                .contentShape(Capsule())
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
                SettingView(settings) {
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
            Text(settings.title)
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
            .clipShape(.capsule)
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
    private var settings: Settings
    private let actions: Actions
    
    // MARK: - Initializer
    init(
        settings: Settings,
        @ViewBuilder actions: () -> Actions = { EmptyView() }
    ) {
        self._settings = .init(wrappedValue: settings)
        self.actions = actions()
    }
    
    // MARK: - Public
    
    // MARK: - Private
}

#if DEBUG
private struct Preview: View {
    // MARK: - View
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                
                LogTitle()
                
                HStack {
                    let message = "Hello World"
                    
                    LogButton(level: .debug, message)
                    LogButton(level: .info, message)
                    LogButton(level: .notice, message)
                    LogButton(level: .error, message)
                    LogButton(level: .fault, message)
                }
            }
            
            LogmoView(settings: .init())
        }
    }
    
    @ViewBuilder
    private func LogTitle() -> some View {
        TextField("", text: $title)
            .accentColor(Color(hex: 0xFFFFFF))
            .foregroundColor(Color(hex: 0xFFFFFF))
            .multilineTextAlignment(.center)
            .padding(8)
            .background(Color(hex: 0x292929))
            .cornerRadius(4)
            .padding(16)
            .onChange(of: title) { title in
                settings.setTitle(title)
            }
    }
    
    @ViewBuilder
    private func LogButton(level: Logma.Level, _ message: Any) -> some View {
        Button {
            switch level {
            case .debug:
                Logma.debug(message)
                
            case .info:
                Logma.info(message)
                
            case .notice:
                Logma.notice(message)
                
            case .error:
                Logma.error(message)
                
            case .fault:
                Logma.fault(message)
            }
        } label: {
            Text("🪵")
                .foregroundColor(.white)
                .frame(height: 24)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(logColor(level: level))
                .cornerRadius(20)
        }
    }
    
    // MARK: - Property
    @StateObject
    private var settings = Settings()
    @State
    private var title: String = ""
    
    // MARK: - Initializer
    init() {
        Logma.configure([LogmoPrinter()])
    }
    
    // MARK: - Public
    
    // MARK: - Private
    private func logColor(level: Logma.Level) -> Color {
        switch level {
        case .debug:
            return Color(hex: 0x989898)
            
        case .info:
            return Color(hex: 0x52A3EE)
            
        case .notice:
            return Color(hex: 0xEDDD52)
            
        case .error:
            return Color(hex: 0xE3953A)
            
        case .fault:
            return Color(hex: 0xF03C3C)
        }
    }
}

#Preview {
    Preview()
}
#endif

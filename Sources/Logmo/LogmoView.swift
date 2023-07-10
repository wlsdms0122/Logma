//
//  LogmoView.swift
//  
//
//  Created by jsilver on 2022/07/24.
//

import Logma
import SwiftUI

struct LogmoView: View {
    struct ScrollRect: Equatable {
        let scrollViewFrame: CGRect
        let lastItemFrame: CGRect
        
        init(scrollView scrollViewFrame: CGRect, lastItem lastItemFrame: CGRect) {
            self.scrollViewFrame = scrollViewFrame
            self.lastItemFrame = lastItemFrame
        }
    }
    
    // MARK: - View
    var body: some View {
        VStack {
            VStack(spacing: 4) {
                HeaderView()
                if isExpand {
                    ContentView()
                        .transition(.slide)
                }
            }
                .padding(8)
                .animation(.default, value: isExpand)
            
            Spacer()
        }
    }
    
    @ViewBuilder
    private func HeaderView() -> some View {
        HStack(spacing: 4) {
            SettingButton()
            Title()
            ExpandButton()
        }
            .padding(.init(top: 4, leading: 8, bottom: 4, trailing: 8))
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .foregroundColor(Color(hex: 0x262626, alpha: 0.6))
            )
    }
    
    @ViewBuilder
    private func SettingButton() -> some View {
        Button {
            
        } label: {
            Image(systemName: "line.3.horizontal")
                .resizable()
                .scaledToFit()
                .foregroundColor(Color(hex: 0xFFFFFF))
                .frame(width: 12, height: 12)
        }
            .frame(width: 18, height: 18)
    }
    
    @ViewBuilder
    private func Title() -> some View {
        Text(logmo.title)
            .font(.system(size: 10, weight: .light))
            .foregroundColor(Color(hex: 0xFFFFFF))
            .frame(height: 20)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .foregroundColor(Color(hex: 0x292929))
            )
    }
    
    @ViewBuilder
    private func ExpandButton() -> some View {
        let imageName = isExpand
            ? "square.split.bottomrightquarter.fill"
            : "square.split.bottomrightquarter"
        
        Button {
            isExpand.toggle()
        } label: {
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .foregroundColor(Color(hex: 0xFFFFFF))
                .frame(width: 12, height: 12)
        }
            .frame(width: 18, height: 18)
    }
    
    @ViewBuilder
    private func ContentView() -> some View {
        let logs = logmo.logs.filter { levelFilter.contains($0.level) }
        let lastItemID = logs.count - 1
        
        GeometryReader { reader in
            VStack(spacing: 0) {
                FilterView()
                    .padding(8)
                ScrollViewReader { reader in
                    ZStack(alignment: .bottomTrailing) {
                        LogList(logs)
                            .onChange(of: lastItemID) { id in
                                guard shouldAutoScroll else { return }
                                
                                isAutoScrolling = true
                                
                                withAnimation {
                                    reader.scrollTo(id, anchor: .bottom)
                                }
                            }
                        
                        ScrollToBottomButton {
                            isAutoScrolling = true
                            
                            withAnimation {
                                reader.scrollTo(lastItemID, anchor: .bottom)
                            }
                        }
                            .padding(.trailing, 16)
                            .padding(.bottom, 8)
                            .opacity(shouldAutoScroll ? 0 : 1)
                            .animation(.default, value: shouldAutoScroll)
                    }
                }
                Handle()
                    .gesture(
                        DragGesture(coordinateSpace: .global)
                            .updating($translation) { gesture, state, _ in
                                state = gesture.translation
                            }
                            .onEnded { gesture in
                                contentHeight = min(max(contentHeight + gesture.translation.height, LogmoView.MINIMUM_CONTENT_HEIGHT), reader.size.height)
                            }
                    )
            }
                .frame(height: min(max(contentHeight + translation.height, LogmoView.MINIMUM_CONTENT_HEIGHT), reader.size.height))
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundColor(Color(hex: 0x262626, alpha: 0.6))
                )
        }
    }
    
    @ViewBuilder
    private func FilterView() -> some View {
        HStack(spacing: 4) {
            FilterButton(level: .debug)
            FilterButton(level: .info)
            FilterButton(level: .notice)
            FilterButton(level: .error)
            FilterButton(level: .fault)
        }
    }
    
    @ViewBuilder
    private func FilterButton(level: Logma.Level) -> some View {
        let containsLevel = levelFilter.contains(level)
        let backgroundColor: Color = containsLevel ? logColor(level: level) : Color(hex: 0x454545)
        
        Button {
            if containsLevel {
                levelFilter.remove(level)
            } else {
                levelFilter.insert(level)
            }
        } label: {
            Text(logTitle(level: level))
                .font(.system(size: 10, weight: .light))
                .foregroundColor(Color(hex: 0xFFFFFF))
                .frame(height: 20)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .foregroundColor(backgroundColor)
                )
        }
    }
    
    @ViewBuilder
    private func LogList(_ logs: [Log]) -> some View {
        GeometryReader { scrollViewReader in
            ScrollView {
                LazyVStack(spacing: 4) {
                    Enumerator(logs) { index, log in
                        if index == logs.count - 1 {
                            LogView(log)
                                .id(index)
                                .overlay(
                                    GeometryReader { reader in
                                        let scrollRect = ScrollRect(
                                            scrollView: scrollViewReader.frame(in: .global),
                                            lastItem: reader.frame(in: .global)
                                        )
                                        
                                        Color.clear.onChange(of: scrollRect) { rects in
                                            let shouldAutoScroll = rects.lastItemFrame.maxY <= rects.scrollViewFrame.maxY + rects.lastItemFrame.height
                                            
                                            guard shouldAutoScroll || !isAutoScrolling else { return }
                                            
                                            isAutoScrolling = false
                                            
                                            self.shouldAutoScroll = shouldAutoScroll
                                        }
                                    }
                                )
                        } else {
                            LogView(log)
                        }
                    }
                }
                    .padding(.horizontal, 8)
            }
        }
    }
    
    @ViewBuilder
    private func LogView(_ log: Log) -> some View {
        Button {
            UIPasteboard.general.string = log.message
        } label: {
            HStack(spacing: 0) {
                logColor(level: log.level)
                    .frame(width: 4)
                Text(log.message)
                    .font(.system(size: 10, weight: .light))
                    .foregroundColor(Color(hex: 0xFFFFFF))
                    .multilineTextAlignment(.leading)
                    .padding(4)
                Spacer()
            }
                .background(Color(hex: 0x292929))
                .cornerRadius(4)
        }
    }
    
    @ViewBuilder
    private func ScrollToBottomButton(action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            Image(systemName: "arrow.down.to.line")
                .resizable()
                .foregroundColor(Color(hex: 0xFFFFFF))
                .frame(width: 10, height: 12)
                .frame(width: 24, height: 24)
                .background(Color(hex: 0x636363, alpha: 0.8))
                .cornerRadius(4)
        }
    }
    
    @ViewBuilder
    private func Handle() -> some View {
        RoundedRectangle(cornerRadius: 1.5)
            .foregroundColor(Color(hex: 0xFFFFFF))
            .frame(width: 40, height: 3)
            .padding(8)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
    }
    
    // MARK: - Constant
    private static let MINIMUM_CONTENT_HEIGHT: CGFloat = 150
    
    // MARK: - Property
    @State
    private var isExpand: Bool = false
    @State
    private var levelFilter: Set<Logma.Level> = [.debug, .info, .notice, .error, .fault]
    
    @GestureState
    private var translation: CGSize = .zero
    @State
    private var contentHeight: CGFloat = LogmoView.MINIMUM_CONTENT_HEIGHT
    
    @State
    private var shouldAutoScroll: Bool = true
    @State
    private var isAutoScrolling: Bool = false
    
    @StateObject
    private var logmo: Logmo
    
    // MARK: - Initializer
    init(logmo: Logmo) {
        self._logmo = .init(wrappedValue: logmo)
    }
    
    // MARK: - Public
    
    // MARK: - Private
    private func logTitle(level: Logma.Level) -> String {
        switch level {
        case .debug:
            return "DEBUG"
            
        case .info:
            return "INFO"
            
        case .notice:
            return "NOTICE"
            
        case .error:
            return "ERROR"
            
        case .fault:
            return "FAULT"
        }
    }
    
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

#if DEBUG
struct LogmoView_Preview: View {
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
            
            LogmoView(logmo: .shared)
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
                Logmo.shared.setTitle(title)
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

struct LogmoView_Previews: PreviewProvider {
    static var previews: some View {
        LogmoView_Preview()
    }
}
#endif

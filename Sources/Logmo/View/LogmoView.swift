//
//  LogmoView.swift
//  
//
//  Created by jsilver on 2022/07/24.
//

import Logma
import SwiftUI

struct LogmoView<CustomSetting: View>: View {
    struct ScrollRect: Equatable {
        let scrollViewFrame: CGRect
        let contentViewFrame: CGRect
        
        init(scrollView scrollViewFrame: CGRect, contentView contentViewFrame: CGRect) {
            self.scrollViewFrame = scrollViewFrame
            self.contentViewFrame = contentViewFrame
        }
    }
    
    // MARK: - View
    var body: some View {
        VStack {
            VStack(spacing: 4) {
                HeaderView()
                ContentView()
                    .opacity(isExpand ? 1 : 0)
            }
                .padding(8)
            
            Spacer()
        }
            .sheet(isPresented: $isSettingPresented) {
                SettingView(settings) {
                    customSettingContent()
                } onClose: {
                    Haptic.impact(style: .rigid)
                    isSettingPresented = false
                }
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
            Haptic.impact(style: .rigid)
            isSettingPresented = true
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
        Text(settings.title)
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
            Haptic.impact(style: .rigid)
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
        let logs = settings.logs.filter { levelFilter.contains($0.level) }
            .filter { query.isEmpty || $0.message.contains(query) }
        let lastItemID = logs.count - 1
        
        GeometryReader { reader in
            VStack(spacing: 0) {
                VStack {
                    Group {
                        if settings.showFilters {
                            FilterView()
                        }
                        if settings.showSearchBar {
                            SearchBar()
                        }
                    }
                        .padding(.horizontal, 8)
                    
                    ScrollViewReader { reader in
                        ZStack(alignment: .bottomTrailing) {
                            LogList(logs)
                                .onAppear {
                                    reader.scrollTo(lastItemID, anchor: .bottom)
                                }
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
                }
                    .padding(.top, 8)
                
                Handle()
                    .gesture(
                        DragGesture(coordinateSpace: .global)
                            .updating($translation) { gesture, state, _ in
                                state = gesture.translation
                            }
                            .onEnded { gesture in
                                logViewHeight = min(max(logViewHeight + gesture.translation.height, MINIMUM_LOG_VIEW_HEIGHT), reader.size.height)
                            }
                    )
            }
                .frame(height: min(max(logViewHeight + translation.height, MINIMUM_LOG_VIEW_HEIGHT), reader.size.height))
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
            Haptic.impact(style: .rigid)
            
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
    private func SearchBar() -> some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .resizable()
                .foregroundColor(Color(hex: 0xFFFFFF))
                .frame(width: 10, height: 10)
            
            ZStack(alignment: .leading) {
                TextField("", text: $query)
                    .foregroundColor(Color(hex: 0xFFFFFF))
                    .accentColor(Color(hex: 0xFFFFFF))
                
                if query.isEmpty {
                    Text("Search")
                        .foregroundColor(Color(hex: 0xEBEBF5))
                }
            }
                .font(.system(size: 10, weight: .light))
            
            if !query.isEmpty {
                Button {
                    Haptic.impact(style: .rigid)
                    query = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .foregroundColor(Color(hex: 0xEBEBF5))
                        .frame(width: 10, height: 10)
                }
            }
        }
            .padding(.horizontal, 8)
            .frame(height: 20)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .foregroundColor(Color(hex: 0x292929))
            )
    }
    
    @ViewBuilder
    private func LogList(_ logs: [Log]) -> some View {
        GeometryReader { scrollViewReader in
            ScrollView {
                LazyVStack(spacing: 4) {
                    Iterator(logs) { index, log in
                        LogView(log).id(index)
                    }
                }
                    .padding(.horizontal, 8)
                    .overlay(
                        GeometryReader { reader in
                            let scrollRect = ScrollRect(
                                scrollView: scrollViewReader.frame(in: .global),
                                contentView: reader.frame(in: .global)
                            )
                            
                            Color.clear.onChange(of: scrollRect) { rects in
                                let shouldAutoScroll = rects.contentViewFrame.maxY <= rects.scrollViewFrame.maxY + MINIMUM_SCROLL_THRESHOLD
                                
                                guard shouldAutoScroll || !isAutoScrolling else { return }
                                
                                isAutoScrolling = false
                                
                                self.shouldAutoScroll = shouldAutoScroll
                            }
                        }
                    )
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
    private let MINIMUM_LOG_VIEW_HEIGHT: CGFloat = 150
    private let MINIMUM_SCROLL_THRESHOLD: CGFloat = 40
    
    // MARK: - Property
    @State
    private var isExpand: Bool = false
    @State
    private var levelFilter: Set<Logma.Level> = [.debug, .info, .notice, .error, .fault]
    @State
    private var query: String = ""
    
    // Log view size properties
    @GestureState
    private var translation: CGSize = .zero
    @State
    private var logViewHeight: CGFloat = 150
    
    // Content view auto scrolling properties
    @State
    private var shouldAutoScroll: Bool = true
    @State
    private var isAutoScrolling: Bool = false
    
    @State
    private var isSettingPresented: Bool = false
    
    @StateObject
    private var settings: Settings
    
    private let customSettingContent: () -> CustomSetting?
    
    // MARK: - Initializer
    init(
        settings: Settings,
        @ViewBuilder customSetting content: @escaping () -> CustomSetting? = { Optional<EmptyView>.none }
    ) {
        self._settings = .init(wrappedValue: settings)
        self.customSettingContent = content
    }
    
    // MARK: - Public
    
    // MARK: - Private
    private func logTitle(level: Logma.Level) -> String {
        switch level {
        case .debug:
            "DEBUG"
            
        case .info:
            "INFO"
            
        case .notice:
            "NOTICE"
            
        case .error:
            "ERROR"
            
        case .fault:
            "FAULT"
        }
    }
    
    private func logColor(level: Logma.Level) -> Color {
        switch level {
        case .debug:
            Color(hex: 0x989898)
            
        case .info:
            Color(hex: 0x52A3EE)
            
        case .notice:
            Color(hex: 0xEDDD52)
            
        case .error:
            Color(hex: 0xE3953A)
            
        case .fault:
            Color(hex: 0xF03C3C)
        }
    }
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
                Task {
                    await Logmo.shared.setTitle(title)
                }
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

#Preview {
    Preview()
}
#endif

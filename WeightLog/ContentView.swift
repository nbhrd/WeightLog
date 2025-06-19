//
//  ContentView.swift
//  WeightLog
//
//  Created by N H on 2025/05/01.
//

import SwiftUI

struct ContentView: View {
    @State private var showInputView = false
    @State private var selectedTab = 0

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                ListView()
                    .tabItem {
                        Image(systemName: "list.bullet")
                        Text("一覧")
                    }
                    .tag(0)

                GraphView()
                    .tabItem {
                        Image(systemName: "chart.bar")
                        Text("グラフ")
                    }
                    .tag(1)

                Color.clear // 空タブで中央スペース確保
                    .tabItem {
                        Image(systemName: "")
                        Text("")
                    }
                    .tag(99)

                CalendarView()
                    .tabItem {
                        Image(systemName: "calendar")
                        Text("カレンダー")
                    }
                    .tag(2)

                SettingsView()
                    .tabItem {
                        Image(systemName: "gearshape")
                        Text("設定")
                    }
                    .tag(3)
            }

            // フローティングボタン
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation(.spring()) {
                            showInputView = true
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.accentColor)
                            .background(Color(UIColor.systemBackground))
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    .offset(y: -20)
                    Spacer()
                }
            }
        }
        .sheet(isPresented: $showInputView) {
            InputView()
        }
    }
}


#Preview {
    ContentView()
}


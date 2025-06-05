//
//  ContentView.swift
//  WeightLog
//
//  Created by N H on 2025/05/01.
//

import SwiftUI

struct ContentView: View {
    @State private var showAddWeight = false

    var body: some View {
        ZStack {
            TabView {
//                InputView()
//                    .tabItem {
//                        Image(systemName: "square.and.pencil")
//                        Text("入力")
//                    }

                ListView()
                    .tabItem {
                        Image(systemName: "list.bullet")
                        Text("一覧")
                    }

                GraphView()
                    .tabItem {
                        Image(systemName: "chart.bar")
                        Text("グラフ")
                    }

                CalendarView()
                    .tabItem {
                        Image(systemName: "calendar")
                        Text("カレンダー")
                    }

                SettingsView()
                    .tabItem {
                        Image(systemName: "gearshape")
                        Text("設定")
                    }
            }
            
            // フローティングボタン
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation(.spring()) {
                            showAddWeight = true
                        }
                    }) {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.accentColor)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    .padding(.trailing, 24)
                    .padding(.bottom, 24)
                    .accessibilityLabel("体重を追加")
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            Spacer().frame(height: 40)
        }
        // モーダル表示
        .sheet(isPresented: $showAddWeight) {
            WeightAddView(defaultDate: .now)
        }
        
    }
}

#Preview {
    ContentView()
}

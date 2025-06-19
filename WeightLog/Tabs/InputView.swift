//
//  InputView.swift
//  WeightLog
//
//  Created by N H on 2025/05/01.
//

import SwiftUI
import UIKit

struct InputView: View {
    @State private var date = Date()
    @State private var weight: String = ""
    @State private var memo: String = ""
    @FocusState private var isFocused: Bool
    @AppStorage("lastSavedWeight") private var lastSavedWeight: Double = 0
    @State private var showToast = false
    @State private var showCheckmark = false
    @State private var isWeightInputInvalid = false
    
    @Environment(\.modelContext) private var modelContext
    
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("体重 (kg)").textCase(nil)) {
                    TextField("例: 65.4", text: $weight)
                        .keyboardType(.decimalPad)
                        .focused($isFocused)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                isFocused = true
                            }
                        }
                }
                
                Section(header: Text("日付")) {
                    DatePicker("記録日", selection: $date, displayedComponents: .date)
                        .environment(\.locale, Locale(identifier: "ja_JP"))
                }

                Section(header: Text("メモ（任意）")) {
                    TextField("気づいたことや補足など", text: $memo)
                }
            }
            .navigationTitle("体重を記録")
            .onTapGesture {
                isFocused = false
            }
            
            Button(action: {
                save()
            }) {
                Text("保存")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .background(Color.accentColor)
                    .cornerRadius(10)
            }
        }
        .overlay(
                Group {
                    if showToast {
                        Text("体重を入力してください")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.red)
                            .cornerRadius(10)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    if showCheckmark {
                        SaveSuccessToast()
                    }
                },
                alignment: .center
            )
    }

    private func save() {
        isFocused = false

        guard let value = Double(weight) else {
            isWeightInputInvalid = true
            // Haptics：エラー振動
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            
            withAnimation {
                showToast = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    showToast = false
                }
            }
            print("数値に変換できません")
            return
        }

        // 保存処理
        print("保存されました：\(value)kg")
        let record = WeightRecord(date: date, weight: value, memo: memo)
        modelContext.insert(record)
        try? modelContext.save()

        isWeightInputInvalid = false
        weight = ""
        memo = ""

        performSaveSuccessFeedback(showToastBinding: $showCheckmark) {
            dismiss()
        }
    }
}

#Preview {
    InputView()
}

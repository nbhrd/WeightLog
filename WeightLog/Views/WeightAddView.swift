//
//  WeightAddView.swift
//  WeightLog
//
//  Created by N H on 2025/05/12.
//

import SwiftUI

struct WeightAddView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State var defaultDate: Date
    @State private var weight = ""
    @State private var memo = ""
    @State private var showToast = false
    
    @FocusState private var isWeightFocused: Bool

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("体重")) {
                    TextField("例: 65.4", text: $weight)
                        .keyboardType(.decimalPad)
                        .focused($isWeightFocused)
                }

                Section(header: Text("日付")) {
                    Text(defaultDate, format: .dateTime.year().month().day().weekday())
                        .foregroundColor(.gray)
                }

                Section(header: Text("メモ")) {
                    TextField("任意", text: $memo)
                }
            }
            .navigationTitle("新規追加")
            .onAppear {
                isWeightFocused = true
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        if let value = Double(weight) {
                            let newRecord = WeightRecord(date: defaultDate, weight: value, memo: memo)
                            modelContext.insert(newRecord)

                            do {
                                try modelContext.save()
                                performSaveSuccessFeedback(showToastBinding: $showToast) {
                                    dismiss()
                                }
                            } catch {
                                print("保存失敗: \(error)")
                            }
                        }
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
            }
            .overlay(
                Group {
                    if showToast {
                        SaveSuccessToast()
                    }
                }
            )
            .animation(.easeInOut(duration: 0.3), value: showToast)
        }
    }
}

#Preview {
    WeightAddView(defaultDate: .now)
}

//
//  WeightEditView.swift
//  WeightLog
//
//  Created by N H on 2025/05/07.
//

import SwiftUI
import SwiftData

struct WeightEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var record: WeightRecord
    
    @State private var showToast = false

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("体重 (kg)")) {
                    TextField("例: 65.2", value: $record.weight, format: .number)
                        .keyboardType(.decimalPad)
                }

                Section(header: Text("日付")) {
                    Text(record.date, format: .dateTime.year().month().day().weekday())
                        .foregroundColor(.gray)
                }

                Section(header: Text("メモ")) {
                    TextField("任意メモ", text: $record.memo)
                }
            }
            .navigationTitle("編集")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        performSaveSuccessFeedback(showToastBinding: $showToast) {
                            dismiss()
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
    let sample = WeightRecord(date: .now, weight: 65.0, memo: "サンプル")
    return WeightEditView(record: sample)
}

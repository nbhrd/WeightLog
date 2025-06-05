//
//  TargetWeightView.swift
//  WeightLog
//
//  Created by N H on 2025/05/14.
//

import SwiftUI

struct TargetWeightView: View {
    @AppStorage("targetWeight") private var targetWeight: Double = 60.0
    @State private var tempWeight: String = ""
    @Environment(\.dismiss) private var dismiss
    @State private var showToast = false

    var body: some View {
        ZStack {
            Form {
                Section(header: Text("目標体重（kg）")) {
                    TextField("例: 60.0", text: $tempWeight)
                        .keyboardType(.decimalPad)
                }

                Button("保存") {
                    guard let value = Double(tempWeight) else {
                        // トーストで「無効な数値です」など表示しても良い
                        return
                    }

                    targetWeight = value
                    performSaveSuccessFeedback(showToastBinding: $showToast) {
                        dismiss()
                    }
                }
            }

            // トースト表示
            if showToast {
                SaveSuccessToast()
            }
        }
        .navigationTitle("目標体重の設定")
        .onAppear {
            tempWeight = String(format: "%.1f", targetWeight)
        }
    }
}

#Preview {
    TargetWeightView()
}

//
//  WeightInputField.swift
//  WeightLog
//
//  Created by N H on 2025/06/02.
//

import SwiftUI

struct WeightInputField: View {
    @Binding var weight: Double
    @FocusState private var isFocused: Bool
    @State private var internalText: String = ""

    var body: some View {
        TextField("例: 654 → 65.4kg", text: $internalText)
            .keyboardType(.numberPad)
            .focused($isFocused)
            .onChange(of: internalText) { newValue in
                // 数字のみ許可（数字以外は除外）
                let filtered = newValue.filter { $0.isNumber }
                if let intValue = Int(filtered) {
                    weight = Double(intValue) / 10.0
                } else {
                    weight = 0
                }
            }
            .onAppear {
                internalText = String(Int(weight * 10))
            }
    }
}


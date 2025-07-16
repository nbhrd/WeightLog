//
//  NumberPadView.swift
//  WeightLog
//
//  Created by N H on 2025/07/14.
//

import SwiftUI

struct NumberPadView: View {
    @Binding var input: String

    private let buttons: [[String]] = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        ["", "0", "⌫"]
    ]

    var body: some View {
        VStack(spacing: 10) {
            ForEach(buttons, id: \.self) { row in
                HStack(spacing: 10) {
                    ForEach(row, id: \.self) { label in
                        Button(action: {
                            if label == "⌫" {
                                if !input.isEmpty {
                                    input.removeLast()
                                }
                            } else if !label.isEmpty {
                                // 最大桁数制限
                                let first = input.first
                                let limit = (first == "1" || first == "2") ? 4 : 3

                                if input.count < limit {
                                    input.append(label)
                                }
                            }
                        }) {
                            Text(label)
                                .font(.title)
                                .frame(maxWidth: .infinity, minHeight: 60)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                        .disabled(label.isEmpty)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}


#Preview {
    @Previewable @State var tempInput = ""
    NumberPadView(input: $tempInput)
}

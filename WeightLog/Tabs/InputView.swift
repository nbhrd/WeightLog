//
//  InputView.swift
//  WeightLog
//
//  Created by N H on 2025/05/01.
//

import SwiftUI

struct InputView: View {
    @State private var date = Date()
    @State private var rawWeightInput: String = ""
    @State private var memo: String = ""
    @AppStorage("lastSavedWeight") private var lastSavedWeight: Double = 0
    @State private var showToast = false
    @State private var showCheckmark = false
    @State private var isWeightInputInvalid = false

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    /// 表示用の整形済み体重（Double → String）
    var formattedWeight: String {
        formatWeight(from: rawWeightInput)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("")) {
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(formattedWeight == "0.0" ? "0.0" : formattedWeight)
                            .font(.system(size: 60, weight: .black))

                        Text("kg")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }

                Section(header: Text("")) {
                    DatePicker("記録日", selection: $date, displayedComponents: .date)
                        .environment(\.locale, Locale(identifier: "ja_JP"))
                }

                // Optional: メモ欄
//                Section(header: Text("メモ（任意）")) {
//                    TextField("気づいたことや補足など", text: $memo)
//                }
            }
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }

            NumberPadView(input: $rawWeightInput)
                .padding(.bottom)

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

        let value = parsedWeight(from: rawWeightInput)

        guard value > 0 else {
            isWeightInputInvalid = true

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

        print("保存されました：\(value)kg")
        let record = WeightRecord(date: date, weight: value, memo: memo)
        modelContext.insert(record)
        try? modelContext.save()

        isWeightInputInvalid = false
        rawWeightInput = ""
        memo = ""

        performSaveSuccessFeedback(showToastBinding: $showCheckmark) {
            dismiss()
        }
    }

    private func formatWeight(from raw: String) -> String {
        guard !raw.isEmpty, let _ = Int(raw), let firstChar = raw.first else {
            return "0.0"
        }

        if ["1", "2"].contains(firstChar) {
            if raw.count <= 3 {
                // 3桁以下 → 整数扱い
                return String(format: "%.1f", Double(raw)!)
            } else {
                // 4桁以上 → 小数点を挿入
                let intPart = String(raw.dropLast())
                let decimal = String(raw.suffix(1))
                return "\(intPart).\(decimal)"
            }
        } else {
            if raw.count == 1 {
                // 1桁 → 10倍
                if let doubleValue = Double(raw) {
                    return String(format: "%.1f", doubleValue * 10)
                } else {
                    return "0.0"
                }
            } else if raw.count == 2 {
                // 2桁 → そのまま表示
                return String(format: "%.1f", Double(raw)!)
            } else {
                // 3桁以上 → 小数点挿入
                let trimmed = String(raw.prefix(5)) // 5桁制限（例: "55555" → "5555.5"）
                let intPart = String(trimmed.dropLast())
                let decimal = String(trimmed.suffix(1))
                return "\(intPart).\(decimal)"
            }
        }
    }

    /// 保存用 Double に変換：555 → 55.5
    private func parsedWeight(from raw: String) -> Double {
        switch raw.count {
        case 1:
            return Double(raw)! * 10
        case 2:
            return Double(raw)!
        default:
            let intPart = String(raw.dropLast())
            let decimal = String(raw.suffix(1))
            return Double("\(intPart).\(decimal)") ?? 0.0
        }
    }
}


#Preview {
    InputView()
}

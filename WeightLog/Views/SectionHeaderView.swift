//
//  SectionHeaderView.swift
//  WeightLog
//
//  Created by N H on 2025/06/02.
//

import SwiftUI

struct SectionHeaderView: View {
    let month: Date
    let records: [WeightRecord]

    var body: some View {
        let avg = averageWeight(of: records)
        let min = minWeight(of: records)
        let max = maxWeight(of: records)

        return HStack(spacing: 12) {
            Text(formattedMonth(month))
                .font(.headline)

            Group {
                Text("平均 \(avg, specifier: "%.1f")")
                Text("最低 \(min, specifier: "%.1f")")
                Text("最高 \(max, specifier: "%.1f")")
            }
            .font(.subheadline)
            .foregroundColor(.secondary)

            Text("kg")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .textCase(nil)
        }
    }

    private func formattedMonth(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy年M月"
        return formatter.string(from: date)
    }

    private func averageWeight(of records: [WeightRecord]) -> Double {
        guard !records.isEmpty else { return 0 }
        return records.map(\.weight).reduce(0, +) / Double(records.count)
    }

    private func minWeight(of records: [WeightRecord]) -> Double {
        records.map(\.weight).min() ?? 0
    }

    private func maxWeight(of records: [WeightRecord]) -> Double {
        records.map(\.weight).max() ?? 0
    }
}

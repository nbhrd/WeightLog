//
//  CalendarView.swift
//  WeightLog
//
//  Created by N H on 2025/05/01.
//

import SwiftUI
import SwiftData

struct CalendarView: View {
    @Query(sort: [SortDescriptor(\WeightRecord.date)]) var records: [WeightRecord]
    
    @State private var currentDate = Date()  // ← 表示中の月
    @State private var selectedRecord: WeightRecord? = nil
    @State private var newDate: IdentifiableDate? = nil
    
    // 月表示用のフォーマッタ
    var currentMonthText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy年M月"
        return formatter.string(from: currentDate)
    }
    
    // 表示月の日付一覧
    var datesInCurrentMonth: [Date] {
        guard let range = Calendar.current.range(of: .day, in: .month, for: currentDate),
              let startOfMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: currentDate)) else {
            return []
        }

        let firstWeekday = Calendar.current.component(.weekday, from: startOfMonth)
        let paddingCount = firstWeekday - 1 // 1: 日曜日 → 0個の余白

        let paddingDates = Array(repeating: Date.distantPast, count: paddingCount)

        let monthDates = range.compactMap { day -> Date? in
            Calendar.current.date(byAdding: .day, value: day - 1, to: startOfMonth)
        }

        return paddingDates + monthDates
    }

    
    // 特定日付の体重を取得
    func weightForDate(_ date: Date) -> String? {
        if let record = records.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
            return String(format: "%.1fkg", record.weight)
        }
        return nil
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 10) {
                // ✅ 月送りヘッダー
                HStack {
                    Button {
                        withAnimation {
                            currentDate = Calendar.current.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                    
                    Spacer()
                    
                    Text(currentMonthText)
                        .font(.headline)
                    
                    Spacer()
                    
                    Button {
                        withAnimation {
                            currentDate = Calendar.current.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
                        }
                    } label: {
                        Image(systemName: "chevron.right")
                    }
                }
                .padding(.horizontal)
                
                // ✅ 曜日ヘッダー（固定）
                HStack {
                    ForEach(["日", "月", "火", "水", "木", "金", "土"], id: \.self) { day in
                        Text(day)
                            .font(.subheadline)
                            .foregroundColor(day == "日" ? .red : day == "土" ? .blue : .primary)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal)
                
                // ✅ カレンダー本体
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 12) {
                    ForEach(datesInCurrentMonth, id: \.self) { date in
                        if Calendar.current.isDate(date, equalTo: .distantPast, toGranularity: .day) {
                            Color.clear.frame(height: 50) // 空白セル
                        } else {
                            CalendarDateCell(
                                date: date,
                                record: records.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }),
                                onTap: { tappedDate, tappedRecord in
                                    if let record = tappedRecord {
                                        selectedRecord = record
                                    } else {
                                        newDate = IdentifiableDate(value: tappedDate)
                                    }
                                }
                            )
                        }
                    }

                }
                .padding(.horizontal)
                .frame(height: 6 * 50) // ← 最大6週 × 高さ50程度確保
            }
            .navigationTitle("カレンダー")
            .sheet(item: $selectedRecord) { record in
                WeightEditView(record: record)
            }
            .sheet(item: $newDate) { identifiableDate in
                WeightAddView(defaultDate: identifiableDate.value)
            }
        }
    }
}

#Preview {
    CalendarView()
}

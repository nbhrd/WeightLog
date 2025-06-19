//
//  ListView.swift
//  WeightLog
//
//  Created by N H on 2025/05/01.
//

import SwiftUI
import SwiftData

struct ListView: View {
    @Query(sort: [SortDescriptor(\WeightRecord.date, order: .reverse)]) var records: [WeightRecord]
    @Environment(\.modelContext) private var modelContext
    
    @State private var showDeleteAlert = false
    @State private var recordToDelete: WeightRecord?
    @State private var selectedRecord: WeightRecord?
    
    @State private var startDate: Date = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    @State private var endDate: Date = Date()
    
    var filteredRecords: [WeightRecord] {
        records.filter { record in
            record.date >= startDate && record.date <= endDate
        }
    }

    // グループ化：日付単位（年月日だけ抽出）
    var groupedRecords: [(date: Date, records: [WeightRecord])] {
        // 日付単位にグループ化（キーは Date）
        let grouped: [Date: [WeightRecord]] = Dictionary(grouping: records) { record in
            Calendar.current.startOfDay(for: record.date)
        }

        // キー（日付）で降順ソートされた配列に変換
        var result: [(date: Date, records: [WeightRecord])] = []

        for (key, value) in grouped {
            result.append((date: key, records: value))
        }

        result.sort { $0.date > $1.date }
        return result
    }
    
    var groupedByMonth: [(month: Date, records: [WeightRecord])] {
        let grouped = Dictionary(grouping: filteredRecords) { record in
            let components = Calendar.current.dateComponents([.year, .month], from: record.date)
            return Calendar.current.date(from: components)!
        }

        var result: [(month: Date, records: [WeightRecord])] = []
        for (key, value) in grouped {
            let sorted = value.sorted { $0.date > $1.date }
            result.append((month: key, records: sorted))
        }

        result.sort { $0.month > $1.month }
        return result
    }

    var body: some View {
        NavigationStack {
            if records.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "tray")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    Text("まだ記録がありません")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Text("右下の「入力」から記録を始めましょう")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                .multilineTextAlignment(.center)
                .padding()
                .navigationTitle("記録一覧")
            } else {
                VStack {
                    HStack {
                        DatePicker("開始日", selection: $startDate, displayedComponents: .date)
                        DatePicker("終了日", selection: $endDate, displayedComponents: .date)
                    }
                    .padding(.horizontal)
                    
                    HStack(spacing: 16) {
                        Button(action: {
                            startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
                            endDate = Date()
                        }) {
                            Text("表示リセット")
                                .font(.subheadline)
                                .frame(maxWidth: .infinity)
                                .padding(10)
                                .background(Color(.systemGray6))
                                .foregroundColor(.blue)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.blue, lineWidth: 1)
                                )
                        }

                        Button(action: {
                            if let minDate = records.map(\.date).min(),
                               let maxDate = records.map(\.date).max() {
                                    startDate = Calendar.current.startOfDay(for: minDate)

                                    if let endOfDay = Calendar.current.date(byAdding: DateComponents(day: 1, second: -1), to: Calendar.current.startOfDay(for: maxDate)) {
                                        endDate = endOfDay
                                    }
                                }
                        }) {
                            Text("全期間表示")
                                .font(.subheadline)
                                .frame(maxWidth: .infinity)
                                .padding(10)
                                .background(Color(.systemGray6))
                                .foregroundColor(.blue)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.blue, lineWidth: 1)
                                )
                        }
                    }
                    .padding(.horizontal)


                    List {
                        ForEach(groupedByMonth, id: \.month) { group in
                            Section(header: SectionHeaderView(month: group.month, records: group.records)) {
                                ForEach(group.records) { record in
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Text(formattedDateOnly(record.date)) // 5月24日 (金)
                                                .font(.subheadline)
                                                .foregroundColor(.gray)

                                            Spacer()

                                            Text("\(record.weight, specifier: "%.1f") kg")
                                                .font(.headline)
                                                .foregroundColor(.primary)
                                        }

                                        if !record.memo.isEmpty {
                                            Text(record.memo)
                                                .font(.footnote)
                                                .foregroundColor(.secondary)
                                                .padding(.top, 2)
                                        }
                                    }
                                    .padding(.vertical, 8)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .contentShape(Rectangle()) // タップ領域を広げる
                                    .onTapGesture {
                                        selectedRecord = record
                                    }
                                    .swipeActions(edge: .trailing) {
                                        Button(role: .destructive) {
                                            recordToDelete = record
                                            showDeleteAlert = true
                                        } label: {
                                            Label("削除", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                        }


                    }
                    .navigationTitle("記録一覧")
                    .sheet(item: $selectedRecord) { record in
                        WeightEditView(record: record)
                    }
                    .alert("この記録を削除しますか？", isPresented: $showDeleteAlert, actions: {
                        Button("削除", role: .destructive) {
                            if let record = recordToDelete {
                                modelContext.delete(record)
                                try? modelContext.save()
                                recordToDelete = nil
                            }
                        }
                        Button("キャンセル", role: .cancel) {
                            recordToDelete = nil
                        }
                    }, message: {
                        Text("削除すると元に戻せません")
                    })
                }
            }
        }
        .onAppear {
            if let minDate = records.map(\.date).min(),
               let maxDate = records.map(\.date).max() {
                startDate = Calendar.current.startOfDay(for: minDate)
                endDate = Calendar.current.date(byAdding: DateComponents(day: 1, second: -1), to: Calendar.current.startOfDay(for: maxDate)) ?? Date()
            }
        }
    }
    
    private func formattedMonth(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy年M月"
        return formatter.string(from: date)
    }

    private func formattedDateOnly(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M月d日 (E)" // 月日だけ
        return formatter.string(from: date)
    }
}

#Preview {
    ListView()
}

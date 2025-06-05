//
//  ExportHelper.swift
//  WeightLog
//
//  Created by N H on 2025/05/17.
//

import Foundation
import SwiftData

func generateCSV(from records: [WeightRecord]) -> String {
    var csv = "日付,体重(kg),メモ\n"
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy/MM/dd"

    for record in records {
        let date = formatter.string(from: record.date)
        let weight = String(format: "%.1f", record.weight)
        let memo = record.memo.replacingOccurrences(of: ",", with: " ")
        csv += "\(date),\(weight),\(memo)\n"
    }

    return csv
}

func exportCSVFile(from records: [WeightRecord]) -> URL? {
    let csvString = generateCSV(from: records)
    let fileName = "体重記録.csv"
    let tempDir = FileManager.default.temporaryDirectory
    let fileURL = tempDir.appendingPathComponent(fileName)

    do {
        try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
        return fileURL
    } catch {
        print("エクスポート失敗: \(error)")
        return nil
    }
}

func importCSVData(from url: URL, modelContext: ModelContext) throws -> Int {
    let content = try String(contentsOf: url, encoding: .utf8)
    let lines = content.components(separatedBy: .newlines).filter { !$0.isEmpty }
    guard lines.count > 1 else { return 0 }

    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy/MM/dd"
    var count = 0

    for line in lines.dropFirst() {
        let fields = line.components(separatedBy: ",")
        guard fields.count >= 2,
              let date = formatter.date(from: fields[0]),
              let weight = Double(fields[1]) else { continue }

        let memo = fields.count >= 3 ? fields[2] : ""
        let record = WeightRecord(date: date, weight: weight, memo: memo)
        modelContext.insert(record)
        count += 1
    }

    try modelContext.save()
    return count
}

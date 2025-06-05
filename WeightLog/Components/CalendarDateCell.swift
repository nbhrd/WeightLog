//
//  CalendarDateCell.swift
//  WeightLog
//
//  Created by N H on 2025/05/12.
//

import SwiftUI
import HolidayJp

struct CalendarDateCell: View {
    let date: Date
    let record: WeightRecord?
    let onTap: (Date, WeightRecord?) -> Void

    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    var dateTextColor: Color {
        if isJapaneseHoliday(date) || isSunday(date) {
            return .red
        } else if isSaturday(date) {
            return .blue
        } else {
            return .primary
        }
    }
    
    func isSunday(_ date: Date) -> Bool {
        Calendar.current.component(.weekday, from: date) == 1
    }

    func isSaturday(_ date: Date) -> Bool {
        Calendar.current.component(.weekday, from: date) == 7
    }
    
    func isJapaneseHoliday(_ date: Date) -> Bool {
        return HolidayJp.isHoliday(date)
    }

    var body: some View {
        VStack(spacing: 4) {
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.body.bold())
                .foregroundColor(isToday ? .white : dateTextColor)
                .frame(width: 32, height: 32)
                .background(isToday ? Color.accentColor : Color.clear)
                .clipShape(Circle())

            if let record = record {
                Text(String(format: "%.1f", record.weight))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            } else {
                Text(" ")
                    .font(.caption2)
                    .foregroundColor(.clear)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 50)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap(date, record)
        }
    }
}


//#Preview {
//    CalendarDateCell()
//}

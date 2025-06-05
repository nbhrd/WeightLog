//
//  GraphView.swift
//  WeightLog
//
//  Created by N H on 2025/05/01.
//

import SwiftUI
import SwiftData
import Charts

struct GraphView: View {
    @Query(sort: [SortDescriptor(\WeightRecord.date)]) var records: [WeightRecord]
    @AppStorage("targetWeight") private var targetWeight: Double = 60.0
    @State private var selectedDate: Date? = nil

    var weightRange: ClosedRange<Double> {
        let weights = records.map(\.weight) + [targetWeight]

        guard let min = weights.min(), let max = weights.max() else {
            return 50...70 // フォールバック
        }

        let margin = 1.0
        let lower = floor(min - margin)
        let upper = ceil(max + margin)
        return lower...upper
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if records.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        Text("まだ記録がありません")
                            .foregroundColor(.gray)
                    }
                } else {
                    ScrollViewReader { scrollProxy in
                        ScrollView(.horizontal) {
                            Chart {
                                ForEach(records) { record in
                                    LineMark(
                                        x: .value("日付", record.date),
                                        y: .value("体重", record.weight)
                                    )
                                    .interpolationMethod(.monotone)
                                    .foregroundStyle(Color.accentColor)
                                    .symbol(Circle())
                                }
                                // 目標体重ライン（Chart の中に入れる！）
                                RuleMark(
                                    y: .value("目標体重", targetWeight)
                                )
                                .lineStyle(StrokeStyle(lineWidth: 2, dash: [5]))
                                .foregroundStyle(Color.red)
                                .annotation(position: .topTrailing) {
                                    Text("目標 \(String(format: "%.1f", targetWeight))kg")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                                
                                // タップされたポイントの表示
                                if let selectedDate = selectedDate {
                                    if let selectedRecord = records.first(where: {
                                        Calendar.current.isDate($0.date, inSameDayAs: selectedDate)
                                    }) {
                                        PointMark(
                                            x: .value("日付", selectedRecord.date),
                                            y: .value("体重", selectedRecord.weight)
                                        )
                                        .foregroundStyle(Color.orange)
                                        .symbolSize(50)
                                        .annotation(position: .top) {
                                            VStack(spacing: 4) {
                                                // 日付表示（例: 2025/5/28）
                                                Text(dateFormatter.string(from: selectedRecord.date))
                                                    .font(.caption2)
                                                    .foregroundColor(.gray)

                                                // 体重表示（例: 63.4kg）
                                                Text("\(selectedRecord.weight, specifier: "%.1f")kg")
                                                    .font(.caption)
                                                    .foregroundColor(.black)
                                            }
                                            .padding(6)
                                            .background(
                                                RoundedRectangle(cornerRadius: 6)
                                                    .fill(Color.white)
                                                    .shadow(radius: 2)
                                            )
                                        }

                                    }
                                }
                            }
                            .id("chartEnd")
                            .frame(width: CGFloat(records.count) * 50)
                            .chartXAxis {
                                AxisMarks(values: .stride(by: .day)) { value in
                                    AxisGridLine()
                                    AxisTick()
                                    AxisValueLabel {
                                        if let dateValue = value.as(Date.self) {
                                            Text(dateValue.formatted(.dateTime.day()))
                                        }
                                    }
                                }
                            }
                            .chartYScale(domain: weightRange)
                            .chartYAxis {
                                AxisMarks(values: .stride(by: 0.5)) { value in
                                    AxisGridLine()
                                    AxisTick()
                                    AxisValueLabel()
                                }
                            }
                            .chartOverlay { proxy in
                                GeometryReader { geo in
                                    Rectangle().fill(Color.clear).contentShape(Rectangle())
                                        .simultaneousGesture(
                                            DragGesture(minimumDistance: 0)
                                                .onChanged { value in
                                                    let x = value.location.x - geo[proxy.plotAreaFrame].origin.x
                                                    if let date: Date = proxy.value(atX: x) {
                                                        selectedDate = date
                                                    }
                                                }
                                        )
                                }
                            }
                            .frame(height: 250)
                            .padding()
                        }
                        .onAppear {
                            scrollProxy.scrollTo("chartEnd", anchor: .trailing)
                        }
                    }
                }
                if records.count < 3 {
                    Text("※ データが少ないため、グラフの表示が正確でない可能性があります")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding(.top, 8)
                }
            }
            .navigationTitle("体重グラフ")
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }
}

#Preview {
    GraphView()
}

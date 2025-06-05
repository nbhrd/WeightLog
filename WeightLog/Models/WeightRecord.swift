//
//  SwiftUIView.swift
//  WeightLog
//
//  Created by N H on 2025/05/05.
//

import SwiftData
import Foundation

@Model
class WeightRecord {
    var date: Date
    var weight: Double
    var memo: String

    init(date: Date, weight: Double, memo: String = "") {
        self.date = date
        self.weight = weight
        self.memo = memo
    }
}

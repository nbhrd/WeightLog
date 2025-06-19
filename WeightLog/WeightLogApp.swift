//
//  WeightLogApp.swift
//  WeightLog
//
//  Created by N H on 2025/05/01.
//

import SwiftUI
import SwiftData

@main
struct WeightLogApp: App {
    @AppStorage("colorSchemeSetting") private var colorSchemeSetting: String = "system"

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(
                    colorSchemeSetting == "light" ? .light :
                    colorSchemeSetting == "dark" ? .dark : nil
                )
        }
        .modelContainer(for: [WeightRecord.self])
    }
}

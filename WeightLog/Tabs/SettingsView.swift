//
//  SettingsView.swift
//  WeightLog
//
//  Created by N H on 2025/05/01.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @AppStorage("targetWeight") private var targetWeight: Double = 60.0
    @AppStorage("colorSchemeSetting") private var colorSchemeSetting: String = "system"
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\WeightRecord.date)]) private var records: [WeightRecord]

    @State private var exportedFileURL: URL? = nil
    @State private var showImporter = false
    @State private var importError: String? = nil
    @State private var showDeleteAlert = false
    @State private var showDeleteSuccess = false
    @State private var importedCount = 0
    @State private var showImportSuccess = false
    @State private var navigateToGraph = false

    var body: some View {
        NavigationStack {
            Form {
                // 🔹 目標体重
                Section("目標") {
                    NavigationLink(destination: TargetWeightView()) {
                        HStack {
                            Text("目標体重の設定")
                            Spacer()
                            Text(String(format: "%.1fkg", targetWeight))
                                .foregroundColor(.secondary)
                        }
                    }
                }

                // 🔹 通知
                Section("通知") {
                    NavigationLink("毎日の記録リマインダー") {
                        ReminderSettingsView()
                    }

                    NavigationLink("カスタム通知文言") {
                        CustomNotificationMessageView()
                    }
                }

                // 🔹 表示
                Section("表示") {
                    NavigationLink("グラフの色") {
                        GraphColorSettingsView()
                    }
                }
                
                Section("表示モード") {
                    Picker("外観", selection: $colorSchemeSetting) {
                        Text("システムに従う").tag("system")
                        Text("ライトモード").tag("light")
                        Text("ダークモード").tag("dark")
                    }
                    .pickerStyle(.segmented)
                }

                // 🔹 データ管理
                Section("データ") {
                    Button("体重データをエクスポート") {
                        exportedFileURL = exportCSVFile(from: records)
                    }

                    // ✅ ファイルが生成されたらShareLinkを表示
                    if let fileURL = exportedFileURL {
                        ShareLink(item: fileURL) {
                            Label("エクスポートしたCSVを共有", systemImage: "square.and.arrow.up")
                        }
                    }

                    Button("CSVをインポート") {
                        showImporter = true
                    }

                    Button(role: .destructive) {
                        showDeleteAlert = true
                    } label: {
                        Label("全データを削除", systemImage: "trash")
                    }
                }

                // 🔹 その他
                Section("その他") {
                    NavigationLink("このアプリについて") {
                        AboutAppView()
                    }

                    NavigationLink("記録ロック（パスコード）") {
                        PasscodeLockView()
                    }
                }
            }
            .navigationTitle("設定")
        }
        // 全データ削除アラート
        .alert("本当にすべての記録を削除しますか？", isPresented: $showDeleteAlert) {
            Button("キャンセル", role: .cancel) {}
            Button("削除", role: .destructive) {
                deleteAllRecords()
            }
        } message: {
            Text("この操作は取り消せません")
        }
        // 全データ削除完了アラート
        .alert("削除完了", isPresented: $showDeleteSuccess) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("すべての記録を削除しました。")
        }
        // インポート成功用アラート
        .alert("インポート成功", isPresented: $showImportSuccess) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("CSVファイルの読み込みが完了しました。")
        }
        // インポートエラー用アラート
        .alert("エラー", isPresented: .constant(importError != nil)) {
            Button("OK") { importError = nil }
        } message: {
            Text(importError ?? "")
        }
        .fileImporter(
            isPresented: $showImporter,
            allowedContentTypes: [.commaSeparatedText],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    // ✅ 安全にアクセス開始
                    if url.startAccessingSecurityScopedResource() {
                        defer { url.stopAccessingSecurityScopedResource() }

                        do {
                            try importCSVData(from: url, modelContext: modelContext)
                            showImportSuccess = true
                        } catch {
                            importError = "インポート失敗: \(error.localizedDescription)"
                        }
                    } else {
                        importError = "ファイルの読み取り権限がありません"
                    }
                }

            case .failure(let error):
                importError = "ファイル選択失敗: \(error.localizedDescription)"
            }
        }
    }
    
    private func deleteAllRecords() {
        for record in records {
            modelContext.delete(record)
        }

        do {
            try modelContext.save()
            showDeleteSuccess = true
        } catch {
            print("削除エラー: \(error)")
        }
    }
}

#Preview {
    SettingsView()
}

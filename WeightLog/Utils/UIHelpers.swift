//
//  UIHelpers.swift
//  WeightLog
//
//  Created by N H on 2025/05/15.
//

import SwiftUI
import UIKit

/// 成功時のトースト表示 + Haptics + アニメーションを共通化
func performSaveSuccessFeedback(
    showToastBinding: Binding<Bool>,
    delay: TimeInterval = 1.5,
    completion: @escaping () -> Void = {}
) {
    let generator = UINotificationFeedbackGenerator()
    generator.notificationOccurred(.success)

    withAnimation {
        showToastBinding.wrappedValue = true
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
        withAnimation {
            showToastBinding.wrappedValue = false
        }
        completion()
    }
}

//
//  SaveSuccessToast.swift
//  WeightLog
//
//  Created by N H on 2025/05/15.
//

import SwiftUI

struct SaveSuccessToast: View {
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0.0

    var body: some View {
        VStack {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .frame(width: 60, height: 60)
                .foregroundColor(.green)
                .padding()
                .clipShape(Circle())
                .shadow(radius: 10)
                .scaleEffect(scale)
                .opacity(opacity)
                .onAppear {
                    withAnimation(.interpolatingSpring(stiffness: 200, damping: 20)) {
                        scale = 1.0
                        opacity = 1.0
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            scale = 0.8
                            opacity = 0.0
                        }
                    }
                }

            Spacer()
        }
    }
}

#Preview {
    SaveSuccessToast()
}

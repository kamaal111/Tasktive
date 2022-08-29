//
//  CircularProgressBar.swift
//  Tasktive
//
//  Created by Kamaal Farah on 23/07/2022.
//

import SwiftUI
import TasktiveLocale
import ShrimpExtensions

struct CircularProgressBar: View {
    let progress: Double
    let lineWidth: CGFloat

    init(progress: Double, lineWidth: CGFloat) {
        self.progress = progress
        self.lineWidth = lineWidth
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: lineWidth)
                .opacity(0.3)
                .foregroundColor(.accentColor)
            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                .foregroundColor(.accentColor)
                .rotationEffect(Angle(degrees: 270))
                .animation(.linear, value: progress)
            Text(progressPrecentage)
                .accessibilityLabel(TasktiveLocale.getText(.TASKS_PROGRESSION_PRESENTAGE, with: [progressPrecentage]))
                .accessibilityIdentifier(AccessibilityIdentifiers.circularProgressBarPrecentage.rawValue)
                .font(.body)
                .bold()
        }
    }

    private var progressPrecentage: String {
        "\((progress * 100).toFixed(1))%"
    }
}

struct CircularProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        CircularProgressBar(progress: 25, lineWidth: 8)
    }
}

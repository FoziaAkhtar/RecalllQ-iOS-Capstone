
import SwiftUI

// =====================================================
// COMPONENT: ProgressCard
// =====================================================
// PURPOSE:
// Shows progress metric for dashboard analytics
// =====================================================

struct ProgressCard: View {

    let title: String
    let value: String
    let progress: Double

    var body: some View {

        VStack(spacing: 8) {

            // =====================================================
            // TITLE
            // =====================================================
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            // =====================================================
            // VALUE
            // =====================================================
            Text(value)
                .font(.headline)
                .bold()
                .contentTransition(.numericText()) // smooth updates

            // =====================================================
            // PROGRESS BAR
            // =====================================================
            ProgressView(value: clampedProgress)
                .tint(progressColor)
                .animation(.easeInOut(duration: 0.3), value: progress)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)

        // =====================================================
        // ACCESSIBILITY
        // =====================================================
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title), \(value), progress \(Int(clampedProgress * 100)) percent")
    }

    // =====================================================
    // SAFE PROGRESS VALUE (0...1)
    // =====================================================
    private var clampedProgress: Double {
        min(max(progress, 0.0), 1.0)
    }

    // =====================================================
    // PROGRESS COLOR (VISUAL FEEDBACK)
    // =====================================================
    private var progressColor: Color {

        switch clampedProgress {
        case 0.0..<0.4:
            return .red
        case 0.4..<0.75:
            return .orange
        default:
            return .green
        }
    }
}

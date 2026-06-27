
import SwiftUI

// =====================================================
// COMPONENT: ProgressCard
// =====================================================
// PURPOSE:
// Shows progress-style metric for dashboard
// Used for analytics / completion tracking
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

            // =====================================================
            // PROGRESS BAR 
            // =====================================================
            ProgressView(value: clampedProgress)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }

    // =====================================================
    // SAFE PROGRESS VALUE (0...1)
    // =====================================================
    private var clampedProgress: Double {
        min(max(progress, 0.0), 1.0)
    }
}

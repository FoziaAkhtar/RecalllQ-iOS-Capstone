
import SwiftUI

// =====================================================
// COMPONENT: StatCard
// =====================================================
// PURPOSE:
// Reusable dashboard UI card used for analytics
// (Memories count, Top tag, Suggestions, etc.)
// =====================================================

struct StatCard: View {

    // MARK: - INPUT VALUES
    let title: String
    let value: String

    var body: some View {

        VStack(spacing: 6) {

            // =====================================================
            // TITLE (LABEL)
            // =====================================================
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)

            // =====================================================
            // VALUE (MAIN DATA)
            // =====================================================
            Text(value)
                .font(.headline)
                .bold()
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.12))
        )
    }
}

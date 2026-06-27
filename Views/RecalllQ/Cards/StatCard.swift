
import SwiftUI

// =====================================================
// COMPONENT: StatCard
// =====================================================
// PURPOSE:
// Reusable dashboard analytics card
// Displays key metrics in a clean, consistent format
// =====================================================

struct StatCard: View {

    // =====================================================
    // INPUT VALUES
    // =====================================================
    let title: String
    let value: String

    var body: some View {

        VStack(spacing: 6) {

            // =====================================================
            // TITLE
            // =====================================================
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            // =====================================================
            // VALUE
            // =====================================================
            Text(value)
                .font(.headline)
                .bold()
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.12))
        .cornerRadius(12)
    }
}

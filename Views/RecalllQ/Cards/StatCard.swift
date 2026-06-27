
import SwiftUI

// =====================================================
// COMPONENT: StatCard
// =====================================================
// PURPOSE:
// Reusable dashboard analytics card
// =====================================================

struct StatCard: View {

    // =====================================================
    // INPUT VALUES
    // =====================================================
    let title: String
    let value: String

    var body: some View {

        VStack(spacing: 6) {

            // TITLE
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)

            // VALUE
            Text(value)
                .font(.headline)
                .bold()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.12))
        .cornerRadius(12)
    }
}

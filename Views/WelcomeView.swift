
import SwiftUI

// =====================================================
// VIEW: WelcomeView
// =====================================================
// PURPOSE:
// - First screen displayed when the app launches
// - Displays RecalllQ branding
// - Entry point into MainTabView (NOT single screen)
// - Keeps navigation architecture clean and scalable
// =====================================================

struct WelcomeView: View {

    var body: some View {

        VStack(spacing: 25) {

            Spacer()

            // =====================================================
            // APP TITLE
            // =====================================================
            Text("RecalllQ")
                .font(.largeTitle)
                .bold()

            // =====================================================
            // APP SUBTITLE
            // =====================================================
            Text("Focus. Track. Improve.")
                .font(.headline)
                .foregroundColor(.gray)

            Spacer()

            // =====================================================
            // NAVIGATION BUTTON
            // =====================================================
            NavigationLink {

                MainTabView()

            } label: {

                Text("Get Started")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding()
        .navigationBarBackButtonHidden(true)
    }
}

// =====================================================
// PREVIEW
// =====================================================

#Preview {
    NavigationStack {
        WelcomeView()
    }
}


import SwiftUI

// ==========================================
// WELCOME SCREEN
// ==========================================
// PURPOSE:
// - First UI screen
// - App branding
// - Entry point into app features
// ==========================================

struct WelcomeView: View {

    var body: some View {

        NavigationStack {

            VStack(spacing: 25) {

                Spacer()

                // APP NAME
                Text("RecallQ")
                    .font(.largeTitle)
                    .bold()

                // SUBTITLE
                Text("Focus. Track. Improve.")
                    .foregroundColor(.gray)

                Spacer()

                // NAVIGATION BUTTON
                NavigationLink(destination: DashboardView()) {

                    Text("Get Started")
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
        }
    }
}

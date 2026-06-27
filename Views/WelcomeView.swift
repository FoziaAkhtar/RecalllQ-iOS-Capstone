
import SwiftUI

// =====================================================
// VIEW: WelcomeView
// =====================================================
// PURPOSE:
// - Entry screen of app
// - Routes safely into MainTabView
// =====================================================

struct WelcomeView: View {

    @EnvironmentObject var appState: AppState

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
            // NAVIGATION BUTTON (SAFE ROUTING)
            // =====================================================
            NavigationLink {

                MainTabView()
                    .environmentObject(appState)

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

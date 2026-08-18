
import SwiftUI

// =====================================================
// VIEW: WelcomeView
// =====================================================
// PURPOSE:
//
// - Entry screen of RecalllQ
// - Introduces the application
// - Sends the user to LoginView
// - Does NOT bypass authentication
//
// FLOW:
//
// Welcome
//    ↓
// Get Started
//    ↓
// Login
//
// =====================================================

struct WelcomeView: View {

    // =====================================================
    // APP STATE
    // =====================================================

    @EnvironmentObject var appState: AppState

    // =====================================================
    // BODY
    // =====================================================

    var body: some View {

        NavigationStack {

            ZStack {

                // =================================================
                // BACKGROUND
                // =================================================

                RecalllQTheme.background
                    .ignoresSafeArea()

                VStack(spacing: 25) {

                    Spacer()

                    // =================================================
                    // APP ICON
                    // =================================================

                    ZStack {

                        Circle()
                            .fill(
                                RecalllQTheme.primary
                                    .opacity(0.12)
                            )
                            .frame(
                                width: 120,
                                height: 120
                            )

                        Image(
                            systemName:
                                "brain.head.profile"
                        )
                        .font(
                            .system(
                                size: 55,
                                weight: .semibold
                            )
                        )
                        .foregroundColor(
                            RecalllQTheme.primary
                        )
                    }

                    // =================================================
                    // APP TITLE
                    // =================================================

                    Text("RecalllQ")
                        .font(
                            .system(
                                size: 42,
                                weight: .bold
                            )
                        )
                        .foregroundColor(
                            RecalllQTheme.primaryText
                        )

                    // =================================================
                    // TAGLINE
                    // =================================================

                    Text(
                        "Focus. Track. Improve."
                    )
                    .font(.title3)
                    .bold()
                    .foregroundColor(
                        RecalllQTheme.secondaryText
                    )

                    // =================================================
                    // DESCRIPTION
                    // =================================================

                    Text(
                        "Your intelligent learning companion for building stronger memories, studying smarter, and improving your academic performance."
                    )
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(
                        RecalllQTheme.secondaryText
                    )
                    .padding(.horizontal, 25)

                    Spacer()

                    // =================================================
                    // GET STARTED
                    // =================================================

                    NavigationLink {

                        LoginView()
                            .environmentObject(appState)

                    } label: {

                        HStack(spacing: 12) {

                            Text("Get Started")
                                .font(.headline)

                            Image(
                                systemName:
                                    "arrow.right"
                            )
                            .font(
                                .headline.bold()
                            )
                        }
                        .foregroundColor(.white)
                        .frame(
                            maxWidth: .infinity
                        )
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [
                                    RecalllQTheme.primary,
                                    RecalllQTheme.smartPurple
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius:
                                    RecalllQTheme.mediumRadius
                            )
                        )
                        .shadow(
                            color:
                                RecalllQTheme.primary
                                    .opacity(0.20),
                            radius: 8,
                            x: 0,
                            y: 4
                        )
                    }
                    .padding(.horizontal, 24)

                    // =================================================
                    // FOOTER
                    // =================================================

                    Text(
                        "Learn smarter. Remember more."
                    )
                    .font(.caption)
                    .foregroundColor(
                        RecalllQTheme.secondaryText
                    )

                    Spacer(minLength: 25)
                }
                .padding()
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}

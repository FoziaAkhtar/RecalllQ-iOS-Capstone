import SwiftUI

// =====================================================
// MORE VIEW
// =====================================================
// PURPOSE:
// Central navigation screen for secondary RecalllQ features.
//
// FEATURES:
//
// - Quiz navigation
// - AI Study Chat navigation
// - Settings navigation
// - RecalllQ themed background
// - Modern feature cards
// - Uses global AppState
//
// IMPORTANT:
//
// SwiftUI automatically creates a "More" tab when a TabView
// contains more than five tabs.
//
// This custom MoreView replaces that automatic system screen.
//
// The final MainTabView will contain:
//
// 0 = Dashboard
// 1 = Notes
// 2 = Memories
// 3 = Flashcards
// 4 = More
//
// The More screen will then contain:
//
// More
//   ↓
// Quiz
// AI Study Chat
// Settings
// =====================================================

struct MoreView: View {

    // =====================================================
    // GLOBAL APP STATE
    // =====================================================
    // PURPOSE:
    // Provides access to the shared RecalllQ application state.
    //
    // The AppState is passed to the destination screens so
    // Quiz, Chat, and Settings continue using the same user
    // account and application data.
    // =====================================================

    @EnvironmentObject var appState: AppState

    // =====================================================
    // BODY
    // =====================================================

    var body: some View {

        ZStack {

            // =================================================
            // FULL SCREEN BACKGROUND
            // =================================================
            // IMPORTANT:
            //
            // This is the main fix for the original problem.
            //
            // The automatic SwiftUI "More" screen did not use
            // RecalllQTheme.background.
            //
            // Our custom MoreView now controls its own background.
            // =================================================

            RecalllQTheme.background
                .ignoresSafeArea()

            // =================================================
            // MAIN CONTENT
            // =================================================

            ScrollView {

                VStack(
                    alignment: .leading,
                    spacing: RecalllQTheme.largePadding
                ) {

                  
                    // =================================================
                    // FEATURE SECTION
                    // =================================================

                    VStack(
                        alignment: .leading,
                        spacing: RecalllQTheme.mediumPadding
                    ) {

                        Text("Study Tools")
                            .font(
                                .system(
                                    size: 20,
                                    weight: .bold
                                )
                            )
                            .foregroundStyle(
                                RecalllQTheme.primaryText
                            )

                        // =================================================
                        // QUIZ CARD
                        // =================================================

                        NavigationLink {

                            QuizView()
                                .environmentObject(appState)

                        } label: {

                            MoreFeatureCard(
                                title: "Quiz",
                                subtitle:
                                    "Test your knowledge and track your progress.",
                                icon:
                                    "questionmark.circle.fill",
                                background:
                                    RecalllQTheme.pinkBackground,
                                accent:
                                    RecalllQTheme.quizPink
                            )
                        }
                        .buttonStyle(.plain)

                        // =================================================
                        // AI STUDY CHAT CARD
                        // =================================================

                        NavigationLink {

                            ChatView()
                                .environmentObject(appState)

                        } label: {

                            MoreFeatureCard(
                                title: "AI Study Chat",
                                subtitle:
                                    "Ask questions and study with your AI assistant.",
                                icon:
                                    "bubble.left.and.bubble.right.fill",
                                background:
                                    RecalllQTheme.purpleBackground,
                                accent:
                                    RecalllQTheme.smartPurple
                            )
                        }
                        .buttonStyle(.plain)

                    }
                    .padding(
                        .horizontal,
                        RecalllQTheme.mediumPadding
                    )

                    // =================================================
                    // SETTINGS SECTION
                    // =================================================

                    VStack(
                        alignment: .leading,
                        spacing: RecalllQTheme.mediumPadding
                    ) {

                        Text("App")
                            .font(
                                .system(
                                    size: 20,
                                    weight: .bold
                                )
                            )
                            .foregroundStyle(
                                RecalllQTheme.primaryText
                            )

                        // =================================================
                        // SETTINGS CARD
                        // =================================================

                        NavigationLink {

                            SettingsView()
                                .environmentObject(appState)

                        } label: {

                            MoreFeatureCard(
                                title: "Settings",
                                subtitle:
                                    "Manage your account, AI settings, and app preferences.",
                                icon:
                                    "gearshape.fill",
                                background:
                                    RecalllQTheme.blueBackground,
                                accent:
                                    RecalllQTheme.primary
                            )
                        }
                        .buttonStyle(.plain)

                    }
                    .padding(
                        .horizontal,
                        RecalllQTheme.mediumPadding
                    )

                    // =================================================
                    // BOTTOM SPACING
                    // =================================================

                    Spacer(
                        minLength: RecalllQTheme.largePadding
                    )
                }
                .padding(
                    .top,
                    RecalllQTheme.mediumPadding
                )
                .padding(
                    .bottom,
                    RecalllQTheme.largePadding
                )
            }
        }

        // =====================================================
        // NAVIGATION TITLE
        // =====================================================

        .navigationTitle("More")
        .navigationBarTitleDisplayMode(.large)
    }
}

// =====================================================
// MORE FEATURE CARD
// =====================================================
// PURPOSE:
// Reusable visual card used by the More screen.
//
// USED FOR:
//
// - Quiz
// - AI Study Chat
// - Settings
//
// DESIGN:
//
// - Rounded card
// - Feature icon
// - Feature title
// - Feature description
// - Chevron navigation indicator
// - RecalllQ theme colours
// =====================================================

private struct MoreFeatureCard: View {

    // =====================================================
    // CARD INFORMATION
    // =====================================================

    let title: String
    let subtitle: String
    let icon: String
    let background: Color
    let accent: Color

    // =====================================================
    // BODY
    // =====================================================

    var body: some View {

        HStack(
            spacing: RecalllQTheme.mediumPadding
        ) {

            // =================================================
            // FEATURE ICON
            // =================================================

            ZStack {

                RoundedRectangle(
                    cornerRadius:
                        RecalllQTheme.mediumRadius
                )
                .fill(accent.opacity(0.14))
                .frame(
                    width: 58,
                    height: 58
                )

                Image(systemName: icon)
                    .font(
                        .system(
                            size: 25,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(accent)

            }

            // =================================================
            // FEATURE TEXT
            // =================================================

            VStack(
                alignment: .leading,
                spacing: 5
            ) {

                Text(title)
                    .font(
                        .system(
                            size: 18,
                            weight: .bold
                        )
                    )
                    .foregroundStyle(
                        RecalllQTheme.primaryText
                    )

                Text(subtitle)
                    .font(
                        .system(
                            size: 14,
                            weight: .regular
                        )
                    )
                    .foregroundStyle(
                        RecalllQTheme.secondaryText
                    )
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
            }

            Spacer()

            // =================================================
            // NAVIGATION CHEVRON
            // =================================================

            Image(systemName: "chevron.right")
                .font(
                    .system(
                        size: 14,
                        weight: .semibold
                    )
                )
                .foregroundStyle(
                    RecalllQTheme.secondaryText
                )
        }

        // =====================================================
        // CARD CONTAINER
        // =====================================================

        .padding(
            RecalllQTheme.mediumPadding
        )
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(
            background
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius:
                    RecalllQTheme.largeRadius
            )
        )
        .overlay {

            RoundedRectangle(
                cornerRadius:
                    RecalllQTheme.largeRadius
            )
            .stroke(
                accent.opacity(0.12),
                lineWidth: 1
            )
        }
        .shadow(
            color:
                Color.black.opacity(
                    RecalllQTheme.shadowOpacity
                ),
            radius:
                RecalllQTheme.shadowRadius,
            y:
                RecalllQTheme.shadowY
        )
    }
}

// =====================================================
// PREVIEW
// =====================================================

#Preview {

    NavigationStack {

        MoreView()

    }
    .environmentObject(
        AppState()
    )
}

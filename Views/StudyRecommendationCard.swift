
import SwiftUI

// =====================================================
// VIEW: StudyRecommendationCard
// =====================================================
// PURPOSE:
// Displays a personalized study recommendation.
//
// Uses:
// - Memory information
// - Flashcard performance
// - Study recommendation score
// - Personalized reason
// =====================================================

struct StudyRecommendationCard: View {

    // =====================================================
    // APP STATE
    // =====================================================

    @EnvironmentObject var appState: AppState

    // =====================================================
    // RECOMMENDATION
    // =====================================================

    let recommendation:
        StudyRecommendationService.Recommendation

    // =====================================================
    // BODY
    // =====================================================

    var body: some View {

        VStack(
            alignment: .leading,
            spacing: 14
        ) {

            // =================================================
            // HEADER
            // =================================================

            HStack {

                ZStack {

                    Circle()
                        .fill(
                            RecalllQTheme.studyOrange
                                .opacity(0.15)
                        )
                        .frame(
                            width: 46,
                            height: 46
                        )

                    Image(
                        systemName:
                            "sparkles"
                    )
                    .font(.title3)
                    .foregroundColor(
                        RecalllQTheme.studyOrange
                    )
                }

                VStack(
                    alignment: .leading,
                    spacing: 4
                ) {

                    Text(
                        "Recommended For You"
                    )
                    .font(.headline)

                    Text(
                        "Personalized study suggestion"
                    )
                    .font(.caption)
                    .foregroundColor(
                        RecalllQTheme.secondaryText
                    )
                }

                Spacer()
            }

            // =================================================
            // MEMORY TITLE
            // =================================================

            Text(
                recommendation.memory.title
            )
            .font(.title3)
            .bold()
            .foregroundColor(
                RecalllQTheme.primaryText
            )

            // =================================================
            // SUMMARY
            // =================================================

            Text(
                recommendation.memory.summary
            )
            .font(.subheadline)
            .foregroundColor(
                RecalllQTheme.secondaryText
            )
            .lineLimit(3)

            // =================================================
            // REASON
            // =================================================

            HStack(
                alignment: .top,
                spacing: 8
            ) {

                Image(
                    systemName:
                        "lightbulb.fill"
                )
                .foregroundColor(
                    RecalllQTheme.studyOrange
                )

                Text(
                    recommendation.reason
                )
                .font(.caption)
                .foregroundColor(
                    RecalllQTheme.secondaryText
                )
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )
            }

            // =================================================
            // TAGS
            // =================================================

            if !recommendation.memory.tags.isEmpty {

                ScrollView(
                    .horizontal,
                    showsIndicators: false
                ) {

                    HStack(
                        spacing: 6
                    ) {

                        ForEach(
                            recommendation.memory.tags,
                            id: \.self
                        ) { tag in

                            Text(tag.capitalized)
                                .font(.caption2)
                                .bold()
                                .padding(
                                    .horizontal,
                                    9
                                )
                                .padding(
                                    .vertical,
                                    5
                                )
                                .background(
                                    Capsule()
                                        .fill(
                                            RecalllQTheme
                                                .primary
                                                .opacity(0.10)
                                        )
                                )
                                .foregroundColor(
                                    RecalllQTheme.primary
                                )
                        }
                    }
                }
            }

            // =================================================
            // SCORE
            // =================================================

            HStack {

                Image(
                    systemName:
                        "chart.bar.fill"
                )
                .foregroundColor(
                    RecalllQTheme.success
                )

                Text(
                    "Priority Score"
                )
                .font(.caption)
                .foregroundColor(
                    RecalllQTheme.secondaryText
                )

                Spacer()

                Text(
                    "\(Int(recommendation.score))"
                )
                .font(.caption)
                .bold()
                .foregroundColor(
                    RecalllQTheme.primary
                )
            }
        }
        .padding(
            RecalllQTheme.largePadding
        )
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(
            RoundedRectangle(
                cornerRadius:
                    RecalllQTheme.largeRadius
            )
            .fill(
                RecalllQTheme.cardBackground
            )
        )
        .shadow(
            color:
                Color.black.opacity(
                    RecalllQTheme.shadowOpacity
                ),
            radius:
                RecalllQTheme.shadowRadius,
            x: 0,
            y:
                RecalllQTheme.shadowY
        )
        .onAppear {

            // =================================================
            // REFRESH PERSONALIZED RECOMMENDATIONS
            // =================================================

            appState.generateStudyRecommendations()
        }
    }
}

// =====================================================
// PREVIEW
// =====================================================

#Preview {

    let appState =
        AppState()

    if let recommendation =
        appState.studyRecommendations.first {

        StudyRecommendationCard(
            recommendation:
                recommendation
        )
        .environmentObject(
            appState
        )
        .padding()
    } else {

        Text(
            "No study recommendations yet."
        )
        .environmentObject(
            appState
        )
    }
}

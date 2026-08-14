
import SwiftUI

// =====================================================
// VIEW: QuizView
// =====================================================
// PURPOSE:
// Main quiz learning screen for RecalllQ.
//
// MATCHES:
// - QuizViewModel
// - Quiz
// - QuizQuestion
// - AppState
//
// FEATURES:
// - Multiple choice questions
// - Answer selection
// - Correct / incorrect results
// - Quiz progress
// - Score tracking
// - Quiz completion
// - Restart quiz
// - Generate quiz from flashcards
// - Empty state
// =====================================================

struct QuizView: View {

    // =====================================================
    // GLOBAL APP STATE
    // =====================================================

    @EnvironmentObject var appState: AppState

    // =====================================================
    // QUIZ VIEW MODEL
    // =====================================================

    private var vm: QuizViewModel {
        appState.quizViewModel
    }

    // =====================================================
    // BODY
    // =====================================================

    var body: some View {

        ScrollView {

            VStack(
                alignment: .leading,
                spacing: 20
            ) {

                // =================================================
                // HEADER
                // =================================================

                HStack {

                    VStack(
                        alignment: .leading,
                        spacing: 4
                    ) {

                        Text("Quiz")
                            .font(.largeTitle)
                            .bold()

                        Text("Test your knowledge.")
                            .font(.subheadline)
                            .foregroundColor(
                                RecalllQTheme.secondaryText
                            )
                    }

                    Spacer()

                    Image(
                        systemName:
                            "questionmark.circle.fill"
                    )
                    .font(.system(size: 40))
                    .foregroundColor(
                        RecalllQTheme.primary
                    )
                }

                // =================================================
                // EMPTY STATE
                // =================================================

                if vm.currentQuiz == nil {

                    emptyState

                }

                // =================================================
                // COMPLETED STATE
                // =================================================

                else if vm.currentQuiz?.isCompleted == true {

                    completedState

                }

                // =================================================
                // ACTIVE QUIZ
                // =================================================

                else if let question = vm.currentQuestion {

                    activeQuiz(question)
                }
            }
            .padding()
        }
        .navigationTitle("Quiz")
        .navigationBarTitleDisplayMode(.inline)
    }

    // =====================================================
    // ACTIVE QUIZ
    // =====================================================

    @ViewBuilder
    private func activeQuiz(
        _ question: QuizQuestion
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 18
        ) {

            // =================================================
            // PROGRESS
            // =================================================

            VStack(
                alignment: .leading,
                spacing: 8
            ) {

                HStack {

                    Text(
                        "Question \(currentQuestionNumber) of \(totalQuestions)"
                    )
                    .font(.caption)
                    .foregroundColor(
                        RecalllQTheme.secondaryText
                    )

                    Spacer()

                    Text(
                        "\(Int(vm.currentQuiz?.percentage ?? 0))%"
                    )
                    .font(.caption)
                    .bold()
                    .foregroundColor(
                        RecalllQTheme.primary
                    )
                }

                ProgressView(
                    value: Double(currentQuestionNumber),
                    total: Double(totalQuestions)
                )
                .tint(
                    RecalllQTheme.primary
                )
            }

            // =================================================
            // QUESTION CARD
            // =================================================

            VStack(
                alignment: .leading,
                spacing: 14
            ) {

                Label(
                    "Question",
                    systemImage:
                        "questionmark.bubble.fill"
                )
                .font(.headline)
                .foregroundColor(
                    RecalllQTheme.primary
                )

                Text(question.question)
                    .font(.title3)
                    .bold()
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
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

            // =================================================
            // ANSWER OPTIONS
            // =================================================

            Text("Choose an answer")
                .font(.headline)

            ForEach(
                question.options,
                id: \.self
            ) { option in

                answerButton(
                    option: option,
                    question: question
                )
            }

            // =================================================
            // SHOW RESULT
            // =================================================

            if vm.showResult {

                resultCard(question)

            } else {

                Button {

                    vm.submitAnswer()

                } label: {

                    HStack {

                        Image(
                            systemName:
                                "checkmark.circle"
                        )

                        Text("Submit Answer")
                            .bold()

                        Spacer()

                        Image(
                            systemName:
                                "arrow.right"
                        )
                    }
                    .padding()
                    .frame(
                        maxWidth: .infinity
                    )
                    .foregroundColor(.white)
                    .background(
                        RoundedRectangle(
                            cornerRadius:
                                RecalllQTheme.buttonRadius
                        )
                        .fill(
                            RecalllQTheme.primaryButton
                        )
                    )
                }
                .disabled(
                    question.selectedAnswer == nil
                )
                .opacity(
                    question.selectedAnswer == nil
                    ? 0.5
                    : 1
                )
            }

            // =================================================
            // NEXT QUESTION
            // =================================================

            if vm.showResult {

                Button {

                    vm.nextQuestion()

                } label: {

                    HStack {

                        Text(
                            isLastQuestion
                            ? "Finish Quiz"
                            : "Next Question"
                        )
                        .bold()

                        Spacer()

                        Image(
                            systemName:
                                "arrow.right"
                        )
                    }
                    .padding()
                    .frame(
                        maxWidth: .infinity
                    )
                    .foregroundColor(.white)
                    .background(
                        RoundedRectangle(
                            cornerRadius:
                                RecalllQTheme.buttonRadius
                        )
                        .fill(
                            RecalllQTheme.primaryButton
                        )
                    )
                }
            }
        }
    }

    // =====================================================
    // ANSWER BUTTON
    // =====================================================

    @ViewBuilder
    private func answerButton(
        option: String,
        question: QuizQuestion
    ) -> some View {

        Button {

            if !vm.showResult {

                vm.selectAnswer(option)
            }

        } label: {

            HStack {

                Text(option)
                    .font(.body)
                    .multilineTextAlignment(
                        .leading
                    )

                Spacer()

                if question.selectedAnswer == option {

                    Image(
                        systemName:
                            "checkmark.circle.fill"
                    )
                    .foregroundColor(
                        RecalllQTheme.primary
                    )
                }
            }
            .padding()
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
            .background(
                RoundedRectangle(
                    cornerRadius:
                        RecalllQTheme.mediumRadius
                )
                .fill(
                    question.selectedAnswer == option
                    ? RecalllQTheme.blueBackground
                    : RecalllQTheme.cardBackground
                )
            )
            .overlay(
                RoundedRectangle(
                    cornerRadius:
                        RecalllQTheme.mediumRadius
                )
                .stroke(
                    question.selectedAnswer == option
                    ? RecalllQTheme.primary
                    : Color.gray.opacity(0.15),
                    lineWidth: 1
                )
            )
        }
        .buttonStyle(.plain)
        .disabled(vm.showResult)
    }

    // =====================================================
    // RESULT CARD
    // =====================================================

    @ViewBuilder
    private func resultCard(
        _ question: QuizQuestion
    ) -> some View {

        let isCorrect =
            question.isCorrect

        VStack(
            alignment: .leading,
            spacing: 12
        ) {

            HStack {

                Image(
                    systemName:
                        isCorrect
                        ? "checkmark.circle.fill"
                        : "xmark.circle.fill"
                )
                .foregroundColor(
                    isCorrect
                    ? RecalllQTheme.success
                    : .red
                )

                Text(
                    isCorrect
                    ? "Correct!"
                    : "Not Quite"
                )
                .font(.headline)
                .bold()

                Spacer()
            }

            Text("Correct Answer")
                .font(.caption)
                .foregroundColor(
                    RecalllQTheme.secondaryText
                )

            Text(
                question.correctAnswer
            )
            .font(.body)
            .bold()

            if !question.explanation.isEmpty {

                Text(
                    question.explanation
                )
                .font(.caption)
                .foregroundColor(
                    RecalllQTheme.secondaryText
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
                isCorrect
                ? RecalllQTheme.greenBackground
                : RecalllQTheme.redBackground
            )
        )
    }

    // =====================================================
    // COMPLETED STATE
    // =====================================================

    private var completedState: some View {

        VStack(
            spacing: 18
        ) {

            ZStack {

                Circle()
                    .fill(
                        RecalllQTheme.greenBackground
                    )
                    .frame(
                        width: 110,
                        height: 110
                    )

                Image(
                    systemName:
                        "checkmark"
                )
                .font(
                    .system(size: 50)
                )
                .foregroundColor(
                    RecalllQTheme.success
                )
            }

            Text("Quiz Complete!")
                .font(.title)
                .bold()

            Text(
                "You answered \(vm.currentQuiz?.correctAnswers ?? 0) out of \(totalQuestions) correctly."
            )
            .font(.headline)
            .foregroundColor(
                RecalllQTheme.secondaryText
            )
            .multilineTextAlignment(
                .center
            )

            Text(
                "\(Int(vm.currentQuiz?.percentage ?? 0))%"
            )
            .font(
                .system(size: 48)
            )
            .bold()
            .foregroundColor(
                RecalllQTheme.primary
            )

            Button {

                vm.resetCurrentQuiz()

            } label: {

                HStack {

                    Image(
                        systemName:
                            "arrow.clockwise"
                    )

                    Text("Restart Quiz")
                        .bold()
                }
                .frame(
                    maxWidth: .infinity
                )
                .padding()
                .foregroundColor(.white)
                .background(
                    RoundedRectangle(
                        cornerRadius:
                            RecalllQTheme.buttonRadius
                    )
                    .fill(
                        RecalllQTheme.primaryButton
                    )
                )
            }
        }
        .frame(
            maxWidth: .infinity
        )
    }

    // =====================================================
    // EMPTY STATE
    // =====================================================

    private var emptyState: some View {

        VStack(
            spacing: 16
        ) {

            Image(
                systemName:
                    "questionmark.circle"
            )
            .font(
                .system(size: 60)
            )
            .foregroundColor(
                RecalllQTheme.primary
            )

            Text("No Quiz Available")
                .font(.title2)
                .bold()

            Text(
                "Create flashcards first. RecalllQ can then generate a quiz from your flashcards."
            )
            .font(.subheadline)
            .foregroundColor(
                RecalllQTheme.secondaryText
            )
            .multilineTextAlignment(
                .center
            )
            .padding(.horizontal)

            Button {

                appState.startQuiz()

            } label: {

                HStack {

                    Image(
                        systemName:
                            "sparkles"
                    )

                    Text("Generate Quiz")
                        .bold()
                }
                .frame(
                    maxWidth: .infinity
                )
                .padding()
                .foregroundColor(.white)
                .background(
                    RoundedRectangle(
                        cornerRadius:
                            RecalllQTheme.buttonRadius
                    )
                    .fill(
                        RecalllQTheme.primaryButton
                    )
                )
            }
            .padding(.horizontal)
        }
        .frame(
            maxWidth: .infinity
        )
    }

    // =====================================================
    // CURRENT QUESTION NUMBER
    // =====================================================

    private var currentQuestionNumber: Int {

        (vm.currentQuiz?.currentQuestionIndex ?? 0) + 1
    }

    // =====================================================
    // TOTAL QUESTIONS
    // =====================================================

    private var totalQuestions: Int {

        vm.currentQuiz?.totalQuestions ?? 0
    }

    // =====================================================
    // LAST QUESTION
    // =====================================================

    private var isLastQuestion: Bool {

        currentQuestionNumber >= totalQuestions
    }
}


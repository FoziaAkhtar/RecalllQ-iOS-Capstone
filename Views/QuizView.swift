
import SwiftUI

// =====================================================
// VIEW: QuizView
// =====================================================
// PURPOSE:
// Main quiz learning screen for RecalllQ.
//
// FEATURES:
// - Multiple choice questions
// - Answer selection
// - Correct / incorrect results
// - Quiz progress
// - Score tracking
// - Quiz completion
// - Restart quiz
// - Generate quiz
// - Empty state
// - Lively RecalllQ UI
// =====================================================

struct QuizView: View {

    // =====================================================
    // APP STATE
    // =====================================================

    @EnvironmentObject var appState: AppState

    // =====================================================
    // VIEW MODEL
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
                spacing: 24
            ) {

                // =================================================
                // HEADER
                // =================================================

                header

                // =================================================
                // CONTENT
                // =================================================

                if vm.currentQuiz == nil {

                    emptyState

                } else if vm.currentQuiz?.isCompleted == true {

                    completedState

                } else if let question = vm.currentQuestion {

                    activeQuiz(question)
                }
            }
            .padding()
        }
        .background(
            RecalllQTheme.background
                .ignoresSafeArea()
        )
        .navigationTitle("Quiz")
        .navigationBarTitleDisplayMode(.inline)
    }

    // =====================================================
    // HEADER
    // =====================================================

    private var header: some View {

        HStack {

            VStack(
                alignment: .leading,
                spacing: 5
            ) {

                Text("Quiz")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(
                        RecalllQTheme.primaryText
                    )

                Text("Test your knowledge.")
                    .font(.subheadline)
                    .foregroundColor(
                        RecalllQTheme.secondaryText
                    )
            }

            Spacer()

            ZStack {

                Circle()
                    .fill(
                        RecalllQTheme.purpleBackground
                    )
                    .frame(
                        width: 52,
                        height: 52
                    )

                Image(
                    systemName:
                        "questionmark.circle.fill"
                )
                .font(.title2)
                .foregroundColor(
                    RecalllQTheme.smartPurple
                )
            }
        }
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
            spacing: 20
        ) {

            // =================================================
            // QUIZ TITLE
            // =================================================

            if let quiz = vm.currentQuiz {

                VStack(
                    alignment: .leading,
                    spacing: 4
                ) {

                    Text(quiz.title)
                        .font(.headline)
                        .foregroundColor(
                            RecalllQTheme.primaryText
                        )

                    Text(
                        "\(quiz.answeredQuestions) of \(quiz.totalQuestions) answered"
                    )
                    .font(.caption)
                    .foregroundColor(
                        RecalllQTheme.secondaryText
                    )
                }
            }

            // =================================================
            // PROGRESS
            // =================================================

            progressSection

            // =================================================
            // QUESTION
            // =================================================

            questionCard(question)

            // =================================================
            // ANSWERS
            // =================================================

            Text("Choose an answer")
                .font(.headline)
                .foregroundColor(
                    RecalllQTheme.primaryText
                )

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
            // RESULT
            // =================================================

            if vm.showResult {

                resultCard(question)

                nextButton

            } else {

                submitButton(
                    question: question
                )
            }
        }
    }

    // =====================================================
    // PROGRESS SECTION
    // =====================================================

    private var progressSection: some View {

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
                    "\(Int(vm.scorePercentage))%"
                )
                .font(.caption)
                .bold()
                .foregroundColor(
                    RecalllQTheme.smartPurple
                )
            }

            ProgressView(
                value: progressValue,
                total: 1
            )
            .tint(
                RecalllQTheme.smartPurple
            )
            .scaleEffect(
                x: 1,
                y: 1.25,
                anchor: .center
            )
        }
    }

    // =====================================================
    // QUESTION CARD
    // =====================================================

    private func questionCard(
        _ question: QuizQuestion
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 14
        ) {

            HStack {

                Image(
                    systemName:
                        "questionmark.bubble.fill"
                )
                .foregroundColor(
                    RecalllQTheme.smartPurple
                )

                Text("Question")
                    .font(.headline)
                    .foregroundColor(
                        RecalllQTheme.smartPurple
                    )

                Spacer()

                Text(
                    question.difficulty.displayName
                )
                .font(.caption)
                .bold()
                .padding(
                    .horizontal,
                    10
                )
                .padding(
                    .vertical,
                    5
                )
                .background(
                    difficultyBackground(
                        question.difficulty
                    )
                )
                .clipShape(
                    Capsule()
                )
            }

            Text(question.question)
                .font(.title3)
                .bold()
                .foregroundColor(
                    RecalllQTheme.primaryText
                )
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
        .overlay(
            RoundedRectangle(
                cornerRadius:
                    RecalllQTheme.largeRadius
            )
            .stroke(
                RecalllQTheme.smartPurple.opacity(0.15),
                lineWidth: 1
            )
        )
        .shadow(
            color:
                RecalllQTheme.smartPurple.opacity(0.08),
            radius: 8,
            x: 0,
            y: 4
        )
    }

    // =====================================================
    // DIFFICULTY BACKGROUND
    // =====================================================

    @ViewBuilder
    private func difficultyBackground(
        _ difficulty: QuizQuestion.Difficulty
    ) -> some View {

        switch difficulty {

        case .easy:

            RecalllQTheme.greenBackground

        case .medium:

            RecalllQTheme.orangeBackground

        case .hard:

            RecalllQTheme.redBackground
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

        let isSelected =
            question.selectedAnswer == option

        let isCorrect =
            question.correctAnswer == option

        let showCorrectAnswer =
            vm.showResult && isCorrect

        let showWrongAnswer =
            vm.showResult &&
            isSelected &&
            !isCorrect

        Button {

            if !vm.showResult {

                vm.selectAnswer(option)
            }

        } label: {

            HStack(
                spacing: 12
            ) {

                // =================================================
                // OPTION LETTER
                // =================================================

                Text(
                    optionLetter(
                        option,
                        question: question
                    )
                )
                .font(.subheadline)
                .bold()
                .frame(
                    width: 30,
                    height: 30
                )
                .background(
                    Circle()
                        .fill(
                            optionCircleColor(
                                option: option,
                                question: question
                            )
                        )
                )
                .foregroundColor(
                    .white
                )

                // =================================================
                // ANSWER TEXT
                // =================================================

                Text(option)
                    .font(.body)
                    .multilineTextAlignment(
                        .leading
                    )
                    .foregroundColor(
                        RecalllQTheme.primaryText
                    )

                Spacer()

                // =================================================
                // RESULT ICON
                // =================================================

                if showCorrectAnswer {

                    Image(
                        systemName:
                            "checkmark.circle.fill"
                    )
                    .foregroundColor(
                        RecalllQTheme.success
                    )

                } else if showWrongAnswer {

                    Image(
                        systemName:
                            "xmark.circle.fill"
                    )
                    .foregroundColor(
                        RecalllQTheme.error
                    )

                } else if isSelected {

                    Image(
                        systemName:
                            "checkmark.circle.fill"
                    )
                    .foregroundColor(
                        RecalllQTheme.smartPurple
                    )
                }
            }
            .padding()
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
            .background(
                answerBackground(
                    option: option,
                    question: question
                )
            )
            .overlay(
                RoundedRectangle(
                    cornerRadius:
                        RecalllQTheme.mediumRadius
                )
                .stroke(
                    answerBorderColor(
                        option: option,
                        question: question
                    ),
                    lineWidth: 1.5
                )
            )
        }
        .buttonStyle(.plain)
        .disabled(vm.showResult)
    }

    // =====================================================
    // OPTION LETTER
    // =====================================================

    private func optionLetter(
        _ option: String,
        question: QuizQuestion
    ) -> String {

        guard let index =
                question.options.firstIndex(
                    of: option
                )
        else {
            return "?"
        }

        let letters = [
            "A",
            "B",
            "C",
            "D",
            "E",
            "F"
        ]

        if index < letters.count {

            return letters[index]
        }

        return "?"
    }

    // =====================================================
    // OPTION CIRCLE COLOR
    // =====================================================

    private func optionCircleColor(
        option: String,
        question: QuizQuestion
    ) -> Color {

        if vm.showResult {

            if option == question.correctAnswer {

                return RecalllQTheme.success
            }

            if option == question.selectedAnswer {

                return RecalllQTheme.error
            }
        }

        if option == question.selectedAnswer {

            return RecalllQTheme.smartPurple
        }

        return RecalllQTheme.secondaryText
    }

    // =====================================================
    // ANSWER BACKGROUND
    // =====================================================

    private func answerBackground(
        option: String,
        question: QuizQuestion
    ) -> Color {

        if vm.showResult {

            if option == question.correctAnswer {

                return RecalllQTheme.greenBackground
            }

            if option == question.selectedAnswer {

                return RecalllQTheme.redBackground
            }
        }

        if option == question.selectedAnswer {

            return RecalllQTheme.purpleBackground
        }

        return RecalllQTheme.cardBackground
    }

    // =====================================================
    // ANSWER BORDER
    // =====================================================

    private func answerBorderColor(
        option: String,
        question: QuizQuestion
    ) -> Color {

        if vm.showResult {

            if option == question.correctAnswer {

                return RecalllQTheme.success
            }

            if option == question.selectedAnswer {

                return RecalllQTheme.error
            }
        }

        if option == question.selectedAnswer {

            return RecalllQTheme.smartPurple
        }

        return Color.gray.opacity(0.15)
    }

    // =====================================================
    // SUBMIT BUTTON
    // =====================================================

    private func submitButton(
        question: QuizQuestion
    ) -> some View {

        Button {

            vm.submitAnswer()

        } label: {

            HStack {

                Image(
                    systemName:
                        "checkmark.circle.fill"
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
                        RecalllQTheme.buttonRadius
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

    // =====================================================
    // RESULT CARD
    // =====================================================

    private func resultCard(
        _ question: QuizQuestion
    ) -> some View {

        let isCorrect =
            question.isCorrect

        return VStack(
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
                .font(.title2)
                .foregroundColor(
                    isCorrect
                    ? RecalllQTheme.success
                    : RecalllQTheme.error
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

            Divider()

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
                .fixedSize(
                    horizontal: false,
                    vertical: true
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
    // NEXT BUTTON
    // =====================================================

    private var nextButton: some View {

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
                        RecalllQTheme.buttonRadius
                )
            )
        }
    }

    // =====================================================
    // COMPLETED STATE
    // =====================================================

    private var completedState: some View {

        VStack(
            spacing: 20
        ) {

            ZStack {

                Circle()
                    .fill(
                        RecalllQTheme.greenBackground
                    )
                    .frame(
                        width: 120,
                        height: 120
                    )

                Image(
                    systemName:
                        "checkmark.circle.fill"
                )
                .font(
                    .system(size: 60)
                )
                .foregroundColor(
                    RecalllQTheme.success
                )
            }

            Text("Quiz Complete!")
                .font(.title)
                .bold()

            Text(
                "Great work! You completed the quiz."
            )
            .font(.subheadline)
            .foregroundColor(
                RecalllQTheme.secondaryText
            )
            .multilineTextAlignment(
                .center
            )

            // =================================================
            // SCORE
            // =================================================

            VStack(
                spacing: 6
            ) {

                Text(
                    "\(vm.correctAnswers) / \(totalQuestions)"
                )
                .font(
                    .system(
                        size: 32,
                        weight: .bold
                    )
                )
                .foregroundColor(
                    RecalllQTheme.smartPurple
                )

                Text(
                    "\(Int(vm.scorePercentage))%"
                )
                .font(
                    .system(
                        size: 46,
                        weight: .bold
                    )
                )
                .foregroundColor(
                    RecalllQTheme.smartPurple
                )

                Text("Final Score")
                    .font(.caption)
                    .foregroundColor(
                        RecalllQTheme.secondaryText
                    )
            }

            // =================================================
            // RESTART
            // =================================================

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
                            RecalllQTheme.buttonRadius
                    )
                )
            }
        }
        .frame(
            maxWidth: .infinity
        )
        .padding(.vertical, 20)
    }

    // =====================================================
    // EMPTY STATE
    // =====================================================

    private var emptyState: some View {

        VStack(
            spacing: 18
        ) {

            ZStack {

                Circle()
                    .fill(
                        RecalllQTheme.purpleBackground
                    )
                    .frame(
                        width: 110,
                        height: 110
                    )

                Image(
                    systemName:
                        "questionmark.circle.fill"
                )
                .font(
                    .system(size: 55)
                )
                .foregroundColor(
                    RecalllQTheme.smartPurple
                )
            }

            Text("No Quiz Available")
                .font(.title2)
                .bold()

            Text(
                "Create flashcards or memories first. RecalllQ can then generate a quiz to test your knowledge."
            )
            .font(.subheadline)
            .foregroundColor(
                RecalllQTheme.secondaryText
            )
            .multilineTextAlignment(
                .center
            )
            .fixedSize(
                horizontal: false,
                vertical: true
            )

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
                            RecalllQTheme.buttonRadius
                    )
                )
            }
        }
        .frame(
            maxWidth: .infinity
        )
        .padding(.vertical, 30)
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
    // PROGRESS
    // =====================================================

    private var progressValue: Double {

        guard totalQuestions > 0 else {
            return 0
        }

        return Double(currentQuestionNumber)
            / Double(totalQuestions)
    }

    // =====================================================
    // LAST QUESTION
    // =====================================================

    private var isLastQuestion: Bool {

        guard totalQuestions > 0 else {
            return false
        }

        return currentQuestionNumber >= totalQuestions
    }
}


import SwiftUI

// =====================================================
// VIEW: FlashcardsView
// =====================================================
// PURPOSE:
// Premium RecalllQ flashcard learning experience.
//
// FEATURES:
// - Flashcard statistics
// - Memory → Flashcard conversion progress
// - Search
// - Generate flashcards from Memories
// - Generation status
// - Study mode
// - Answer reveal
// - Easy / Medium / Hard review
// - Spaced repetition status
// - Previous / Next navigation
// - Mastery tracking
// - Accuracy tracking
// - Flashcard list
// - Delete flashcards
// - Reset all flashcards
// - Study Session integration
// =====================================================

struct FlashcardsView: View {

    // =====================================================
    // APP STATE
    // =====================================================

    @EnvironmentObject var appState: AppState

    // =====================================================
    // VIEW MODEL
    // =====================================================

    private var vm: FlashcardViewModel {
        appState.flashcardViewModel
    }

    // =====================================================
    // LOCAL STATE
    // =====================================================

    @State private var showingResetConfirmation = false
    @State private var showingGenerationInfo = false

    // =====================================================
    // MEMORY INFORMATION
    // =====================================================

    private var memoryCount: Int {
        appState.memoryViewModel.memories.count
    }

    private var flashcardCount: Int {
        vm.totalFlashcards
    }

    private var convertedMemoryCount: Int {
        min(flashcardCount, memoryCount)
    }

    private var remainingFlashcards: Int {
        max(memoryCount - convertedMemoryCount, 0)
    }

    private var memoryProgress: Double {
        guard memoryCount > 0 else {
            return 0
        }

        return min(
            Double(convertedMemoryCount) / Double(memoryCount),
            1.0
        )
    }

    private var memoryProgressPercentage: Int {
        Int(memoryProgress * 100)
    }

    // =====================================================
    // ACCURACY
    // =====================================================

    private var accuracyText: String {
        String(
            format: "%.0f%%",
            vm.overallAccuracy * 100
        )
    }

    // =====================================================
    // REVIEW INFORMATION
    // =====================================================

    private var reviewedCount: Int {
        vm.reviewedFlashcards
    }

    private var unreviewedCount: Int {
        max(flashcardCount - reviewedCount, 0)
    }

    // =====================================================
    // GENERATION BUTTON TITLE
    // =====================================================

    private var generateButtonTitle: String {

        if memoryCount == 0 {
            return "Create Memories First"
        }

        if remainingFlashcards > 0 {
            return "Generate \(remainingFlashcards) Flashcard\(remainingFlashcards == 1 ? "" : "s")"
        }

        return "Generate Flashcards"
    }

    // =====================================================
    // MEMORY STATUS
    // =====================================================

    private var memoryStatusText: String {

        if memoryCount == 0 {
            return "Create your first Memory to begin studying."
        }

        if convertedMemoryCount >= memoryCount {
            return "All Memories have been converted into flashcards."
        }

        return "\(remainingFlashcards) Memory\(remainingFlashcards == 1 ? "" : "ies") ready for flashcard generation."
    }

    // =====================================================
    // BODY
    // =====================================================

    var body: some View {

        ScrollView(showsIndicators: false) {

            VStack(
                alignment: .leading,
                spacing: 20
            ) {

                headerSection

                statisticsSection

                memoryProgressCard

                generationSection

                generationMessages

                searchSection

                if let card = vm.currentFlashcard {
                    studySection(card)
                } else {
                    emptyState
                }

                flashcardListSection
            }
            .padding()
            .padding(.bottom, 30)
        }
        .background(
            RecalllQTheme.background
                .ignoresSafeArea()
        )
        .navigationTitle("Flashcards")
        .navigationBarTitleDisplayMode(.inline)
    }

    // =====================================================
    // HEADER
    // =====================================================

    private var headerSection: some View {

        HStack(spacing: 14) {

            VStack(
                alignment: .leading,
                spacing: 5
            ) {

                Text("Flashcards")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(
                        RecalllQTheme.primaryText
                    )

                Text("Turn your Memories into active learning.")
                    .font(.subheadline)
                    .foregroundColor(
                        RecalllQTheme.secondaryText
                    )
            }

            Spacer()

            ZStack {

                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                RecalllQTheme.primary.opacity(0.18),
                                RecalllQTheme.smartPurple.opacity(0.12)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(
                        width: 56,
                        height: 56
                    )

                Image(
                    systemName: "rectangle.on.rectangle.fill"
                )
                .font(.title2)
                .foregroundColor(
                    RecalllQTheme.primary
                )
            }
        }
    }

    // =====================================================
    // STATISTICS
    // =====================================================

    private var statisticsSection: some View {

        HStack(spacing: 10) {

            statisticCard(
                value: "\(vm.totalFlashcards)",
                title: "Cards",
                icon: "rectangle.stack.fill",
                color: RecalllQTheme.primary
            )

            statisticCard(
                value: "\(vm.masteredFlashcards)",
                title: "Mastered",
                icon: "checkmark.seal.fill",
                color: RecalllQTheme.success
            )

            statisticCard(
                value: accuracyText,
                title: "Accuracy",
                icon: "chart.bar.fill",
                color: RecalllQTheme.secondary
            )
        }
    }

    // =====================================================
    // STATISTIC CARD
    // =====================================================

    @ViewBuilder
    private func statisticCard(
        value: String,
        title: String,
        icon: String,
        color: Color
    ) -> some View {

        VStack(spacing: 7) {

            Image(systemName: icon)
                .font(.headline)
                .foregroundColor(color)

            Text(value)
                .font(.title3)
                .bold()
                .foregroundColor(
                    RecalllQTheme.primaryText
                )

            Text(title)
                .font(.caption2)
                .foregroundColor(
                    RecalllQTheme.secondaryText
                )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(
                cornerRadius: RecalllQTheme.mediumRadius
            )
            .fill(
                RecalllQTheme.cardBackground
            )
        )
        .overlay(
            RoundedRectangle(
                cornerRadius: RecalllQTheme.mediumRadius
            )
            .stroke(
                color.opacity(0.12),
                lineWidth: 1
            )
        )
    }

    // =====================================================
    // MEMORY PROGRESS
    // =====================================================

    private var memoryProgressCard: some View {

        VStack(
            alignment: .leading,
            spacing: 16
        ) {

            HStack {

                VStack(
                    alignment: .leading,
                    spacing: 5
                ) {

                    Label(
                        "Memory → Flashcards",
                        systemImage: "brain.head.profile"
                    )
                    .font(.headline)
                    .foregroundColor(
                        RecalllQTheme.primaryText
                    )

                    Text(
                        "\(convertedMemoryCount) of \(memoryCount) Memories converted"
                    )
                    .font(.caption)
                    .foregroundColor(
                        RecalllQTheme.secondaryText
                    )
                }

                Spacer()

                ZStack {

                    Circle()
                        .stroke(
                            RecalllQTheme.primary.opacity(0.12),
                            lineWidth: 7
                        )
                        .frame(
                            width: 62,
                            height: 62
                        )

                    Circle()
                        .trim(
                            from: 0,
                            to: memoryProgress
                        )
                        .stroke(
                            LinearGradient(
                                colors: [
                                    RecalllQTheme.primary,
                                    RecalllQTheme.smartPurple
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            style: StrokeStyle(
                                lineWidth: 7,
                                lineCap: .round
                            )
                        )
                        .rotationEffect(
                            .degrees(-90)
                        )
                        .frame(
                            width: 62,
                            height: 62
                        )

                    Text(
                        "\(memoryProgressPercentage)%"
                    )
                    .font(.caption)
                    .bold()
                    .foregroundColor(
                        RecalllQTheme.primary
                    )
                }
            }

            ProgressView(
                value: memoryProgress
            )
            .tint(
                RecalllQTheme.primary
            )

            Text(memoryStatusText)
                .font(.caption)
                .foregroundColor(
                    RecalllQTheme.secondaryText
                )

            HStack(spacing: 12) {

                progressMiniStat(
                    icon: "brain.head.profile",
                    value: "\(memoryCount)",
                    title: "Memories"
                )

                progressMiniStat(
                    icon: "rectangle.stack.fill",
                    value: "\(flashcardCount)",
                    title: "Cards"
                )

                progressMiniStat(
                    icon: "clock.fill",
                    value: "\(unreviewedCount)",
                    title: "Unreviewed"
                )
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(
                cornerRadius: RecalllQTheme.largeRadius
            )
            .fill(
                RecalllQTheme.cardBackground
            )
        )
        .overlay(
            RoundedRectangle(
                cornerRadius: RecalllQTheme.largeRadius
            )
            .stroke(
                RecalllQTheme.primary.opacity(0.10),
                lineWidth: 1
            )
        )
        .shadow(
            color: Color.black.opacity(
                RecalllQTheme.shadowOpacity
            ),
            radius: RecalllQTheme.shadowRadius,
            x: 0,
            y: RecalllQTheme.shadowY
        )
    }

    // =====================================================
    // MINI PROGRESS STAT
    // =====================================================

    @ViewBuilder
    private func progressMiniStat(
        icon: String,
        value: String,
        title: String
    ) -> some View {

        VStack(spacing: 5) {

            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(
                    RecalllQTheme.primary
                )

            Text(value)
                .font(.subheadline)
                .bold()
                .foregroundColor(
                    RecalllQTheme.primaryText
                )

            Text(title)
                .font(.caption2)
                .foregroundColor(
                    RecalllQTheme.secondaryText
                )
        }
        .frame(maxWidth: .infinity)
    }

    // =====================================================
    // GENERATION SECTION
    // =====================================================

    private var generationSection: some View {

        Button {

            appState.createFlashcardsFromAllMemories()

        } label: {

            HStack(spacing: 14) {

                ZStack {

                    Circle()
                        .fill(Color.white.opacity(0.18))
                        .frame(
                            width: 44,
                            height: 44
                        )

                    Image(
                        systemName: "sparkles"
                    )
                    .font(.title3)
                }

                VStack(
                    alignment: .leading,
                    spacing: 4
                ) {

                    Text(generateButtonTitle)
                        .font(.headline)

                    Text(
                        memoryCount > 0
                        ? "Create intelligent study cards from your Memories"
                        : "Add Memories before generating flashcards"
                    )
                    .font(.caption)
                    .opacity(0.88)
                }

                Spacer()

                if vm.isGeneratingFlashcards {

                    ProgressView()
                        .tint(.white)

                } else {

                    Image(
                        systemName: "arrow.right"
                    )
                    .font(.headline)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
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
                    cornerRadius: RecalllQTheme.largeRadius
                )
            )
            .shadow(
                color: RecalllQTheme.primary.opacity(0.20),
                radius: 10,
                x: 0,
                y: 5
            )
        }
        .disabled(
            memoryCount == 0 ||
            vm.isGeneratingFlashcards
        )
        .opacity(
            memoryCount == 0 ? 0.55 : 1
        )
    }

    // =====================================================
    // GENERATION MESSAGES
    // =====================================================

    @ViewBuilder
    private var generationMessages: some View {

        if vm.isGeneratingFlashcards {

            statusMessage(
                icon: "sparkles",
                text: "RecalllQ is generating your flashcards...",
                color: RecalllQTheme.primary
            )

        } else if let message = vm.flashcardGenerationMessage {

            statusMessage(
                icon: "checkmark.circle.fill",
                text: message,
                color: RecalllQTheme.success
            )
        }

        if let error = vm.flashcardGenerationError {

            statusMessage(
                icon: "exclamationmark.triangle.fill",
                text: error,
                color: RecalllQTheme.error
            )
        }

        if !vm.flashcards.isEmpty {

            Button {

                showingResetConfirmation = true

            } label: {

                HStack {

                    Image(
                        systemName: "trash.fill"
                    )

                    Text("Reset All Flashcards")
                        .font(.subheadline)
                        .bold()

                    Spacer()
                }
                .padding(.vertical, 4)
                .foregroundColor(
                    RecalllQTheme.error
                )
            }
            .alert(
                "Reset All Flashcards?",
                isPresented: $showingResetConfirmation
            ) {

                Button(
                    "Cancel",
                    role: .cancel
                ) {}

                Button(
                    "Reset",
                    role: .destructive
                ) {
                    vm.resetAllFlashcards()
                }

            } message: {

                Text(
                    "This will permanently delete all saved flashcards."
                )
            }
        }
    }

    // =====================================================
    // STATUS MESSAGE
    // =====================================================

    @ViewBuilder
    private func statusMessage(
        icon: String,
        text: String,
        color: Color
    ) -> some View {

        HStack(spacing: 10) {

            Image(systemName: icon)
                .foregroundColor(color)

            Text(text)
                .font(.caption)
                .foregroundColor(
                    RecalllQTheme.primaryText
                )

            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(
                cornerRadius: RecalllQTheme.mediumRadius
            )
            .fill(
                color.opacity(0.09)
            )
        )
    }

    // =====================================================
    // SEARCH
    // =====================================================

    private var searchSection: some View {

        HStack(spacing: 10) {

            Image(
                systemName: "magnifyingglass"
            )
            .foregroundColor(
                RecalllQTheme.primary
            )

            TextField(
                "Search your flashcards...",
                text: Binding(
                    get: {
                        vm.searchText
                    },
                    set: {
                        vm.searchText = $0
                    }
                )
            )

            if !vm.searchText.isEmpty {

                Button {

                    vm.searchText = ""

                } label: {

                    Image(
                        systemName: "xmark.circle.fill"
                    )
                    .foregroundColor(
                        RecalllQTheme.secondaryText
                    )
                }
            }
        }
        .padding(13)
        .background(
            RoundedRectangle(
                cornerRadius: RecalllQTheme.mediumRadius
            )
            .fill(
                RecalllQTheme.cardBackground
            )
        )
        .overlay(
            RoundedRectangle(
                cornerRadius: RecalllQTheme.mediumRadius
            )
            .stroke(
                RecalllQTheme.primary.opacity(0.10),
                lineWidth: 1
            )
        )
    }

    // =====================================================
    // STUDY SECTION
    // =====================================================

    @ViewBuilder
    private func studySection(
        _ card: Flashcard
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 18
        ) {

            HStack {

                Label(
                    "Study Mode",
                    systemImage: "brain.head.profile"
                )
                .font(.headline)
                .foregroundColor(
                    RecalllQTheme.primary
                )

                Spacer()

                Text(
                    "\(vm.currentCardNumber) / \(vm.filteredFlashcards.count)"
                )
                .font(.caption)
                .bold()
                .foregroundColor(
                    RecalllQTheme.secondaryText
                )
            }

            ProgressView(
                value: Double(vm.currentCardNumber),
                total: Double(
                    max(vm.filteredFlashcards.count, 1)
                )
            )
            .tint(
                RecalllQTheme.primary
            )

            Divider()

            Text("QUESTION")
                .font(.caption)
                .bold()
                .tracking(1)
                .foregroundColor(
                    RecalllQTheme.secondaryText
                )

            Text(card.question)
                .font(.title3)
                .bold()
                .foregroundColor(
                    RecalllQTheme.primaryText
                )
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )

            if vm.isShowingAnswer {

                answerSection(card)

            } else {

                showAnswerButton
            }

            navigationButtons
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
                cornerRadius: RecalllQTheme.largeRadius
            )
            .fill(
                RecalllQTheme.cardBackground
            )
        )
        .overlay(
            RoundedRectangle(
                cornerRadius: RecalllQTheme.largeRadius
            )
            .stroke(
                RecalllQTheme.primary.opacity(0.12),
                lineWidth: 1
            )
        )
        .shadow(
            color: Color.black.opacity(
                RecalllQTheme.shadowOpacity
            ),
            radius: RecalllQTheme.shadowRadius,
            x: 0,
            y: RecalllQTheme.shadowY
        )
    }

    // =====================================================
    // ANSWER SECTION
    // =====================================================

    private func answerSection(
        _ card: Flashcard
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 14
        ) {

            Divider()

            Text("ANSWER")
                .font(.caption)
                .bold()
                .tracking(1)
                .foregroundColor(
                    RecalllQTheme.secondaryText
                )

            Text(card.answer)
                .font(.body)
                .foregroundColor(
                    RecalllQTheme.primaryText
                )
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )

            Text("How well did you know this?")
                .font(.caption)
                .foregroundColor(
                    RecalllQTheme.secondaryText
                )
                .padding(.top, 3)

            HStack(spacing: 8) {

                difficultyButton(
                    title: "Easy",
                    icon: "face.smiling.fill",
                    color: RecalllQTheme.success
                ) {
                    vm.markEasy()
                }

                difficultyButton(
                    title: "Medium",
                    icon: "minus.circle.fill",
                    color: RecalllQTheme.secondary
                ) {
                    vm.markMedium()
                }

                difficultyButton(
                    title: "Hard",
                    icon: "exclamationmark.circle.fill",
                    color: RecalllQTheme.error
                ) {
                    vm.markHard()
                }
            }
        }
    }

    // =====================================================
    // SHOW ANSWER
    // =====================================================

    private var showAnswerButton: some View {

        Button {

            vm.showAnswer()

        } label: {

            HStack {

                Image(
                    systemName: "eye.fill"
                )

                Text("Reveal Answer")
                    .font(.headline)

                Spacer()

                Image(
                    systemName: "chevron.down"
                )
            }
            .padding()
            .frame(maxWidth: .infinity)
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
                    cornerRadius: RecalllQTheme.mediumRadius
                )
            )
        }
    }

    // =====================================================
    // NAVIGATION BUTTONS
    // =====================================================

    private var navigationButtons: some View {

        HStack {

            Button {

                vm.previousCard()

            } label: {

                Label(
                    "Previous",
                    systemImage: "chevron.left"
                )
            }

            Spacer()

            Button {

                vm.nextCard()

            } label: {

                Label(
                    "Next",
                    systemImage: "chevron.right"
                )
            }
        }
        .font(.subheadline)
        .bold()
        .foregroundColor(
            RecalllQTheme.primary
        )
    }

    // =====================================================
    // DIFFICULTY BUTTON
    // =====================================================

    @ViewBuilder
    private func difficultyButton(
        title: String,
        icon: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {

        Button {

            action()

        } label: {

            VStack(spacing: 5) {

                Image(
                    systemName: icon
                )

                Text(title)
                    .font(.caption)
                    .bold()
            }
            .frame(
                maxWidth: .infinity
            )
            .padding(.vertical, 11)
            .foregroundColor(color)
            .background(
                RoundedRectangle(
                    cornerRadius: RecalllQTheme.smallRadius
                )
                .fill(
                    color.opacity(0.10)
                )
            )
        }
    }

    // =====================================================
    // FLASHCARD LIST
    // =====================================================

    @ViewBuilder
    private var flashcardListSection: some View {

        if !vm.filteredFlashcards.isEmpty {

            VStack(
                alignment: .leading,
                spacing: 12
            ) {

                HStack {

                    Text("Your Flashcards")
                        .font(.title3)
                        .bold()
                        .foregroundColor(
                            RecalllQTheme.primaryText
                        )

                    Spacer()

                    Text(
                        "\(vm.filteredFlashcards.count)"
                    )
                    .font(.caption)
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
                        RecalllQTheme.primary.opacity(0.10)
                    )
                    .foregroundColor(
                        RecalllQTheme.primary
                    )
                    .clipShape(
                        Capsule()
                    )
                }

                ForEach(
                    vm.filteredFlashcards
                ) { card in

                    flashcardRow(card)
                }
            }
        }
    }

    // =====================================================
    // FLASHCARD ROW
    // =====================================================

    @ViewBuilder
    private func flashcardRow(
        _ card: Flashcard
    ) -> some View {

        HStack(
            alignment: .top,
            spacing: 12
        ) {

            ZStack {

                RoundedRectangle(
                    cornerRadius: 12
                )
                .fill(
                    RecalllQTheme.blueBackground
                )
                .frame(
                    width: 46,
                    height: 46
                )

                Image(
                    systemName: "rectangle.on.rectangle.fill"
                )
                .foregroundColor(
                    RecalllQTheme.primary
                )
            }

            VStack(
                alignment: .leading,
                spacing: 7
            ) {

                Text(card.question)
                    .font(.headline)
                    .foregroundColor(
                        RecalllQTheme.primaryText
                    )
                    .lineLimit(2)

                Text(card.answer)
                    .font(.caption)
                    .foregroundColor(
                        RecalllQTheme.secondaryText
                    )
                    .lineLimit(2)

                HStack(spacing: 8) {

                    difficultyBadge(card)

                    Text(
                        "\(card.timesReviewed) reviews"
                    )
                    .font(.caption2)
                    .foregroundColor(
                        RecalllQTheme.secondaryText
                    )

                    if card.timesReviewed > 0 {

                        Text(
                            "\(Int(card.accuracy * 100))%"
                        )
                        .font(.caption2)
                        .bold()
                        .foregroundColor(
                            RecalllQTheme.success
                        )
                    }
                }
            }

            Spacer()
        }
        .padding()
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(
            RoundedRectangle(
                cornerRadius: RecalllQTheme.mediumRadius
            )
            .fill(
                RecalllQTheme.cardBackground
            )
        )
        .overlay(
            RoundedRectangle(
                cornerRadius: RecalllQTheme.mediumRadius
            )
            .stroke(
                Color.gray.opacity(0.08),
                lineWidth: 1
            )
        )
        .contextMenu {

            Button(
                role: .destructive
            ) {

                vm.deleteFlashcard(
                    id: card.id
                )

            } label: {

                Label(
                    "Delete",
                    systemImage: "trash"
                )
            }
        }
    }

    // =====================================================
    // DIFFICULTY BADGE
    // =====================================================

    @ViewBuilder
    private func difficultyBadge(
        _ card: Flashcard
    ) -> some View {

        let color: Color = {

            switch card.difficulty {

            case .easy:
                return RecalllQTheme.success

            case .medium:
                return RecalllQTheme.secondary

            case .hard:
                return RecalllQTheme.error
            }
        }()

        Text(
            card.difficulty.displayName
        )
        .font(.caption2)
        .bold()
        .foregroundColor(color)
        .padding(
            .horizontal,
            7
        )
        .padding(
            .vertical,
            4
        )
        .background(
            color.opacity(0.10)
        )
        .clipShape(
            Capsule()
        )
    }

    // =====================================================
    // EMPTY STATE
    // =====================================================

    private var emptyState: some View {

        VStack(spacing: 15) {

            ZStack {

                Circle()
                    .fill(
                        RecalllQTheme.blueBackground
                    )
                    .frame(
                        width: 82,
                        height: 82
                    )

                Image(
                    systemName: "rectangle.on.rectangle"
                )
                .font(
                    .system(size: 32)
                )
                .foregroundColor(
                    RecalllQTheme.primary
                )
            }

            Text(
                vm.searchText.isEmpty
                ? "Ready to Learn?"
                : "No Flashcards Found"
            )
            .font(.title3)
            .bold()
            .foregroundColor(
                RecalllQTheme.primaryText
            )

            Text(
                vm.searchText.isEmpty
                ? "Create Memories and RecalllQ will turn them into study-ready flashcards."
                : "Try another search term."
            )
            .font(.caption)
            .foregroundColor(
                RecalllQTheme.secondaryText
            )
            .multilineTextAlignment(.center)

            if vm.flashcards.isEmpty &&
                !appState.memoryViewModel.memories.isEmpty {

                Button {

                    appState.createFlashcardsFromAllMemories()

                } label: {

                    HStack {

                        Image(
                            systemName: "sparkles"
                        )

                        Text(
                            "Generate From Memories"
                        )
                        .font(.headline)

                        Spacer()

                        Image(
                            systemName: "arrow.right"
                        )
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
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
                                RecalllQTheme.mediumRadius
                        )
                    )
                }
                .padding(.top, 4)
            }
        }
        .frame(
            maxWidth: .infinity
        )
        .padding(30)
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
                RecalllQTheme.primary.opacity(0.10),
                lineWidth: 1
            )
        )
    }
}


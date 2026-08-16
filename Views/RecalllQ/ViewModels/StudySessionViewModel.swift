
import Foundation
import Combine

// =====================================================
// VIEWMODEL: StudySessionViewModel
// =====================================================
// PURPOSE:
// Manages personalized study sessions for RecalllQ.
//
// FEATURES:
// - Start study session
// - End study session
// - Cancel study session
// - LIVE timer that updates every second
// - Track flashcards reviewed
// - Track quizzes completed
// - Track memories studied
// - Save sessions locally
// - Load previous sessions
// - Calculate total study time
// - Calculate today's study time
// - Show recent study activity
// - Reset study history
// =====================================================

final class StudySessionViewModel: ObservableObject {

    // =====================================================
    // MAIN STATE
    // =====================================================

    @Published private(set) var sessions: [StudySession] = []

    // =====================================================
    // ACTIVE SESSION
    // =====================================================

    @Published private(set) var activeSession: StudySession?

    @Published private(set) var isStudying: Bool = false

    @Published private(set) var currentSessionStartDate: Date?

    // =====================================================
    // LIVE TIMER
    // =====================================================
    // IMPORTANT:
    // This value changes every second.
    // Because it is @Published, SwiftUI updates the UI.
    // =====================================================

    @Published private(set) var elapsedSessionTime: TimeInterval = 0

    private var timer: Timer?

    // =====================================================
    // STORAGE
    // =====================================================

    private let storageKey =
        "recallq_study_sessions"

    // =====================================================
    // INIT
    // =====================================================

    init() {

        loadSessions()
    }

    // =====================================================
    // DEINIT
    // =====================================================

    deinit {

        stopTimer()
    }

    // =====================================================
    // START STUDY SESSION
    // =====================================================

    func startSession() {

        // -------------------------------------------------
        // Prevent multiple active sessions
        // -------------------------------------------------

        guard !isStudying else {

            print(
                "⚠️ A study session is already active."
            )

            return
        }

        let startDate = Date()

        let session =
            StudySession(
                startDate: startDate
            )

        activeSession = session

        currentSessionStartDate =
            startDate

        elapsedSessionTime = 0

        isStudying = true

        // -------------------------------------------------
        // START LIVE TIMER
        // -------------------------------------------------

        startTimer()

        print("========================================")
        print("📚 STUDY SESSION STARTED")
        print("Start: \(startDate)")
        print("========================================")
    }

    // =====================================================
    // START TIMER
    // =====================================================

    private func startTimer() {

        // Remove any existing timer first.
        stopTimer()

        // -------------------------------------------------
        // Timer fires every 1 second.
        // -------------------------------------------------

        timer =
            Timer.scheduledTimer(
                withTimeInterval: 1.0,
                repeats: true
            ) { [weak self] _ in

                guard let self = self else {
                    return
                }

                self.updateElapsedTime()
            }

        // Make timer continue while scrolling/UI is busy.
        RunLoop.main.add(
            timer!,
            forMode: .common
        )

        // Update immediately.
        updateElapsedTime()
    }

    // =====================================================
    // UPDATE ELAPSED TIME
    // =====================================================

    private func updateElapsedTime() {

        guard
            let startDate =
                currentSessionStartDate,
            isStudying
        else {

            return
        }

        elapsedSessionTime =
            max(
                Date().timeIntervalSince(startDate),
                0
            )
    }

    // =====================================================
    // STOP TIMER
    // =====================================================

    private func stopTimer() {

        timer?.invalidate()

        timer = nil
    }

    // =====================================================
    // END STUDY SESSION
    // =====================================================

    func endSession() {

        guard
            var session = activeSession
        else {

            print(
                "⚠️ No active study session."
            )

            return
        }

        // -------------------------------------------------
        // Stop live timer
        // -------------------------------------------------

        stopTimer()

        // -------------------------------------------------
        // End date
        // -------------------------------------------------

        let endDate = Date()

        session.endDate =
            endDate

        // -------------------------------------------------
        // Calculate final duration
        // -------------------------------------------------

        let duration =
            endDate.timeIntervalSince(
                session.startDate
            )

        session.duration =
            max(
                duration,
                0
            )

        // -------------------------------------------------
        // Save completed session
        // -------------------------------------------------

        sessions.insert(
            session,
            at: 0
        )

        saveSessions()

        // -------------------------------------------------
        // Reset active session
        // -------------------------------------------------

        clearActiveSession()

        print("========================================")
        print("✅ STUDY SESSION COMPLETED")
        print(
            "Duration: \(formatDuration(session.duration))"
        )
        print(
            "Flashcards: \(session.flashcardsReviewed)"
        )
        print(
            "Memories: \(session.memoriesStudied)"
        )
        print(
            "Quizzes: \(session.quizzesCompleted)"
        )
        print("========================================")
    }

    // =====================================================
    // CANCEL ACTIVE SESSION
    // =====================================================

    func cancelSession() {

        guard isStudying else {

            return
        }

        stopTimer()

        clearActiveSession()

        print(
            "🛑 Study session cancelled."
        )
    }

    // =====================================================
    // CLEAR ACTIVE SESSION
    // =====================================================

    private func clearActiveSession() {

        activeSession = nil

        currentSessionStartDate = nil

        elapsedSessionTime = 0

        isStudying = false

        stopTimer()
    }

    // =====================================================
    // RECORD FLASHCARD REVIEW
    // =====================================================

    func recordFlashcardReviewed() {

        guard
            var session = activeSession
        else {

            print(
                "⚠️ No active session for flashcard activity."
            )

            return
        }

        session.flashcardsReviewed += 1

        activeSession = session

        print(
            "🧠 Flashcard reviewed: \(session.flashcardsReviewed)"
        )
    }

    // =====================================================
    // RECORD QUIZ COMPLETION
    // =====================================================

    func recordQuizCompleted() {

        guard
            var session = activeSession
        else {

            print(
                "⚠️ No active session for quiz activity."
            )

            return
        }

        session.quizzesCompleted += 1

        activeSession = session

        print(
            "📝 Quiz completed: \(session.quizzesCompleted)"
        )
    }

    // =====================================================
    // RECORD MEMORY STUDIED
    // =====================================================

    func recordMemoryStudied() {

        guard
            var session = activeSession
        else {

            print(
                "⚠️ No active session for memory activity."
            )

            return
        }

        session.memoriesStudied += 1

        activeSession = session

        print(
            "🧠 Memory studied: \(session.memoriesStudied)"
        )
    }

    // =====================================================
    // TOTAL STUDY TIME
    // =====================================================

    var totalStudyTime: TimeInterval {

        sessions.reduce(0) { total, session in

            total + session.duration
        }
    }

    // =====================================================
    // TODAY'S STUDY TIME
    // =====================================================

    var todayStudyTime: TimeInterval {

        let calendar =
            Calendar.current

        return sessions
            .filter { session in

                calendar.isDate(
                    session.startDate,
                    inSameDayAs: Date()
                )
            }
            .reduce(0) { total, session in

                total + session.duration
            }
    }

    // =====================================================
    // TOTAL SESSIONS
    // =====================================================

    var totalSessions: Int {

        sessions.count
    }

    // =====================================================
    // TOTAL FLASHCARDS REVIEWED
    // =====================================================

    var totalFlashcardsReviewed: Int {

        sessions.reduce(0) { total, session in

            total + session.flashcardsReviewed
        }
    }

    // =====================================================
    // TOTAL QUIZZES COMPLETED
    // =====================================================

    var totalQuizzesCompleted: Int {

        sessions.reduce(0) { total, session in

            total + session.quizzesCompleted
        }
    }

    // =====================================================
    // TOTAL MEMORIES STUDIED
    // =====================================================

    var totalMemoriesStudied: Int {

        sessions.reduce(0) { total, session in

            total + session.memoriesStudied
        }
    }

    // =====================================================
    // RECENT SESSIONS
    // =====================================================

    var recentSessions: [StudySession] {

        Array(
            sessions.prefix(5)
        )
    }

    // =====================================================
    // FORMATTED TOTAL STUDY TIME
    // =====================================================

    var formattedTotalStudyTime: String {

        formatDuration(
            totalStudyTime
        )
    }

    // =====================================================
    // FORMATTED TODAY STUDY TIME
    // =====================================================

    var formattedTodayStudyTime: String {

        formatDuration(
            todayStudyTime
        )
    }

    // =====================================================
    // FORMATTED ACTIVE SESSION TIME
    // =====================================================
    // This now reads the @Published timer value.
    // The UI will update every second.
    // =====================================================

    var formattedActiveSessionTime: String {

        let totalSeconds =
            max(
                Int(elapsedSessionTime),
                0
            )

        let hours =
            totalSeconds / 3600

        let minutes =
            (
                totalSeconds % 3600
            ) / 60

        let seconds =
            totalSeconds % 60

        if hours > 0 {

            return String(
                format:
                    "%02d:%02d:%02d",
                hours,
                minutes,
                seconds
            )
        }

        return String(
            format:
                "%02d:%02d",
            minutes,
            seconds
        )
    }

    // =====================================================
    // FORMAT DURATION
    // =====================================================

    func formatDuration(
        _ duration: TimeInterval
    ) -> String {

        let totalSeconds =
            max(
                Int(duration),
                0
            )

        let hours =
            totalSeconds / 3600

        let minutes =
            (
                totalSeconds % 3600
            ) / 60

        let seconds =
            totalSeconds % 60

        if hours > 0 {

            return String(
                format:
                    "%dh %02dm",
                hours,
                minutes
            )
        }

        if minutes > 0 {

            return String(
                format:
                    "%dm %02ds",
                minutes,
                seconds
            )
        }

        return String(
            format:
                "%ds",
            seconds
        )
    }

    // =====================================================
    // SAVE SESSIONS
    // =====================================================

    private func saveSessions() {

        do {

            let data =
                try JSONEncoder().encode(
                    sessions
                )

            UserDefaults.standard.set(
                data,
                forKey:
                    storageKey
            )

            print(
                "💾 Saved \(sessions.count) study sessions."
            )

        } catch {

            print(
                "❌ Could not save study sessions: \(error)"
            )
        }
    }

    // =====================================================
    // LOAD SESSIONS
    // =====================================================

    private func loadSessions() {

        guard
            let data =
                UserDefaults.standard.data(
                    forKey:
                        storageKey
                )
        else {

            sessions = []

            print(
                "ℹ️ No saved study sessions found."
            )

            return
        }

        do {

            sessions =
                try JSONDecoder().decode(
                    [StudySession].self,
                    from:
                        data
                )

            sessions.sort {
                $0.startDate > $1.startDate
            }

            print(
                "✅ Loaded \(sessions.count) study sessions."
            )

        } catch {

            print(
                "❌ Could not load study sessions: \(error)"
            )

            sessions = []
        }
    }

    // =====================================================
    // RESET ALL SESSIONS
    // =====================================================

    func resetAllSessions() {

        stopTimer()

        sessions.removeAll()

        clearActiveSession()

        UserDefaults.standard.removeObject(
            forKey:
                storageKey
        )

        print(
            "🗑️ All study sessions reset."
        )
    }
}

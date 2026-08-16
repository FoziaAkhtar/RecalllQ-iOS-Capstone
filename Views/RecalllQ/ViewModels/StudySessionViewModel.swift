
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
// - Track study duration
// - Track flashcards reviewed
// - Track quizzes completed
// - Track memories studied
// - Save sessions locally
// - Load previous sessions
// - Calculate total study time
// - Calculate today's study time
// - Show recent study activity
// =====================================================

final class StudySessionViewModel: ObservableObject {

    // =====================================================
    // MAIN STATE
    // =====================================================

    @Published var sessions: [StudySession] = []

    // =====================================================
    // ACTIVE SESSION
    // =====================================================

    @Published var activeSession: StudySession?

    // =====================================================
    // TIMER STATE
    // =====================================================

    @Published var isStudying: Bool = false

    @Published var currentSessionStartDate: Date?

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

        let session =
            StudySession(
                startDate: Date()
            )

        activeSession = session

        currentSessionStartDate =
            session.startDate

        isStudying = true

        print("========================================")
        print("📚 STUDY SESSION STARTED")
        print("Start: \(session.startDate)")
        print("========================================")
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
        // End date
        // -------------------------------------------------

        let endDate = Date()

        session.endDate = endDate

        // -------------------------------------------------
        // Calculate duration
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

        activeSession = nil

        currentSessionStartDate = nil

        isStudying = false

        print("========================================")
        print("✅ STUDY SESSION COMPLETED")
        print(
            "Duration: \(formatDuration(session.duration))"
        )
        print("========================================")
    }

    // =====================================================
    // CANCEL ACTIVE SESSION
    // =====================================================

    func cancelSession() {

        activeSession = nil

        currentSessionStartDate = nil

        isStudying = false

        print(
            "🛑 Study session cancelled."
        )
    }

    // =====================================================
    // RECORD FLASHCARD REVIEW
    // =====================================================

    func recordFlashcardReviewed() {

        guard
            var session = activeSession
        else {

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

        sessions.reduce(0) {

            $0 + $1.duration

        }
    }

    // =====================================================
    // TODAY'S STUDY TIME
    // =====================================================

    var todayStudyTime: TimeInterval {

        let calendar =
            Calendar.current

        return sessions
            .filter {

                calendar.isDate(
                    $0.startDate,
                    inSameDayAs: Date()
                )

            }
            .reduce(0) {

                $0 + $1.duration

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

        sessions.reduce(0) {

            $0 + $1.flashcardsReviewed

        }
    }

    // =====================================================
    // TOTAL QUIZZES COMPLETED
    // =====================================================

    var totalQuizzesCompleted: Int {

        sessions.reduce(0) {

            $0 + $1.quizzesCompleted

        }
    }

    // =====================================================
    // TOTAL MEMORIES STUDIED
    // =====================================================

    var totalMemoriesStudied: Int {

        sessions.reduce(0) {

            $0 + $1.memoriesStudied

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
    // FORMAT DURATION
    // =====================================================

    func formatDuration(
        _ duration: TimeInterval
    ) -> String {

        let totalSeconds =
            Int(
                max(
                    duration,
                    0
                )
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

        sessions.removeAll()

        activeSession = nil

        currentSessionStartDate = nil

        isStudying = false

        UserDefaults.standard.removeObject(
            forKey:
                storageKey
        )

        print(
            "🗑️ All study sessions reset."
        )
    }
}


import Foundation
import Combine

// =====================================================
// VIEWMODEL: StudySessionViewModel
// =====================================================
// PURPOSE:
// Manages personalized study sessions for RecalllQ.
//
// USER DATA ISOLATION:
// Each authenticated user gets their own:
//
// - Study sessions
// - Study time
// - Flashcard activity
// - Quiz activity
// - Memory activity
//
// STORAGE FORMAT:
//
// recallq_study_sessions_<userID>
//
// Example:
//
// recallq_study_sessions_student1@gmail.com
// recallq_study_sessions_student2@gmail.com
//
// =====================================================

@MainActor
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

    @Published private(set) var elapsedSessionTime: TimeInterval = 0

    private var timer: Timer?

    // =====================================================
    // CURRENT USER
    // =====================================================

    // This is the authenticated user's unique identifier.
    //
    // AppState uses the normalized email as the local ID.
    // =====================================================

    private(set) var currentUserID: String?

    // =====================================================
    // STORAGE
    // =====================================================

    private let storagePrefix = "recallq_study_sessions"

    // =====================================================
    // INIT
    // =====================================================

    init() {
        // -------------------------------------------------
        // IMPORTANT:
        //
        // Do NOT automatically load another user's data.
        //
        // AppState will call:
        //
        //     switchUser(to: userID)
        //
        // after successful login.
        // -------------------------------------------------

        sessions = []

        print("ℹ️ StudySessionViewModel initialized.")
        print("🔐 Waiting for authenticated user.")
    }

    // =====================================================
    // DEINIT
    // =====================================================

    deinit {
        timer?.invalidate()
        timer = nil
    }

    // =====================================================
    // NORMALIZE USER ID
    // =====================================================

    private func normalizeUserID(_ userID: String) -> String {

        userID
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            .lowercased()
    }

    // =====================================================
    // USER-SPECIFIC STORAGE KEY
    // =====================================================

    private func storageKey(for userID: String) -> String {

        let cleanUserID = normalizeUserID(userID)

        // -------------------------------------------------
        // Encode the user ID so the storage key is safe.
        // -------------------------------------------------

        let encodedUserID = cleanUserID
            .data(using: .utf8)?
            .base64EncodedString()
            .replacingOccurrences(
                of: "=",
                with: ""
            )
            .replacingOccurrences(
                of: "/",
                with: "_"
            )
            .replacingOccurrences(
                of: "+",
                with: "-"
            )
            ?? cleanUserID

        return "\(storagePrefix)_\(encodedUserID)"
    }

    // =====================================================
    // SWITCH USER
    // =====================================================
    //
    // Called by AppState after authentication.
    //
    // IMPORTANT:
    //
    // User A's data is cleared from memory first.
    // Then User B's data is loaded.
    //
    // =====================================================

    func switchUser(to userID: String) {

        let cleanUserID = normalizeUserID(userID)

        guard !cleanUserID.isEmpty else {

            print(
                "❌ StudySessionViewModel: Cannot switch to empty user ID."
            )

            clearCurrentUserData()

            currentUserID = nil

            return
        }

        // -------------------------------------------------
        // If the same user is already active, do not reload.
        // -------------------------------------------------

        if currentUserID == cleanUserID {

            print(
                "ℹ️ Study sessions already loaded for \(cleanUserID)."
            )

            return
        }

        // -------------------------------------------------
        // Stop any previous user's active session.
        // -------------------------------------------------

        stopTimer()

        clearActiveSession()

        // -------------------------------------------------
        // IMPORTANT:
        //
        // Remove previous user's sessions from RAM.
        // -------------------------------------------------

        sessions.removeAll()

        // -------------------------------------------------
        // Set new user.
        // -------------------------------------------------

        currentUserID = cleanUserID

        // -------------------------------------------------
        // Load ONLY this user's sessions.
        // -------------------------------------------------

        loadSessions()

        print("========================================")
        print("🔐 STUDY SESSION USER SWITCH")
        print("========================================")
        print("👤 Current user: \(cleanUserID)")
        print("📚 Sessions loaded: \(sessions.count)")
        print("========================================")
    }

    // =====================================================
    // CLEAR CURRENT USER DATA FROM MEMORY
    // =====================================================
    //
    // IMPORTANT:
    //
    // This does NOT delete the saved user's data.
    //
    // It only removes it from the active ViewModel.
    //
    // This is used during logout/user switching.
    //
    // =====================================================

    func clearCurrentUserData() {

        stopTimer()

        clearActiveSession()

        sessions.removeAll()

        print(
            "🧹 Study sessions removed from active memory."
        )
    }

    // =====================================================
    // SAVE
    // =====================================================
    //
    // Public wrapper used by AppState.
    //
    // =====================================================

    func save() {
        saveSessions()
    }

    // =====================================================
    // START STUDY SESSION
    // =====================================================

    func startSession() {

        // -------------------------------------------------
        // Require authenticated user.
        // -------------------------------------------------

        guard let userID = currentUserID,
              !userID.isEmpty else {

            print(
                "❌ Cannot start study session: no authenticated user."
            )

            return
        }

        // -------------------------------------------------
        // Prevent multiple active sessions.
        // -------------------------------------------------

        guard !isStudying else {

            print(
                "⚠️ A study session is already active."
            )

            return
        }

        let startDate = Date()

        let session = StudySession(
            startDate: startDate
        )

        activeSession = session

        currentSessionStartDate = startDate

        elapsedSessionTime = 0

        isStudying = true

        // -------------------------------------------------
        // Start live timer.
        // -------------------------------------------------

        startTimer()

        print("========================================")
        print("📚 STUDY SESSION STARTED")
        print("========================================")
        print("👤 User: \(userID)")
        print("Start: \(startDate)")
        print("========================================")
    }

    // =====================================================
    // START TIMER
    // =====================================================

    private func startTimer() {

        stopTimer()

        timer = Timer.scheduledTimer(
            withTimeInterval: 1.0,
            repeats: true
        ) { [weak self] _ in

            guard let self = self else {
                return
            }

            Task { @MainActor in
                self.updateElapsedTime()
            }
        }

        if let timer = timer {

            RunLoop.main.add(
                timer,
                forMode: .common
            )
        }

        updateElapsedTime()
    }

    // =====================================================
    // UPDATE ELAPSED TIME
    // =====================================================

    private func updateElapsedTime() {

        guard
            let startDate = currentSessionStartDate,
            isStudying
        else {
            return
        }

        elapsedSessionTime = max(
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

        guard let userID = currentUserID,
              !userID.isEmpty else {

            print(
                "❌ Cannot end study session: no authenticated user."
            )

            return
        }

        guard var session = activeSession else {

            print(
                "⚠️ No active study session."
            )

            return
        }

        // -------------------------------------------------
        // Stop live timer.
        // -------------------------------------------------

        stopTimer()

        // -------------------------------------------------
        // End date.
        // -------------------------------------------------

        let endDate = Date()

        session.endDate = endDate

        // -------------------------------------------------
        // Calculate final duration.
        // -------------------------------------------------

        let duration =
            endDate.timeIntervalSince(
                session.startDate
            )

        session.duration = max(
            duration,
            0
        )

        // -------------------------------------------------
        // Save completed session.
        // -------------------------------------------------

        sessions.insert(
            session,
            at: 0
        )

        saveSessions()

        // -------------------------------------------------
        // Reset active session.
        // -------------------------------------------------

        clearActiveSession()

        print("========================================")
        print("✅ STUDY SESSION COMPLETED")
        print("========================================")
        print("👤 User: \(userID)")
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

        guard var session = activeSession else {

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

        guard var session = activeSession else {

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

        guard var session = activeSession else {

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

        let calendar = Calendar.current

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

        // -------------------------------------------------
        // Never save data without a user.
        // -------------------------------------------------

        guard let userID = currentUserID,
              !userID.isEmpty else {

            print(
                "⚠️ Study sessions were not saved because no user is active."
            )

            return
        }

        let key = storageKey(
            for: userID
        )

        do {

            let data =
                try JSONEncoder().encode(
                    sessions
                )

            UserDefaults.standard.set(
                data,
                forKey: key
            )

            print(
                "💾 Saved \(sessions.count) study sessions for \(userID)."
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

        // -------------------------------------------------
        // Never load data without a user.
        // -------------------------------------------------

        guard let userID = currentUserID,
              !userID.isEmpty else {

            sessions = []

            return
        }

        let key = storageKey(
            for: userID
        )

        guard
            let data =
                UserDefaults.standard.data(
                    forKey: key
                )
        else {

            sessions = []

            print(
                "ℹ️ No saved study sessions for \(userID)."
            )

            return
        }

        do {

            sessions =
                try JSONDecoder().decode(
                    [StudySession].self,
                    from: data
                )

            sessions.sort {
                $0.startDate > $1.startDate
            }

            print(
                "✅ Loaded \(sessions.count) study sessions for \(userID)."
            )

        } catch {

            print(
                "❌ Could not load study sessions: \(error)"
            )

            sessions = []
        }
    }

    // =====================================================
    // RESET CURRENT USER'S SESSIONS
    // =====================================================
    //
    // Deletes ONLY the currently authenticated user's
    // saved study history.
    //
    // =====================================================

    func resetAllSessions() {

        guard let userID = currentUserID,
              !userID.isEmpty else {

            print(
                "❌ Cannot reset sessions: no authenticated user."
            )

            return
        }

        stopTimer()

        sessions.removeAll()

        clearActiveSession()

        let key = storageKey(
            for: userID
        )

        UserDefaults.standard.removeObject(
            forKey: key
        )

        print("========================================")
        print("🗑️ STUDY HISTORY RESET")
        print("========================================")
        print("👤 User: \(userID)")
        print("========================================")
    }
}

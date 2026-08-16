
import Foundation

// =====================================================
// MODEL: StudySession
// =====================================================
// PURPOSE:
// Represents one personalized study session in RecalllQ.
//
// Tracks:
// - When the session started
// - When the session ended
// - Study duration
// - Flashcards reviewed
// - Quizzes completed
// - Memories studied
// =====================================================

struct StudySession: Identifiable, Codable, Equatable {

    // =====================================================
    // IDENTITY
    // =====================================================

    var id: UUID = UUID()

    // =====================================================
    // SESSION DATES
    // =====================================================

    var startDate: Date

    var endDate: Date?

    // =====================================================
    // SESSION DURATION
    // =====================================================

    var duration: TimeInterval = 0

    // =====================================================
    // LEARNING ACTIVITY
    // =====================================================

    var flashcardsReviewed: Int = 0

    var quizzesCompleted: Int = 0

    var memoriesStudied: Int = 0

    // =====================================================
    // INITIALIZER
    // =====================================================

    init(
        id: UUID = UUID(),
        startDate: Date = Date(),
        endDate: Date? = nil,
        duration: TimeInterval = 0,
        flashcardsReviewed: Int = 0,
        quizzesCompleted: Int = 0,
        memoriesStudied: Int = 0
    ) {

        self.id = id

        self.startDate = startDate

        self.endDate = endDate

        self.duration = duration

        self.flashcardsReviewed =
            flashcardsReviewed

        self.quizzesCompleted =
            quizzesCompleted

        self.memoriesStudied =
            memoriesStudied
    }

    // =====================================================
    // FORMATTED DATE
    // =====================================================

    var formattedDate: String {

        let formatter =
            DateFormatter()

        formatter.dateStyle = .medium

        formatter.timeStyle = .short

        return formatter.string(
            from: startDate
        )
    }

    // =====================================================
    // FORMATTED DURATION
    // =====================================================

    var formattedDuration: String {

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

            return "\(hours)h \(minutes)m"

        } else if minutes > 0 {

            return "\(minutes)m \(seconds)s"

        } else {

            return "\(seconds)s"
        }
    }

    // =====================================================
    // ACTIVITY SUMMARY
    // =====================================================

    var activitySummary: String {

        var activities: [String] = []

        if memoriesStudied > 0 {

            activities.append(
                "\(memoriesStudied) memories"
            )
        }

        if flashcardsReviewed > 0 {

            activities.append(
                "\(flashcardsReviewed) flashcards"
            )
        }

        if quizzesCompleted > 0 {

            activities.append(
                "\(quizzesCompleted) quizzes"
            )
        }

        if activities.isEmpty {

            return "No learning activity recorded."

        }

        return activities.joined(
            separator: " • "
        )
    }

    // =====================================================
    // IS COMPLETED
    // =====================================================

    var isCompleted: Bool {

        endDate != nil
    }
}

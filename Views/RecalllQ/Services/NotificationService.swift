
import Foundation
import UserNotifications

// =====================================================
// SERVICE: NotificationService
// =====================================================
// PURPOSE:
// Handles local iOS notifications (reminders)
// Used for notes + memory alerts
// =====================================================

final class NotificationService {

    // =====================================================
    // REQUEST PERMISSION
    // =====================================================
    func requestPermission() {

        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in

            DispatchQueue.main.async {

                if let error = error {
                    print("❌ Notification permission error:", error.localizedDescription)
                    return
                }

                print(granted
                      ? "✅ Notification permission granted"
                      : "⚠️ Notification permission denied")
            }
        }
    }

    // =====================================================
    // SCHEDULE NOTIFICATION
    // =====================================================
    func scheduleNotification(
        id: String = UUID().uuidString,
        title: String,
        body: String,
        date: Date
    ) {

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: date
            ),
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: id,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in

            if let error = error {
                print("❌ Schedule notification error:", error.localizedDescription)
            } else {
                print("✅ Notification scheduled for \(date)")
            }
        }
    }

    // =====================================================
    // CANCEL NOTIFICATION
    // =====================================================
    func cancelNotification(id: String) {

        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [id])

        print("🗑️ Cancelled notification: \(id)")
    }
}

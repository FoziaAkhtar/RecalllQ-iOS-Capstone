
import Foundation
import UserNotifications

// =====================================================
// SERVICE: NotificationService 
// =====================================================
// PURPOSE:
// Handles local iOS notifications (reminders)
// Used for memory reminders and productivity alerts
// =====================================================

final class NotificationService {

    // =====================================================
    // REQUEST NOTIFICATION PERMISSION
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

                if granted {
                    print("✅ Notification permission granted")
                } else {
                    print("⚠️ Notification permission denied")
                }
            }
        }
    }

    // =====================================================
    // SCHEDULE NOTIFICATION
    // =====================================================
    func scheduleNotification(
        title: String,
        body: String,
        date: Date
    ) {

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: date
        )

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: false
        )

        let identifier = UUID().uuidString

        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in

            DispatchQueue.main.async {

                if let error = error {
                    print("❌ Failed to schedule notification:", error.localizedDescription)
                } else {
                    print("✅ Notification scheduled successfully at \(date)")
                }
            }
        }
    }
}


import Foundation
import UserNotifications

// =====================================================
// SERVICE: NotificationService
// =====================================================
// PURPOSE:
// Handles local iOS notifications for RecalllQ.
//
// FEATURES:
// - Requests notification permission
// - Checks current permission status
// - Schedules reminders
// - Cancels reminders
// =====================================================

final class NotificationService {

    // =====================================================
    // REQUEST PERMISSION
    // =====================================================

    func requestPermission() {

        UNUserNotificationCenter.current()
            .requestAuthorization(
                options: [
                    .alert,
                    .sound,
                    .badge
                ]
            ) { granted, error in

                DispatchQueue.main.async {

                    if let error = error {

                        print(
                            "❌ Notification permission error:",
                            error.localizedDescription
                        )

                        return
                    }

                    if granted {

                        print(
                            "✅ Notification permission granted"
                        )

                    } else {

                        print(
                            "⚠️ Notification permission denied"
                        )
                    }
                }
            }
    }

    // =====================================================
    // CHECK PERMISSION
    // =====================================================

    func checkPermission(
        completion: @escaping (Bool) -> Void
    ) {

        UNUserNotificationCenter.current()
            .getNotificationSettings { settings in

                DispatchQueue.main.async {

                    completion(
                        settings.authorizationStatus == .authorized
                    )
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

        // -------------------------------------------------
        // DO NOT SCHEDULE PAST DATES
        // -------------------------------------------------

        guard date > Date() else {

            print(
                "⚠️ Reminder date must be in the future."
            )

            return
        }

        // -------------------------------------------------
        // NOTIFICATION CONTENT
        // -------------------------------------------------

        let content =
            UNMutableNotificationContent()

        content.title = title
        content.body = body
        content.sound = .default
        content.badge = 1

        // -------------------------------------------------
        // DATE COMPONENTS
        // -------------------------------------------------

        let components =
            Calendar.current.dateComponents(
                [
                    .year,
                    .month,
                    .day,
                    .hour,
                    .minute
                ],
                from: date
            )

        // -------------------------------------------------
        // CREATE TRIGGER
        // -------------------------------------------------

        let trigger =
            UNCalendarNotificationTrigger(
                dateMatching: components,
                repeats: false
            )

        // -------------------------------------------------
        // CREATE REQUEST
        // -------------------------------------------------

        let request =
            UNNotificationRequest(
                identifier: id,
                content: content,
                trigger: trigger
            )

        // -------------------------------------------------
        // ADD REQUEST
        // -------------------------------------------------

        UNUserNotificationCenter.current()
            .add(request) { error in

                DispatchQueue.main.async {

                    if let error = error {

                        print(
                            "❌ Schedule notification error:",
                            error.localizedDescription
                        )

                    } else {

                        print(
                            "✅ Reminder scheduled for \(date)"
                        )
                    }
                }
            }
    }

    // =====================================================
    // CANCEL NOTIFICATION
    // =====================================================

    func cancelNotification(
        id: String
    ) {

        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(
                withIdentifiers: [id]
            )

        print(
            "🗑️ Cancelled notification: \(id)"
        )
    }

    // =====================================================
    // SHOW PENDING REMINDERS
    // =====================================================

    func printPendingNotifications() {

        UNUserNotificationCenter.current()
            .getPendingNotificationRequests { requests in

                print(
                    "🔔 Pending reminders: \(requests.count)"
                )

                for request in requests {

                    print(
                        "➡️ \(request.identifier)"
                    )
                }
            }
    }
}

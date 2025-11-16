import Foundation
import UserNotifications

/// Manages local notifications for reminders and triggers
class NotificationManager {
    static let shared = NotificationManager()

    private init() {}

    /// Request notification permissions
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            print("Error requesting notification authorization: \(error)")
            return false
        }
    }

    /// Schedule daily reminder notification
    func scheduleDailyReminder(at hour: Int, minute: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Time to check in"
        content.body = "How was your day?"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(
            identifier: "daily-reminder",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling daily reminder: \(error)")
            }
        }
    }

    /// Send immediate notification for trigger
    func sendTriggerNotification(title: String, message: String, identifier: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        content.sound = .default
        content.categoryIdentifier = "trigger"

        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: nil // Send immediately
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error sending trigger notification: \(error)")
            }
        }
    }

    /// Send weekly report notification
    func sendWeeklyReport() {
        let content = UNMutableNotificationContent()
        content.title = "Your week in review"
        content.body = "Your weekly mood report is ready"
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "weekly-report-\(Date().timeIntervalSince1970)",
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error sending weekly report: \(error)")
            }
        }
    }

    /// Cancel daily reminder
    func cancelDailyReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["daily-reminder"])
    }

    /// Cancel all notifications
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    /// Check current notification settings
    func checkAuthorizationStatus() async -> UNAuthorizationStatus {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus
    }
}

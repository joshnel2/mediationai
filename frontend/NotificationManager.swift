import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    private init() {
        // Request permission at launch
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound,.badge]) { _, _ in }
    }

    func scheduleUpdate(for disputeID:String, title:String){
        let content = UNMutableNotificationContent()
        content.title = "Crashout Update"
        content.body = title
        content.sound = UNNotificationSound.default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "update_\(disputeID)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}
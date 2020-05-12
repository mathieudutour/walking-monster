//
//  Redux+notifications.swift
//  The Walking Monster
//
//  Created by Mathieu Dutour on 12/05/2020.
//  Copyright © 2020 Mathieu Dutour. All rights reserved.
//

import UIKit

extension Redux: UNUserNotificationCenterDelegate {
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    completionHandler([.alert, .badge, .sound])
  }

  static func requestNotifications(complete: @escaping (_ error: Error?) -> Void) {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .alert]) { granted, error in
      if granted == true && error == nil {
        UIApplication.shared.registerForRemoteNotifications()
      }
      complete(error)
    }
  }

  static func sendNotification(identifier: String, title: String) {
    let center = UNUserNotificationCenter.current()
    center.getNotificationSettings { settings in
        switch settings.authorizationStatus {
        case .notDetermined:
            break
        case .authorized, .provisional:
            let content = UNMutableNotificationContent()
            content.title = title

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

            center.add(request) { error in
              guard error == nil else {
                print(error!)
                return
              }
              print("Scheduling notification with id: \(identifier)")
            }
        default:
            break
        }
    }
  }
}

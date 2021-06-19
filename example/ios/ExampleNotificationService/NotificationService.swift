//
//  NotificationService.swift
//  ExampleNotificationService
//

import UserNotifications
import ExponeaSDK_Notifications

class NotificationService: UNNotificationServiceExtension {
  let exponeaService = ExponeaNotificationService(
      appGroup: "group.com.exponea.ExponeaSDK-Example2"
  )

  override func didReceive(
      _ request: UNNotificationRequest,
      withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void
  ) {
      exponeaService.process(request: request, contentHandler: contentHandler)
  }

  override func serviceExtensionTimeWillExpire() {
      exponeaService.serviceExtensionTimeWillExpire()
  }
}

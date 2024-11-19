//
//  ViewController.swift
//  Project-21-Notification
//
//  Created by Serhii Prysiazhnyi on 19.11.2024.
//

import UIKit
import UserNotifications

class ViewController: UIViewController, UNUserNotificationCenterDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Register", style: .plain, target: self, action: #selector(registerLocal))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Schedule", style: .plain, target: self, action: #selector(scheduleBoth))
        
        registerCategories()
    }
    
    @objc func registerLocal() {
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Yay!")
            } else {
                print("D'oh")
            }
        }
    }
    
    @objc func scheduleBoth() {
        scheduleLocal(timeInterval: 5)
        scheduleLocalPeapet(timeInterval: 7)
    }
    
    //         PUSH #1
    func scheduleLocal(timeInterval: TimeInterval) {
        let center = UNUserNotificationCenter.current()
        
        let content = createNotificationContent(title: "Late wake up call", body: "The early bird catches the worm, but the second mouse gets the cheese.", categoryIdentifier: "alarm")
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
        print("Push #1")
    }
    
    //         PUSH #2
    @objc func scheduleLocalPeapet(timeInterval: Int) {
        let center = UNUserNotificationCenter.current()
        
        let content = createNotificationContent(title: "Это TITLE отложенного сообщения", body: "Это BODY отложенного сообщения. Если выберешь отложить, то сообщение придет через 10 сек", categoryIdentifier: "alarmSchedul")
        
        let triggerTimeInterval: TimeInterval = TimeInterval(timeInterval)
        let triggerSchedul = UNTimeIntervalNotificationTrigger(timeInterval: triggerTimeInterval, repeats: false)
        
        let requestSchedul = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: triggerSchedul)
        center.add(requestSchedul)
        print("Push #2")
    }
    
    // Создание контента для уведомлений
    func createNotificationContent(title: String, body: String, categoryIdentifier: String) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.categoryIdentifier = categoryIdentifier
        content.userInfo = ["customData": "fizzbuzz"]
        content.sound = UNNotificationSound.default
        return content
    }
    
    func registerCategories() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        let show = UNNotificationAction(identifier: "show", title: "Tell me more…", options: .foreground)
        let category = UNNotificationCategory(identifier: "alarm", actions: [show], intentIdentifiers: [])
        
        center.setNotificationCategories([category])
        print("in push")
        let showMy = UNNotificationAction(identifier: "showMy", title: "Открыть подробнее", options: .foreground)
        let categoryMy = UNNotificationCategory(identifier: "alarmSchedul", actions: [showMy], intentIdentifiers: [])
        
        center.setNotificationCategories([categoryMy])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        let userInfo = response.notification.request.content.userInfo
        
        switch response.notification.request.content.categoryIdentifier {
        case "alarm":
            handleNotificationResponse(response, userInfo: userInfo, completionHandler: completionHandler)
        case "alarmSchedul":
            handleSchedulNotificationResponse(response, userInfo: userInfo, completionHandler: completionHandler)
        default:
            completionHandler()
        }
    }
    
    // Обработка ответа на первое уведомление
    private func handleNotificationResponse(_ response: UNNotificationResponse, userInfo: [AnyHashable: Any], completionHandler: @escaping () -> Void) {
        var alertTitle = ""
        var alertMessage = ""
        
        switch response.actionIdentifier {
        case UNNotificationDefaultActionIdentifier:
            alertTitle = "Default Action"
            alertMessage = "Вы просто нажали на уведомление."
        case "show":
            alertTitle = "Show More Info"
            alertMessage = "Вы выбрали действие 'Показать больше информации'."
        default:
            alertTitle = "Unknown Action"
            alertMessage = "Выбрано неизвестное действие."
        }
        
        
        
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
            // Удаление всех доставленных уведомлений (включая второе)
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        }))
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(alert, animated: true)
        }
        completionHandler()
    }
    
    // Обработка ответа на отложенное уведомление
    private func handleSchedulNotificationResponse(_ response: UNNotificationResponse, userInfo: [AnyHashable: Any], completionHandler: @escaping () -> Void) {
        let alertTitle = "Выберите действие!"
        let alertMessage = "Отложить на 10 сек или отменить"
        
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
            //               completionHandler()
            self.scheduleLocalPeapet(timeInterval: 10)
            print("Сообщение отложено")
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { _ in
            //               completionHandler()
            print("Сброс непрочитанных сообщений")
        }))
        
        // Удаление всех доставленных уведомлений (включая второе)
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(alert, animated: true)
        }
        completionHandler()
    }
}

// для отображения push при активном приложении

extension ViewController {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Здесь вы определяете, как будет отображаться уведомление, пока приложение активно
        completionHandler([.banner, .sound])
        
    }
}

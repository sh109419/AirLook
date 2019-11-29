//
//  AppDelegate.swift
//  AirAlert
//
//  Created by hyf on 2018/8/15.
//  Copyright © 2018年 Deng Junqiang. All rights reserved.
//

import UIKit
import UserNotifications
import os.log

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    static let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "AppDelegate")
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // set app language
        
        // after install this app, set language as system language, default is English
        if Settings.sharedInstance.NoAppLanguage() {
            // get phone language
            //用户在手机系统设置里设置的语言。返回一个数组: ["zh-Hans-CN", “en"]
            let appLanguages = Locale.preferredLanguages
            var phoneLanguage = "en"
            if appLanguages.count > 0 {
                phoneLanguage = appLanguages[0]
                if phoneLanguage.hasPrefix("zh-Hans") {
                    phoneLanguage = "zh-Hans"
                }
            }
            
            Settings.sharedInstance.initAppLanguage(languageDef: phoneLanguage)
        
        } else {
            // set app language according to UserDefault.Setting
            Settings.sharedInstance.setAppLanguage()
        }
        
        //Request Authorization at Launch Time 请求权限
        requestNotificationAuthorization()
        
        //turn on user notifications  设置通知代理
        UNUserNotificationCenter.current().delegate = self
    
        //向APNs请求token
        if Settings.sharedInstance.NoDeviceToken() {
            UIApplication.shared.registerForRemoteNotifications()
        }
        
        return true
    }

    //token请求回调
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        //将Data转换为String
        var tokenStr: String = ""
        for i in 0 ..< deviceToken.count{
            tokenStr += String(format: "%02.2hhx", arguments: [deviceToken[i]])
        }
        
        print("tokenString: ", tokenStr)
        //tokenString:  e3d734d52e3ddb02de65cb6f8440c5a2cdb9cc2fc69261d6bd1a45424a69ab1a
        Settings.sharedInstance.deviceToken = tokenStr
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error)
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // do it here because  there is no guarantee that applicationWillTerminate: will ever get called.
        os_log("applicationDidEnterBackground", log: AppDelegate.log)
        if airData != nil {
            airData?.Save()
            Settings.sharedInstance.stationID = (airData?.idx)!
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
}

// MARK: - UNUserNotificationCenterDelegate

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    private func syncData(data: Any) {
        if let returnData = try? JSONSerialization.data(withJSONObject: data),
            let test = try? JSONDecoder().decode(AirData.self, from: returnData) {
            airData = test
            //print(test)
            if let view = self.window?.rootViewController?.children.first as? RootViewController {
                if view.isViewLoaded {
                    view.refreshUI() }
            }
        }
    }
    
    // run if app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        os_log("willPresent %{public}@", log: AppDelegate.log, notification.request.content.body)
        
        let data = notification.request.content.userInfo["data"]
        syncData(data: data as Any)
    
       // completionHandler(.alert)
    }
    
    // run after clicking the popup notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        os_log("didReceive %{public}@", log: AppDelegate.log, response.notification.request.content.body)
        
        let data = response.notification.request.content.userInfo["data"]
        syncData(data: data as Any)
        
        completionHandler()
    }
}

// MARK: - Various utility methods

extension AppDelegate {
    
    private func requestNotificationAuthorization() {
        // Request permission to display alerts and play sounds.
        UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .alert]) { granted, error in
            if !granted {
                // check if notifications are enabled
                // Either denied or notDetermined
                let alertController = UIAlertController(
                    title: "Enable notifications?".localized,
                    message: "Only air pollution notifications be pushed.".localized,
                    preferredStyle: .alert)
                let settingsAction = UIAlertAction(
                    title: "Settings".localized,  style: .default) { (_) -> Void in
                    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                        return
                    }
                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        })
                    }
                }
                let cancelAction = UIAlertAction(
                    title: "Cancel".localized, style: .default, handler: nil)
                alertController.addAction(cancelAction)
                alertController.addAction(settingsAction)
                DispatchQueue.main.async {
                    self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
}



//
//  AppDelegate.swift
//  Holliston High School
//
//  Created by Thomas Reeve on 11/20/17.
//  Copyright © 2017 Tom Reeve. All rights reserved.
//

import UIKit
import UserNotifications

import Firebase
import FirebaseMessaging

import SWRevealViewController

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"

    /**
     Runs after the app has launched. This is the "beginning point" of the app
     */
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        /* sets up Firebase Cloud Messaging system, to allow for automatic notifications of new
            news posts, and manual notifications when desired
            */
        // set up Firebase Cloud Messaging
        FirebaseApp.configure()
        
        // set this AppDelegate instance as the messaging delegate (receiver)
        Messaging.messaging().delegate = self as MessagingDelegate
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions, completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        application.registerForRemoteNotifications()
        /* END Firebase setup */
    
        return true
    }

    /**
    This is set up to attach the cloud messaging to the app when in the foreground
     */
    func applicationWillEnterForeground(_ application: UIApplication) {
        if let rootViewController = self.window?.rootViewController as? RevealViewController {
            rootViewController.refreshData()
        }
        
        Messaging.messaging().shouldEstablishDirectChannel = true
    }
    

    /**
    This runs with a remote (cloud) notification comes in
     */
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        if let messageId = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageId)")
        }
        //print full message
        print(userInfo)

        if let update = userInfo["update_data"] {
            let updateVal = update as! String
            if let revealViewController = self.window?.rootViewController as? RevealViewController {
                    revealViewController.refreshArticleStore(name: updateVal)
                }
        }
        
        if let title = userInfo["title"] {
            let titleVal = title as! String
            if let rootViewController = self.window?.rootViewController as? RevealViewController {
                let index = rootViewController.newsArticleIndexFor(headline: titleVal)
                if index >= 0 {
                    rootViewController.showNewsArticle(index: index)
                }
            }
        }
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
}

//Firebase Cloud Messaging code
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    //Receive displayed notifications for iOS 10 devices
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping(UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        // With sqizzling disabled you must let Mesaging know about the mesage, for Analytics
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        //Print message ID
        print(userInfo)
        
        // Chang this to your preferred presentation option
        completionHandler([])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        //Print message ID
        print(userInfo)
        
        // Change this to your preferred presentation option
        completionHandler()
    }
}
// END of iOS 10 message handling


extension AppDelegate : MessagingDelegate {
    // START refresh token
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        let token = Messaging.messaging().fcmToken
        print("Firebase registration token: \(token ?? "")")
        
        Messaging.messaging().subscribe(toTopic: "news")
        Messaging.messaging().subscribe(toTopic: "updates")
        #if DEBUG
            Messaging.messaging().subscribe(toTopic: "debug")
        #else
            Messaging.messaging().unsubscribe(fromTopic: "debug")
        #endif
    }
    
    //START ios 10 data message
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Receieved data message: \(remoteMessage.appData)")
    }
    // END iOS 10 data message
}

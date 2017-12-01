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

    // runs after the app has launched. This is the "beginning point" of the app
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
    
    func applicationWillEnterForeground(application: UIApplication) {
        if let rootViewController = self.window?.rootViewController as? RevealViewController {
            rootViewController.refreshData()
        }
        
        Messaging.messaging().shouldEstablishDirectChannel = true
    }
    

    // this runs with a remote (cloud) notification comes in
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let messageId = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageId)")
        }
        //print full message
        print(userInfo)

        if let update = userInfo["update_data"] {
            let updateVal = update as! String
            if updateVal == "news" {
                if let revealViewController = self.window?.rootViewController as? RevealViewController {
                    revealViewController.refreshData()
                }
            }
        }
        
        if let aps = userInfo["aps" as String] as? [String: AnyObject] {
            if let alert = aps["alert"] as? [String: String] {
                if let body = alert["body"] {
                    if let rootViewController = self.window?.rootViewController as? RevealViewController {
                        let index = rootViewController.newsArticleIndexFor(headline: body)
                        if index >= 0 {
                            rootViewController.showNewsArticle(index: index)
                        }
                    }
                }
            }
        }
        
        completionHandler(UIBackgroundFetchResult.newData)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
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
        //Messaging.messaging().subscribe(toTopic: "debug")
    }
    
    //START ios 10 data message
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Receieved data message: \(remoteMessage.appData)")
    }
    // END iOS 10 data message
}

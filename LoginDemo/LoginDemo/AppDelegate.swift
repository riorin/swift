//
//  AppDelegate.swift
//  LoginDemo
//
//  Created by Bayu Yasaputro on 02/04/18.
//  Copyright © 2018 DyCode. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications

enum ContentType: String {
    case movie = "movie"
    case news = "news"
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    // MARK: - Lifecycle
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Use Firebase library to configure APIs
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        }
        else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        if let sessionId = UserDefaults.standard.value(forKey: kSessionIdKey) as? String, !sessionId.isEmpty {
            showMainViewController()
        }
        
        return true
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

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        let urlString = url.absoluteString
        if urlString.contains("dymovies://") {
            if let pathString = urlString.components(separatedBy: "dymovies://").last {
                let data = pathString.components(separatedBy: "/")
                let type = data[0]
                let id = data[1]
                
                let dict = [
                    "type": type,
                    "id": id
                ]
                
                handlePushNotification(with: dict)
            }
        }
        
        return true
    }
    
    // MARK: - Helpers
    
    
    func setRootViewController(_ viewController: UIViewController) {
        
        UIView.transition(with: window!, duration: 0.3, options: [.transitionCrossDissolve, .allowAnimatedContent], animations: { () -> Void in
            
            let oldState = UIView.areAnimationsEnabled
            
            UIView.setAnimationsEnabled(false)
            self.window?.rootViewController = viewController
            UIView.setAnimationsEnabled(oldState)
            
        }, completion: nil)
    }
    
    func showMainViewController() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "rootHome")
        
        setRootViewController(vc)
    }
    
    func showLoginViewController() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "rootLogin")
        
        setRootViewController(vc)
    }
    
    func handlePushNotification(with userInfo: [AnyHashable: Any]) {
        
        if let type = userInfo["type"] as? String, let contentType = ContentType(rawValue: type) {
            
            switch contentType {
            case .movie:
                if let idString = userInfo["id"] as? String, let movieId = Int(idString) {
                 
                    if UIApplication.shared.applicationState != .active {
                        
                        if let nc = window?.rootViewController as? UINavigationController {
                            nc.viewControllers.last?.showMovieViewController(with: movieId)
                        }
                        else {
                            
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let vc = storyboard.instantiateViewController(withIdentifier: "movie") as! MovieViewController
                            vc.movieId = movieId
                            
                            let nc = UINavigationController(rootViewController: vc)
                            window?.rootViewController?.present(nc, animated: true, completion: nil)
                        }
                    }
                }
                
            case .news:
                break
            }
            
        }
    }
    
    // MARK: - Notifications
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        if application.applicationState == .inactive {
            handlePushNotification(with: userInfo)
        }
        completionHandler(.newData)
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        handlePushNotification(with: userInfo)
        completionHandler()
    }
}

// MARK: - MessagingDelegate
extension AppDelegate: MessagingDelegate {

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("*** FCM toke: \(fcmToken)")
    }
}







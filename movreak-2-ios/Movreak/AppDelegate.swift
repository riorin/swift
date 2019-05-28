//
//  AppDelegate.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 8/19/16.
//  Copyright © 2016 DyCode. All rights reserved.
//

import UIKit
import Firebase
import GooglePlaces
import GoogleMaps
import UserNotifications
import FacebookCore
import FacebookLogin
import TwitterKit
import Realm
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var realm: Realm!
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        
        // Override point for customization after application launch.
        
        // Firebase
        let filePath = Bundle.main.path(forResource: "MovreakFree-GoogleService-Info", ofType: "plist")
        let options = FirebaseOptions(contentsOfFile: filePath!)
        FirebaseApp.configure(options: options!)
        
        if let apiKey = options?.apiKey {
            GMSPlacesClient.provideAPIKey(apiKey)
            GMSServices.provideAPIKey(apiKey)
        }
        
        // Facebook
        SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // Twitter
        Twitter.sharedInstance().start(withConsumerKey: kTwitterConsumerKey, consumerSecret: kTwitterConsumerSecret)
        
        let config = Realm.Configuration(
            fileURL: URL(fileURLWithPath: RLMRealmPathForFile("Movreak.realm")),
            
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 12,
            
            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if (oldSchemaVersion < 1) {
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                }
        })
        
        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config
        
        // Now that we've told Realm how to handle the schema change, opening the file
        // will automatically perform the migration
        realm = try! Realm()
        
        let appDidRunOnce = UserDefaults.standard.bool(forKey: kAppDidRunOnceKey)
        if !appDidRunOnce {
            UserManager.shared.localSignOut()
            
            UserDefaults.standard.set(true, forKey: kAppDidRunOnceKey)
            UserDefaults.standard.synchronize()
        }
        
        registerForRemoteNotifications()
        LocationManager.shared.updateLocation()
        
        UserDefaults.standard.set(Date(), forKey: kLastAppRefreshKey)
        UserDefaults.standard.synchronize()
        
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().disabledDistanceHandlingClasses.append(ReviewComposerViewController.self)

        
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
        
        if let lastRefreshDate = MVSetting.current()?.lastRefreshDate {
            if abs(lastRefreshDate.timeIntervalSinceNow) > kClientSettingRefreshTimeInterval {
                provider.request(Movreak1.clientSetting, completion: { (result) in })
            }
        }
        
        if let date = UserDefaults.standard.value(forKey: kLastAppRefreshKey) as? Date, Date().timeIntervalSince(date) > kAppRefreshTimeInterval {
            
            LocationManager.shared.updateLocation()
            showSplashViewController()
            
            UserDefaults.standard.set(Date(), forKey: kLastAppRefreshKey)
            UserDefaults.standard.synchronize()
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        var handled = true
        if url.absoluteString.contains(SDKSettings.appId) {
            handled = SDKApplicationDelegate.shared.application(app, open: url, options: options)
        }
        else {
            handled = Twitter.sharedInstance().application(app, open: url, options: options)
        }
        return handled
    }
    
    // MARK: - Helpers
    
    func showMainViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "Lite")
        setRoot(viewController: viewController)
    }
    
    func showSplashViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "Splash")
        setRoot(viewController: viewController)
    }
    
    func setRoot(viewController: UIViewController) {
        
        UIView.transition(with: window!, duration: 0.25, options: [.transitionCrossDissolve, .allowAnimatedContent], animations: {
            
            let oldState = UIView.areAnimationsEnabled
            UIView.setAnimationsEnabled(false)
            self.window?.rootViewController = viewController
            UIView.setAnimationsEnabled(oldState)
            
        }) { (finished) in
            
        }
    }
    
    // MARK: - Push Notification Helpers
    
    func registerForRemoteNotifications() {
        
        let application = UIApplication.shared
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in }
            )
        }
        else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        completionHandler(.newData)
    }
}

// MARK: - UNUserNotificationCenterDelegate
@available(iOS 10.0, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
    }
}

// MARK: - MessagingDelegate
extension AppDelegate: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        
    }
}




import UIKit
import GoogleMaps

let googleApiKey = "AIzaSyBeCW7H7dAt64dOzYTYAXZxital8-HbpTc"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        GMSServices.provideAPIKey(googleApiKey)
        return true
    }
}


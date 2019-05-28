//
//  UserManager.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 2/17/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin
import TwitterKit
import Alamofire
import SwiftyJSON
import RxSwift
import RealmSwift
import ObjectMapper

#if (arch(i386) || arch(x86_64)) && os(iOS)
    let kFBAuthenticationToken = "kFBAuthenticationToken"
#endif

struct FacebookProfileRequest: GraphRequestProtocol {
    
    struct Response: GraphResponseProtocol {
        
        var json: JSON?
        
        init(rawResponse: Any?) {
            // Decode JSON from rawResponse into other properties here.
            if let rawResponse = rawResponse {
                self.json = JSON(rawResponse)
            }
        }
    }
    
    var graphPath: String = "/me"
    var parameters: [String: Any]? = ["fields": "name, first_name, last_name, picture.type(large), email, link, birthday, updated_time, timezone, about, gender, education, work, hometown, location, installed, verified, cover, currency, devices, quotes, political, religion, website"]
    var accessToken: AccessToken? = AccessToken.current
    var httpMethod: GraphRequestHTTPMethod = .GET
    var apiVersion: GraphAPIVersion = .defaultVersion
}

enum SignInProvider {
    case facebook
    case twitter
    case path
    
    var description: String {
        
        switch self {
        case .facebook:
            return "facebook"
            
        case .twitter:
            return "twitter"
            
        case .path:
            return "path"
        }
    }
    
    func userDataString(from json: JSON) -> String {
        var userDataString = ""
        var userData: [String: Any] = [:]
        
        if self == .facebook {
            
            userData["AuthProvider"] = description
            userData["providerName"] = description.capitalized
            userData["MovreakOS"] = "iOS"
            userData["MovreakType"] = "Movreak Remake for iOS"
            userData["MovreakVersion"] = "v4.9.4"
            
            userData["FacebookID"] = json["id"].stringValue
            userData["identifier"] = String(format: "www.facebook.com/profile.php?id=%@", json["id"].stringValue)
            userData["email"] = json["email"].stringValue
            userData["verifiedEmail"] = json["email"].stringValue
            userData["displayName"] = json["name"].stringValue
            userData["firstName"] = json["first_name"].stringValue
            userData["lastName"] = json["last_name"].stringValue
            userData["gender"] = json["gender"].stringValue
            userData["photo"] = json["picture"]["data"]["url"].stringValue
            userData["coverImage"] = json["cover"]["source"].stringValue
            userData["aboutMe"] = json["about"].stringValue
            userData["description"] = json["about"].stringValue
            userData["modifiedDate"] = json["updated_time"].stringValue
            userData["timeZone"] = json["timezone"].intValue
            userData["url"] = json["link"].stringValue
            userData["birthday"] = json["birthday"].stringValue
            userData["religion"] = json["religion"].stringValue
            userData["political"] = json["political"].stringValue
            userData["location"] = json["location"]["name"].stringValue
        }
        else if self == .twitter {
            
            userData["AuthProvider"] = description
            userData["providerName"] = description.capitalized
            userData["MovreakOS"] = "iOS"
            userData["MovreakType"] = "Movreak Remake for iOS"
            userData["MovreakVersion"] = "v4.9.4"
            
            userData["TwitterUserName"] = json["screen_name"].stringValue
            var identifier = ""
            if let twitterID = json["id"].number?.intValue { identifier = "twitter.com/account/profile?user_id=\(twitterID)" }
            else if let screenName = json["screen_name"].string { identifier = "twitter.com/\(screenName)" }
            userData["identifier"] = identifier
            userData["providerUsername"] = json["screen_name"].stringValue
            userData["preferredUsername"] = json["screen_name"].stringValue
            userData["email"] = json["email"].stringValue
            userData["verifiedEmail"] = json["email"].stringValue
            userData["displayName"] = json["name"].stringValue
//            userData["firstName"] =
//            userData["lastName"] =
//            userData["gender"] =
            userData["photo"] = json["profile_image_url"].stringValue
            userData["coverImage"] = json["profile_banner_url"].stringValue
            userData["aboutMe"] = json["description"].stringValue
            userData["description"] = json["description"].stringValue
//            userData["modifiedDate"] =
            userData["timeZone"] = json["time_zone"].stringValue
//            userData["url"] =
//            userData["birthday"] =
//            userData["religion"] =
//            userData["political"] =
            userData["location"] = json["location"].stringValue
        }
        
        userData = [
            "profile": userData,
            "stat": "ok"
        ]
        
        if let data = try? JSONSerialization.data(withJSONObject: userData, options: .prettyPrinted) {
            if let string = String(data: data, encoding: .utf8) {
                userDataString = string
            }
        }
        
        return userDataString
    }
}

class UserManager: NSObject {

    class var shared: UserManager {
        struct Static {
            static let instance: UserManager = UserManager()
        }
        return Static.instance
    }
    
    var userAgent: String {
        let bundleVersion = Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as! String
        let model = UIDevice.current.model
        let systemVersion = UIDevice.current.systemVersion
        let scale = String(format: "%.2f", UIScreen.main.scale)
        
        return "Movreak/\(bundleVersion) (\(model); iOS \(systemVersion); Scale/\(scale))"
    }
    
    var headers: [String: String] {
        var authorization = ""
        
        var username = kMovreakSvcUsername
        var password = kMovreakSvcPassword
        if let userIdentifier = profile?.userIdentifier {
            username = userIdentifier
            password = userIdentifier
        }
        
        if let authorizationData = "\(username):\(password)".data(using: String.Encoding.utf8) {
            authorization = authorizationData.base64EncodedString(options: [])
        }
        
        return [
            "User-Agent": userAgent,
            "Content-Type": "application/json",
            "Accept": "application/json",
            "DataServiceVersion": "1.0",
            "X-TimeZone-Offset": "\(TimeZone.current.secondsFromGMT() / 3600)",
            "Authorization": "Basic \(authorization)"
        ]
    }
    
    private var _profile: MVProfile?
    var profile: MVProfile? {
        get {
            if _profile == nil {
                let realm = try! Realm()
                _profile = realm.objects(MVProfile.self).first
            }
            return _profile
        }
        set {
            _profile = newValue
        }
    }
    
    // MARK: - Privates
    
    private func signInWithFacebook(completion: @escaping MovreakCompletion<AccessToken>) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let viewController = appDelegate.window?.rootViewController!
        
        let fbLoginManager = LoginManager()
        fbLoginManager.loginBehavior = .systemAccount
        let permissions: [ReadPermission] = [
            .email,
            .publicProfile,
            .userFriends,
            .custom("user_birthday"),
            .custom("user_location"),
            .custom("user_religion_politics")
        ]
        fbLoginManager.logIn(permissions, viewController: viewController) { (result) in
            
            switch result {
            case .cancelled:
                completion(nil, nil)
                
            case .success(_, _, let accessToken):
                #if (arch(i386) || arch(x86_64)) && os(iOS)
                    UserDefaults.standard.set(accessToken.authenticationToken, forKey: kFBAuthenticationToken)
                    UserDefaults.standard.synchronize()
                #endif
                completion(accessToken, nil)
                
            case .failed(let error):
                completion(nil, error)
            }
        }
    }
    
    private func facebookProfile(completion: @escaping MovreakCompletion<JSON>) -> GraphRequestConnection {
        
        let connection = GraphRequestConnection()
        connection.add(FacebookProfileRequest()) { (response, result) in
            
            switch result {
            case .success(let response):
                completion(response.json, nil)
                
            case .failed(let error):
                completion(nil, error)
            }
        }
        connection.start()
        
        return connection
    }
    
    private func signInWithTwitter(in viewController: UIViewController? = nil, completion: @escaping MovreakCompletion<TWTRSession>) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        var vc = appDelegate.window?.rootViewController!
        if let viewController = viewController {
            vc = viewController
        }
        
        Twitter.sharedInstance().logIn(with: vc) { (session, error) in
            
            if let session = session {
                completion(session, nil)
            }
            else {
                completion(nil, error)
            }
        }
    }
    
    private func twitterProfile(completion: @escaping MovreakCompletion<JSON>) -> Progress {
        
        let client = TWTRAPIClient.withCurrentUser()
        let request = client.urlRequest(withMethod: "GET", url: "https://api.twitter.com/1.1/account/verify_credentials.json", parameters: ["include_email": "true", "skip_status": "true", "include_entities": "true"], error: nil)
        
        let progress = client.sendTwitterRequest(request) { (response, data, error) in
            
            if let data = data {
                let json = JSON(data: data)
                completion(json, nil)
            }
            else {
                completion(nil, error)
            }
        }
        
        return progress
    }
    
    private func signIn(withProvider provider: SignInProvider, userData: JSON, completion: @escaping MovreakCompletion<MVProfile>) -> Request {
        
        let parameters: [String: Any] = [
            "profile": provider.userDataString(from: userData)
        ]
        
        var headers = self.headers
        headers["Content-Type"] = "application/x-www-form-urlencoded; charset=utf-8"
        
        let request = Alamofire.request("\(kBaseUrl)\(kLoginPathUrl)", method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers)
            .responseData { (response) in
                
                switch response.result {
                case .success(let value):
                    let json = JSON(data: value)
                    
                    var profile: MVProfile?
                    if let profileJson = json["profile"].dictionaryObject {
                        profile = MVProfile(JSON: profileJson)
                        if let profile = profile {
                            try! realm.write {
                                realm.add(profile, update: true)
                            }
                        }
                    }
                    completion(profile, nil)
                    
                case .failure(let error):
                    completion(nil, error)
                }
        }
        
        return request
    }
    
    func updateUserProfile(completion: @escaping MovreakCompletion<MVProfile>) -> Request {
        
        var parameters: [String: Any] = [:]
        if let profile = profile { parameters["profile"] = profile.jsonString() }
        
        
        var headers = self.headers
        headers["Content-Type"] = "application/x-www-form-urlencoded; charset=utf-8"
        
        let request = Alamofire.request("\(kBaseUrl)\(kUserProfileUpdatePathUrl)", method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers)
            .responseData { (response) in
                
                switch response.result {
                case .success(let value):
                    let json = JSON(data: value)
                    
                    if let profileJson = json["profile"].dictionaryObject {
                        let profile = MVProfile(JSON: profileJson)
                        if let profile = profile {
                            try! realm.write {
                                realm.add(profile, update: true)
                            }
                        }
                        completion(profile, nil)
                    }
                    else if json["Status"].stringValue.lowercased() == "ok" {
                        completion(self.profile, nil)
                    }
                    else {
                        completion(nil, json.movreakError)
                    }
                    
                case .failure(let error):
                    completion(nil, error)
                }
        }
        
        return request
    }
    
    func updateUserProfilePreference(completion: @escaping MovreakCompletion<MVProfile>) -> Request {
        
        var parameters: [String: Any] = [:]
        if let profile = profile { parameters["profile"] = profile.preferencesJsonString() }
        
        var headers = self.headers
        headers["Content-Type"] = "application/x-www-form-urlencoded; charset=utf-8"
        
        let request = Alamofire.request("\(kBaseUrl)\(kUserProfileUpdatePrefsPathUrl)", method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers)
            .responseData { (response) in
                
                switch response.result {
                case .success(let value):
                    let json = JSON(data: value)
                    
                    if let profileJson = json["profile"].dictionaryObject {
                        let profile = MVProfile(JSON: profileJson)
                        if let profile = profile {
                            try! realm.write {
                                realm.add(profile, update: true)
                            }
                        }
                        completion(profile, nil)
                    }
                    else if json["Status"].stringValue.lowercased() == "ok" {
                        completion(self.profile, nil)
                    }
                    else {
                        completion(nil, json.movreakError)
                    }
                    
                case .failure(let error):
                    completion(nil, error)
                }
        }
        
        return request
    }
    
    // MARK: - Users
    
    func connectToFacebook() -> Observable<Any> {
        
        return Observable.create { (observer) -> Disposable in
         
            UserManager.shared.signInWithFacebook { (result, error) in
                
                if let result = result {
                    observer.on(.next(result))
                    
                    _ = UserManager.shared.facebookProfile { (result, error) in
                        
                        if let json = result {
                            observer.on(.next(json))
                            
                            if let profile = self.profile {
                                
                                try! realm.write {
                                    profile.facebookID = json["id"].stringValue
                                }
                            
                                _ = self.updateUserProfile { (result, error) in
                                    if let profile = result {
                                        observer.on(.next(profile))
                                        observer.onCompleted()
                                    }
                                    else if let error = error {
                                        self.deauthorizedFacebook()
                                        observer.onError(error)
                                    }
                                    else {
                                        observer.onCompleted()
                                    }
                                }
                            }
                            else {
                                _ = UserManager.shared.signIn(withProvider: .facebook, userData: json) { (result, error) in
                                    
                                    if let profile = result {
                                        observer.on(.next(profile))
                                        observer.onCompleted()
                                        
                                        NotificationCenter.default.post(name: kUserDidSignInOrOutNotification, object: nil)
                                    }
                                    else if let error = error {
                                        self.deauthorizedFacebook()
                                        observer.onError(error)
                                    }
                                    else {
                                        observer.onCompleted()
                                    }
                                }
                            }
                        }
                        else if let error = error {
                            self.deauthorizedFacebook()
                            observer.onError(error)
                        }
                        else {
                            observer.onCompleted()
                        }
                    }
                }
                else if let error = error {
                    self.deauthorizedFacebook()
                    observer.onError(error)
                }
                else {
                    observer.onCompleted()
                }
            }
            
            let disposable = Disposables.create {
                
            }
            return disposable
        }
    }
    
    func connectToFacebook(completion: @escaping MovreakCompletion<Bool>) {
        
        connectToFacebook()
            .subscribe { (event) in
                switch event {
                case .next:
                    break
                    
                case .error(let error):
                    completion(false, error)
                    
                case .completed:
                    completion(true, nil)
                }
            }
            .disposed(by: disposeBag)
    }
    
    func connectToTwitter(in viewController: UIViewController? = nil) -> Observable<Any> {
        
        return Observable.create { (observer) -> Disposable in
            
            UserManager.shared.signInWithTwitter(in: viewController) { (session, error) in
                
                if let session = session {
                    observer.on(.next(session))
                    
                    _ = UserManager.shared.twitterProfile { (result, error) in
                        
                        if let json = result {
                            observer.on(.next(json))
                            
                            if let profile = self.profile {
                                
                                try! realm.write {
                                    profile.twitterUserName = json["screen_name"].stringValue
                                }
                                
                                _ = self.updateUserProfile { (result, error) in
                                    if let profile = result {
                                        observer.on(.next(profile))
                                        observer.onCompleted()
                                        
                                        NotificationCenter.default.post(name: kUserDidSignInOrOutNotification, object: nil)
                                    }
                                    else if let error = error {
                                        self.deauthorizedTwitter()
                                        observer.onError(error)
                                    }
                                    else {
                                        observer.onCompleted()
                                    }
                                }
                            }
                            else{
                                _ = UserManager.shared.signIn(withProvider: .twitter, userData: json) { (result, error) in
                                    
                                    if let profile = result {
                                        observer.on(.next(profile))
                                        observer.onCompleted()
                                    }
                                    else if let error = error {
                                        self.deauthorizedTwitter()
                                        observer.onError(error)
                                    }
                                    else {
                                        observer.onCompleted()
                                    }
                                }
                            }
                        }
                        else if let error = error {
                            self.deauthorizedTwitter()
                            observer.onError(error)
                        }
                        else {
                            observer.onCompleted()
                        }
                    }
                }
                else if let error = error {
                    self.deauthorizedTwitter()
                    observer.onError(error)
                }
                else {
                    observer.onCompleted()
                }
            }
            
            let disposable = Disposables.create {
                
            }
            return disposable
        }
    }
    
    func connectToTwitter(in viewCOntroller: UIViewController? = nil, completion: @escaping MovreakCompletion<Bool>) {
        
        connectToTwitter(in: viewCOntroller)
            .subscribe { (event) in
                switch event {
                case .next:
                    break
                    
                case .error(let error):
                    completion(false, error)
                    
                case .completed:
                    completion(true, nil)
                }
            }
            .disposed(by: disposeBag)
    }
    
    func connectToPath(from viewController: MovreakViewController) -> Observable<Any> {
        
        if let profile = profile {
            
            return Observable.create { (observer) -> Disposable in
                
                viewController.pathDynamicModal = viewController.presentPathSignInViewController(in: viewController.view, completion: { (viewController, pathProfile) in
                    
                    observer.on(.next(pathProfile))
                    
                    try! realm.write {
                        profile.pathUserID = pathProfile.userId
                    }
                    
                    _ = self.updateUserProfile { (profile, error) in
                        
                        if let profile = profile {
                            observer.on(.next(profile))
                            observer.onCompleted()
                            viewController.removeFromParentViewController()
                            
                            NotificationCenter.default.post(name: kUserDidSignInOrOutNotification, object: nil)
                        }
                        else if let error = error {
                            self.deauthorizedPath()
                            observer.onError(error)
                            viewController.removeFromParentViewController()
                        }
                        else {
                            observer.onCompleted()
                            viewController.removeFromParentViewController()
                        }
                    }
                    
                }, cancelledCompletion: { (viewController, error) in
                    
                    self.deauthorizedPath()
                    if let error = error {
                        observer.onError(error)
                    }
                    else {
                        let error = NSError(domain: "MOVREAK", code: 0, userInfo: [NSLocalizedDescriptionKey: "Sign-in to Path is cancelled"])
                        observer.onError(error)
                    }
                    viewController.removeFromParentViewController()
                })
                
                viewController.pathDynamicModal?.closedHandler = {
                    
                    if realm.objects(PathProfile.self).count <= 0 {
                        let error = NSError(domain: "MOVREAK", code: 0, userInfo: [NSLocalizedDescriptionKey: "Sign-in to Path is cancelled"])
                        observer.onError(error)
                    }
                    viewController.pathDynamicModal = nil
                }
                
                let disposable = Disposables.create { }
                return disposable
            }
        }
        else {
            
            return Observable.create { (observer) -> Disposable in
                
                let error = NSError(domain: "MOVREAK", code: 0, userInfo: [NSLocalizedDescriptionKey: "Please sign-in with Facebook or Twitter first"])
                observer.onError(error)
                
                let disposable = Disposables.create { }
                return disposable
            }
        }
    }

    func disconnectFromFacebook() -> Observable<Any> {
    
        return Observable.create { (observer) -> Disposable in
            
            if let profile = self.profile {
                
                self.deauthorizedFacebook()
                
                if let provider = profile.authProvider?.lowercased(),
                    provider == SignInProvider.facebook.description {
                    
                    _ = self.updateUserProfilePreference { (profile, error) in
                        self.localSignOut()
                        
                        observer.onNext(false)
                        observer.onCompleted()
                    }
                }
                else {
                    observer.onNext(profile)
                    observer.onCompleted()
                }
            }
            else {
                observer.onCompleted()
            }
            
            let disposable = Disposables.create {
                
            }
            return disposable
        }
    }
    
    func disconnectFromTwitter() -> Observable<Any> {
     
        return Observable.create { (observer) -> Disposable in
            
            if let profile = self.profile {
                
                self.deauthorizedTwitter()
                
                if let provider = profile.authProvider?.lowercased(),
                    provider == SignInProvider.twitter.description {
                    
                    _ = self.updateUserProfilePreference { (profile, error) in
                        self.localSignOut()
                        
                        observer.onNext(false)
                        observer.onCompleted()
                    }
                }
                else {
                    observer.onNext(profile)
                    observer.onCompleted()
                }
            }
            else {
                observer.onCompleted()
            }
            
            let disposable = Disposables.create { }
            return disposable
        }
    }
    
    func disconnectFromPath() -> Observable<Any> {
        
        return Observable.create { (observer) -> Disposable in
            
            self.deauthorizedPath()
            observer.onCompleted()
            
            let disposable = Disposables.create { }
            return disposable
        }
    }
    
    private func deauthorizedFacebook() {
        
        if let profile = profile {
            try! realm.write {
                profile.facebookID = nil
            }
        }
        
        let fbLoginManager = LoginManager()
        fbLoginManager.logOut()
        
        #if (arch(i386) || arch(x86_64)) && os(iOS)
            UserDefaults.standard.set(nil, forKey: kFBAuthenticationToken)
            UserDefaults.standard.synchronize()
        #endif
    }
    
    private func deauthorizedTwitter() {
        
        if let profile = profile {
            try! realm.write {
                profile.twitterUserName = nil
            }
        }
        
        if let userID = Twitter.sharedInstance().sessionStore.session()?.userID {
            Twitter.sharedInstance().sessionStore.logOutUserID(userID)
        }
    }
    
    private func deauthorizedPath() {
        
        if let profile = profile {
            try! realm.write {
                profile.pathUserID = nil
            }
        }
     
        if let pathProfile = realm.objects(PathProfile.self).first {
            try! realm.write {
                if let smallPhoto = pathProfile.smallPhoto {
                    realm.delete(smallPhoto)
                }
                if let mediumPhoto = pathProfile.mediumPhoto {
                    realm.delete(mediumPhoto)
                }
                if let originalPhoto = pathProfile.originalPhoto {
                    realm.delete(originalPhoto)
                }
                realm.delete(pathProfile)
            }
        }
    }
    
    func localSignOut() {
        
        deauthorizedFacebook()
        deauthorizedTwitter()
        deauthorizedPath()
        
        if let profile = profile {
            
            let realm = try! Realm()
            try! realm.write { realm.delete(profile) }
            
            self.profile = nil
        }
    }
    
    var isConnectedToFacebook: Bool {
        #if (arch(i386) || arch(x86_64)) && os(iOS)
            return UserDefaults.standard.object(forKey: kFBAuthenticationToken) != nil
        #else
            return AccessToken.current != nil
        #endif
    }
    
    var canPostToFacebook: Bool {
        if let permissions = AccessToken.current?.grantedPermissions,
            permissions.contains(Permission(name: "publish_actions")) {
            
            return true
        }
        return false
    }
    
    var isConnectedToTwitter: Bool {
        return Twitter.sharedInstance().sessionStore.session() != nil
    }
    
    var isConnectedToPath: Bool {
        return realm.objects(PathProfile.self).count > 0
    }
    
    // MARK: - Publish
    func askPublishPermissionToFacebook(from viewController: UIViewController ,completion: @escaping MovreakCompletion<Bool>) {
        
        let fbLoginManager = LoginManager()
        fbLoginManager.loginBehavior = .systemAccount
        let permissions: [PublishPermission] = [
            .publishActions
        ]
        
        fbLoginManager.logIn(permissions, viewController: viewController) { (result) in
            
            switch result {
            case .cancelled:
                completion(nil, nil)
                
            case .success:
                if self.canPostToFacebook {
                    completion(true, nil)
                }
                else {
                    completion(nil, nil)
                }
                
            case .failed(let error):
                completion(nil, error)
            }
        }
    }
    
    // MARK: - Upload Images
    
    private func updateUserProfileImageUrl(urlString: String, completion: @escaping MovreakCompletion<Bool>) {
        
        guard let profile = profile else {
            completion(nil, nil)
            return
        }
        
        let parameters = [
            "userpid": "\(profile.userProfileID)",
            "photoUrl": urlString
        ]
        
        var headers = self.headers
        headers["Content-Type"] = "application/x-www-form-urlencoded; charset=utf-8"
        
        Alamofire.request("\(kBaseUrl)\(kUserProfileChangePhotoPathUrl)", method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers)
            .responseData { (response) in
                
                switch response.result {
                case .success(let value):
                    let json = JSON(data: value)
                    if let status = json["Status"].string?.lowercased(), status == "ok" {
                        completion(true, nil)
                    }
                    else {
                        var errorMessage = "Failed to change profile picture"
                        if let message = json["Message"].string {
                            errorMessage = message
                        }
                        let error = NSError(domain: "MOVREAK", code: 0, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                        completion(nil, error)
                    }
                    
                case .failure(let error):
                    completion(nil, error)
                }
        }
    }
    
    private func uploadImage(image: UIImage, name: String, completion: @escaping MovreakCompletion<String>) {
        
        let accountName = "movreak"
        let sharedKey = "g7X+8zhw8mxM+jwWHOSWhoeWQ9FLsRjStjWYe4G6lnXgbE5B8Nq8bJkYNjZ3YE2LzdgEs1oEEJkXLoyCF31f+w=="
        let connectionString = "DefaultEndpointsProtocol=http;AccountName=\(accountName);AccountKey=\(sharedKey)"
        
        let containerName = "userphoto"
        let imageName = name
        
        do {
            
            let account = try AZSCloudStorageAccount(fromConnectionString: connectionString)
            let blobClient = account.getBlobClient()
            let blobContainer = blobClient.containerReference(fromName: containerName)
            
            blobContainer.createContainerIfNotExists(completionHandler: { (error, exists) in
                
                if let error = error {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
                else {
                    
                    let blockBlob = blobContainer.blockBlobReference(fromName: imageName)
                    
                    if let data = UIImageJPEGRepresentation(image, 0.9) {
                        blockBlob.upload(from: data, accessCondition: nil, requestOptions: nil, operationContext: nil, completionHandler: { (error) in
                            
                            if error == nil {
                                let urlString = "http://\(accountName).blob.core.windows.net/\(containerName)/\(imageName)"
                                DispatchQueue.main.async {
                                    completion(urlString, nil)
                                }
                            }
                            else {
                                DispatchQueue.main.async {
                                    completion(nil, error)
                                }
                            }
                        })
                    }
                }
            })
        }
        catch {
            completion(nil, error)
        }
    }
    
    func changeProfileImage(image: UIImage, completion: @escaping MovreakCompletion<Bool>) {
        
        if let profile = profile {
            
            DispatchQueue.global().async {
                let width = min(image.scale == 1 ? 500 : 250, min(image.size.width, image.size.height))
                let croppedImage = image.cropCenterAndResize(to: CGSize(width: width, height: width))
                
                DispatchQueue.main.async {
                    
                    let imageName: String = "UserAvatarBig-\(profile.userProfileID)-\(String.randomString(length: 8)).jpg"
                    self.uploadImage(image: croppedImage, name: imageName) { (result, error) in
                        
                        if let urlString = result {
                            try! realm.write { self.profile?.bigPhotoUrl = urlString }
                            
                            DispatchQueue.global().async {
                                let scaledImage = image.cropCenterAndResize(to: CGSize(width: 80, height: 80))
                                
                                DispatchQueue.main.async {
                                    
                                    var imageName = URL(string: urlString)!.lastPathComponent
                                    imageName = imageName.replacingOccurrences(of: "UserAvatarBig", with: "UserAvatar")
                                    
                                    self.uploadImage(image: scaledImage, name: imageName) { (result, error) in
                                        try! realm.write { self.profile?.photoUrl = urlString }
                                        
                                        if let urlString = result {
                                            self.updateUserProfileImageUrl(urlString: urlString) { (result, error) in
                                                
                                                completion(result, error)
                                            }
                                        }
                                        else {
                                            completion(nil, error)
                                        }
                                    }
                                }
                            }
                        }
                        else {
                            completion(nil, error)
                        }
                    }
                    
                }
            }
        }
        else {
            completion(nil, nil)
        }
    }
    
    private func updateUserCoverImageUrl(urlString: String, completion: @escaping MovreakCompletion<Bool>) {
        
        guard let profile = profile else {
            completion(nil, nil)
            return
        }
        
        let parameters = [
            "userpid": "\(profile.userProfileID)",
            "coverImageUrl": urlString
        ]
        
        var headers = self.headers
        headers["Content-Type"] = "application/x-www-form-urlencoded; charset=utf-8"
        
        Alamofire.request("\(kBaseUrl)\(kUserProfileUpdateCoverPathUrl)", method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers)
            .responseData { (response) in
                
                switch response.result {
                case .success(let value):
                    let json = JSON(data: value)
                    if let status = json["Status"].string?.lowercased(), status == "ok" {
                        completion(true, nil)
                    }
                    else {
                        var errorMessage = "Failed to change profile picture"
                        if let message = json["Message"].string {
                            errorMessage = message
                        }
                        let error = NSError(domain: "MOVREAK", code: 0, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                        completion(nil, error)
                    }
                    
                case .failure(let error):
                    completion(nil, error)
                }
        }
    }
    
    func changeCoverImage(image: UIImage, completion: @escaping MovreakCompletion<Any>) {
        
        if let profile = profile {
            
            let width = min(image.scale == 1 ? 750 : 375, min(image.size.width, image.size.height))
            DispatchQueue.global().async {
                let croppedImage = image.cropCenterAndResize(to: CGSize(width: width, height: width))
                
                DispatchQueue.main.async {
                    
                    let imageName: String = "UserCover-\(profile.userProfileID)-\(String.randomString(length: 8)).jpg"
                    self.uploadImage(image: croppedImage, name: imageName) { (result, error) in
                        
                        if let urlString = result {
                            try! realm.write { self.profile?.coverImageUrl = urlString }
                            
                            self.updateUserCoverImageUrl(urlString: urlString) { (result, error) in
                                
                                completion(result, error)
                            }
                        }
                        else {
                            completion(nil, error)
                        }
                    }
                }
            }
        }
    }
}

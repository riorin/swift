//
//  PathSignInViewController.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 3/27/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift

typealias PathSignInCompletion = (_ viewController: PathSignInViewController, _ pathProfile: PathProfile) -> Void
typealias PathSignInCancelledCompletion = (_ viewController: PathSignInViewController, _ error: Error?) -> Void

class PathSignInViewController: MovreakViewController {

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    
    let authUrlString = "https://partner.path.com/oauth2/authenticate?response_type=code&client_id=\(kPathClientId)"
    
    fileprivate var accessToken: String?
    fileprivate var userId: String?
    fileprivate var email: String?
    fileprivate var password: String?
    
    var completion: PathSignInCompletion = { (viewController, pathProfile) in }
    var cancelledCompletion: PathSignInCancelledCompletion = { (viewController, error) in }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.layer.cornerRadius = 4.0
        view.layer.masksToBounds = true
        
        
        URLCache.shared.removeAllCachedResponses()
        URLCache.shared.diskCapacity = 0
        URLCache.shared.memoryCapacity = 0
        
        if let cookies = HTTPCookieStorage.shared.cookies {
            for cookie in cookies {
                HTTPCookieStorage.shared.deleteCookie(cookie)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let url = URL(string: authUrlString) {
            
            let request = URLRequest(url: url)
            webView.loadRequest(request)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - Helpers
    
    func requestAccessToken(with code: String) {
        
        showLoadingView(in: view, label: "Loading Path...")
        oAuthPathProvider.request(.accessToken(code))
            .subscribe { [weak self] (event) in
                if let weakSelf = self {
                    
                    switch event {
                    case .next(let response):
                        let json = JSON(data: response.data)
                        weakSelf.accessToken = json["access_token"].string
                        weakSelf.userId = json["user_id"].string
                        
                        if json["access_token"].stringValue.characters.count == 0 {
                            let error = NSError(domain: "MOVREAK", code: 9001, userInfo: [NSLocalizedDescriptionKey: "Unknown error"])
                            weakSelf.cancelledCompletion(weakSelf, error)
                        }
                        else {
                            weakSelf.authenticate()
                        }
                        
                    case .error(let error):
                        weakSelf.hideLoadingView()
                        weakSelf.cancelledCompletion(weakSelf, error)
                        
                    case .completed:
                        break
                    }
                }
            }
            .disposed(by: disposeBag)
    }
    
    func authenticate() {
        
        guard let email = email, let password = password else {
            
            let error = NSError(domain: "MOVREAK", code: 400, userInfo: [NSLocalizedDescriptionKey: "You haven't entered username and password of your Path account. Please try to sign-in to Path again"])
            self.cancelledCompletion(self, error)
            
            return
        }
        
        showLoadingView(in: view, label: "Signing-in to Path...")
        pathProvider.request(.authenticateUser(email, password))
            .subscribe { [weak self] (event) in
                if let weakSelf = self {
                    
                    switch event {
                    case .next(let response):
                        do {
                            let object = try PropertyListSerialization.propertyList(from: response.data, options: [], format: nil)
                            
                            let json = JSON(object)
                            let profile = PathProfile.from(json: json)
                            profile.accessToken = weakSelf.accessToken
                            profile.email = weakSelf.email
                            profile.password = weakSelf.password
                            
                            try! realm.write { realm.add(profile, update: true) }
                            
                            weakSelf.hideLoadingView()
                            weakSelf.completion(weakSelf, profile)
                        }
                        catch let error {
                            weakSelf.hideLoadingView()
                            weakSelf.cancelledCompletion(weakSelf, error)
                        }
                        
                    case .error(let error):
                        weakSelf.hideLoadingView()
                        weakSelf.cancelledCompletion(weakSelf, error)
                        
                    case .completed:
                        break
                    }
                }
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - UIWebViewDelegate
extension PathSignInViewController: UIWebViewDelegate {
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        if let urlString = request.url?.absoluteString {
            
            if urlString.hasPrefix(kPathCallbackUrl) {
                if let query = request.url?.queryItems {
                    
                    if let code = query["code"] {
                        
                        requestAccessToken(with: code)
                        return false
                    }
                }
            }
            else if urlString.range(of: "partner.path.com/oauth2/authenticate") != nil && navigationType == .formSubmitted {
                
                if let email = webView.stringByEvaluatingJavaScript(from: "$('#email').val();"),
                    let password = webView.stringByEvaluatingJavaScript(from: "$('#password').val();") {
                    
                    if email.characters.count > 0 {
                        self.email = email
                    }
                    if password.characters.count > 0 {
                        self.password = password
                    }
                }
            }
        }
        
        return true
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        
        loadingView.startAnimating()
        webView.alpha = 0.5
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        
        loadingView.stopAnimating()
        webView.alpha = 1.0
        
        if let urlString = webView.request?.url?.absoluteString {
            
            if urlString.range(of: "/decline") != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    self.cancelledCompletion(self, nil)
                })
            }
        }
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        
        loadingView.stopAnimating()
        webView.alpha = 1.0
    }
}

// MARK: - UIViewController
extension UIViewController {
    
    func presentPathSignInViewController(in view: UIView?, completion: @escaping PathSignInCompletion, cancelledCompletion: @escaping PathSignInCancelledCompletion) -> PathDynamicModal? {
        
        let viewController = PathSignInViewController(nibName: "PathSignInViewController", bundle: nil)
        viewController.completion = completion
        viewController.cancelledCompletion = cancelledCompletion
        
        addChildViewController(viewController)
        
        if let signInView = viewController.view {
            signInView.frame = CGRect(x: 0, y: 0, width: 310, height: 430)
            
            var inView: UIView = self.view
            if let view = view { inView = view }
            let pathDynamicModal = PathDynamicModal.show(modalView: signInView, inView: inView)
            
            return pathDynamicModal
        }
        
        return nil
    }
}

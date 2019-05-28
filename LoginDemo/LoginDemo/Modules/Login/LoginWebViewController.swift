//
//  LoginWebViewController.swift
//  LoginDemo
//
//  Created by Bayu Yasaputro on 05/04/18.
//  Copyright © 2018 DyCode. All rights reserved.
//

import UIKit
import WebKit
import RxSwift

class LoginWebViewController: UIViewController {

    weak var webView: WKWebView!
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    
    var requestToken: RequestToken?
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let webView = WKWebView()
        webView.frame = view.bounds
        view.addSubview(webView)
        view.sendSubview(toBack: webView)
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-0-[wv]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["wv": webView]))
        view.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-0-[wv]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["wv": webView]))
        
        
        
        webView.navigationDelegate = self
        self.webView = webView
        
        let dataTypes = WKWebsiteDataStore.allWebsiteDataTypes()
        let date = Date(timeIntervalSince1970: 0)
        WKWebsiteDataStore.default().removeData(ofTypes: dataTypes, modifiedSince: date) {
            self.createRequestToken()
        }
    }

    func createRequestToken() {
        
        provider.rx.request(.createRequestToken)
            .map(to: RequestToken.self)
            .subscribe { [weak self] (event) in
                
                switch event {
                case .success(let requestToken):
                    
                    let urlString = "https://www.themoviedb.org/authenticate/\(requestToken.request_token)"
                    let request = URLRequest(url: URL(string: urlString)!)
                    
                    self?.requestToken = requestToken
                    self?.webView.load(request)
                    
                case .error(let error):
                    print(error.localizedDescription)
                }
            }
            .disposed(by: disposeBag)
    }
    
    func createSession() {
        
        if let token = requestToken?.request_token {
            
            provider.rx.request(.createSession(token))
                .map(to: Session.self)
                .subscribe { (event) in
                    
                    switch event {
                    case .success(let session):
                        UserDefaults.standard.set(token, forKey: kRequestTokenKey)
                        UserDefaults.standard.set(session.session_id, forKey: kSessionIdKey)
                        UserDefaults.standard.synchronize()
                        
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.showMainViewController()
                        
                    case .error(let error):
                        print(error.localizedDescription)
                    }
                }
            .disposed(by: disposeBag)
        }
    }
}

extension LoginWebViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        
        if let response = navigationResponse.response as? HTTPURLResponse {
            let headers = response.allHeaderFields
            
            if let callback = headers["authentication-callback"] as? String {
                print(callback)
                
                createSession()
                decisionHandler(.cancel)
                return
            }
        }
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        loadingView.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadingView.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        loadingView.stopAnimating()
    }
}

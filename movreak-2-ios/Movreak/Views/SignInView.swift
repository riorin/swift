//
//  SignInView.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 2/24/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import UIKit

typealias SignInCompletion = (_ povider: SignInProvider) -> Void

protocol SignInViewDelegate {
    func signInViewFacebookButtonTapped(view: SignInView)
    func signInViewTwitterButtonTapped(view: SignInView)
    func signInViewPathButtonTapped(view: SignInView)
}

class SignInView: UIView {
    var delegate: SignInViewDelegate?
    var completion: SignInCompletion?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupViews()
    }
    
    // MARK: - Helpers
    
    func setupViews() {
        
        layer.cornerRadius = 4.0
        layer.masksToBounds = true
    }
    
    // MARK: - Actions
    
    @IBAction func facebookButtonTapped(_ sender: UIButton) {
        if let completion = completion {
            completion(.facebook)
        }
        else if let delegate = delegate {
            delegate.signInViewFacebookButtonTapped(view: self)
        }
    }
    
    @IBAction func twitterButtonTapped(_ sender: UIButton) {
        if let completion = completion {
            completion(.twitter)
        }
        else if let delegate = delegate {
            delegate.signInViewTwitterButtonTapped(view: self)
        }
    }
    
    @IBAction func pathButtonTapped(_ sender: UIButton) {
        if let completion = completion {
            completion(.path)
        }
        else if let delegate = delegate {
            delegate.signInViewPathButtonTapped(view: self)
        }
    }
}

// MARK: - UIViewController
extension UIViewController {
    
    func presentSignInViewController(in view: UIView?, delegate: SignInViewDelegate) -> PathDynamicModal {
        
        let signInView = Bundle.main.loadNibNamed("SignInView", owner: nil, options: nil)?.first as! SignInView
        signInView.frame = CGRect(x: 0, y: 0, width: 315, height: 319) //387)
        signInView.delegate = delegate
        
        var inView: UIView = self.view
        if let view = view { inView = view }
        let pathDynamicModal = PathDynamicModal.show(modalView: signInView, inView: inView)
        
        return pathDynamicModal
    }
    
    func presentSignInView(in view: UIView?, completion: @escaping SignInCompletion) -> PathDynamicModal {
        
        let signInView = Bundle.main.loadNibNamed("SignInView", owner: nil, options: nil)?.first as! SignInView
        signInView.frame = CGRect(x: 0, y: 0, width: 315, height: 319) //387)
        signInView.completion = completion
        
        var inView: UIView = self.view
        if let view = view { inView = view }
        let pathDynamicModal = PathDynamicModal.show(modalView: signInView, inView: inView)
        
        return pathDynamicModal
    }
}

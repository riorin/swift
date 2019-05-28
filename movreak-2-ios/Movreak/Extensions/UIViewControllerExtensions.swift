//
//  UIViewControllerExtensions.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 10/17/16.
//  Copyright © 2016 DyCode. All rights reserved.
//

import UIKit
import RxSwift

extension UIViewController {
    
    @IBAction func backButtonTapped(_ sender: AnyObject) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func closeButtonTapped(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    func showLoadingView() {
        showLoadingView(in: view)
    }
    
    func showLoadingView(in view: UIView!) {
        showLoadingView(in: view, label: MVSetting.current()?.randomLoadingMessage())
    }
    
    func showLoadingView(in view: UIView!, label: String!) {
        
        if let activityView =  DejalBezelActivityView.current() {
            activityView.activityLabel.text = label
            activityView.layoutSubviews()
        }
        else {
            DejalBezelActivityView.addActivityView(to: view, withLabel: label)
        }
    }
    
    func hideLoadingView() {
        
        if DejalBezelActivityView.current() != nil {
            DejalBezelActivityView.remove(animated: true)
        }
    }
    
//    func configureNavigationBar(withBackgroundImage backgroundImage: UIImage?, tintColor: UIColor, barTintColor: UIColor?, shadowImage: UIImage?) {
//        
//        if let navigationController = navigationController {
//            
//            var duration: TimeInterval = 0.3
//            if let transitionDuration = transitionCoordinator?.transitionDuration {
//                duration = transitionDuration
//            }
//            
//            let transition = CATransition()
//            transition.duration = duration
//            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
//            transition.type = kCATransitionFade
//            
//            navigationController.navigationBar.layer.add(transition, forKey: nil)
//            UIView.animate(withDuration: duration, animations: {
//                
//                navigationController.navigationBar.setBackgroundImage(backgroundImage, for: .default)
//                navigationController.navigationBar.isTranslucent = backgroundImage == nil
//                navigationController.navigationBar.shadowImage = shadowImage
//                navigationController.navigationBar.barTintColor = barTintColor
//                navigationController.navigationBar.tintColor = tintColor
//                navigationController.navigationBar.titleTextAttributes = [
//                    NSFontAttributeName: kCoreSans17Font,
//                    NSForegroundColorAttributeName: tintColor
//                ]
//                
//            }, completion: { (finished) in
//                
//            })
//        }
//    }
    
    func configureNavigationBar(with tintColor: UIColor, barTintColor: UIColor?) {
        
        if let navigationController = navigationController {
            
            var duration: TimeInterval = 0.3
            if let transitionDuration = transitionCoordinator?.transitionDuration {
                duration = transitionDuration
            }
            
            let transition = CATransition()
            transition.duration = duration
            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            transition.type = kCATransitionFade
            
            navigationController.navigationBar.layer.add(transition, forKey: nil)
            UIView.animate(withDuration: duration, animations: {
                
                navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
                navigationController.navigationBar.isTranslucent = barTintColor == nil
                navigationController.navigationBar.shadowImage = UIImage()
                navigationController.navigationBar.barTintColor = barTintColor
                navigationController.navigationBar.tintColor = tintColor
                navigationController.navigationBar.titleTextAttributes = [
                    NSFontAttributeName: kCoreSans17Font,
                    NSForegroundColorAttributeName: tintColor
                ]
                
                if barTintColor == nil {
                    navigationController.navigationBar.layer.borderColor = nil
                    navigationController.navigationBar.layer.borderWidth = 0
                    navigationController.navigationBar.layer.shadowColor = nil
                    navigationController.navigationBar.layer.shadowOffset = CGSize(width: 0, height: -3)
                    navigationController.navigationBar.layer.shadowRadius = 3
                    navigationController.navigationBar.layer.shadowOpacity = 0
                    navigationController.navigationBar.layer.masksToBounds = false
                }
                else {
                    navigationController.navigationBar.layer.borderColor = kBorderColor.cgColor
                    navigationController.navigationBar.layer.borderWidth = kBorderWidth
                    navigationController.navigationBar.layer.shadowColor = kShadowColor.cgColor
                    navigationController.navigationBar.layer.shadowOffset = kShadowOffset
                    navigationController.navigationBar.layer.shadowRadius = kShadowRadius
                    navigationController.navigationBar.layer.shadowOpacity = kShadowOpacity
                    navigationController.navigationBar.layer.masksToBounds = false
                }
                
            }, completion: { (finished) in
                
            })
        }
    }
    
    func showErrorAlert(withTitle title: String = "Ooops!", error: Error, completion: @escaping ((UIAlertAction) -> Void)) {
        showErrorAlert(withTitle: title, message: error.localizedDescription, completion: completion)
    }
    
    func showErrorAlert(withTitle title: String = "Ooops!", message: String, completion: @escaping ((UIAlertAction) -> Void)) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: completion))
        present(alertController, animated: true, completion: nil)
    }
    
    func showConfirmationAlert(with title: String = "Confirmation", message: String, actions: [UIAlertAction]) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for action in actions { alertController.addAction(action) }
        present(alertController, animated: true, completion: nil)
    }
    
    func presentErrorNotificationView(with message: String) {
        let notificationView = CSNotificationView(parentViewController: self, tintColor: .red, image: CSNotificationView.image(for: .error), message: message)
        notificationView?.textLabel.font = kCoreSans15Font
        notificationView?.setVisible(true, animated: true, completion: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: { 
                notificationView?.setVisible(false, animated: true, completion: { })
            })
        })
    }
    
    func presentWarningNotificationView(with message: String) {
        
        let notificationView = CSNotificationView(parentViewController: self, tintColor: .yellow, image: CSNotificationView.image(for: .error), message: message)
        notificationView?.textLabel.font = kCoreSans15Font
        notificationView?.setVisible(true, animated: true, completion: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                notificationView?.setVisible(false, animated: true, completion: { })
            })
        })
    }
    
    func presentSuccessNotificationView(with message: String) {
        let color = UIColor(red: 0.21, green: 0.72, blue: 0.00, alpha: 1.0)
        let notificationView = CSNotificationView(parentViewController: self, tintColor: color, image: CSNotificationView.image(for: .success), message: message)
        notificationView?.textLabel.font = kCoreSans15Font
        notificationView?.setVisible(true, animated: true, completion: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                notificationView?.setVisible(false, animated: true, completion: { })
            })
        })
    }
}

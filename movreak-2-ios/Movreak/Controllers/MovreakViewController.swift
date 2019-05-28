//
//  MovreakViewController.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 10/24/16.
//  Copyright © 2016 DyCode. All rights reserved.
//

import UIKit
import SwiftyJSON
import FacebookCore
import TwitterKit
import DKImagePickerController
import MobileCoreServices


class MovreakViewController: UIViewController {

    var viewDidAppearedOnce: Bool = false
    
    var isLoading: Bool = false
    var titleForEmptyDataSet: String = "No Data :("
    
    var pathDynamicModal: PathDynamicModal? {
        didSet {
            if let pathDynamicModal = pathDynamicModal {
                pathDynamicModal.closedHandler = { [weak self] () -> Void in
                    self?.pathDynamicModal = nil
                }
            }
        }
    }
    
    var refreshControl: UIRefreshControl?
    var imagePickerController: UIImagePickerController?
    var didCancelHandler: () -> Void = { }
    var didFinishPickingMediaHandler: (UIImage?) -> Void = { (image) in }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(MovreakViewController.userDidSignInOrOut(sender:)), name: kUserDidSignInOrOutNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    // MARK: - Helpers
    
    func presentImagePickerController(didCancelHandler: @escaping () -> Void, didFinishPickingMediaHandler: @escaping (UIImage?) -> Void) {
        
        imagePickerController = UIImagePickerController()
        imagePickerController?.delegate = self
        imagePickerController?.mediaTypes = [kUTTypeImage as String]
        imagePickerController?.allowsEditing = true
        
        self.didCancelHandler = didCancelHandler
        self.didFinishPickingMediaHandler = didFinishPickingMediaHandler
        
        let camera = UIAlertAction(title: "Taking a Photo by Camera", style: .default, handler: { (action) -> Void in
            
            self.imagePickerController?.sourceType = .camera
            self.imagePickerController?.cameraCaptureMode = .photo
            if let imagePickerController = self.imagePickerController {
                self.present(imagePickerController, animated: true, completion: nil)
            }
        })
        let gallery = UIAlertAction(title: "Choosing Photo from library", style: .default, handler: { (action) -> Void in
           
            self.imagePickerController?.sourceType = .photoLibrary
            if let imagePickerController = self.imagePickerController {
                self.present(imagePickerController, animated: true, completion: nil)
            }
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
        
            self.imagePickerController?.delegate = nil
            self.imagePickerController = nil
        }
        
        let alertController = UIAlertController(title: nil, message: "Change Photo by...", preferredStyle: .actionSheet)
        alertController.addAction(gallery)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alertController.addAction(camera)
        }
        alertController.addAction(cancel)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func presentImagePickerController(completion: @escaping (_ assets: [DKAsset]) -> Void) {
        
        let imagePickerController = DKImagePickerController()
        imagePickerController.assetType = .allPhotos
        imagePickerController.singleSelect = true
        imagePickerController.didSelectAssets = completion
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func signIn(completion: @escaping MovreakCompletion<Bool>) {
        
        pathDynamicModal = presentSignInView(in: view) { (signInProvider) in
            let signInCompletion: MovreakCompletion<Bool> = { (result, error) in
                self.hideLoadingView()
                
                if let result = result, result == true {
                    completion(true, nil)
                    self.pathDynamicModal?.closeWithLeansRight()
                }
                else if let error = error {
                    completion(false, error)
                }
                else {
                    completion(false, nil)
                }
            }
            
            switch signInProvider {
            case .facebook:
                self.showLoadingView(in: self.view, label: "Connect with Facebook...")
                UserManager.shared.connectToFacebook()
                    .subscribe { [weak self] (event) in
                        if let weakSelf = self {
                            
                            switch event {
                            case .next(let response):
                                if let _ = response as? AccessToken {
                                    weakSelf.showLoadingView(in: weakSelf.view, label: "Load Facebook profile...")
                                }
                                else if let _ = response as? JSON {
                                    weakSelf.showLoadingView(in: weakSelf.view, label: "Signing-in to Movreak...")
                                }
                                else if let _ = response as? MVProfile {
                                }
                                else {
                                }
                                
                            case .error(let error):
                                weakSelf.hideLoadingView()
                                signInCompletion(false, error)
                                
                            case .completed:
                                weakSelf.hideLoadingView()
                                signInCompletion(true, nil)
                            }
                        }
                    }
                    .disposed(by: disposeBag)
                
            case .twitter:
                self.showLoadingView(in: self.view, label: "Connect with Twitter...")
                UserManager.shared.connectToTwitter()
                    .subscribe { [weak self] (event) in
                        if let weakSelf = self {
                            
                            switch event {
                            case .next(let response):
                                if let _ = response as? TWTRSession {
                                    weakSelf.showLoadingView(in: weakSelf.view, label: "Load Twitter profile...")
                                }
                                else if let _ = response as? JSON {
                                    weakSelf.showLoadingView(in: weakSelf.view, label: "Signing-in to Movreak...")
                                }
                                else if let _ = response as? MVProfile {
                                }
                                else {
                                    
                                }
                                
                            case .error(let error):
                                weakSelf.hideLoadingView()
                                signInCompletion(false, error)
                                
                            case .completed:
                                weakSelf.hideLoadingView()
                                signInCompletion(true, nil)
                            }
                        }
                    }
                    .disposed(by: disposeBag)
                
            case .path:
                let error = NSError(domain: "MOVREAK", code: 0, userInfo: [NSLocalizedDescriptionKey: "Please sign-in with Facebook or Twitter first"])
                signInCompletion(false, error)
            }
        }
    }
    
    func userDidSignInOrOut(sender: Notification) {
        
        if UserManager.shared.profile == nil {
            userDidSignOut()
        }
        else {
            userDidSignIn()
        }
    }
    
    func userDidSignIn() { }
    
    func userDidSignOut() { }
    
    func refresh(sender: UIRefreshControl) {
        
    }
    
    func barButtonItemDoubleTapped() {
        
    }
    
    func setupRefreshControl(with scrollView: UIScrollView) {
        
        // Programmatically inserting a UIRefreshControl
        let refreshControl = UIRefreshControl()
        scrollView.addSubview(refreshControl)
        
        // When activated, invoke our refresh function
        refreshControl.addTarget(self, action: #selector(MovreakViewController.refresh(sender:)), for: .valueChanged)
        
        self.refreshControl = refreshControl
    }
}

// MARK: - UIGestureRecognizerDelegate
extension MovreakViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension MovreakViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        dismiss(animated: true) {
            
            picker.delegate = nil
            self.imagePickerController = nil
        
            self.didCancelHandler()
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var image: UIImage?
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            image = editedImage
        }
        else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            image = originalImage
        }
     
        dismiss(animated: true) {
            
            picker.delegate = nil
            self.imagePickerController = nil
            
            self.didFinishPickingMediaHandler(image)
        }
    }
}

// MARK: - DZNEmptyDataSetSource
extension MovreakViewController: DZNEmptyDataSetSource {
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "img_movreak")
    }
    
    func imageAnimation(forEmptyDataSet scrollView: UIScrollView!) -> CAAnimation! {
        
        let animation = CABasicAnimation(keyPath: "transform.rotation.y")
        animation.fromValue = 0.0
        animation.toValue = CGFloat.pi * 2
        animation.duration = 1.5
        animation.isCumulative = true
        animation.repeatCount = Float.infinity
        
        return animation
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        
        if !isLoading {
            return NSAttributedString(string: titleForEmptyDataSet, attributes: [NSFontAttributeName: kCoreSansBold24Font])
        }
        return nil
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
       
        var title = "Tap to refresh"
        if isLoading {
            if let message = MVSetting.current()?.randomLoadingMessage() {
                title = message
            }
        }
        return NSAttributedString(string: title, attributes: [NSFontAttributeName: kCoreSans17Font])
    }
}

// MARK: - DZNEmptyDataSetDelegate
extension MovreakViewController: DZNEmptyDataSetDelegate {
    
    func emptyDataSetShouldAnimateImageView(_ scrollView: UIScrollView!) -> Bool {
        return isLoading
    }
    
    func emptyDataSet(_ scrollView: UIScrollView!, didTap view: UIView!) {
     
        
    }
}

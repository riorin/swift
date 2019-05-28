//
//  TabBarController.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 9/23/16.
//  Copyright © 2016 DyCode. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    var viewDidAppearedOnce: Bool = false
    var lastTapDate: Date = Date()
    
    var movreakButton: DCPathButton!
    let buttons: [DCPathItemButton] = [
        DCPathItemButton(image: UIImage(named: "icn_movies")!, index: 0),
        DCPathItemButton(image: UIImage(named: "icn_cinemas")!, index: 1),
        DCPathItemButton(image: UIImage(named: "icn_watched_movies")!, index: 2),
        DCPathItemButton(image: UIImage(named: "icn_user_reviews")!, index: 3)
    ]
    
    var pathDynamicModal: PathDynamicModal? {
        didSet {
            if let pathDynamicModal = pathDynamicModal {
                pathDynamicModal.closedHandler = { [weak self] () -> Void in
                    self?.pathDynamicModal = nil
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        configureMovreakButton()
        delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        if !viewDidAppearedOnce {
            viewDidAppearedOnce = true
            
            if let items = tabBar.items {
                for item in items {
                    item.image = item.image?.withRenderingMode(.alwaysOriginal)
                    item.selectedImage = item.selectedImage?.withRenderingMode(.alwaysOriginal)
                    item.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.white], for: .normal)
                    item.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.white], for: .selected)
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .default
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    // MARK: - Helpers
    
    func configureMovreakButton() {
        
        movreakButton = DCPathButton(center: UIImage(named: "icn_movreak_off"), highlightedImage: UIImage(named: "icn_movreak_off"))
        movreakButton.delegate = self
        movreakButton.allowSounds = true
        movreakButton.dcButtonCenter = tabBar.center
        movreakButton.allowCenterButtonRotation = false
        movreakButton.bloomRadius = 105
        movreakButton.bottomViewColor = UIColor.black
        movreakButton.autoresizingMask = .flexibleTopMargin
        
        movreakButton.addPathItems(buttons)
        
        view.addSubview(movreakButton)
    }
}

// MARK: -
extension TabBarController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        if viewController == tabBarController.selectedViewController {
            let date = Date()
            
            var movreakViewController: MovreakViewController?
            if let navigationController = viewController as? UINavigationController {
                if let viewController = navigationController.viewControllers.first as? MovreakViewController {
                    
                    movreakViewController = viewController
                }
            }
            else if let viewController = viewController as? MovreakViewController {
                movreakViewController = viewController
            }
            
            if date.timeIntervalSince(lastTapDate) < 0.5 {
                movreakViewController?.barButtonItemDoubleTapped()
                lastTapDate = Date(timeIntervalSince1970: 0)
            }
            else {
                lastTapDate = date
            }
            
            return false
        }
        
        return true
    }
}

// MARK: - DCPathButtonDelegate
extension TabBarController: DCPathButtonDelegate {
    
    func pathButton(_ dcPathButton: DCPathButton!, clickItemButtonAt itemButtonIndex: UInt) {
        
        switch itemButtonIndex {
        case 0:
            showMoviesViewController(in: navigationController)
            
        case 1:
            showCinemasViewController(in: navigationController)
            
        case 2:
            pathDynamicModal = presentSignInView(in: view) { (signInProvider) in
                
                let completion: MovreakCompletion<Bool> = { (result, error) in
                    self.hideLoadingView()
                    
                    if let result = result, result == true {
                        self.showMoviesViewController(in: self.navigationController)
                        self.pathDynamicModal?.closeWithLeansRight()
                    }
                    else if let error = error {
                        self.presentErrorNotificationView(with: error.localizedDescription)
                    }
                    else {
                        
                    }
                }
                
                switch signInProvider {
                case .facebook:
                    self.showLoadingView(in: self.view, label: "Connect with Facebook...")
                    UserManager.shared.connectToFacebook(completion: completion)
                    
                case .twitter:
                    self.showLoadingView(in: self.view, label: "Connect with Twitter...")
                    UserManager.shared.connectToTwitter(completion: completion)
                    
                default:
                    break
                }
            }
            
        case 3:
            showUserReviewsViewController(in: navigationController)
            
        default:
            break
        }
    }
}

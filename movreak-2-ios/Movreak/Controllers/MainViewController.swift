//
//  MainViewController.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 1/5/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var tabBar: UITabBar!
    var movreakButton: DCPathButton!
    let buttons: [DCPathItemButton] = [
        DCPathItemButton(image: UIImage(named: "icn_movies"), highlightedImage: UIImage(named: "icn_movies"), backgroundImage: nil, backgroundHighlightedImage: nil)!,
        DCPathItemButton(image: UIImage(named: "icn_cinemas"), highlightedImage: UIImage(named: "icn_cinemas"), backgroundImage: nil, backgroundHighlightedImage: nil)!,
        DCPathItemButton(image: UIImage(named: "icn_watched_movies"), highlightedImage: UIImage(named: "icn_watched_movies"), backgroundImage: nil, backgroundHighlightedImage: nil)!,
        DCPathItemButton(image: UIImage(named: "icn_user_reviews"), highlightedImage: UIImage(named: "icn_user_reviews"), backgroundImage: nil, backgroundHighlightedImage: nil)!
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
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
    
    func setupViews() {
        
        if let items = tabBar.items {
            for item in items {
                item.image = item.image?.withRenderingMode(.alwaysOriginal)
                item.selectedImage = item.selectedImage?.withRenderingMode(.alwaysOriginal)
                item.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.white], for: .normal)
                item.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.white], for: .selected)
            }
        }
        
        movreakButton = DCPathButton(center: UIImage(named: "icn_movreak_off"), highlightedImage: UIImage(named: "icn_movreak_off"))
        movreakButton.delegate = self
        movreakButton.dcButtonCenter = tabBar.center
        movreakButton.allowSounds = true
        movreakButton.allowCenterButtonRotation = false
        movreakButton.bloomRadius = 105
        movreakButton.bottomViewColor = UIColor.black
        
        movreakButton.addPathItems(buttons)
        
        view.addSubview(movreakButton)
    }
    
}

// MARK: - DCPathButtonDelegate
extension MainViewController: DCPathButtonDelegate {
    
    func pathButton(_ dcPathButton: DCPathButton!, clickItemButtonAt itemButtonIndex: UInt) {
        
    }
}

//
//  Home2ViewController.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 6/21/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import UIKit

class Home2ViewController: MovreakViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    
    lazy var cardsViewController: CardsViewController = {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "Cards") as! CardsViewController
        viewController.delegate = self
        
        return viewController
    }()
    
    lazy var homeViewController: HomeViewController = {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "Home") as! HomeViewController
        
        return viewController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - UIScrollViewDelegate
extension Home2ViewController: UIScrollViewDelegate {
    
}

// MARK: - CardsViewControllerDelegate
extension Home2ViewController: CardsViewControllerDelegate {
    
    func cardsViewController(viewController: CardsViewController, didSelectCardType cardType: CardType) {
        
    }
}

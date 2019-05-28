//
//  MovieViewController.swift
//  LoginDemo
//
//  Created by Bayu Yasaputro on 05/04/18.
//  Copyright © 2018 DyCode. All rights reserved.
//

import UIKit

class MovieViewController: UIViewController {

    var movieId: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func backButtonTapped(_ sender: Any) {
        
        if navigationController?.viewControllers.first == self {
            dismiss(animated: true, completion: nil)
        }
        else {
            navigationController?.popViewController(animated: true)
        }
    }
}


// MARK: - UIViewController
extension UIViewController {
    
    func showMovieViewController(with movieId: Int) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "movie") as! MovieViewController
        
        vc.movieId = movieId
        
        navigationController?.pushViewController(vc, animated: true)
    }
}

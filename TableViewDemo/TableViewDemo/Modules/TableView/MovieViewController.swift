//
//  MovieViewController.swift
//  TableViewDemo
//
//  Created by Bayu Yasaputro on 29/03/18.
//  Copyright © 2018 DyCode. All rights reserved.
//

import UIKit
import RealmSwift

class MovieViewController: UIViewController {

    @IBOutlet weak var backdropImageView: UIImageView!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    
    var movieId: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadData()
    }
    
    func loadData() {
        
        if let movieId = movieId {
            let realm = try! Realm()
            
            if let movie = realm.object(ofType: Movie.self, forPrimaryKey: movieId) {
             
                let backdropUrl = "https://image.tmdb.org/t/p/w1280\(movie.posterPath)"
                let posterUrl = "https://image.tmdb.org/t/p/w185\(movie.posterPath)"
                
                backdropImageView.kf.setImage(with: URL(string: backdropUrl))
                posterImageView.kf.setImage(with: URL(string: posterUrl))
                titleLabel.text = movie.title
                overviewLabel.text = movie.overview
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension UIViewController {
    
    func showMovieViewController(with movieId: Int) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "movie") as! MovieViewController
        viewController.movieId = movieId
        
        navigationController?.pushViewController(viewController, animated: true)
    }
}


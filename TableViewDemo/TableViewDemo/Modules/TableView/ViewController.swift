//
//  ViewController.swift
//  TableViewDemo
//
//  Created by Bayu Yasaputro on 27/03/18.
//  Copyright © 2018 DyCode. All rights reserved.
//

import UIKit
import Kingfisher
import RealmSwift
import RxSwift
import UIScrollView_InfiniteScroll

typealias ImageCompletion = (UIImage?) -> Void
func downloadImage(with url: URL, completion: @escaping ImageCompletion) {
    
    DispatchQueue.global().async {
        
        if let data = try? Data.init(contentsOf: url) {
            let image = UIImage.init(data: data)
            
            DispatchQueue.main.async {
                completion(image)
            }
        }
        else {
            DispatchQueue.main.async {
                completion(nil)
            }
        }
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    weak var refreshControl: UIRefreshControl!
    
    var movies: [Movie] = []
    var page = 1
    
    let disposeBag = DisposeBag()
    
    func loadLocalMovies() {
        
        let realm = try! Realm()
        movies = Array(realm.objects(Movie.self))
    }
    
    func loadMovies(_ page: Int = 1) {
        
        provider.rx.request(.discoverMovie(page))
            .subscribe { (event) in
                
                switch event {
                case .success(let result):
                    do {
                        let response = try JSONDecoder().decode(Movies.self, from: result.data)
                        
                        //                        self
                        self.movies = response.results
                        
                        self.tableView.reloadData()
                    }
                    catch {
                        print(error.localizedDescription)
                    }
                    
                case .error(let error):
                    print(error.localizedDescription)
                }
                
                self.refreshControl.endRefreshing()
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupViews()
        loadMovies()
    }

    // MARK: - Helpers
    
    func setupViews() {
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        
        tableView.addSubview(refreshControl)
        self.refreshControl = refreshControl
        
        tableView.register(UINib(nibName: "MovieTableViewCell", bundle: nil), forCellReuseIdentifier: "MovieCellId")
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 111
        
        tableView.addInfiniteScroll {(tableView) in
            self.loadMovies(self.page)
        }
    }
    
    // MARK: - Actions
    
    @objc func refresh(_ sender: UIRefreshControl) {
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
            
            sender.endRefreshing()
        }
    }
}

// MARK: - Table View
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCellId", for: indexPath) as! MovieTableViewCell
        
        let movie = movies[indexPath.row]
        cell.titleLabel?.text = movie.title
        cell.overviewLabel?.text = movie.overview
        cell.movieImageView.image = nil
        
        let tag = cell.tag + 1
        cell.tag = tag
        
        let urlString = "https://image.tmdb.org/t/p/w185\(movie.posterPath)"
        cell.movieImageView.kf.setImage(with: URL(string: urlString))
        
//        if let url = URL(string: urlString) {
//            downloadImage(with: url, completion: { (image) in
//                if cell.tag == tag {
//                    cell.movieImageView.image = image
//                }
//            })
//
////            DispatchQueue.global().async {
////
////                if let data  = try? Data.init(contentsOf: url) {
////                    let image = UIImage.init(data: data)
////
////                    DispatchQueue.main.async {
////                        if cell.tag == tag {
////                            cell.movieImageView.image = image
////                        }
////                    }
////                }
////            }
//        }
        
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let movie = movies[indexPath.row]
        showMovieViewController(with: movie.movieId)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        if indexPath.row == 0 { return false }
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            movies.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//
//        return 110
//    }
}

// MARK: - MovieTableViewCellDelegate
extension ViewController: MovieTableViewCellDelegate {
    
    func movieTableViewCellReviewButtonTapped(cell: MovieTableViewCell) {
        
        if let indexPath = tableView.indexPath(for: cell) {
           
            let movie = movies[indexPath.row]
            // implementation
        }
    }
}





//
//  MoviesViewController.swift
//  LoginDemo
//
//  Created by Bayu Yasaputro on 04/04/18.
//  Copyright © 2018 DyCode. All rights reserved.
//

import UIKit
import RxSwift
import Kingfisher
import UIScrollView_InfiniteScroll
import RealmSwift

class MoviesViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    weak var refreshControl: UIRefreshControl!
    
    var movies: [Movie] = []
    let disposeBag = DisposeBag()
    
    var totalPage = 0
    var page = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
        
        refreshControl.beginRefreshing()
        loadMovies()
    }
    
    @objc func refresh(_ sender: UIRefreshControl) {
        loadMovies()
    }
    
    func setupViews() {
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        
        collectionView.addSubview(refreshControl)
        self.refreshControl = refreshControl
        
        collectionView.addInfiniteScroll { (collectionView) in
            self.loadMovies(self.page + 1)
        }
        
        collectionView.setShouldShowInfiniteScrollHandler { (collectionView) -> Bool in
            return self.page < self.totalPage
        }
    }
    
    func loadMovies(_ page: Int = 1) {
        
        provider.rx.request(.discoverMovie(page))
            .map(to: Movies.self)
            .subscribe { [weak self] (event) in
                
                switch event {
                case .success(let movies):
                    
                    let realm = try! Realm()
                    try! realm.write {
                        realm.add(movies.results, update: true)
                    }
                    
                    if page == 1 {
                        self?.movies = movies.results
                    }
                    else {
                        self?.movies.append(contentsOf: movies.results)
                    }
                    
                    self?.totalPage = movies.total_pages
                    self?.page = page
                    
                    self?.collectionView.reloadData()
                    
                case .error(let error):
                    print(error.localizedDescription)
                }
                
                self?.refreshControl.endRefreshing()
                self?.collectionView.finishInfiniteScroll()
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - UICollectionViewDataSource
extension MoviesViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath)
        
        let movie = movies[indexPath.row]
        let urlString = "https://image.tmdb.org/t/p/w780\(movie.backdropPath)"
        
        let imageView = cell.viewWithTag(101) as! UIImageView
        imageView.kf.setImage(with: URL(string: urlString))
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension MoviesViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let movie = movies[indexPath.item]
        showMovieViewController(with: movie.movieId)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MoviesViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.frame.width - 30
        let height = width * 9 / 16

        return CGSize(width: width, height: height)
        
        
//        var height = CGFloat(128)
//        if #available(iOS 11.0, *) {
//            height = ((collectionView.frame.height - collectionView.safeAreaInsets.top - collectionView.safeAreaInsets.bottom) - CGFloat(45.0)) / CGFloat(2.0)
//        } else {
//            // Fallback on earlier versions
//        }
//        let width = height *  16 / 9
//
//        return CGSize(width: width, height: height)

    }
}















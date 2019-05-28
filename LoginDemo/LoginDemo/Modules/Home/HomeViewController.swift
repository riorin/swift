//
//  HomeViewController.swift
//  LoginDemo
//
//  Created by Bayu Yasaputro on 03/04/18.
//  Copyright © 2018 DyCode. All rights reserved.
//

import UIKit
import RxSwift
import Kingfisher

class HomeViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var movies: [Movie] = []
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 128
        
        loadMovies()
    }
    
    func loadMovies() {
        
        provider.rx.request(.discoverMovie(1))
            .subscribe { (event) in
                
                switch event {
                case .success(let result):
                    do {
                        let response = try JSONDecoder().decode(Movies.self, from: result.data)
                        self.movies = response.results
                        self.tableView.reloadData()
                    }
                    catch {
                        print(error.localizedDescription)
                    }
                    
                case .error(let error):
                    print(error.localizedDescription)
                }
            }
            .disposed(by: disposeBag)
    }
    

    @IBAction func logoutButtonTapped(_ sender: UIBarButtonItem) {
        
        UserDefaults.standard.setValue(nil, forKey: "kEmailKey")
        UserDefaults.standard.synchronize()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.showLoginViewController()
    }
}

// MARK: - UITableViewDataSource
extension HomeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
//        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
//
//        let movie = movies[indexPath.row]
//        cell.textLabel?.text = movie.title
//        cell.detailTextLabel?.text = movie.overview
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieCellId", for: indexPath) as! MovieTableViewCell
        let tag = cell.tag + 1
        cell.tag = tag
        
        let movie = movies[indexPath.row]
        cell.titleLabel?.text = movie.title
        cell.overviewLabel?.text = movie.overview
        
        let urlString = "https://image.tmdb.org/t/p/w185\(movie.posterPath)"
        cell.loadingView.startAnimating()
        cell.posterImageView.kf.setImage(with: URL(string: urlString)) { (_, _, _, _) in
            cell.loadingView.stopAnimating()
        }
        
//        cell.posterImageView.image = nil
//
//        let urlString = "https://image.tmdb.org/t/p/w185\(movie.posterPath)"
//        if let url = URL(string: urlString) {
//
//            cell.loadingView.startAnimating()
//            downloadImage(with: url) { (image) in
//
//                if cell.tag == tag {
//                    cell.loadingView.stopAnimating()
//                    cell.posterImageView?.image = image
//                }
//            }
//        }
        
        cell.delegate = self
        
        return cell
    }
}

func downloadImage(with url: URL, completion: @escaping (UIImage?) -> Void) {
    
    DispatchQueue.global().async {
        
        let data = try? Data.init(contentsOf: url)
        
        if let data = data {
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

// MARK: - UITableViewDelegate
extension HomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            movies.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        return [
            UITableViewRowAction(style: .normal, title: "Close", handler: { (action, indexPath) in
                tableView.isEditing = false
            }),
            UITableViewRowAction(style: .destructive, title: "Delete", handler: { (action, indexPath) in
                self.movies.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            })
        ]
    }
}

// MARK: - MovieTableViewCellDelegate
extension HomeViewController: MovieTableViewCellDelegate {
    
    func movieTableViewCellReButtontapped(cell: MovieTableViewCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            
            let movie = movies[indexPath.row]
            print("Re: \(movie.title)")
        }
    }
}






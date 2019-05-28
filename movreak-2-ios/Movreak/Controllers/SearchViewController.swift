//
//  SearchViewController.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 3/21/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import UIKit
import CoreLocation

class SearchViewController: MovreakViewController {
    
    @IBOutlet weak var tableView: UITableView!
    weak var searchView: SearchView!
    
    var keyword: String?
    var movies: [MVMovie] = []
    var theaters: [MVTheater] = []
    
    var nearbyMovies: [MVMovie] = []
    var recentMovies: [MVMovie] = []
    
    var isPicker: Bool = false
    var completion: (MVMovie?) -> Void = { (movie) in }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
        
        nearbyMovies = MVNearbyMovies.nearby().movies.map { (movie) -> MVMovie in return movie }
        recentMovies = MVRecentMovies.recent().movies.map { (movie) -> MVMovie in return movie }
        
        if let keyword = keyword {
            searchMovie(with: keyword)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        configureNavigationBar(with: UIColor.black, barTintColor: UIColor.white)
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
        
        let searchView = SearchView.searchView(with: self)
        searchView.textField.text = keyword
        
        navigationItem.titleView = searchView
        self.searchView = searchView
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 202
        tableView.tableFooterView = UIView()
        
        titleForEmptyDataSet = "No Result"
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
    }
    
    func search(with text: String) {
        
        showLoadingView(in: view, label: "Searching...")
        
        isLoading = true
        provider2.request(.search(text))
            .mapObject(MVSearch.self)
            .subscribe { [weak self] event in
                
                switch event {
                case .next(let result):
                    self?.movies = result.movies
                    self?.theaters = result.theaters
                    
                case .completed:
                    self?.isLoading = false
                    self?.tableView.reloadData()
                    self?.hideLoadingView()
                    
                case .error(let error):
                    print(error.localizedDescription)
                    self?.isLoading = false
                    self?.tableView.reloadData()
                    self?.hideLoadingView()
                }
            }
            .disposed(by: disposeBag)
    }
    
    func searchMovie(with searchText: String) {
        
        var keyWord = searchText
        var yearString = ""
        var year: Int?
        
        if let range0 = searchText.range(of: "("), let range1 = searchText.range(of: ")") {
            if range0.upperBound < range1.upperBound {
                yearString = searchText.substring(to: range1.lowerBound).substring(from: range0.upperBound)
            }
        }
        
        var y: Int = 0
        if yearString.characters.count > 0 {
            let scanner = Scanner(string: yearString)
            scanner.scanInt(&y)
        }
        
        if y != 0 {
            keyWord = searchText.replacingOccurrences(of: "(\(yearString))", with: "")
            year = y
        }
        
        showLoadingView(in: view, label: "Search movie...")
        provider.request(.movieSearch(keyWord, year))
            .mapArray(MVMovie.self)
            .subscribe { [weak self] event in
                
                switch event {
                case .next(let movies):
                    self?.movies = movies
                    
                case .completed:
                    self?.tableView.reloadData()
                    self?.hideLoadingView()
                    
                case .error(let error):
                    print(error.localizedDescription)
                    self?.hideLoadingView()
                }
            }
            .disposed(by: disposeBag)
    }
    
    override func backButtonTapped(_ sender: AnyObject) {
        super.backButtonTapped(sender)
        completion(nil)
    }
}

// MARK: - UITableViewDataSource
extension SearchViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return movies.count
        }
        else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCellId", for: indexPath) as! SearchMovieResultViewCell
            
            cell.headerViewHeightConstraint.constant = 0
            if indexPath.row == 0 {
                cell.headerLabel.text = "Search results"
                cell.headerViewHeightConstraint.constant = 34
            }
            
            let movie = movies[indexPath.row]
            
            cell.movieImageView.image = MVMovie.defaultPosterImage()
            if let posterUrl = movie.posterUrl, let url = try? posterUrl.asURL() {
                cell.movieImageView.sd_setImage(with: url, placeholderImage: MVMovie.defaultPosterImage())
            }
            
            cell.titleLabel.text = movie.title?.uppercased()
            
            var subtitle = ""
            if let genre = movie.genre {
                subtitle = genre
            }
            cell.subtitleLabel.text = subtitle
            
            var durationText = ""
            if let year = movie.year.value {
                durationText = "\(year)"
            }
            if let duration = movie.duration.value?.durationString {
                if durationText.characters.count == 0 { durationText = duration }
                else { durationText = "\(durationText), \(duration)"}
            }
            cell.yearLabel.text = durationText
            
            if isPicker {
                cell.detailButton.isHidden = false
            }
            
            cell.delegate = self
            
            return cell
        }
        else {
        
            let cell = tableView.dequeueReusableCell(withIdentifier: "MoviesCellId", for: indexPath) as! SearchMoviesViewCell
            cell.tag = indexPath.section
            
            if indexPath.section == 1 {
                cell.titleLabel.text = "Playing near you"
            }
            else {
                cell.titleLabel.text = "Recent search"
            }
            
            cell.collectionView.dataSource = self
            cell.collectionView.delegate = self
            
            cell.collectionView.reloadData()
            
            return cell
        }
    }
}

// MARK: - UITableViewDelegate
extension SearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            let movie = movies[indexPath.row]
            MVRecentMovies.recent().add(movie: movie)
            
            
            if isPicker {
                completion(movie)
            }
            else {
                showMovieDetailViewController(withMovie: movie)
            }
        }
    }
}

// MARK: - UICollectionViewDataSource
extension SearchViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let cell = collectionView.tableViewCell {
            if cell.tag == 1 {
                if nearbyMovies.count > 0 {
                    return nearbyMovies.count + 1
                }
                return 0
            }
            else {
                return recentMovies.count
            }
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCellId", for: indexPath) as! SearchMovieViewCell
        
        cell.tag = indexPath.item
        cell.seeAllButton.isHidden = true
        cell.seeAllButton.isEnabled = false
        cell.detailButton.isHidden = true
        
        var movie: MVMovie?
        if let tableViewCell = collectionView.tableViewCell {
            if tableViewCell.tag == 1 {
                
                if indexPath.item == nearbyMovies.count {
                    
                    cell.seeAllButton.isHidden = false
                    cell.seeAllButton.isEnabled = true
                    cell.seeAllButton.titleLabel?.numberOfLines = 2
                    cell.seeAllButton.titleLabel?.textAlignment = .center
                    
                    let attString = NSMutableAttributedString(string: "See all", attributes: [NSFontAttributeName: kCoreSansBold15Font, NSForegroundColorAttributeName: k0C5BE8Color])
                    attString.append(NSAttributedString(string: "\n\(nearbyMovies.count) movies", attributes: [NSFontAttributeName: kCoreSans14Font, NSForegroundColorAttributeName: k888888Color]))
                    cell.seeAllButton.setAttributedTitle(attString, for: .normal)
                    
                    return cell
                }
                
                movie = nearbyMovies[indexPath.item]
            }
            else {
                movie = recentMovies[indexPath.item]
            }
        }
        
        cell.titleLabel.text = movie?.title?.uppercased()
        
        cell.posterImageView.image = MVMovie.defaultPosterImage()
        if let posterUrl = movie?.posterUrl, let url = try? posterUrl.asURL() {
            loadImageAndImageColors(with: url, completion: { (image, imageColors) in
                if cell.tag == indexPath.item {
                    if let image = image {
                        
                        UIView.transition(with: cell, duration: 0.25, options: .transitionCrossDissolve, animations: {
                            cell.posterImageView.image = image
                            cell.imageColors = imageColors
                        }, completion: nil)
                    }
                }
            })
        }
        
        if isPicker {
            cell.detailButton.isHidden = false
        }
    
        cell.delegate = self
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension SearchViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 160, height: 138)
    }
}

// MARK: - UICollectionViewDelegate
extension SearchViewController: UICollectionViewDelegate {
 
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        var movie: MVMovie?
        if let tableViewCell = collectionView.tableViewCell {
            if tableViewCell.tag == 1 {
                movie = nearbyMovies[indexPath.item]
            }
            else {
                movie = recentMovies[indexPath.item]
            }
        }
        
        if !isPicker {
            showMovieDetailViewController(withMovie: movie)
        }
        else if let movie = movie {
            completion(movie)
        }
    }
}


// MARK: - SearchMovieResultViewCellDelegate
extension SearchViewController: SearchMovieResultViewCellDelegate {
 
    func searchMovieResultViewCellDetailButtonTapped(cell: SearchMovieResultViewCell) {
        
        if let indexPath = tableView.indexPath(for: cell) {
            
            let movie = movies[indexPath.row]
            showMovieDetailViewController(withMovie: movie)
        }
    }
}

// MARK: - SearchMovieViewCellDelegate
extension SearchViewController: SearchMovieViewCellDelegate {
    
    func searchMovieViewCellSeeAllButtonTapped(cell: SearchMovieViewCell) {
        
        if let tableViewCell = cell.tableViewCell, tableViewCell.tag == 1 {
            showMoviesViewController()
        }
    }
    
    func searchMovieViewCellDetailButtonTapped(cell: SearchMovieViewCell) {
        
        if let tableViewCell = cell.tableViewCell as? SearchMoviesViewCell {
            if let indexPath = tableViewCell.collectionView.indexPath(for: cell) {
                
                var movie: MVMovie?
                if tableViewCell.tag == 1 {
                    movie = nearbyMovies[indexPath.item]
                }
                else {
                    movie = recentMovies[indexPath.item]
                }
                showMovieDetailViewController(withMovie: movie)
            }
        }
    }
}

// MARK: - SearchViewDelegate
extension SearchViewController: SearchViewDelegate {

    func searchView(_ searchView: SearchView, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        return true
    }
    
    func searchViewShouldReturn(_ searchView: SearchView) -> Bool {
        
        if let text = searchView.textField.text, !text.isEmpty {
            searchMovie(with: text)
        }
        return true
    }
}

// MARK: - DZNEmptyDataSetDataSource, DZNEmptyDataSetDelegate
extension SearchViewController {
    
    override func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return nil
    }
    
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> NSAttributedString! {
        return nil
    }
    
    override func emptyDataSet(_ scrollView: UIScrollView!, didTap view: UIView!) {
        
        if !isLoading {
            searchView.textField.becomeFirstResponder()
        }
    }
}

// MARK: - UIViewController
extension UIViewController {
    
    func showSearchViewController(keyword q: String? = nil, in navigationController: UINavigationController? = nil, completion: ((MVMovie?) -> Void)? = nil) {
        
        let storyboard = UIStoryboard(name: "Search", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "Search") as! SearchViewController
        viewController.keyword = q
        if let completion = completion {
            viewController.completion = completion
            viewController.isPicker = true
        }
        
        var _navigationController: UINavigationController?
        if let navigationController = navigationController {
            _navigationController = navigationController
        }
        else {
            _navigationController = self.navigationController
        }
        _navigationController?.pushViewController(viewController, animated: true)
    }
}


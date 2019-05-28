//
//  MovieListViewController.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 3/7/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import UIKit
import RealmSwift
import SDWebImage
import UIScrollView_InfiniteScroll

typealias MoviePickerCompletion = (_ movie: MVMovie?) -> Void

enum MovieListType {
    case comingSoon
    case popular
    case list(MVMovieList)
}

class MovieListViewController: MovreakViewController  {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            if searchBar != nil {
                searchBar.delegate = self
                if let aClass = NSClassFromString("UISearchBarBackground"),
                    let subviews = searchBar.subviews.last?.subviews {
                    for view in subviews {
                        if view.isKind(of: aClass) {
                            view.removeFromSuperview()
                        }
                    }
                }
            }
        }
    }
    
    @IBOutlet weak var popularMovieSegmentedControlView: UIView!
    @IBOutlet weak var popularMovieSegmentedControl: UISegmentedControl!
    @IBOutlet weak var popularMovieFilterViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var popularMovieFilterViewBottomConstraint: NSLayoutConstraint!
    
    var listType: MovieListType = .popular {
        didSet {
            switch listType {
            case .list(let movieList):
                try! realm.write {
                    realm.add(movieList, update: true)
                }
                rawMovieList = movieList
                
            default:
                break
            }
        }
    }
    
    var movieList: [MVMovie] = []
    var rawMovieList: MVMovieList? {
        didSet {
            filterMovieList()
        }
    }
    
    var timeRange: MovieWatchingTimeRange = .allTime
    var popularMovies: [MVPopularMovie] = []
    var rawPopularMovies: [MVPopularMovie] = [] {
        didSet {
            filterPopularMovies()
        }
    }
    
    var comingSoons: [MVComingSoon] = []
    var rawComingSoons: [MVComingSoon] = [] {
        didSet {
            filterComingSoons()
        }
    }
    
    var setupPosterImageViewDidCalledOnce = false
    var posterImageIndex = 0
    
    var movies: [MVMovie] = []
    var rawMovies: [MVMovie] = []
    
    var completion: MoviePickerCompletion = { (movie) in }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupViews()
        loadMovies()
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
    
    // MARK: - Helpers
    
    func setupViews() {
        
        tableView.register(UINib(nibName: "PopularMovieViewCell", bundle: nil), forCellReuseIdentifier: "MovieCellId")
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 157
        
        tableView.tableFooterView = UIView()
        
        tableView.addInfiniteScroll { [weak self] (collectionView) in
            self?.loadMore()
        }
        tableView.setShouldShowInfiniteScrollHandler { [weak self] (collectionView) -> Bool in
            var shouldShowInfiniteScroll = false
            
            if let weakSelf = self {
                
                switch weakSelf.listType {
                case .popular:
                    shouldShowInfiniteScroll = true
                    
                default:
                    break
                }
            }
            return shouldShowInfiniteScroll
        }
        
        setupRefreshControl(with: tableView)
        
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        titleForEmptyDataSet = "No Movie :("
        
        switch listType {
        case .popular:
            title = "POPULAR MOVIES"
            popularMovieFilterViewHeightConstraint.constant = 44
            
        case .list:
            title = rawMovieList?.name?.uppercased()
            popularMovieFilterViewHeightConstraint.constant = 0
            
        case .comingSoon:
            title = "COMING SOON"
            popularMovieFilterViewHeightConstraint.constant = 0
        }
        view.layoutIfNeeded()
        
        NotificationCenter.default.addObserver(self, selector: #selector(MovieListViewController.keyboardWillShow_hide(sender:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MovieListViewController.keyboardWillShow_hide(sender:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func setupPosterImageView() {
        setupPosterImageViewDidCalledOnce = true
        
        var movie: MVMovie?
        switch listType {
        case .popular:
            if popularMovies.count > 0 {
                if posterImageIndex >= popularMovies.count {
                    posterImageIndex = 0
                }
                movie = popularMovies[posterImageIndex].movie
            }
            
        case .list:
            if movieList.count > 0 {
                if posterImageIndex >= movieList.count {
                    posterImageIndex = 0
                }
                movie = movieList[posterImageIndex]
            }
            
        case .comingSoon:
            let movies = comingSoons.flatMap({ (comingSoon) -> [MVMovie] in
                return comingSoon.movies
            })
            if movies.count > 0 {
                if posterImageIndex >= movies.count {
                    posterImageIndex = 0
                }
                movie = movies[posterImageIndex]
            }
        }
        
        if let movie = movie {
            
            if let posterUrl = movie.bigPosterUrl, let url = try? posterUrl.asURL() {
                SDWebImageManager.shared().downloadImage(with: url, options: [], progress: { (_, _) in }, completed: { (image, _, _, _, _) in
                    
                    if let image = image {
                        UIView.transition(with: self.imageView, duration: 1, options: .transitionCrossDissolve, animations: {
                            self.imageView.image = image
                        }, completion: nil)
                    }
                })
            }
            
            posterImageIndex = posterImageIndex + 1
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 10, execute: { [weak self] in
                self?.setupPosterImageView()
            })
        }
        else {
            setupPosterImageViewDidCalledOnce = false
        }
    }
    
    func loadMovies(skip: Int = 0) {
        
        switch listType {
        case .popular:
            loadPopularMovies(skip: skip)
            
        case .list:
            if let movieList = rawMovieList {
                loadMovieList(with: movieList.listID)
            }
            
        case .comingSoon:
            loadComingSoon()
        }
    }
    
    func loadComingSoon() {
        
        if let city = LocationManager.shared.city?.cityName, let countryCode = LocationManager.shared.city?.countryCode {
            
            isLoading = true
            provider.request(.comingSoon(city, countryCode))
                .mapArray(MVComingSoon.self)
                .subscribe { [weak self] (event) in
                    guard let weakSelf = self else { return }
                    
                    switch event {
                    case .next(let comingSoons):
                        weakSelf.rawComingSoons = comingSoons
                        
                    case .error(let error):
                        weakSelf.presentErrorNotificationView(with: error.localizedDescription)
                        weakSelf.isLoading = false
                        weakSelf.tableView.reloadData()
                        weakSelf.tableView.finishInfiniteScroll()
                        weakSelf.refreshControl?.endRefreshing()
                        
                    case .completed:
                        weakSelf.isLoading = false
                        weakSelf.tableView.reloadData()
                        weakSelf.tableView.finishInfiniteScroll()
                        weakSelf.refreshControl?.endRefreshing()
                        if !weakSelf.setupPosterImageViewDidCalledOnce {
                            weakSelf.setupPosterImageView()
                        }
                    }
                }
                .disposed(by: disposeBag)
        }
    }
    
    func loadMovieList(with listID: String) {
        
        isLoading = true
        provider.request(.movieList(listID))
            .mapObject(MVMovieList.self)
            .subscribe { [weak self] (event) in
                guard let weakSelf = self else { return }
                
                switch event {
                case .next(let movieList):
                    weakSelf.listType = .list(movieList)
                    weakSelf.posterImageIndex = 0
                    
                case .error(let error):
                    weakSelf.presentErrorNotificationView(with: error.localizedDescription)
                    weakSelf.isLoading = false
                    weakSelf.tableView.reloadData()
                    weakSelf.tableView.finishInfiniteScroll()
                    weakSelf.refreshControl?.endRefreshing()
                    
                case .completed:
                    weakSelf.isLoading = false
                    weakSelf.tableView.reloadData()
                    weakSelf.tableView.finishInfiniteScroll()
                    weakSelf.refreshControl?.endRefreshing()
                    if !weakSelf.setupPosterImageViewDidCalledOnce {
                        weakSelf.setupPosterImageView()
                    }
                }
            }
            .disposed(by: disposeBag)
    }
    
    func loadPopularMovies(skip: Int = 0) {
        
        isLoading = true
        provider.request(.popularMovies(skip, timeRange.rawValue))
            .mapArray(MVPopularMovie.self)
            .subscribe { [weak self] (event) in
                guard let weakSelf = self else { return }
                
                switch event {
                case .next(let movies):
                    if skip == 0 {
                        weakSelf.rawPopularMovies = movies
                        weakSelf.posterImageIndex = 0
                    }
                    else { weakSelf.rawPopularMovies += movies }
                    
                case .error(let error):
                    weakSelf.presentErrorNotificationView(with: error.localizedDescription)
                    weakSelf.isLoading = false
                    weakSelf.tableView.reloadData()
                    weakSelf.tableView.finishInfiniteScroll()
                    weakSelf.refreshControl?.endRefreshing()
                    weakSelf.popularMovieSegmentedControl.isEnabled = true
                    
                case .completed:
                    weakSelf.isLoading = false
                    weakSelf.tableView.reloadData()
                    weakSelf.tableView.finishInfiniteScroll()
                    weakSelf.refreshControl?.endRefreshing()
                    if !weakSelf.setupPosterImageViewDidCalledOnce {
                        weakSelf.setupPosterImageView()
                    }
                    weakSelf.popularMovieSegmentedControl.isEnabled = true
                }
            }
            .disposed(by: disposeBag)
    }
    
    func loadMore() {
        
        switch listType {
        case .popular:
            loadPopularMovies(skip: popularMovies.count)
            
        default:
            tableView.finishInfiniteScroll()
        }
    }
    
    func filterMovieList() {
        if searchBar == nil {
            movieList = rawMovieList?.movies.map({ (movie) -> MVMovie in
                return movie
            }) ?? []
        }
        else {
            if let rawMovieList = rawMovieList {
                if let text = searchBar.text, !text.isEmpty {
                    movieList = rawMovieList.movies.filter("title CONTAINS[c] %@", text.lowercased())
                        .map({ (movie) -> MVMovie in
                            return movie
                        })
                }
                else {
                    movieList = rawMovieList.movies.map({ (movie) -> MVMovie in
                        return movie
                    })
                }
            }
        }
    }
    
    func filterPopularMovies() {
        if searchBar == nil { return }
        
        if let text = searchBar.text, !text.isEmpty {
            popularMovies = rawPopularMovies.filter({ (popularMovie) -> Bool in
                return popularMovie.movie?.title?.lowercased().contains(text.lowercased()) == true
            })
        }
        else {
            popularMovies = rawPopularMovies
        }
    }
    
    func filterComingSoons() {
        if searchBar == nil { return }
        
        if let text = searchBar.text, !text.isEmpty {
            comingSoons = []
            for comingSoon in rawComingSoons {
                let movies = comingSoon.movies.filter({ (movie) -> Bool in
                    return movie.title?.lowercased().contains(text.lowercased()) == true
                })
                if movies.count > 0 {
                    let newComingSoon = MVComingSoon(object: comingSoon)
                    newComingSoon.movies = movies
                    comingSoons.append(newComingSoon)
                }
            }
        }
        else {
            comingSoons = rawComingSoons
        }
    }
    
    func filterMovies() {
        if searchBar == nil { return }
        
        if let text = searchBar.text, !text.isEmpty {
            movies = rawMovies.filter({ (movie) -> Bool in
                return movie.title?.lowercased().contains(text.lowercased()) == true
            })
        }
        else {
            movies = rawMovies
        }
    }
    
    // MARK: - Keyboard
    
    func keyboardWillShow_hide(sender: Notification) {
        
        if let userInfo = sender.userInfo {
            if let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue {
                let height = UIScreen.main.bounds.height - keyboardFrame.cgRectValue.minY
                
                var duration = 0.25
                if let animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? Double {
                    duration = animationDuration
                }
                
                popularMovieFilterViewBottomConstraint.constant = height
                UIView.animate(withDuration: duration) {
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func filterSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            timeRange = .allTime
            
        case 1:
            timeRange = .month
            
        case 2:
            timeRange = .week
            
        case 3:
            timeRange = .today
            
        default:
            break
        }
        
        sender.isEnabled = false
        refreshControl?.beginRefreshing()
        loadPopularMovies()
    }
    
    override func refresh(sender: UIRefreshControl) {
        loadMovies()
    }
}

// MARK: - UITableViewDataSource
extension MovieListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        switch listType {
        case .comingSoon:
            return comingSoons.count
            
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch listType {
        case .popular:
            return popularMovies.count
            
        case .list:
            return movieList.count
            
        case .comingSoon:
            return comingSoons[section].movies.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCellId", for: indexPath) as! PopularMovieViewCell
        
        switch listType {
        case .popular:
            
            let movie = popularMovies[indexPath.row]
            
            cell.movieImageView.image = MVMovie.defaultPosterImage()
            if let posterUrl = movie.movie?.posterUrl, let url = try? posterUrl.asURL() {
                cell.movieImageView.sd_setImage(with: url, placeholderImage: MVMovie.defaultPosterImage())
            }
            
            cell.titleLabel.text = movie.movie?.title
            
            cell.subtitleLabel.text = ""
            if let genre = movie.movie?.genre {
                cell.subtitleLabel.text = genre
            }
            
            var durationText = ""
            if let year = movie.movie?.year.value {
                durationText = "\(year)"
            }
            if let duration = movie.movie?.duration.value?.durationString {
                if durationText.characters.count == 0 { durationText = duration }
                else { durationText = "\(durationText), \(duration)"}
            }
            cell.durationLabel.text = durationText
            
            cell.scoreLabel.text = "%"
            if let score = movie.score.value {
                let scoreString = String(format: "%.1f", score)
                cell.scoreLabel.text = "\(scoreString)%"
            }
            
            cell.watchedLabel.isHidden = true
            if movie.watched.value == true {
                cell.watchedLabel.isHidden = false
            }
            
        case .list:
            
            let movie = movieList[indexPath.row]
            
            cell.movieImageView.image = MVMovie.defaultPosterImage()
            if let posterUrl = movie.posterUrl, let url = try? posterUrl.asURL() {
                cell.movieImageView.sd_setImage(with: url, placeholderImage: MVMovie.defaultPosterImage())
            }
            
            cell.titleLabel.text = movie.title
            
            cell.subtitleLabel.text = ""
            if let genre = movie.genre {
                cell.subtitleLabel.text = genre
            }
            
            var durationText = ""
            if let year = movie.year.value {
                durationText = "\(year)"
            }
            if let duration = movie.duration.value?.durationString {
                if durationText.characters.count == 0 { durationText = duration }
                else { durationText = "\(durationText), \(duration)"}
            }
            cell.durationLabel.text = durationText
            
            cell.scoreLabel.isHidden = true
            cell.watchedLabel.isHidden = true
            
        case .comingSoon:
            
            let movie = comingSoons[indexPath.section].movies[indexPath.row]
            
            cell.movieImageView.image = MVMovie.defaultPosterImage()
            if let posterUrl = movie.posterUrl, let url = try? posterUrl.asURL() {
                cell.movieImageView.sd_setImage(with: url, placeholderImage: MVMovie.defaultPosterImage())
            }
            
            cell.titleLabel.text = movie.title
            
            cell.subtitleLabel.text = ""
            if let genre = movie.genre {
                cell.subtitleLabel.text = genre
            }
            
            var durationText = ""
            if let date = movie.releaseDate {
                durationText = date.format(with: "MMM dd, yyyy")
                durationText = "Comming in \(durationText)"
            }
            cell.durationLabel.text = durationText
            
            cell.scoreLabel.isHidden = true
            cell.watchedLabel.isHidden = true
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension MovieListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var movie: MVMovie?
        switch listType {
        case .popular:
            movie = popularMovies[indexPath.row].movie
            
        case .list:
            movie = movieList[indexPath.row]
            
        case .comingSoon:
            movie = comingSoons[indexPath.section].movies[indexPath.row]
        }
        
        showMovieDetailViewController(withMovie: movie)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 44))
        view.backgroundColor = UIColor(white: 1, alpha: 0.95)
        
        let label = UILabel()
        label.font = kCoreSansBold13Font
        label.textColor = UIColor.black
        label.text = comingSoons[section].releaseWeek
        
        view.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[label]-15-|", options: .directionLeadingToTrailing, metrics: nil, views: ["label": label]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[label]-8-|", options: .directionLeadingToTrailing, metrics: nil, views: ["label": label]))
        
        let topSeparator = UIView()
        topSeparator.backgroundColor = UIColor.lightGray
        
        view.addSubview(topSeparator)
        
        topSeparator.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["view": topSeparator]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view(0.5)]", options: .directionLeadingToTrailing, metrics: nil, views: ["view": topSeparator]))
        
        let bottomSeparator = UIView()
        bottomSeparator.backgroundColor = UIColor.lightGray
        
        view.addSubview(bottomSeparator)
        
        bottomSeparator.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["view": bottomSeparator]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[view(0.5)]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["view": bottomSeparator]))
        
        return view
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch listType {
        case .comingSoon:
            return comingSoons[section].releaseWeek
            
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        switch listType {
        case .comingSoon:
            return 44
            
        default:
            return 0
        }
    }
}

// MARK: - UISearchBarDelegate
extension MovieListViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        switch listType {
        case .comingSoon:
            filterComingSoons()
            
        case .list:
            filterMovieList()
            
        case .popular:
            filterPopularMovies()
        }
        
        tableView.reloadData()
    }
}

// MARK: - DZNEmptyDataSetDelegate
extension MovieListViewController {
    
    override func emptyDataSet(_ scrollView: UIScrollView!, didTap view: UIView!) {
        
        if !isLoading {
            loadMovies()
            tableView.reloadEmptyDataSet()
        }
    }
}

// MARK: - UIViewController
extension UIViewController {
    
    func showMovieListViewController(with listType: MovieListType, in navigationController: UINavigationController? = nil) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "MovieList") as! MovieListViewController
        viewController.listType = listType
        
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

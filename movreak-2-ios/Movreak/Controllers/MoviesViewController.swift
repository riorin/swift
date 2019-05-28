//
//  MoviesViewController.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 8/19/16.
//  Copyright © 2016 DyCode. All rights reserved.
//

import UIKit
import CoreLocation
import SDWebImage
import UIImageColors

class MoviesViewController: MovreakViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var dateCityButton: UIButton!
    
    var movieSchedules: MVMovieSchedules?
    var movies: [MVMovie] = []
    
    var date: Date = Date() {
        didSet {
            setupDateCityTitle()
        }
    }
    
    var city: MVCity? {
        didSet {
            setupDateCityTitle()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
        setupDateCityTitle()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !viewDidAppearedOnce {
            viewDidAppearedOnce = true
            
            loadMovieSchedules()
        }
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        configureNavigationBar(with: UIColor.black, barTintColor: UIColor.white)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

    // MARK: - Helpers
    
    func setupViews() {
        
        if navigationController?.viewControllers.first == self {
            navigationItem.leftBarButtonItem = nil
        }
        
        titleForEmptyDataSet = "No Movie :("
        setupRefreshControl(with: collectionView)
        
        collectionView.register(UINib(nibName: "MovieViewCell", bundle: nil), forCellWithReuseIdentifier: "MovieCellId")
        
        collectionView.emptyDataSetSource = self
        collectionView.emptyDataSetDelegate = self
    }
    
    func setupDateCityTitle() {
        
        var strings: [String] = []
        
        var city = self.city
        if city == nil { city = LocationManager.shared.city }
        
        if let cityName = city?.cityName?.uppercased() {
            strings.append(cityName)
        }
        if date.isToday {
            strings.append("TODAY")
        }
        else {
            strings.append(date.format(with: "dd MMM").uppercased())
        }
        
        let title = strings.joined(separator: ", ")
        
        let attrString = NSMutableAttributedString(string: "\(title) ", attributes: [NSFontAttributeName: kCoreSans17Font, NSForegroundColorAttributeName: UIColor.black])
        let attachment = NSTextAttachment()
        attachment.image = UIImage(named: "navi_filter_normal")
        attachment.bounds = CGRect(x: 0.0, y: attachment.image!.size.height / 2, width: attachment.image!.size.width, height: attachment.image!.size.height)
        attrString.append(NSAttributedString(attachment: attachment))
        dateCityButton.setAttributedTitle(attrString, for: .normal)
    }
    
    func loadMovieSchedules() {
        
        var city = self.city
        if city == nil { city = LocationManager.shared.city }
        
        if let cityName = city?.cityName {
            
            isLoading = true
            provider.request(.movieSchedule(date, cityName))
                .mapObject(MVMovieSchedules.self)
                .subscribe { [weak self] (event) in
                    guard let weakSelf = self else { return }
                    
                    switch event {
                    case .next(let movieSchedules):
                        weakSelf.movieSchedules = movieSchedules
                        
                    case .completed:
                        weakSelf.configureMovies()
                        weakSelf.isLoading = false
                        weakSelf.collectionView.reloadData()
                        weakSelf.refreshControl?.endRefreshing()
                        if let status = weakSelf.movieSchedules?.state?.status?.lowercased(), status != "ok",
                            let message = weakSelf.movieSchedules?.state?.message {
                            weakSelf.presentWarningNotificationView(with: message)
                        }
                        
                    case .error(let error):
                        weakSelf.presentErrorNotificationView(with: error.localizedDescription)
                        weakSelf.isLoading = false
                        weakSelf.collectionView.reloadData()
                        weakSelf.refreshControl?.endRefreshing()
                    }
                }
                .disposed(by: disposeBag)
        }
        else {
            
            pathDynamicModal = presentCityPickerView(completion: { (viewController, city) in
                
                self.city = city
                
                LocationManager.shared.city = city
                if let cityName = city.cityName {
                    UserDefaults.standard.set(cityName, forKey: kLastSelectedCity)
                    UserDefaults.standard.synchronize()
                }
                
                self.loadMovieSchedules()
                
                viewController.removeFromParentViewController()
                self.pathDynamicModal?.closeWithLeansRight()
            })
        }
    }
    
    func configureMovies() {
        guard let schedules = movieSchedules?.schedules else { return }
        
        let movies: [MVMovie] = schedules.flatMap { (schedule) -> MVMovie? in
            return schedule.movie
        }
        
        var movieSet: [MVMovie] = []
        for movie in movies {
            if !movieSet.contains { (m) -> Bool in return m.movieID == movie.movieID } {
                movieSet.append(movie)
            }
        }
        
        self.movies = movieSet.sorted { (movies) -> Bool in
            var ascending = true
            if let ads0 = movies.0.ads.value, let ads1 = movies.1.ads.value {
                ascending = ads0 == true
                
                if ads0 == ads1 {
                    if let featured0 = movies.0.featured.value, let featured1 = movies.1.featured.value {
                        ascending = featured0 == true
                        
                        if featured0 == featured1 {
                            if let isNew0 = movies.0.isNew.value, let isNew1 = movies.1.isNew.value {
                                ascending = isNew0 == true
                                
                                if isNew0 == isNew1 {
                                    if let title0 = movies.0.title, let title1 = movies.1.title {
                                        ascending = title0.compare(title1) == .orderedAscending
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            return ascending
        }
        
        if date.isToday { MVNearbyMovies.nearby().add(movies: self.movies) }
    }
    
    // MARK: - Actions
    
    override func refresh(sender: UIRefreshControl) {
        loadMovieSchedules()
    }
    
    @IBAction func dateCityButtonTapped(_ sender: UIButton) {
        
        var city = self.city
        if city == nil { city = LocationManager.shared.city }
        
        presentDateCityPickerViewController(date: date, city: city) { (date, city) in
            
            self.date = date; self.city = city
            
            self.dismiss(animated: true, completion: {
                self.refreshControl?.beginRefreshing()
                self.loadMovieSchedules()
                self.collectionView.reloadEmptyDataSet()
            })
        }
    }
}

// MARK: - UICollectionViewDataSource

extension MoviesViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCardCellId", for: indexPath) as! MovieCardViewCell
        let tag = cell.tag + 1
        cell.tag = tag
        
        let movie = movies[indexPath.item]
        
        cell.posterImageView.image = MVMovie.defaultPosterImage()
        if let posterUrl = movie.posterUrl, let url = try? posterUrl.asURL() {
            loadImageAndImageColors(with: url, completion: { (image, imageColors) in
                if cell.tag == tag {
                    if let image = image {
                        cell.posterImageView.image = image
                        cell.imageColors = imageColors
                    }
                }
            })
        }
        
        cell.titleLabel.text = movie.title?.uppercased()
        
        var subtitle = ""
        if let year = movie.year.value { subtitle = "\(year) " }
        if let genre = movie.genre { subtitle = subtitle + genre }
        cell.subtitleLabel.text = subtitle
        
        cell.adBadgeImageView.isHidden = true
        cell.featuredBadgeImageView.isHidden = true
        cell.newBadgeImageView.isHidden = true
        if let ads = movie.ads.value, ads == true {
            cell.adBadgeImageView.isHidden = false
        }
        else if let featured = movie.featured.value, featured == true {
            cell.featuredBadgeImageView.isHidden = false
        }
        else if let isNew = movie.isNew.value, isNew == true {
            cell.newBadgeImageView.isHidden = false
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension MoviesViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width: CGFloat = (collectionView.frame.width - 45) / 2.0
        let height: CGFloat = width * kGoldenRation// + 58
        
        return CGSize(width: width, height: height)
    }
}

// MARK: - UICollectionViewDelegate
extension MoviesViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
     
        let movie = movies[indexPath.item]
        if let movieSchedules = movieSchedules?.schedules.filter({ (movieSchedule) -> Bool in
            return movieSchedule.movie?.movieID == movie.movieID
        }) {
            
            var navigationController = self.navigationController
            if navigationController?.viewControllers.first == self {
                navigationController = tabBarController?.navigationController
            }
            
            showMovieDetailViewController(withSchedules: movieSchedules, in: navigationController)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if scrollView != collectionView {
            
            let page = Int(scrollView.contentOffset.x / scrollView.frame.width)
            
            let indexPath = IndexPath(item: 0, section: 0)
            if let cell = collectionView.cellForItem(at: indexPath) as? FeaturedMoviesViewCell {
                cell.pageControl.currentPage = page
            }
        }
    }
}

// MARK: - DZNEmptyDataSetDelegate
extension MoviesViewController {
    
    override func emptyDataSet(_ scrollView: UIScrollView!, didTap view: UIView!) {
        
        if !isLoading {
            loadMovieSchedules()
            collectionView.reloadEmptyDataSet()
        }
    }
}

// MARK: - UIViewController
extension UIViewController {
    
    func showMoviesViewController(in navigationController: UINavigationController? = nil) {
     
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "Movies") as! MoviesViewController
        
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



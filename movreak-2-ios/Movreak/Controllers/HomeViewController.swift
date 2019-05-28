//
//  HomeViewController.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 10/26/16.
//  Copyright © 2016 DyCode. All rights reserved.
//

import UIKit
import RealmSwift

import CoreLocation
import SwiftyJSON

enum BackgroundViewState {
    case hidden
    case animating
    case visible
}

class HomeViewController: MovreakViewController {
    
    @IBOutlet weak var collectionView: WigglingCollectionView!
    @IBOutlet var tapGestureRecognizer: UITapGestureRecognizer!
    
    var cards: Results<MVCard>!
    var notificationToken: NotificationToken!
    
    var inCinema: [MVMovie] = []
    var comingSoon: [MVMovie] = []
    var popularMovies: [MVMovie] = []
    var featuredNews: [MVNews] = []
    var latestTrailers: [MVTrailer] = []
    var featuredTrailers: [MVTrailer] = []
    var popularMovieList: [MVMovieList] = []
    var latestReviews: [MVReview] = []
    
    var theaterSchedules: [MVTheaterSchedule] = []
    var cinemas: [MVTheater] = []
    
    
    var backgroundViewState: BackgroundViewState = .hidden
    var headerViewHeight: CGFloat {
        return 54 * 8
    }
        
    lazy var cardsViewController: CardsViewController = {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "Cards") as! CardsViewController
        viewController.delegate = self
        
        return viewController
    }()
    
    let kItemsPerCard: Int = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
        
        cards = realm.objects(MVCard.self).filter("isHidden = %@", false).sorted(byKeyPath: "displayOrder")
        notificationToken = cards.addNotificationBlock { [weak self] (changes) in
            guard let weakSelf = self else { return }
            
            switch changes {
            case .initial:
                NotificationCenter.default.post(name: kCardDidRemoveNotification, object: nil, userInfo: nil)
                weakSelf.setupHomeSections()
                
            case .update:
                NotificationCenter.default.post(name: kCardDidRemoveNotification, object: nil, userInfo: nil)
                weakSelf.collectionView.reloadData()
                weakSelf.setupHomeSections()
                
            case .error(let error):
                print(error.localizedDescription)
            }
        }
        
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
            
        becomeFirstResponder()
        
        configureNavigationBar(with: UIColor.black, barTintColor: UIColor.white)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !viewDidAppearedOnce {
            viewDidAppearedOnce = true
            
            self.hideCardsViewController()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        resignFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .default
        }
    }
    
    // MARK: - Helper
    
    func setupViews() {
        
        var contentInset = collectionView.contentInset
        contentInset.bottom += 305
        collectionView.contentInset = contentInset

        var scrollIndicatorInsets = collectionView.scrollIndicatorInsets
        scrollIndicatorInsets.bottom += 305
        collectionView.scrollIndicatorInsets = scrollIndicatorInsets
        
        let headerView = GSKStretchyHeaderView(frame: CGRect(x: 0, y: -headerViewHeight, width: UIScreen.main.bounds.width, height: headerViewHeight))
        headerView.minimumContentHeight = 0
        headerView.maximumContentHeight = headerViewHeight
        headerView.backgroundColor = .clear
        collectionView.addSubview(headerView)
        
        addChildViewController(cardsViewController)
        cardsViewController.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: headerViewHeight)
        cardsViewController.view.alpha = 1
        headerView.addSubview(cardsViewController.view)
        cardsViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        headerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["view": cardsViewController.view]))
        headerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view(\(headerViewHeight))]", options: .directionLeadingToTrailing, metrics: nil, views: ["view": cardsViewController.view]))
        
        collectionView.emptyDataSetSource = self
        collectionView.emptyDataSetDelegate = self
        titleForEmptyDataSet = "No Data :("
    }
    
    func loadData() {
        
        if LocationManager.shared.city != nil {
            
            loadHomeSections()
            loadTheaterSchedules()
        }
        else {
            
            pathDynamicModal = presentCityPickerView(completion: { (viewController, city) in
                
                LocationManager.shared.city = city
                if let cityName = city.cityName {
                    UserDefaults.standard.set(cityName, forKey: kLastSelectedCity)
                    UserDefaults.standard.synchronize()
                }
                
                self.loadData()
                
                viewController.removeFromParentViewController()
                self.pathDynamicModal?.closeWithLeansRight()
            })
        }
    }
    
    func loadHomeSections() {
        
        if let city = LocationManager.shared.city {
            
            isLoading = true
            provider.request(.home(city))
                .mapObject(MVHome.self)
                .subscribe { [weak self] event in
                    guard let weakSelf = self else { return }
                    
                    switch event {
                    case .next(let home):
                        let card = MVCard.homeCinamasCard()
                        home.cards.append(card)
                        try! realm.write {
                            for card in home.cards {
                                realm.add(card, update: true)
                            }
                            /*
                             for link in home.links {
                                realm.add(link, update: true)
                             }
                             */
                        }
                        
                    case .completed:
                        weakSelf.isLoading = false
                        weakSelf.refreshControl?.endRefreshing()
                        weakSelf.collectionView.reloadEmptyDataSet()
                        
                    case .error(let error):
                        weakSelf.isLoading = false
                        weakSelf.refreshControl?.endRefreshing()
                        weakSelf.collectionView.reloadEmptyDataSet()
                        weakSelf.presentErrorNotificationView(with: error.localizedDescription)
                    }
                }
                .disposed(by: disposeBag)
        }
        else {
            
            pathDynamicModal = presentCityPickerView(completion: { (viewController, city) in
                
                LocationManager.shared.city = city
                if let cityName = city.cityName {
                    UserDefaults.standard.set(cityName, forKey: kLastSelectedCity)
                    UserDefaults.standard.synchronize()
                }
                
                self.loadHomeSections()
                
                viewController.removeFromParentViewController()
                self.pathDynamicModal?.closeWithLeansRight()
            })
        }
    }
    
    func setupHomeSections() {
        
        for card in self.cards {
            if let cardType = CardType(rawValue: card.sectionID) {
                
                switch cardType {
                case .inCinema:
                    reloadInCinema(with: card)
                    
                case .comingSoon:
                    reloadComingSoon(with: card)
                    
                case .popularMovies:
                    reloadPopularMovies(with: card)
                    
                case .featuredNews:
                    reloadFeturedNews(with: card)
                    
                case .latestTrailers:
                    reloadLatestTrailers(with: card)
                    
                case .featuredTrailers:
                    reloadFeaturedTrailers(with: card)
                    
                case .popularMovieList:
                    reloadPopularMovieList(with: card)
                    
                case .latestReviews:
                    reloadLatestReviews(with: card)
                    
                case .cinemas:
                    break
                    
                case .ads:
                    break
                }
            }
        }
        collectionView.reloadData()
    }
    
    func reloadInCinema(with card: MVCard) {
        
        let movies = card.inCinema.sorted { (movies) -> Bool in
            if let title0 = movies.0.title, let title1 = movies.1.title {
                return title0 < title1
            }
            return true
        }
        self.inCinema = movies
        if let index = cards.index(of: card) {
            collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
        }
    }
    
    func reloadComingSoon(with card: MVCard) {
        
        let movies = card.comingSoon.sorted { (movies) -> Bool in
            if let title0 = movies.0.title, let title1 = movies.1.title {
                return title0 < title1
            }
            return true
        }
        self.comingSoon = movies
        if let index = cards.index(of: card) {
            collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
        }
    }
    
    func reloadPopularMovies(with card: MVCard) {
        
        let movies = card.popularMovies.sorted { (movies) -> Bool in
            if let title0 = movies.0.title, let title1 = movies.1.title {
                return title0 < title1
            }
            return true
        }
        self.popularMovies = movies
        if let index = cards.index(of: card) {
            collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
        }
    }
    
    func reloadLatestTrailers(with card: MVCard) {
        
        let trailers = card.latestTrailers.sorted { (trailers) -> Bool in
            if let date0 = trailers.0.createdDate, let date1 = trailers.1.createdDate {
                return date0 > date1
            }
            return true
        }
        self.latestTrailers = trailers
        if let index = cards.index(of: card) {
            collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
        }
    }
    
    func reloadFeaturedTrailers(with card: MVCard) {
        
        let trailers = card.featuredTrailers.sorted { (trailers) -> Bool in
            if let date0 = trailers.0.createdDate, let date1 = trailers.1.createdDate {
                return date0 > date1
            }
            return true
        }
        self.featuredTrailers = trailers
        if let index = cards.index(of: card) {
            collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
        }
    }
    
    func reloadPopularMovieList(with card: MVCard) {
        
        let movieList = card.popularMovieList.sorted { (movieList) -> Bool in
            if let date0 = movieList.0.createdDate, let date1 = movieList.1.createdDate {
                return date0 > date1
            }
            return true
        }
        self.popularMovieList = movieList
        if let index = cards.index(of: card) {
            collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
        }
    }
    
    func reloadLatestReviews(with card: MVCard) {
        
        let reviews = card.latestReviews.sorted { (reviews) -> Bool in
            if let date0 = reviews.0.submittedDate, let date1 = reviews.1.submittedDate {
                return date0 > date1
            }
            return true
        }
        self.latestReviews = reviews
        if let index = cards.index(of: card) {
            collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
        }
    }
    
    func reloadFeturedNews(with card: MVCard) {
        
        let newsList = card.featuredNews.sorted { (news) -> Bool in
            if let date0 = news.0.date, let date1 = news.1.date {
                return date0 > date1
            }
            return true
        }
        self.featuredNews = newsList
        if let index = cards.index(of: card) {
            collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
        }
        
        if featuredNews.count == 0 {
            loadNews()
        }
    }
    
    func loadNews() {
        
        provider.request(.news(0))
            .mapObject(MVNewsList.self)
            .subscribe { [weak self] event in
                
                switch event {
                case .next(let newsList):
                    try! realm.write {
                        for news in newsList.posts {
                            realm.add(news, update: true)
                        }
                    }
                    self?.featuredNews = newsList.posts
                    self?.collectionView.reloadData()
                    
                case .completed:
                    break
                    
                case .error(let error):
                    print(error.localizedDescription)
                }
            }
            .disposed(by: disposeBag)
    }
    
    func reloadTheaters() {
        
        let theaters: [MVTheater] = theaterSchedules.flatMap { (theaterSchedule) -> MVTheater? in
            return theaterSchedule.theater
        }
        
        var theaterSet: [MVTheater] = []
        for theater in theaters {
            if !theaterSet.contains { (t) -> Bool in return t.theaterID == theater.theaterID } {
                theaterSet.append(theater)
            }
        }
        
        self.cinemas = theaterSet.sorted { (theaters) -> Bool in
            var ascending = true
            if let name0 = theaters.0.name, let name1 = theaters.1.name {
                ascending = name0 < name1
            }
            return ascending
        }
        
        if let index = cards.index(matching: "sectionID = %@", CardType.cinemas.rawValue) {
            collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
        }
    }
    
    func loadTheaterSchedules() {
        
        if let cityName = LocationManager.shared.city?.cityName {
            
            provider.request(.theaterSchedule(Date(), cityName))
                .mapArray(MVTheaterSchedule.self)
                .subscribe { [weak self] event in
                    guard let weakSelf = self else { return }
                    
                    switch event {
                    case .next(let schedules):
                        try! realm.write {
                            for schedule in schedules {
                                realm.add(schedule, update: true)
                            }
                        }
                        weakSelf.theaterSchedules = schedules
                        weakSelf.reloadTheaters()
                        weakSelf.loadTheatersDetails()
                        
                    case .completed:
                        break
                        
                    case .error(let error):
                        print(error.localizedDescription)
                    }
                }
                .disposed(by: disposeBag)
        }
        else {
            
            pathDynamicModal = presentCityPickerView { (viewController, city) in
                
                LocationManager.shared.city = city
                if let cityName = city.cityName {
                    UserDefaults.standard.set(cityName, forKey: kLastSelectedCity)
                    UserDefaults.standard.synchronize()
                }
                
                self.loadTheaterSchedules()
                
                viewController.removeFromParentViewController()
                self.pathDynamicModal?.closeWithLeansRight()
            }

        }
    }
    
    func reloadTheater(_ theater: MVTheater) {
        
        if let i = cinemas.index(where: { (t) -> Bool in
            return t.theaterID == theater.theaterID
        }) {
            cinemas[i] = theater
            
            if let index = cards.index(matching: "sectionID = %@", CardType.cinemas.rawValue) {
                if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? CardItemsViewCell {
                    
                    let ip = IndexPath(item: i, section: 0)
                    cell.collectionView.reloadItems(at: [ip])
                }
            }
        }
    }
    
    func loadTheatersDetails() {
        
        for theater in cinemas {
            
            provider.request(.theaterDetail(theater.theaterID))
                .mapObject(MVTheaterDetail.self)
                .subscribe { [weak self] event in
                    guard let weakSelf = self else { return }
                    
                    switch event {
                    case .next(let theaterDetail):
                        if let theater = theaterDetail.theaters.first {
                            try! realm.write {
                                realm.add(theater, update: true)
                            }
                            weakSelf.reloadTheater(theater)
                        }
                        
                    case .completed:
                        break
                        
                    case .error(let error):
                        print(error.localizedDescription)
                    }
                }
                .disposed(by: disposeBag)
        }
    }
    
    func showCardsViewController() {
        backgroundViewState = .animating
        
        let contentOffset = CGPoint(x: 0, y: -(headerViewHeight + 0))
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.collectionView.contentOffset = contentOffset
            self.collectionView.contentInset = UIEdgeInsets(top: (self.headerViewHeight + 0), left: 0, bottom: 305, right: 0)
            self.collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 305, right: 0)
            
            self.cardsViewController.view.alpha = 1
            
        }) { (finished) in
            
            self.backgroundViewState = .visible
        }
    }
    
    func hideCardsViewController() {
        backgroundViewState = .animating
        
        collectionView.panGestureRecognizer.setTranslation(.zero, in: nil)
        let contentOffset = CGPoint(x: 0, y: -0)
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.collectionView.contentOffset = contentOffset
            self.collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 305, right: 0)
            self.collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 305, right: 0)
            
            self.cardsViewController.view.alpha = 0
            
        }) { (finished) in
            
            self.backgroundViewState = .hidden
        }
    }
    
    func resetData() {
        
        inCinema = []
        comingSoon = []
        popularMovies = []
        featuredNews = []
        latestTrailers = []
        featuredTrailers = []
        popularMovieList = []
        latestReviews = []
        
        theaterSchedules = []
        cinemas = []
    }
    
    // MARK: - Actions
    @IBAction func searchButtonTapped(_ sender: UIBarButtonItem) {
        showSearchViewController(keyword: nil, in: tabBarController?.navigationController)
    }
    
    override func refresh(sender: UIRefreshControl) {
        loadData()
    }
    
    override func barButtonItemDoubleTapped() {
        
        if !isLoading {
            resetData()
            loadData()
            collectionView.reloadData()
        }
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        super.motionEnded(motion, with: event)
        
        if motion == .motionShake {
            
            if !isLoading {
                resetData()
                loadData()
                collectionView.reloadData()
            }
        }
    }
    
    @IBAction func cardsButtonTapped(_ sender: UIBarButtonItem) {
        
        if backgroundViewState == .hidden {
            showCardsViewController()
        }
        else if backgroundViewState == .visible {
            hideCardsViewController()
        }
    }
    
    @IBAction func collectionViewTapped(_ sender: UITapGestureRecognizer) {
        
        if sender.state == .ended {
            collectionView.stopWiggle()
        }
    }
    
    // MARK: - UIGestureRecognizerDelegate
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        var shouldBegin = true
        if gestureRecognizer == tapGestureRecognizer {
            
            if !collectionView.isWiggling { shouldBegin = false }
        }
        
        return shouldBegin
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        var requireFailure = false
        if gestureRecognizer == tapGestureRecognizer && otherGestureRecognizer == collectionView.longPressRecognizer {
            requireFailure = true
        }
        
        return requireFailure
    }
}


// MARK: - UICollectionViewDataSource
extension HomeViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == self.collectionView {
            return cards.count
        }
        else {
            if let cell = collectionView.collectionViewCell {
                let card = cards[cell.tag]
                
                if let cardType = CardType(rawValue: card.sectionID) {
                    
                    switch cardType {
                    case .inCinema:
                        return max(kItemsPerCard, inCinema.count)
                        
                    case .comingSoon:
                        return max(kItemsPerCard, comingSoon.count)
                        
                    case .popularMovies:
                        return max(kItemsPerCard, popularMovies.count)
                        
                    case .featuredNews:
                        return featuredNews.count
                        
                    case .latestTrailers:
                        return latestTrailers.count
                        
                    case .featuredTrailers:
                        return featuredTrailers.count
                        
                    case .popularMovieList:
                        return popularMovieList.count
                        
                    case .latestReviews:
                        return latestReviews.count
                        
                    case .cinemas:
                        return cinemas.count
                        
                    case .ads:
                        break
                    }
                }
            }
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == self.collectionView {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardItemsCellId", for: indexPath) as! CardItemsViewCell
            cell.tag = indexPath.item
            
            let card = cards[indexPath.item]
            cell.titleLabel.text = card.title?.uppercased()
            cell.iconImageView.image = nil
            
            cell.pageControl.numberOfPages = 1
            cell.pageControl.currentPage = 0
            cell.seeAllButton.isHidden = false
            
            if let cardType = CardType(rawValue: card.sectionID) {
                
                cell.iconImageView.image = cardType.icon
                cell.seeAllButton.isHidden = false
                
                switch cardType {
                case .inCinema:
                    cell.type = .movie
                    cell.pageControl.numberOfPages = Int(ceil(Double(inCinema.count) / 3.0))
                    
                case .comingSoon:
                    cell.type = .movie
                    cell.pageControl.numberOfPages = Int(ceil(Double(comingSoon.count) / 3.0))
                    
                case .popularMovies:
                    cell.type = .movie
                    cell.pageControl.numberOfPages = Int(ceil(Double(popularMovies.count) / 3.0))
                    
                case .featuredNews:
                    cell.type = .news
                    cell.pageControl.numberOfPages = featuredNews.count
                    
                case .latestTrailers:
                    cell.type = .trailer
                    cell.pageControl.numberOfPages = latestTrailers.count
                    
                case .featuredTrailers:
                    cell.type = .trailer
                    cell.pageControl.numberOfPages = featuredTrailers.count
                    
                case .popularMovieList:
                    cell.type = .movieList
                    cell.pageControl.numberOfPages = 1
                    cell.seeAllButton.isHidden = true
                    
                case .latestReviews:
                    cell.type = .review
                    cell.pageControl.numberOfPages = latestReviews.count
                    
                case .cinemas:
                    cell.type = .theater
                    cell.pageControl.numberOfPages = cinemas.count
                    
                case .ads:
                    cell.pageControl.numberOfPages = 1
                }
                
                cell.pageControl.currentPage =
                    Int(ceil(cell.collectionView.contentOffset.x / cell.collectionView.frame.width))
            }
            
            cell.collectionView.dataSource = self
            cell.collectionView.delegate = self
            cell.collectionView.reloadData()
            
            cell.delegate = self
            
            return cell
        }
        else {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardItemCellId", for: indexPath) as! CardItemViewCell
            cell.imageView.image = nil
            cell.titleLabel.text = nil
            cell.subtitleLabel.text = nil
            cell.profileImageView.image = nil
            cell.nameLabel.text = nil
            cell.movieLabel.text = nil
            cell.reviewLabel.text = nil
            
            if let superviewCell = collectionView.collectionViewCell {
                let card = cards[superviewCell.tag]
                
                if let cardType = CardType(rawValue: card.sectionID) {
                    
                    switch cardType {
                    case .inCinema:
                        cell.type = .movie
                        var movie: MVMovie?
                        if indexPath.item < inCinema.count {
                            movie = inCinema[indexPath.item]
                        }
                        cell.imageView.image = MVMovie.defaultPosterImage()
                        if let image = movie?.posterImage() {
                            cell.imageView.image = image
                        }
                        else {
                            if let posterUrl = movie?.posterUrl {
                                if let url = URL(string: posterUrl) {
                                    cell.imageView.sd_setImage(with: url, placeholderImage: MVMovie.defaultPosterImage())
                                }
                            }
                        }
                        
                    case .comingSoon:
                        cell.type = .movie
                        var movie: MVMovie?
                        if indexPath.item < comingSoon.count {
                            movie = comingSoon[indexPath.item]
                        }
                        cell.imageView.image = MVMovie.defaultPosterImage()
                        if let image = movie?.posterImage() {
                            cell.imageView.image = image
                        }
                        else {
                            if let posterUrl = movie?.posterUrl {
                                if let url = URL(string: posterUrl) {
                                    cell.imageView.sd_setImage(with: url, placeholderImage: MVMovie.defaultPosterImage())
                                }
                            }
                        }
                        
                    case .popularMovies:
                        cell.type = .movie
                        var movie: MVMovie?
                        if indexPath.item < popularMovies.count {
                            movie = popularMovies[indexPath.item]
                        }
                        cell.imageView.image = MVMovie.defaultPosterImage()
                        if let image = movie?.posterImage() {
                            cell.imageView.image = image
                        }
                        else {
                            if let posterUrl = movie?.posterUrl {
                                if let url = URL(string: posterUrl) {
                                    cell.imageView.sd_setImage(with: url, placeholderImage: MVMovie.defaultPosterImage())
                                }
                            }
                        }
                        
                    case .featuredNews:
                        cell.type = .news
                        let news = featuredNews[indexPath.item]
                        cell.subtitleLabel.text = news.title?.stringByDecodingHTMLEntities
                        cell.imageView.image = nil
                        if let image = news.images.first, let imageUrl = image.url, let url = URL(string: imageUrl) {
                            cell.imageView.sd_setImage(with: url)
                        }
                        
                    case .latestTrailers:
                        cell.type = .trailer
                        let trailer = latestTrailers[indexPath.item]
                        var titleText = ""
                        if let title = trailer.title {
                            titleText = title
                        }
                        if let shortDesc = trailer.shortDescription {
                            if titleText.characters.count > 0 {
                                titleText = "\(titleText) - \(shortDesc)"
                            }
                            else {
                                titleText = shortDesc
                            }
                        }
                        cell.titleLabel.text = trailer.createdDate?.timeAgoSinceNow
                        cell.subtitleLabel.text = titleText
                        cell.imageView.image = nil
                        var urlString = trailer.thumbnailBigUrl
                        if urlString == nil { urlString = trailer.thumbnailSmallUrl }
                        if let urlString = urlString {
                            if let url = URL(string: urlString) {
                                cell.imageView.sd_setImage(with: url)
                            }
                        }
                        
                    case .featuredTrailers:
                        cell.type = .trailer
                        let trailer = featuredTrailers[indexPath.item]
                        var titleText = ""
                        if let title = trailer.title {
                            titleText = title
                        }
                        if let shortDesc = trailer.shortDescription {
                            if titleText.characters.count > 0 {
                                titleText = "\(titleText) - \(shortDesc)"
                            }
                            else {
                                titleText = shortDesc
                            }
                        }
                        cell.titleLabel.text = trailer.createdDate?.timeAgoSinceNow
                        cell.subtitleLabel.text = titleText
                        cell.imageView.image = nil
                        var urlString = trailer.thumbnailBigUrl
                        if urlString == nil { urlString = trailer.thumbnailSmallUrl }
                        if let urlString = urlString, let url = URL(string: urlString) {
                            cell.imageView.sd_setImage(with: url)
                        }
                        
                    case .popularMovieList:
                        cell.type = .movieList
                        let movieList = popularMovieList[indexPath.item]
                        cell.subtitleLabel.text = movieList.name
                        cell.imageView.image = nil
                        if let urlString = movieList.posterUrl, let url = URL(string: urlString) {
                            cell.imageView.sd_setImage(with: url)
                        }
                        
                    case .latestReviews:
                        cell.type = .review
                        let review = latestReviews[indexPath.item]
                        cell.imageView.image = MVMovie.defaultPosterImage()
                        if let image = review.movie?.posterImage() {
                            cell.imageView.image = image
                        }
                        else {
                            if let posterUrl = review.movie?.posterUrl, let url = URL(string: posterUrl) {
                                cell.imageView.sd_setImage(with: url, placeholderImage: MVMovie.defaultPosterImage())
                            }
                        }
                        cell.profileImageView.image = MVUser.defaultPhoto()
                        if let photoUrl = review.user?.photoUrl, let url = URL(string: photoUrl) {
                            cell.profileImageView.sd_setImage(with: url, placeholderImage: MVUser.defaultPhoto())
                        }
                        cell.nameLabel.text = review.user?.displayName
                        let attributedText = NSMutableAttributedString(string: "on ", attributes: [NSFontAttributeName: kCoreSans15Font])
                        attributedText.append(NSAttributedString(string: review.movie?.title ?? "", attributes: [NSFontAttributeName: kCoreSansMedium17Font]))
                        cell.movieLabel.attributedText = attributedText
                        cell.reviewLabel.text = review.reviewContent
                        
                    case .cinemas:
                        cell.type = .theater
                        let theater = cinemas[indexPath.item]
                        cell.titleLabel.text = theater.name
                        cell.subtitleLabel.text = theater.cineplexID
                        if let cineplex = theater.cineplex() {
                            cell.subtitleLabel.text = cineplex.description
                        }
                        cell.imageView.image = MVTheater.defaultCoverImage()
                        if let coverPosterUrl = theater.coverPosterUrl, let url = try? coverPosterUrl.asURL() {
                            cell.imageView.sd_setImage(with: url, placeholderImage: MVTheater.defaultCoverImage())
                        }
                        
                    case .ads:
                        break
                    }
                }
                
            }
            
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension HomeViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == self.collectionView {
            
            let width = collectionView.frame.width - 30
            let height = (width / 3) * kGoldenRation + 40
            
            return CGSize(width: width, height: height)
        }
        else {
            
            var width = collectionView.frame.width / 3
            var height = width * kGoldenRation
            
            if let superviewCell = collectionView.collectionViewCell {
                let card = cards[superviewCell.tag]
                
                if let cardType = CardType(rawValue: card.sectionID) {
                    
                    switch cardType {
                    case .inCinema, .comingSoon, .popularMovies:
                        break
                        
                    case .popularMovieList:
                        height = collectionView.frame.height
                        width = height
                        
                    case .featuredNews, .latestTrailers, .featuredTrailers, .latestReviews, .cinemas:
                        width = collectionView.frame.width
                        
                    case .ads:
                        break
                    }
                }
            }
            
            return CGSize(width: width, height: height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        var edgeInsets: UIEdgeInsets = .zero
        
        if collectionView == self.collectionView {
            edgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        }
//        else {
//            
//            if let superviewCell = collectionView.collectionViewCell {
//                let card = cards[superviewCell.tag]
//                
//                if let cardType = CardType(rawValue: card.sectionID) {
//                    switch cardType {
//                    case .popularMovieList:
//                        edgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
//                        
//                    default:
//                        break
//                    }
//                }
//            }
//        }
        
        return edgeInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        var spacing: CGFloat = 0
        
        if collectionView == self.collectionView {
            spacing = 15
        }
        else {
            
            if let superviewCell = collectionView.collectionViewCell {
                let card = cards[superviewCell.tag]
                
                if let cardType = CardType(rawValue: card.sectionID) {
                    switch cardType {
                    case .popularMovieList:
                        spacing = 0.5
                        
                    default:
                        break
                    }
                }
            }
        }
        
        return spacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        var spacing: CGFloat = 0
        
        if collectionView == self.collectionView {
            spacing = 15
        }
        else {
            
            if let superviewCell = collectionView.collectionViewCell {
                let card = cards[superviewCell.tag]
                
                if let cardType = CardType(rawValue: card.sectionID) {
                    switch cardType {
                    case .popularMovieList:
                        spacing = 0.5
                        
                    default:
                        break
                    }
                }
            }
        }
        
        return spacing
    }
}

// MARK: - UICollectionViewDelegate
extension HomeViewController: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView == collectionView {
            
            let alpha = min(1, max(0, abs(scrollView.contentOffset.y) / headerViewHeight))
            if cardsViewController.view.alpha != alpha {
                cardsViewController.view.alpha = alpha
            }
            
            let velocity = collectionView.panGestureRecognizer.velocity(in: nil)
            if collectionView.contentOffset.y < -(headerViewHeight / 2) && backgroundViewState == .hidden && velocity.y >= 0 {
                backgroundViewState = .animating
                
                self.collectionView.contentInset = UIEdgeInsets(top: headerViewHeight + 0, left: 0, bottom: 305, right: 0)
                
                var translation = self.collectionView.panGestureRecognizer.translation(in: nil)
                translation.y = abs(collectionView.contentOffset.y)
                self.collectionView.panGestureRecognizer.setTranslation(translation, in: nil)
                
                self.backgroundViewState = .visible
            }
            else if collectionView.contentOffset.y >= -(headerViewHeight / 3) && backgroundViewState == .visible && velocity.y <= 0 {
                backgroundViewState = .animating
                
                self.collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 305, right: 0)
                self.backgroundViewState = .hidden
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if scrollView == collectionView {
            
            let velocity = collectionView.panGestureRecognizer.velocity(in: nil)
            if backgroundViewState == .visible {
                if decelerate && velocity.y < 0 {
                    hideCardsViewController()
                }
                else {
                    showCardsViewController()
                }
            }
            else {
                
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if scrollView != self.collectionView {
            
            if let superviewCell = scrollView.collectionViewCell as? CardItemsViewCell {
                superviewCell.pageControl.currentPage =
                    Int(ceil(superviewCell.collectionView.contentOffset.x / superviewCell.collectionView.frame.width))
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
     
        if let collectionView = collectionView as? WigglingCollectionView {
            if collectionView.isWiggling { return }
        }
        
        if collectionView == self.collectionView {
            let card = cards[indexPath.item]
            
            if let cardType = CardType(rawValue: card.sectionID) {
                
                switch cardType {
                case .inCinema:
                    showMoviesViewController(in: tabBarController?.navigationController)
                    
                case .comingSoon:
                    showMovieListViewController(with: .comingSoon, in: tabBarController?.navigationController)
                    
                case .popularMovies:
                    showMovieListViewController(with: .popular, in: tabBarController?.navigationController)
                    
                case .featuredNews:
                    showNewsListViewController(in: tabBarController?.navigationController)
                    
                case .latestTrailers:
                    showTrailersViewController(in: tabBarController?.navigationController, isFeatured: false)
                    
                case .featuredTrailers:
                    showTrailersViewController(in: tabBarController?.navigationController, isFeatured: true)
                    
                case .popularMovieList:
                    break
                    
                case .latestReviews:
                    showUserReviewsViewController(in: tabBarController?.navigationController)
                    
                case .cinemas:
                    showCinemasViewController(in: tabBarController?.navigationController)
                    
                case .ads:
                    break
                }
            }
        }
        else {
            
            if let superviewCell = collectionView.collectionViewCell {
                let card = cards[superviewCell.tag]
                
                if let cardType = CardType(rawValue: card.sectionID) {
                    
                    switch cardType {
                    case .inCinema:
                        if indexPath.item < inCinema.count {
                            let movie = inCinema[indexPath.item]
                            showMovieDetailViewController(withMovie: movie, in: tabBarController?.navigationController)
                        }
                        
                    case .comingSoon:
                        if indexPath.item < comingSoon.count {
                            let movie = comingSoon[indexPath.item]
                            showMovieDetailViewController(withMovie: movie, in: tabBarController?.navigationController)
                        }
                        
                    case .popularMovies:
                        if indexPath.item < popularMovies.count {
                            let movie = popularMovies[indexPath.item]
                            showMovieDetailViewController(withMovie: movie, in: tabBarController?.navigationController)
                        }
                        
                    case .featuredNews:
                        let news = featuredNews[indexPath.item]
                        showNewsDetailViewController(withNews: news, in: tabBarController?.navigationController)
                        
                    case .latestTrailers:
                        let trailer = latestTrailers[indexPath.item]
                        showTrailerDetailViewController(with: trailer, in: tabBarController?.navigationController)
                        
                    case .featuredTrailers:
                        let trailer = featuredTrailers[indexPath.item]
                        showTrailerDetailViewController(with: trailer, in: tabBarController?.navigationController)
                        
                    case .popularMovieList:
                        let movieList = popularMovieList[indexPath.item]
                        showMovieListViewController(with: .list(movieList), in: tabBarController?.navigationController)
                        
                    case .latestReviews:
                        let review = latestReviews[indexPath.item]
                        showCommentsViewController(with: review, in: tabBarController?.navigationController)
                        
                    case .cinemas:
                        let theater = cinemas[indexPath.item]
                        let schedules = theaterSchedules.filter({ (s) -> Bool in
                            return s.theater?.theaterID == theater.theaterID
                        })
                        
                        showCinemaDetailViewController(withSchedules: schedules, in: tabBarController?.navigationController)
                        
                    case .ads:
                        break
                    }
                }
            }
        }
    }
}

// MARK: - CardItemsViewCellDelegate
extension HomeViewController: CardItemsViewCellDelegate {
    
    func cardItemsViewCellSeeAllButtonTapped(cell: CardItemsViewCell) {
        
        let card = cards[cell.tag]
        if let cardType = CardType(rawValue: card.sectionID) {
            
            switch cardType {
            case .inCinema:
                showMoviesViewController(in: tabBarController?.navigationController)
                
            case .comingSoon:
                showMovieListViewController(with: .comingSoon, in: tabBarController?.navigationController)
                
            case .popularMovies:
                showMovieListViewController(with: .popular, in: tabBarController?.navigationController)
                
            case .featuredNews:
                showNewsListViewController(in: tabBarController?.navigationController)
                
            case .latestTrailers:
                showTrailersViewController(in: tabBarController?.navigationController, isFeatured: false)
                
            case .featuredTrailers:
                showTrailersViewController(in: tabBarController?.navigationController, isFeatured: true)
                
            case .popularMovieList:
                break
                
            case .latestReviews:
                showUserReviewsViewController(in: tabBarController?.navigationController)
                
            case .cinemas:
                showCinemasViewController(in: tabBarController?.navigationController)
                
            case .ads:
                break
            }
        }
    }
    
    func cardItemsViewCellDeleteButtonTapped(cell: CardItemsViewCell) {
    
        if let indexPath = collectionView.indexPath(for: cell) {
            collectionView.stopWiggle()
            
            let card = cards[indexPath.item]
            try! realm.write {
                card.isHidden.value = true
            }
            
            NotificationCenter.default.post(name: kCardDidRemoveNotification, object: nil, userInfo: nil)
        }
        
    }
}

// MARK: - CardsViewControllerDelegate
extension HomeViewController: CardsViewControllerDelegate {
    
    func cardsViewController(viewController: CardsViewController, didSelectCardType cardType: CardType) {
        
        
    }
}

// MARK: - DZNEmptyDataSetDelegate
extension HomeViewController {
    
    override func emptyDataSet(_ scrollView: UIScrollView!, didTap view: UIView!) {
        
        if !isLoading {
            loadData()
            collectionView.reloadEmptyDataSet()
        }
    }
}


//
//  ProfileViewController.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 1/5/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import UIKit
import FacebookCore
import TwitterKit
import Moya
import RxSwift
import SwiftyJSON
import RealmSwift

enum ProfileTabBarItem {
    case reviews(MVUser?)
    case watchedMovies
    
    var title: String {
        var title = ""
        switch self {
        case .reviews(let user):
            if user?.userProfileID == UserManager.shared.profile?.userProfileID {
                title = "My Reviews"
            }
            else {
                title = "Reviews"
            }
            
        case .watchedMovies:
            title = "Watched Movies"
        }
        return title
    }
}

class ProfileViewController: MovreakViewController {

    lazy var headerView: ProfileHeaderView = {
        let headerView = Bundle.main.loadNibNamed("ProfileHeaderView", owner: nil, options: nil)?.first as! ProfileHeaderView
        
        headerView.coverImageView.image = nil
        headerView.profileImageView.image = nil
        headerView.nameLabel.text = nil
        headerView.addressLabel.text = nil
        headerView.reviewLabel.text = nil
        headerView.watchedLabel.text = nil
        
        headerView.delegate = self
        
        headerView.tabBarView.delegate = self
        headerView.tabBarView.dataSource = self
        
        return headerView
    }()
    
    var tabBarItems: [ProfileTabBarItem] = [.reviews(nil)]
    var selectedTabBarItem: ProfileTabBarItem = .reviews(nil)
    
    var myReviews: [MVReview] = []
    var watchings: [MVWatching] = []
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    lazy var signInView: SignInView = {
        let signInView = Bundle.main.loadNibNamed("SignInView", owner: nil, options: nil)?.first as! SignInView
        signInView.delegate = self
        signInView.backgroundColor = UIColor.clear
        signInView.frame = CGRect(x: 0, y: 0, width: 315, height: 387)
        signInView.center = CGPoint(x: self.view.frame.width / 2, y: (self.view.frame.height - 49) / 2)
        
        return signInView
    }()
    
    var userProfileID: Int64? = UserManager.shared.profile?.userProfileID
    var user: MVUser? = UserManager.shared.profile {
        didSet {
            userProfileID = user?.userProfileID
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
        
        if userProfileID == UserManager.shared.profile?.userProfileID ||
            user == nil && userProfileID == nil {
            
            user = UserManager.shared.profile
            
            headerView.editButton.isHidden = false
            loadProfile()
        }
        else {
            
            headerView.editButton.isHidden = true
            loadUser()
        }
        
        reloadHeaderSection()
        
        NotificationCenter.default.addObserver(self, selector: #selector(ProfileViewController.reviewSubmitedHandler(sender:)), name: kReviewSubmitedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ProfileViewController.profileUpdatedHandler(sender:)), name: kReviewSubmitedNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        configureNavigationBar(with: UIColor.white, barTintColor: nil)
        
        updateTabBarIndicatorView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - Helpers
    
    func setupViews() {
        
        if navigationController?.viewControllers.first == self {
            navigationItem.leftBarButtonItem = nil
        }
        
        collectionView.register(UINib(nibName: "MyReviewViewCell", bundle: nil), forCellWithReuseIdentifier: "MyReviewCellId")
        collectionView.register(UINib(nibName: "MovieViewCell", bundle: nil), forCellWithReuseIdentifier: "MovieCellId")
        
        collectionView.alwaysBounceVertical = true
        collectionView.addSubview(headerView)
        
        collectionView.addInfiniteScroll { [weak self] (collectionView) in
            self?.loadMore()
        }
        collectionView.setShouldShowInfiniteScrollHandler { (collectionView) -> Bool in
            var shouldShowInfiniteScroll = false
            
            switch self.selectedTabBarItem {
            case .reviews:
                if let reviewsCount = self.user?.reviewsCount.value {
                    shouldShowInfiniteScroll = self.myReviews.count < reviewsCount
                }
                
            case .watchedMovies:
                if let watchedMoviesCount = self.user?.watchedMoviesCount.value {
                    shouldShowInfiniteScroll = self.watchings.count < watchedMoviesCount
                }
            }
            
            return shouldShowInfiniteScroll
        }
    }
    
    func reloadHeaderSection() {
        
        collectionView.isHidden = false
        signInView.removeFromSuperview()
        
        headerView.coverImageView.image = MVUser.defaultCoverImage()
        if let coverImageUrl = user?.coverImageUrl {
            if let url = try? coverImageUrl.asURL() {
                headerView.coverImageView.sd_setImage(with: url, placeholderImage: MVUser.defaultCoverImage())
            }
        }
        
        headerView.nameLabel.text = user?.displayName
        
        var location = user?.preferedCity
        if let profile = user as? MVProfile {
            location = profile.location
        }
        if let cityName = user?.preferedCity {
            let cities = realm.objects(MVCity.self).filter("cityName =[c] '\(cityName)'")
            if let city = cities.first, let cityName = city.cityName, let countryName = city.countryName {
                location = "\(cityName.capitalized), \(countryName.capitalized)"
            }
        }
        headerView.addressLabel.text = location
        
        headerView.reviewLabel.text = "0"
        if let reviewsCount = user?.reviewsCount.value {
            headerView.reviewLabel.text = "\(reviewsCount)"
        }
        
        headerView.watchedLabel.text = "0"
        if let watchedMoviesCount = user?.watchedMoviesCount.value {
            headerView.watchedLabel.text = "\(watchedMoviesCount)"
        }
        
        var photoUrl = ""
        if let bigPhotoUrl = user?.bigPhotoUrl {
            photoUrl = bigPhotoUrl
        }
        else if let smallPhotoUrl = user?.photoUrl {
            photoUrl = smallPhotoUrl
        }
        headerView.profileImageView.image = MVUser.defaultPhoto()
        if let url = try? photoUrl.asURL() {
            headerView.profileImageView.sd_setImage(with: url, placeholderImage: MVUser.defaultPhoto())
        }
        
        headerView.tabBarView.reloadData()
        
        updateTabBarIndicatorView()
        
        if user == nil && userProfileID == nil {
            collectionView.isHidden = true
            view.addSubview(signInView)
        }
    }
    
    func reloadDetailsSection() {
        
        let contentOffset = collectionView.contentOffset
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
        if collectionView.contentSize.height - collectionView.frame.height < contentOffset.y {
            collectionView.contentOffset = CGPoint(x: 0, y: collectionView.contentSize.height - collectionView.frame.height)
        }
        else {
            collectionView.contentOffset = contentOffset
        }
    }
    
    func updateTabBarIndicatorView() {
        
        switch selectedTabBarItem {
        case .reviews:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                self.headerView.tabBarView.setTabIndex(0, animated: true)
            })
            
        default:
            break
        }
    }
    
    func loadProfile() {
        
        if let userProfileID = userProfileID {
            
            provider.request(.profile(userProfileID))
                .mapObject(MVProfile.self)
                .subscribe { [weak self] event in
                    guard let weakSelf = self else { return }
                    
                    switch event {
                    case .next(let profile):
                        let realm = try! Realm()
                        try! realm.write { realm.add(profile, update: true) }
                        weakSelf.user = profile
                        weakSelf.tabBarItems = [.reviews(profile)]
                        weakSelf.selectedTabBarItem = weakSelf.tabBarItems[0]
                        
                    case .completed:
                        weakSelf.loadMyReviews()
                        weakSelf.loadWatchedMovies()
                        weakSelf.reloadHeaderSection()
                        weakSelf.collectionView.reloadData()
                        
                    case .error(let error):
                        print(error.localizedDescription)
                    }
                }
                .disposed(by: disposeBag)
        }
    }

    func loadUser() {
        
        if let userProfileID = userProfileID {
            
            provider.request(.profile(userProfileID))
                .mapObject(MVUser.self)
                .subscribe { [weak self] event in
                    guard let weakSelf = self else { return }
                    
                    switch event {
                    case .next(let user):
                        weakSelf.user = user
                        weakSelf.tabBarItems = [.reviews(user)]
                        weakSelf.selectedTabBarItem = weakSelf.tabBarItems[0]
                        
                    case .completed:
                        weakSelf.loadMyReviews()
                        weakSelf.loadWatchedMovies()
                        weakSelf.reloadHeaderSection()
                        weakSelf.collectionView.reloadData()
                        
                    case .error(let error):
                        print(error.localizedDescription)
                    }
                }
                .disposed(by: disposeBag)
        }
    }
    
    func loadMyReviews(skip: Int = 0) {
        
        if let profileID = userProfileID {
            
            provider.request(.userReviews(ReviewFilter.user(profileID), skip))
                .mapObject(MVReviews.self)
                .subscribe { [weak self] event in
                    guard let weakSelf = self else { return }
                    
                    switch event {
                    case .next(let reviews):
                        let myReviews = reviews.reviews.sorted(by: { (reviews) -> Bool in
                            var ascending = false
                            if let date0 = reviews.0.submittedDate, let date1 = reviews.1.submittedDate {
                                ascending = date0.isEarlier(than: date1)
                            }
                            return !ascending
                        })
                        if skip == 0 { weakSelf.myReviews = myReviews }
                        else { weakSelf.myReviews += myReviews }
                        
                    case .completed:
                        weakSelf.collectionView.performBatchUpdates({
                            weakSelf.collectionView.reloadSections(IndexSet([0]))
                        }, completion: { (finished) in
                            weakSelf.collectionView.finishInfiniteScroll()
                        })

                        
                    case .error(let error):
                        print(error.localizedDescription)
                    }
                }
                .disposed(by: disposeBag)
        }
    }
    
    func reviewSubmitedHandler(sender: Notification) {
        loadMyReviews()
    }
    
    func profileUpdatedHandler(sender: Notification) {
        reloadHeaderSection()
    }
    
    func loadWatchedMovies(skip: Int = 0) {
        
        provider.request(.watchedMovie(MovieWatchingTimeRange.allTime.rawValue, skip))
            .mapArray(MVWatching.self)
            .subscribe { [weak self] event in
                
                switch event {
                case .next(let watchings):
                    let watchingList = watchings.sorted(by: { (watchings) -> Bool in
                        var ascending = false
                        if let date0 = watchings.0.submittedDate, let date1 = watchings.1.submittedDate {
                            ascending = date0.isEarlier(than: date1)
                        }
                        return !ascending
                    })
                    if skip == 0 { self?.watchings = watchingList }
                    else { self?.watchings += watchingList }
                    
                case .completed:
                    self?.collectionView.performBatchUpdates({
                        self?.collectionView.reloadSections(IndexSet([0]))
                    }, completion: { (finished) in
                        self?.collectionView.finishInfiniteScroll()
                    })
                    
                case .error(let error):
                    print(error.localizedDescription)
                }
        }
        .disposed(by: disposeBag)
    }
    
    func loadMore() {
        
        switch selectedTabBarItem {
        case .reviews:
            loadMyReviews(skip: myReviews.count)
            
        case .watchedMovies:
            loadWatchedMovies(skip: watchings.count)
        }
    }
    
    override func userDidSignIn() {
        
        if user == nil {
            user = UserManager.shared.profile
            loadMyReviews()
            
            reloadHeaderSection()
            collectionView.reloadData()
        }
    }
    
    override func userDidSignOut() {
        
        if user is MVProfile {
            user = nil
            myReviews = []
            watchings = []
            
            reloadHeaderSection()
            collectionView.reloadData()
        }
    }
    
    func signInWithFacebook() {
        
        showLoadingView(in: view, label: "Signing-in to Facebook...")
        UserManager.shared.connectToFacebook()
            .subscribe { [weak self] (event) in
                if let weakSelf = self {
                    
                    switch event {
                    case .next(let response):
                        if let _ = response as? AccessToken {
                            weakSelf.showLoadingView(in: weakSelf.view, label: "Load Facebook profile...")
                        }
                        else if let _ = response as? JSON {
                            weakSelf.showLoadingView(in: weakSelf.view, label: "Signing-in to Movreak...")
                        }
                        else if let _ = response as? MVProfile {
                        }
                        else {
                        }
                        
                    case .error(let error):
                        weakSelf.hideLoadingView()
                        weakSelf.presentErrorNotificationView(with: error.localizedDescription)
                        
                    case .completed:
                        weakSelf.hideLoadingView()
                        
                        weakSelf.reloadHeaderSection()
                        weakSelf.collectionView.reloadData()
                        
                        weakSelf.loadProfile()
                        weakSelf.loadMyReviews()
                        weakSelf.loadWatchedMovies()
                    }
                }
            }
            .disposed(by: disposeBag)
    }
    
    func signInWithTwitter() {
        
        showLoadingView(in: view, label: "Signing-in to Twitter...")
        UserManager.shared.connectToTwitter()
            .subscribe { [weak self] (event) in
                if let weakSelf = self {
                    
                    switch event {
                    case .next(let response):
                        if let _ = response as? TWTRSession {
                            weakSelf.showLoadingView(in: weakSelf.view, label: "Load Twitter profile...")
                        }
                        else if let _ = response as? JSON {
                            weakSelf.showLoadingView(in: weakSelf.view, label: "Signing-in to Movreak...")
                        }
                        else if let _ = response as? MVProfile {
                        }
                        else {
                            
                        }
                        
                    case .error(let error):
                        weakSelf.hideLoadingView()
                        weakSelf.presentErrorNotificationView(with: error.localizedDescription)
                        
                    case .completed:
                        weakSelf.hideLoadingView()
                        
                        weakSelf.reloadHeaderSection()
                        weakSelf.collectionView.reloadData()
                        
                        weakSelf.loadProfile()
                        weakSelf.loadMyReviews()
                        weakSelf.loadWatchedMovies()
                    }
                }
            }
            .disposed(by: disposeBag)
    }
    
    func signInWithPath() {
        showErrorAlert(message: "Please sign-in with Facebook or Twitter first", completion: { (alertAction) in })
    }
    
    // MARK: - Reviews
    
    func like(review: MVReview) {
        
        let like = MVLike()
        like.contentOwnerID = review.user?.userProfileID
        like.likedContentID = review.reviewID
        like.likerUserIdentifier = UserManager.shared.profile?.userIdentifier
        like.likeFromCity = LocationManager.shared.city?.cityName
        like.user = UserManager.shared.profile
        
        provider.request(.likeReview(like))
            .subscribe { [weak self] event in
                guard let weakSelf = self else { return }
                
                switch event {
                case .next(let response):
                    let json = JSON(data: response.data)
                    if let likedContentID = json["LikedContentID"].string, let reviewID = Int64(likedContentID) {
                        if let index = weakSelf.myReviews.index(where: { (r) -> Bool in
                            return r.reviewID == reviewID
                        }) {
                            try! realm.write {
                                weakSelf.myReviews[index].doesLikeThis.value = true
                            }
                            weakSelf.collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
                        }
                    }
                    
                case .completed:
                    break
                    
                case .error(let error):
                    weakSelf.presentErrorNotificationView(with: error.localizedDescription)
                }
            }
            .disposed(by: disposeBag)
    }
    
    func unlike(review: MVReview) {
        
        provider.request(.unlikeReview(review.reviewID))
            .mapObject(MVResponse.self)
            .subscribe { [weak self] event in
                guard let weakSelf = self else { return }
                
                switch event {
                case .next(let response):
                    if let message = response.message, response.status?.lowercased() != "ok" {
                        weakSelf.presentErrorNotificationView(with: message)
                    }
                    else {
                        if let index = weakSelf.myReviews.index(where: { (r) -> Bool in
                            return r.reviewID == review.reviewID
                        }) {
                            try! realm.write {
                                weakSelf.myReviews[index].doesLikeThis.value = false
                            }
                            weakSelf.collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
                        }
                    }
                    
                case .completed:
                    break
                    
                case .error(let error):
                    weakSelf.presentErrorNotificationView(with: error.localizedDescription)
                }
            }
            .disposed(by: disposeBag)
    }
    
    func flag(review: MVReview, with flagType: FlagType) {
        
        let flag = MVFlag()
        flag.contentOwnerID = review.user?.userProfileID
        flag.flagFromCity = LocationManager.shared.city?.cityName
        flag.flagType = flagType
        flag.flaggedContentID = review.reviewID
        flag.user = UserManager.shared.profile
        
        provider.request(.flagReview(flag))
            .subscribe { [weak self] event in
                guard let weakSelf = self else { return }
                
                switch event {
                case .next(let response):
                    let json = JSON(data: response.data)
                    if let flagType = json["FlagType"].string,
                        let flaggedContentID = json["FlaggedContentID"].string,
                        let reviewID = Int64(flaggedContentID) {
                        
                        if let index = weakSelf.myReviews.index(where: { (r) -> Bool in
                            return r.reviewID == reviewID
                        }) {
                            weakSelf.collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
                        }
                        weakSelf.presentSuccessNotificationView(with: "Awesome! Thanks for your feedback.\nThe review has been marked as \(flagType).")
                    }
                    
                case .completed:
                    break
                    
                case .error(let error):
                    weakSelf.presentErrorNotificationView(with: error.localizedDescription)
                }
            }
            .disposed(by: disposeBag)
    }
    
    func delete(review: MVReview) {
        
        provider.request(.deleteReview(review.reviewID))
            .subscribe { [weak self] event in
                guard let weakSelf = self else { return }
                
                switch event {
                case .next:
                    if let index = weakSelf.myReviews.index(where: { (r) -> Bool in
                        return r.reviewID == review.reviewID
                    }) {
                        weakSelf.myReviews.remove(at: index)
                        weakSelf.collectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
                    }
                    
                case .completed:
                    break
                    
                case .error(let error):
                    weakSelf.presentErrorNotificationView(with: error.localizedDescription)
                }
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - UICollectionViewDataSource
extension ProfileViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        var numberOfRows = 0
        
        if user != nil {
            
            switch selectedTabBarItem {
            case .reviews:
                numberOfRows = myReviews.count
                
            case .watchedMovies:
                numberOfRows = watchings.count
            }
        }
        return numberOfRows
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell: UICollectionViewCell!
        
        switch selectedTabBarItem {
        case .reviews:
            let _cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyReviewCellId", for: indexPath) as! MyReviewViewCell
            _cell.backgroundColor = UIColor.clear
            
            let review = myReviews[indexPath.row]
            _cell.movieTitleLabel.text = review.movie?.title?.uppercased()
            
            var movieSubtitleText = ""
            if let mpaaRating = review.movie?.mpaaRating {
                movieSubtitleText = mpaaRating
            }
            if let duration = review.movie?.duration.value?.durationString {
                if movieSubtitleText.characters.count == 0 { movieSubtitleText = duration }
                else { movieSubtitleText = "\(movieSubtitleText) | \(duration)"}
            }
            if let genre = review.movie?.genre {
                if movieSubtitleText.characters.count == 0 { movieSubtitleText = genre }
                else { movieSubtitleText = "\(movieSubtitleText) | \(genre)"}
            }
            _cell.movieSubtitleLabel.text = movieSubtitleText
            _cell.userTitleLabel.text = review.user?.displayName
            
            var subtitleText = ""
            if let reviewsCount = review.user?.reviewsCount.value {
                if reviewsCount == 1 {
                    subtitleText = "1 review"
                }
                else {
                    subtitleText = "\(reviewsCount) reviews"
                }
            }
            _cell.userSubtitleLabel.text = subtitleText
            
            var thumbsText = NSMutableAttributedString(string: "0 / ", attributes: [NSFontAttributeName: kCoreSansBold13Font])
            if let thumbs = review.thumbs.value {
                if thumbs < 0 { _cell.thumbImageView.image = UIImage(named: "icn_review_thumbs_down") }
                else { _cell.thumbImageView.image = UIImage(named: "icn_review_thumbs_up") }
                thumbsText = NSMutableAttributedString(string: "\(abs(thumbs)) / ", attributes: [NSFontAttributeName: kCoreSansBold13Font])
            }
            thumbsText.append(NSAttributedString(string: "\(kMaxThumbs)", attributes: [NSFontAttributeName: kCoreSansLight13Font]))
            _cell.thumbsLabel.attributedText = thumbsText
            
            _cell.timeLabel.text = review.submittedDate?.timeAgoSinceNow
            _cell.reviewLabel.text = review.reviewContent
            
            var likesCommentsText = "0 Likes"
            if let likesCount = review.likesCount.value {
                if likesCount == 1 { likesCommentsText = "1 Like" }
                else { likesCommentsText = "\(likesCount) Likes" }
            }
            if let repliesCount = review.repliesCount.value {
                if repliesCount == 1 { likesCommentsText = "\(likesCommentsText) - 1 Comment" }
                else { likesCommentsText = "\(likesCommentsText) - \(repliesCount) Comments" }
            }
            else {
                likesCommentsText = "\(likesCommentsText) - 0 Comments"
            }
            _cell.likesCommentsLabel.text = likesCommentsText
            
            _cell.movieImageView.image = MVMovie.defaultPosterImage()
            if let posterUrl = review.movie?.posterUrl, let url = try? posterUrl.asURL() {
                _cell.movieImageView.sd_setImage(with: url, placeholderImage: MVMovie.defaultPosterImage())
            }
            
            _cell.userImageView.image = MVUser.defaultPhoto()
            if let photoUrl = review.user?.photoUrl, let url = try? photoUrl.asURL() {
                _cell.userImageView.sd_setImage(with: url, placeholderImage: MVUser.defaultPhoto())
            }
            
            _cell.likeButton.isEnabled = true
            let likeImage = _cell.likeButton.currentImage
            if review.doesLikeThis.value == true {
                _cell.likeButton.setImage(likeImage?.withRenderingMode(.alwaysTemplate), for: .normal)
            }
            else {
                _cell.likeButton.setImage(likeImage?.withRenderingMode(.alwaysOriginal), for: .normal)
            }
            _cell.flagButton.isEnabled = true
            
            _cell.deleteButton.isEnabled =  true
            _cell.deleteButton.isHidden = true
            if UserManager.shared.profile?.userProfileID == review.user?.userProfileID {
                _cell.deleteButton.isHidden = false
            }
            
            let commentImage = _cell.commentButton.currentImage
            if review.replies.filter({ (review) -> Bool in
                return review.user?.userProfileID == UserManager.shared.profile?.userProfileID
            }).count > 0 {
                _cell.commentButton.setImage(commentImage?.withRenderingMode(.alwaysTemplate), for: .normal)
            }
            else {
                _cell.commentButton.setImage(commentImage?.withRenderingMode(.alwaysOriginal), for: .normal)
            }
            
            _cell.delegate = self
            
            cell = _cell
       
        case .watchedMovies:
            let _cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCellId", for: indexPath) as! MovieViewCell
            let watching = watchings[indexPath.item]
            let movie = watching.movie
            
            _cell.imageView.image = MVMovie.defaultPosterImage()
            if let posterUrl = movie?.posterUrl, let url = try? posterUrl.asURL() {
                _cell.imageView.sd_setImage(with: url, placeholderImage: MVMovie.defaultPosterImage())
            }
            
            _cell.adBadgeImageView.isHidden = true
            _cell.featuredBadgeImageView.isHidden = true
            _cell.newBadgeImageView.isHidden = true
            if let ads = movie?.ads.value, ads == true {
                _cell.adBadgeImageView.isHidden = false
            }
            else if let featured = movie?.featured.value, featured == true {
                _cell.featuredBadgeImageView.isHidden = false
            }
            else if let isNew = movie?.isNew.value, isNew == true {
                _cell.newBadgeImageView.isHidden = false
            }
            
            _cell.titleLabel.text = movie?.title?.uppercased()
            
            var subtitle = ""
            if let year = movie?.year.value { subtitle = "\(year) " }
            if let genre = movie?.genre { subtitle = subtitle + genre }
            _cell.subtitleLabel.text = subtitle
            
            cell = _cell
        }
    
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ProfileViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var size: CGSize = .zero
        
        switch selectedTabBarItem {
        case .reviews:
            let width = collectionView.frame.width - 30
            
            let review = myReviews[indexPath.item]
            let reviewLabelWidth = width - 30
            var reviewLabelHeight: CGFloat = 18.5
            if let text = review.reviewContent {
                let frame = NSString(string: text).boundingRect(
                    with: CGSize(width: reviewLabelWidth, height: .infinity),
                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                    attributes: [NSFontAttributeName: kCoreSansLight15Font],
                    context: nil
                )
                reviewLabelHeight = max(reviewLabelHeight, min(92.5, frame.height))
            }
            let height = reviewLabelHeight + 219.5
            size = CGSize(width: width, height: height)
            
        case .watchedMovies:
            let width: CGFloat = (collectionView.frame.width - 45) / 2.0
            let height: CGFloat = width * kGoldenRation + 58
            
            size = CGSize(width: width, height: height)
        }
        
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
       
        return 15
    }
}

// MARK: - UICollectionViewDelegate
extension ProfileViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch selectedTabBarItem {
        case .reviews:
            let review = myReviews[indexPath.item]
            showCommentsViewController(with: review, in: tabBarController?.navigationController)
            
        case .watchedMovies:
            let watching = watchings[indexPath.item]
            showMovieDetailViewController(withMovie: watching.movie, in: tabBarController?.navigationController)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offsetY = scrollView.contentOffset.y
        if offsetY >= -headerView.minimumContentHeight && offsetY <= -(headerView.minimumContentHeight - 15) {
            let alpha = max(0, min(1, (headerView.minimumContentHeight + offsetY) / 15))
            
            headerView.separatorView.alpha = alpha
            headerView.tabBarBackgroundView.alpha = alpha
        }
        else if offsetY < -headerView.minimumContentHeight {
            if headerView.separatorView.alpha != 0 {
                
                headerView.separatorView.alpha = 0
                headerView.tabBarBackgroundView.alpha = 0
            }
        }
        else if offsetY > -(headerView.minimumContentHeight - 15) {
            if headerView.separatorView.alpha != 1 {
                
                headerView.separatorView.alpha = 1
                headerView.tabBarBackgroundView.alpha = 1
            }
        }
    }
}

// MARK: - headerViewDelegate
extension ProfileViewController: ProfileHeaderViewDelegate {
    
    func profileHeaderViewEditButtonTapped(view: ProfileHeaderView) {
        showEditProfileViewController(in: tabBarController?.navigationController)
    }
}

// MARK: - SignInViewDelegate
extension ProfileViewController: SignInViewDelegate {
    
    func signInViewFacebookButtonTapped(view: SignInView) {
        signInWithFacebook()
    }
    
    func signInViewTwitterButtonTapped(view: SignInView) {
        signInWithTwitter()
    }
    
    func signInViewPathButtonTapped(view: SignInView) {
        signInWithPath()
    }
}

// MARK: - CMTabbarViewDatasouce
extension ProfileViewController: CMTabbarViewDatasouce {
    
    func tabbarTitles(for tabbarView: CMTabbarView!) -> [String]! {
        return tabBarItems.map { (tabBarItem) -> String in
            return tabBarItem.title
        }
    }
}

// MARK: - CMTabbarViewDelegate
extension ProfileViewController: CMTabbarViewDelegate {
    
    func tabbarView(_ tabbarView: CMTabbarView!, didSelectedAt index: Int) {
        selectedTabBarItem = tabBarItems[index]
        reloadDetailsSection()
    }
}

// MARK: - 
extension ProfileViewController: MyReviewViewCellDelegate {

    func myReviewViewCellFlagButtonTapped(cell: MyReviewViewCell) {
        
        if UserManager.shared.profile == nil {
            
            signIn { (result, error) in
                
                if let result = result, result == true {
                    self.myReviewViewCellFlagButtonTapped(cell: cell)
                }
                else if let error = error {
                    self.presentErrorNotificationView(with: error.localizedDescription)
                }
                else {
                    
                }
            }
        }
        else {
            
            if let indexPath = collectionView.indexPath(for: cell) {
                let review = myReviews[indexPath.item]
                
                cell.flagButton.isEnabled = false
                
                let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                alertController.addAction(UIAlertAction(title: "Mark as Spoiler", style: .default, handler: { (_) in
                    self.flag(review: review, with: .spoiler)
                }))
                alertController.addAction(UIAlertAction(title: "Report as Spam", style: .default, handler: { (_) in
                    self.flag(review: review, with: .spam)
                }))
                alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
                    cell.flagButton.isEnabled = true
                }))
                
                present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func myReviewViewCellLikeButtonTapped(cell: MyReviewViewCell) {
        
        
        if UserManager.shared.profile == nil {
            
            signIn { (result, error) in
                
                if let result = result, result == true {
                    self.myReviewViewCellLikeButtonTapped(cell: cell)
                }
                else if let error = error {
                    self.presentErrorNotificationView(with: error.localizedDescription)
                }
                else {
                    
                }
            }
        }
        else {
            
            if let indexPath = collectionView.indexPath(for: cell) {
                let review = myReviews[indexPath.item]
                
                cell.likeButton.isEnabled = false
                if review.doesLikeThis.value == true {
                    unlike(review: review)
                }
                else {
                    like(review: review)
                }
            }
        }
    }
    
    func myReviewViewCellUserButtonTapped(cell: MyReviewViewCell) {
        
    }
    
    func myReviewViewCellMovieButtonTapped(cell: MyReviewViewCell) {
        
        if let indexPath = collectionView.indexPath(for: cell) {
            let review = myReviews[indexPath.item]
            
            showMovieDetailViewController(withMovie: review.movie, in: tabBarController?.navigationController)
        }
    }
    
    func myReviewViewCellDeleteButtonTapped(cell: MyReviewViewCell) {
        
        if let indexPath = collectionView.indexPath(for: cell) {
            let review = myReviews[indexPath.item]
            
            cell.deleteButton.isEnabled = false
            delete(review: review)
        }
    }
    
    func myReviewViewCellCommentButtonTapped(cell: MyReviewViewCell) {
        
        if let indexPath = collectionView.indexPath(for: cell) {
            let review = myReviews[indexPath.item]
            
            showCommentsViewController(with: review, in: tabBarController?.navigationController)
        }
    }
}

// MARK: - UIViewController
extension UIViewController {
    
    func showProfileViewController(_ user: MVUser? = nil, in navigationController: UINavigationController? = nil) {
        
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "Profile") as! ProfileViewController
        viewController.user = user
        
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

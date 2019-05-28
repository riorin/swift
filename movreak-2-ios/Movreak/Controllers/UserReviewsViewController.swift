//
//  UserReviewsViewController.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 10/17/16.
//  Copyright © 2016 DyCode. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON

enum ReviewFilter {
    case all
    case nowPlayingMovie
    case movie(Int64)
    case user(Int64)
    case detail(Int64)
}

enum ReviewMenu {
    case all
    case nowPlayingMovie
    case movie
    case myReviews
    
    var title: String {
        switch self {
        case .all:
            return "ALL REVIEWS"
            
        case .nowPlayingMovie:
            return "IN CINEMA MOVIE'S REVIEWS"
            
        case .movie:
            return "A MOVIE'S REVIEWS"
            
        case .myReviews:
            return "MY REVIEWS"
        }
    }
    
    var subtitle: String? {
        switch self {
        case .nowPlayingMovie:
            return "Only shows user reviews of in-cinema movies"
            
        case .movie:
            return "Select a movie to filter reviews"
            
        default:
            return nil
        }
    }
}

class UserReviewsViewController: MovreakViewController {

    var navigationMenuItem: AWNavigationMenuItem!
    var reviewMenus: [ReviewMenu] = [.all, .nowPlayingMovie, .movie, .myReviews]
    var selectedReviewMenu: ReviewMenu = .all
    
    var selectedReviewFilter: ReviewFilter = .all
    
    @IBOutlet weak var tableView: UITableView!
    
    var reviews: MVReviews?
    var reviewList: [MVReview] = []
    
    var selectedMovie: MVMovie? {
        didSet {
            if let movieID = selectedMovie?.movieID {
                selectedReviewFilter = .movie(movieID)
            }
        }
    }
    var selectedUser: MVUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(UserReviewsViewController.reviewSubmitedHandler(sender:)), name: kReviewSubmitedNotification, object: nil)
        
        loadUserReviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        configureNavigationBar(with: UIColor.black, barTintColor: UIColor.white)
    }
    
    deinit {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Helpers
    
    func setupViews() {
    
        if navigationController?.viewControllers.first == self {
            navigationItem.leftBarButtonItem = nil
        }
        
        setupRefreshControl(with: tableView)
        tableView.register(UINib(nibName: "UserReviewViewCell", bundle: nil), forCellReuseIdentifier: "UserReviewCellId")
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 312

        navigationMenuItem = AWNavigationMenuItem()
        navigationMenuItem.dataSource = self
        navigationMenuItem.delegate = self
        
        tableView.addInfiniteScroll { (collectionView) in
            self.loadMore()
        }
        tableView.setShouldShowInfiniteScrollHandler { (tableView) -> Bool in
            if let reviews = self.reviews {
                if self.reviewList.count < reviews.reviewCount && self.reviewList.count != 0 {
                    return true
                }
            }
            return false
        }
        
        titleForEmptyDataSet = "No Review :("
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
    }
    
    func reviewSubmitedHandler(sender: Notification) {
        loadUserReviews()
    }
    
    func loadUserReviews(skip: Int = 0) {
        
        if refreshControl?.isRefreshing == false && skip == 0 { refreshControl?.beginRefreshing() }
        isLoading = true
        provider.request(.userReviews(selectedReviewFilter, skip))
            .mapObject(MVReviews.self)
            .subscribe { [weak self] event in
                guard let weakSelf = self else { return }
                
                switch event {
                case .next(let reviews):
                    weakSelf.reviews = reviews
                    if skip == 0 { weakSelf.reviewList = reviews.reviews }
                    else { weakSelf.reviewList += reviews.reviews }
                    
                case .error(let error):
                    weakSelf.isLoading = false
                    weakSelf.tableView.reloadData()
                    weakSelf.refreshControl?.endRefreshing()
                    print(error.localizedDescription)
                    
                case .completed:
                    weakSelf.isLoading = false
                    weakSelf.tableView.reloadData()
                    weakSelf.refreshControl?.endRefreshing()
                    weakSelf.tableView.finishInfiniteScroll()
                }
            }
            .disposed(by: disposeBag)
    }
    
    func loadMore() {
        loadUserReviews(skip: reviewList.count)
    }
    
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
                        if let index = weakSelf.reviewList.index(where: { (r) -> Bool in
                            return r.reviewID == reviewID
                        }) {
                            try! realm.write {
                                weakSelf.reviewList[index].doesLikeThis.value = true
                                if let likesCount = weakSelf.reviewList[index].likesCount.value {
                                    weakSelf.reviewList[index].likesCount.value = likesCount + 1
                                }
                            }
                            weakSelf.tableView.reloadRows(at: [IndexPath(row: 0, section: index)], with: .automatic)
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
                        if let index = weakSelf.reviewList.index(where: { (r) -> Bool in
                            return r.reviewID == review.reviewID
                        }) {
                            try! realm.write {
                                weakSelf.reviewList[index].doesLikeThis.value = false
                                if let likesCount = weakSelf.reviewList[index].likesCount.value {
                                    weakSelf.reviewList[index].likesCount.value = max(0, likesCount - 1)
                                }
                            }
                            weakSelf.tableView.reloadRows(at: [IndexPath(row: 0, section: index)], with: .automatic)
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
                        
                        if let index = weakSelf.reviewList.index(where: { (r) -> Bool in
                            return r.reviewID == reviewID
                        }) {
                            weakSelf.tableView.reloadRows(at: [IndexPath(row: 0, section: index)], with: .automatic)
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
                case .next(let response):
                    if let index = weakSelf.reviewList.index(where: { (r) -> Bool in
                        return r.reviewID == review.reviewID
                    }) {
                        weakSelf.reviewList.remove(at: index)
                        weakSelf.tableView.deleteSections(IndexSet([index]), with: .automatic)
                    }
                    
                case .completed:
                    break
                    
                case .error(let error):
                    weakSelf.presentErrorNotificationView(with: error.localizedDescription)
                }
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - Actions
    
    override func refresh(sender: UIRefreshControl) {
        loadUserReviews()
    }
    
    @IBAction func composeButtonTapped(_ sender: UIBarButtonItem) {
        
        if UserManager.shared.profile == nil {
            
            signIn { (result, error) in
                
                if let result = result, result == true {
                    self.performSegue(withIdentifier: "ShowReviewComposer", sender: sender)
                }
                else if let error = error {
                    self.presentErrorNotificationView(with: error.localizedDescription)
                }
                else {
                    
                }
            }
        }
        else {
            performSegue(withIdentifier: "ShowReviewComposer", sender: sender)
        }
    }
}

// MARK: - UITableViewDataSource
extension UserReviewsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return reviewList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserReviewCellId", for: indexPath) as! UserReviewViewCell
        
        let review = reviewList[indexPath.section]
        cell.movieTitleLabel.text = review.movie?.title?.uppercased()
        
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
        cell.movieSubtitleLabel.text = movieSubtitleText
        cell.userTitleLabel.text = review.user?.displayName
        
        var subtitleText = ""
        if let reviewsCount = review.user?.reviewsCount.value {
            if reviewsCount == 1 {
                subtitleText = "1 review"
            }
            else {
                subtitleText = "\(reviewsCount) reviews"
            }
        }
        cell.userSubtitleLabel.text = subtitleText
        
        var thumbsText = NSMutableAttributedString(string: "0 / ", attributes: [NSFontAttributeName: kCoreSansBold13Font])
        if let thumbs = review.thumbs.value {
            if thumbs < 0 { cell.thumbImageView.image = UIImage(named: "icn_review_thumbs_down") }
            else { cell.thumbImageView.image = UIImage(named: "icn_review_thumbs_up") }
            thumbsText = NSMutableAttributedString(string: "\(abs(thumbs)) / ", attributes: [NSFontAttributeName: kCoreSansBold13Font])
        }
        thumbsText.append(NSAttributedString(string: "\(kMaxThumbs)", attributes: [NSFontAttributeName: kCoreSansLight13Font]))
        cell.thumbsLabel.attributedText = thumbsText
        
        cell.timeLabel.text = review.submittedDate?.timeAgoSinceNow
        cell.reviewLabel.text = review.reviewContent
        
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
        cell.likesCommentsLabel.text = likesCommentsText
        
        cell.movieImageView.image = MVMovie.defaultPosterImage()
        if let posterUrl = review.movie?.posterUrl, let url = try? posterUrl.asURL() {
            cell.movieImageView.sd_setImage(with: url, placeholderImage: MVMovie.defaultPosterImage())
        }
        
        cell.userImageView.image = MVUser.defaultPhoto()
        if let photoUrl = review.user?.photoUrl, let url = try? photoUrl.asURL() {
            cell.userImageView.sd_setImage(with: url, placeholderImage: MVUser.defaultPhoto())
        }
        
        cell.likeButton.isEnabled = true
        let likeImage = cell.likeButton.currentImage
        if review.doesLikeThis.value == true {
            cell.likeButton.setImage(likeImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        }
        else {
            cell.likeButton.setImage(likeImage?.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        cell.flagButton.isEnabled = true
        
        cell.deleteButton.isEnabled =  true
        cell.deleteButton.isHidden = true
        if UserManager.shared.profile?.userProfileID == review.user?.userProfileID {
            cell.deleteButton.isHidden = false
        }
        
        let commentImage = cell.commentButton.currentImage
        if review.replies.filter({ (review) -> Bool in
            return review.user?.userProfileID == UserManager.shared.profile?.userProfileID
        }).count > 0 {
            cell.commentButton.setImage(commentImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        }
        else {
            cell.commentButton.setImage(commentImage?.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
        cell.delegate = self
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension UserReviewsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let review = reviewList[indexPath.section]
        
        var navigationController = self.navigationController
        if navigationController?.viewControllers.first == self {
            navigationController = tabBarController?.navigationController
        }
        
        showCommentsViewController(with: review, in: navigationController)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        var height: CGFloat = 12
        if section == 0 {
            height = 0
        }
        return height
    }
}

// MARK: - AWNavigationMenuItemDataSource
extension UserReviewsViewController: AWNavigationMenuItemDataSource {
    
    func numberOfRows(in inMenuItem: AWNavigationMenuItem) -> UInt {
        return UInt(reviewMenus.count)
    }
    
    func maskViewFrame(in inMenuItem: AWNavigationMenuItem) -> CGRect {
        return view.bounds
    }
    
    func navigationMenuItem(_ inMenuItem: AWNavigationMenuItem, attributedMenuTitleAt inIndex: UInt) -> NSAttributedString? {
        
        let reviewMenu = reviewMenus[Int(inIndex)]
        let attString = NSMutableAttributedString(string: reviewMenu.title, attributes: [NSFontAttributeName: kCoreSans17Font, NSForegroundColorAttributeName: UIColor.black])
        if let subtitle = reviewMenu.subtitle {
            let subtitleAttString = NSAttributedString(string: "\n\(subtitle)", attributes: [NSFontAttributeName: kCoreSansLight13Font, NSForegroundColorAttributeName: UIColor.lightGray])
            attString.append(subtitleAttString)
        }
        
        return attString
    }
}

// MARK: - AWNavigationMenuItemDelegate
extension UserReviewsViewController: AWNavigationMenuItemDelegate {
    
    func navigationMenuItem(_ inMenuItem: AWNavigationMenuItem, selectionDidChange inIndex: UInt) {
       
        let previousSelectedReviewMenu = selectedReviewMenu
        selectedReviewMenu = reviewMenus[Int(inIndex)]
        
        switch selectedReviewMenu {
            
        case .myReviews:
            if let profile = UserManager.shared.profile {
                selectedUser = profile
                selectedReviewFilter = .user(profile.userProfileID)
                self.loadUserReviews()
            }
            else {
                
                signIn { (result, error) in
                    
                    if let result = result, result == true, let profile = UserManager.shared.profile {
                        
                        self.selectedUser = profile
                        self.loadUserReviews()
                    }
                    else if let error = error {
                        self.presentErrorNotificationView(with: error.localizedDescription)
                        
                        self.selectedReviewMenu = previousSelectedReviewMenu
                        if let index = self.reviewMenus.index(where: { (reviewMenu) -> Bool in
                            return reviewMenu.title == previousSelectedReviewMenu.title
                        }) {
                            inMenuItem.setSelectedIndex(index)
                        }
                    }
                    else {
                        
                    }
                }
            }
        case .movie:
            
            self.showSearchViewController(keyword: nil, in: nil, completion: { (movie) in
                
                if let movie = movie {
                    
                    self.selectedMovie = movie
                    self.loadUserReviews()
                }
                else {
                    
                    self.selectedReviewMenu = previousSelectedReviewMenu
                    if let index = self.reviewMenus.index(where: { (reviewMenu) -> Bool in
                        return reviewMenu.title == previousSelectedReviewMenu.title
                    }) {
                        inMenuItem.setSelectedIndex(index)
                    }
                }
                
                self.navigationController?.popViewController(animated: true)
            })
            
        case .all:
            selectedReviewFilter = .all
            loadUserReviews()
            
        case .nowPlayingMovie:
            selectedReviewFilter = .nowPlayingMovie
            loadUserReviews()
        }
    }
}

// MARK: - UserReviewViewCellDelegate
extension UserReviewsViewController: UserReviewViewCellDelegate {
    
    func userReviewViewCellLikeButtonTapped(cell: UserReviewViewCell) {
        
        if UserManager.shared.profile == nil {
            
            signIn { (result, error) in
                
                if let result = result, result == true {
                    self.userReviewViewCellLikeButtonTapped(cell: cell)
                }
                else if let error = error {
                    self.presentErrorNotificationView(with: error.localizedDescription)
                }
                else {
                    
                }
            }
        }
        else {
            if let indexPath = tableView.indexPath(for: cell) {
                let review = reviewList[indexPath.section]
                
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
    
    func userReviewViewCellFlagButtonTapped(cell: UserReviewViewCell) {
        
        if UserManager.shared.profile == nil {
            
            signIn { (result, error) in
                
                if let result = result, result == true {
                    self.userReviewViewCellFlagButtonTapped(cell: cell)
                }
                else if let error = error {
                    self.presentErrorNotificationView(with: error.localizedDescription)
                }
                else {
                    
                }
            }
        }
        else {
            if let indexPath = tableView.indexPath(for: cell) {
                let review = reviewList[indexPath.section]
                
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
    
    func userReviewViewCellDeleteButtonTapped(cell: UserReviewViewCell) {
        
        if let indexPath = tableView.indexPath(for: cell) {
            let review = reviewList[indexPath.section]
            
            cell.deleteButton.isEnabled = false
            delete(review: review)
        }
    }
    
    func userReviewViewCellUserButtonTapped(cell: UserReviewViewCell) {
        
        if let indexPath = tableView.indexPath(for: cell) {
            let review = reviewList[indexPath.section]
            
            var navigationController = self.navigationController
            if navigationController?.viewControllers.first == self {
                navigationController = tabBarController?.navigationController
            }
            showProfileViewController(review.user, in: navigationController)
        }
    }
    
    func userReviewViewCellMovieButtonTapped(cell: UserReviewViewCell) {
     
        if let indexPath = tableView.indexPath(for: cell) {
            let review = reviewList[indexPath.section]
            showMovieDetailViewController(withMovie: review.movie)
        }
    }
    
    func userReviewViewCellCommentButtonTapped(cell: UserReviewViewCell) {
        
        if let indexPath = tableView.indexPath(for: cell) {
            let review = reviewList[indexPath.section]
            
            var navigationController = self.navigationController
            if navigationController?.viewControllers.first == self {
                navigationController = tabBarController?.navigationController
            }
            
            showCommentsViewController(with: review, in: navigationController)
        }
    }
}

// MARK: - DZNEmptyDataSetDelegate
extension UserReviewsViewController {
    
    override func emptyDataSet(_ scrollView: UIScrollView!, didTap view: UIView!) {
        
        if !isLoading {
            loadUserReviews()
            tableView.reloadEmptyDataSet()
        }
    }
}

// MARK: - UIViewController
extension UIViewController {
    
    func showUserReviewsViewController(in navigationController: UINavigationController? = nil) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "UserReviews") as! UserReviewsViewController
        
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

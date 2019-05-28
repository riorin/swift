//
//  CommentsViewController.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 2/2/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import UIKit
import SwiftyJSON
import DateToolsSwift

class CommentsViewController: MovreakViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textViewView: UIView!
    @IBOutlet weak var textViewViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var tapGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet weak var sendButton: UIButton!
    
    var reviewID: Int64?
    var review: MVReview? {
        didSet {
            if let review = review {
                reviewID = review.reviewID
                replies = review.replies.sorted(by: { (reviews) -> Bool in
                    if let date0 = reviews.0.submittedDate, let date1 = reviews.1.submittedDate {
                        return date0 < date1
                    }
                    return true
                })
            }
        }
    }
    var replies: [MVReview] = []
    var isWriting: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Helpers
    func setupViews() {
        
        setupRefreshControl(with: tableView)
        
        tableView.register(UINib(nibName: "CommentViewCell", bundle: nil), forCellReuseIdentifier: "CommentCellId")
        tableView.register(UINib(nibName: "WritingViewCell", bundle: nil), forCellReuseIdentifier: "WritingCellId")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 95.0
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 65, bottom: 0, right: 0)
        tableView.tableFooterView = UIView()
        
        textView.layer.cornerRadius = 4
        textView.layer.masksToBounds = true
        
        textViewView.keyboardDistanceFromTextField = 0
    }
    
    func loadUserReview() {
        
        guard let reviewID = reviewID else { return }
        
        provider.request(.userReviews(.detail(reviewID), 0))
            .mapObject(MVReviews.self)
            .subscribe { [weak self] event in
                guard let weakSelf = self else { return }
                
                switch event {
                case .next(let reviews):
                    weakSelf.review = reviews.reviews.first
                    
                case .completed:
                    weakSelf.tableView.reloadData()
                    weakSelf.refreshControl?.endRefreshing()
                    
                case .error(let error):
                    weakSelf.tableView.reloadData()
                    weakSelf.refreshControl?.endRefreshing()
                    print(error.localizedDescription)
                }
            }
            .disposed(by: disposeBag)
        
    }
    
    func validateReviewInputs() -> Bool {
        
        if UserManager.shared.profile == nil {
            
            signIn { (result, error) in
                
                if let result = result, result == true {
                    self.submitReview()
                }
                else if let error = error {
                    self.presentErrorNotificationView(with: error.localizedDescription)
                }
                else {
                }
            }
            return false
        }
        else {
            
            if !textView.text.isValidReviewText {
                showErrorAlert(message: "Would be good if you write (longer) comment", completion: { (_) in })
                return false
            }
        }
        
        return true
    }
    
    func submitReview() {
        
        if !validateReviewInputs() {
            sendButton.isEnabled = true
            return
        }
        guard let review = review else {
            sendButton.isEnabled = true
            return
        }
        
        let comment = MVReview()
        comment.replyToID = "\(review.reviewID)"
        comment.replyToUser = review.user?.userName
        comment.thumbs.value = 0
        comment.reviewContent = textView.text
        
        let profile = UserManager.shared.profile
        comment.submitCity = profile?.preferedCity
        comment.submitCountryCode = profile?.preferedCountry
        comment.movie = review.movie
        comment.user = profile
        
        comment.submitCity = profile?.preferedCity
        comment.submitCountryCode = profile?.preferedCountry
        
        comment.submitLocation = LocationManager.shared.city?.cityName
        comment.submitLat.value = LocationManager.shared.location?.coordinate.latitude
        comment.submitLong.value = LocationManager.shared.location?.coordinate.longitude
        
        provider.request(.postReview(comment))
            .mapObject(MVReview.self)
            .subscribe { [weak self] event in
                guard let weakSelf = self else { return }
                
                switch event {
                case .next:
                    weakSelf.replies.append(comment)
                    
                case .completed:
                    weakSelf.sendButton.isEnabled = true
                    weakSelf.resetTextView()
                    weakSelf.tableView.reloadData()
                    weakSelf.loadUserReview()
                    weakSelf.presentSuccessNotificationView(with: "Your comment is submitted")
                    NotificationCenter.default.post(name: kReviewSubmitedNotification, object: nil, userInfo: nil)
                    
                case .error(let error):
                    weakSelf.sendButton.isEnabled = true
                    weakSelf.presentErrorNotificationView(with: error.localizedDescription)
                }
            }
            .disposed(by: disposeBag)
    }
    
    func resetTextView() {
        isWriting = false
        textView.text = nil
    }
    
    func delete(review: MVReview) {
        
        provider.request(.deleteReview(review.reviewID))
            .subscribe { [weak self] event in
                guard let weakSelf = self else { return }
                
                switch event {
                case .next(let response):
                    if let index = weakSelf.replies.index(where: { (r) -> Bool in
                        return r.reviewID == review.reviewID
                    }) {
                        weakSelf.replies.remove(at: index)
                        weakSelf.tableView.deleteRows(at: [IndexPath(row: index, section: 1)], with: .automatic)
                    }
                    NotificationCenter.default.post(name: kReviewSubmitedNotification, object: nil, userInfo: nil)
                    
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
        loadUserReview()
    }
    
    @IBAction func sendButtonTapped(_ sender: UIButton) {
        sender.isEnabled = false
        submitReview()
    }
    
    @IBAction func tableViewTapped(_ sender: UITapGestureRecognizer) {
    
        if sender.state == .ended {
            view.endEditing(true)
        }
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        var shouldBegin = true
        if gestureRecognizer == tapGestureRecognizer {
            
            if textView.isFirstResponder { shouldBegin = true }
            else { shouldBegin = false }
        }
        
        return shouldBegin
    }
}

// MARK: - UITableViiewDataSource
extension CommentsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        var numberOfRows = 0
        if section == 0 {
            numberOfRows =  1
        }
        else if section == 1 {
            numberOfRows = replies.count
        }
        else if isWriting {
            numberOfRows = 1
        }

        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell!
        
        if indexPath.section == 0 {
            
            let _cell = tableView.dequeueReusableCell(withIdentifier: "CommentCellId", for: indexPath) as! CommentViewCell
            _cell.selectionStyle = .none
        
            _cell.userImageView.image = MVUser.defaultPhoto()
            if let photoUrl = review?.user?.photoUrl, let url = try? photoUrl.asURL() {
                _cell.userImageView.sd_setImage(with: url, placeholderImage: MVUser.defaultPhoto())
            }
            
            _cell.userTitleLabel.text = review?.user?.displayName
            _cell.userSubtitleLabel.text = review?.movie?.title?.uppercased()
            _cell.timeLabel.text = review?.submittedDate?.timeAgoSinceNow
            _cell.commentLabel.text = review?.reviewContent
            
            cell = _cell
        }
        else if indexPath.section == 1 {
            
            let _cell = tableView.dequeueReusableCell(withIdentifier: "CommentCellId", for: indexPath) as! CommentViewCell
            _cell.selectionStyle = .none
            
            let reply = replies[indexPath.row]
            _cell.userImageView.image = MVUser.defaultPhoto()
            if let photoUrl = reply.user?.photoUrl, let url = try? photoUrl.asURL() {
                _cell.userImageView.sd_setImage(with: url, placeholderImage: MVUser.defaultPhoto())
            }
            
            _cell.userTitleLabel.text = reply.user?.displayName
            _cell.userSubtitleLabel.text = nil
            _cell.timeLabel.text = reply.submittedDate?.timeAgoSinceNow
            _cell.commentLabel.text = reply.reviewContent
            
            cell = _cell
        }
        else {
            
            let _cell = tableView.dequeueReusableCell(withIdentifier: "WritingCellId", for: indexPath) as! WritingViewCell
            _cell.selectionStyle = .none
            
            let profile = UserManager.shared.profile
            
            _cell.userImageView.image = MVProfile.defaultPhoto()
            if let photoUrl = profile?.photoUrl, let url = try? photoUrl.asURL() {
                _cell.userImageView.sd_setImage(with: url, placeholderImage: MVProfile.defaultPhoto())
            }
            
            cell = _cell
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CommentsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        if indexPath.section == 1 {
            let comment = replies[indexPath.row]
            if comment.user?.userProfileID == UserManager.shared.profile?.userProfileID {
                return true
            }
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete && indexPath.section == 1 {
            
            let comment = replies[indexPath.row]
            delete(review: comment)
        }
    }
}

// MARK: - UITextViewDelegate
extension CommentsViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if UserManager.shared.profile == nil {
            textView.resignFirstResponder()
            
            signIn { (result, error) in
                
                if let result = result, result == true {
                    textView.becomeFirstResponder()
                }
                else if let error = error {
                    self.presentErrorNotificationView(with: error.localizedDescription)
                }
                else {
                }
            }
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
       
        let width = textView.bounds.width - textView.textContainerInset.left - textView.textContainerInset.right
        let rect = NSString(string: textView.text).boundingRect(with: CGSize(width: width, height: .infinity), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSFontAttributeName: textView.font!], context: nil)
        let height = rect.height + textView.textContainerInset.top + textView.textContainerInset.bottom
        
        textViewHeightConstraint.constant = min(91, max(36, height))
        UIView.animate(withDuration: 0.25) { 
            self.view.layoutIfNeeded()
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let isWriting = textView.text.characters.count > 0
        if isWriting != (NSString(string: textView.text).replacingCharacters(in: range, with: text).characters.count > 0) {
            self.isWriting = !isWriting
            tableView.reloadSections(IndexSet([2]), with: .automatic)
        }
        
        return true
    }
}

// MARK: - UIViewController
extension UIViewController {
    
    func showCommentsViewController(with review: MVReview, in navigationController: UINavigationController? = nil) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "Comments") as! CommentsViewController
        viewController.review = review
        
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

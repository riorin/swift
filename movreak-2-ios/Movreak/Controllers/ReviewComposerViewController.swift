//
//  ReviewComposerViewController.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 2/23/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin
import FacebookShare
import TwitterKit
import GooglePlacePicker

class ReviewComposerViewController: MovreakViewController {
    
    @IBOutlet weak var movieImageView: UIImageView!
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var movieSubtitleLabel: UILabel!
    @IBOutlet weak var movieDisclosureImageView: UIImageView! {
        didSet {
            movieDisclosureImageView.image = movieDisclosureImageView.image?.withRenderingMode(.alwaysTemplate)
        }
    }
    @IBOutlet weak var movieButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var pathButton: UIButton!
    @IBOutlet weak var twitterButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var ratingView: UIView!
    @IBOutlet weak var positiveRatingView: ReviewRatingView! {
        didSet {
            positiveRatingView.isPositiveRating = true
        }
    }
    @IBOutlet weak var positiveRatingViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var negativeRatingView: ReviewRatingView! {
        didSet {
            negativeRatingView.isPositiveRating = false
        }
    }
    @IBOutlet weak var negativeRatingViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var ratingViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var unlikeButton: UIButton!
    
    var review: MVReview = MVReview()
    
    var movie: MVMovie? {
        didSet {
            if let movie = movie {
                movieButton.setTitle(nil, for: .normal)
                movieTitleLabel.text = movie.title?.uppercased()
                
                var movieSubtitleText = ""
                if let mpaaRating = movie.mpaaRating {
                    movieSubtitleText = mpaaRating
                }
                if let duration = movie.duration.value?.durationString {
                    if movieSubtitleText.characters.count == 0 { movieSubtitleText = duration }
                    else { movieSubtitleText = "\(movieSubtitleText) | \(duration)"}
                }
                if let genre = movie.genre {
                    if movieSubtitleText.characters.count == 0 { movieSubtitleText = genre }
                    else { movieSubtitleText = "\(movieSubtitleText) | \(genre)"}
                }
                movieSubtitleLabel.text = movieSubtitleText
                movieImageView.image = MVMovie.defaultPosterImage()
                if let posterUrl = movie.posterUrl, let url = try? posterUrl.asURL() {
                    movieImageView.sd_setImage(with: url, placeholderImage: MVMovie.defaultPosterImage())
                }
            }
        }
    }
    
    var isPositiveRating: Bool = true
    var thumbs: Int {
        if isPositiveRating { return Int(positiveRatingView.rating) }
        else { return Int(negativeRatingView.rating) * -1 }
    }
    var skipThumbsSelectionCheck = false
    
    var place: GMSPlace? {
        didSet {
            
            if let name = place?.name {
                let text = NSMutableAttributedString(string: "  I'm at ", attributes: [NSFontAttributeName: kCoreSans15Font])
                text.append(NSAttributedString(string: name, attributes: [NSFontAttributeName: kCoreSansBold13Font]))
                locationButton.setAttributedTitle(text, for: .normal)
            }
        }
    }
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !viewDidAppearedOnce {
            viewDidAppearedOnce = true
            
            textView.becomeFirstResponder()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                
                ratingViewBottomConstraint.constant = height
                UIView.animate(withDuration: duration) {
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    // MARK: - Helpers
    func setupViews() {
        
        if let _ = UserManager.shared.profile {
            
            if UserManager.shared.isConnectedToFacebook && UserManager.shared.canPostToFacebook {
                facebookButton.isSelected = true
            }
            
            if UserManager.shared.isConnectedToTwitter {
                twitterButton.isSelected = true
            }
            
            if UserManager.shared.isConnectedToPath {
                pathButton.isSelected = true
            }
        }
        
        movieImageView.image = nil
        movieTitleLabel.text = nil
        movieSubtitleLabel.text = nil
        movieButton.setTitle("Select a Movie...", for: .normal)
        
        NotificationCenter.default.addObserver(self, selector: #selector(CinemasViewController.keyboardWillShow_hide(sender:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CinemasViewController.keyboardWillShow_hide(sender:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func validateReviewInputs() -> Bool {
        
        if movie == nil {
            showErrorAlert(message: "Sorry, Movie is not selected", completion: { (_) in })
            return false
        }
        
        if !textView.text.isValidReviewText {
            showErrorAlert(message: "Would be good if you write (longer) review", completion: { (_) in })
            return false
        }
        
        if !skipThumbsSelectionCheck && positiveRatingView.rating == 0 && negativeRatingView.rating == 0 {
            
            let justSend = UIAlertAction(title: "Just send", style: .default, handler: { (alertAction) in
                self.skipThumbsSelectionCheck = true
                self.submitReview()
            })
            let illFixIt = UIAlertAction(title: "I'll fix it", style: .cancel, handler: { (alertAction) in
                
            })
            showConfirmationAlert(message: "Thumbs rating is empty. Fix it?", actions: [justSend, illFixIt])
            return false
        }
        
        return true
    }
    
    func submitReview() {
        
        review.reviewContent = textView.text
        review.thumbs.value = thumbs
        
        let profile = UserManager.shared.profile
        review.submitCity = profile?.preferedCity
        review.submitCountryCode = profile?.preferedCountry

        review.submitLocation = place?.name
        review.submitLat.value = place?.coordinate.latitude
        review.submitLong.value = place?.coordinate.longitude
        
        review.movie = movie
        review.user = profile
        
        var sharedWithAcc: [String] = []
        if facebookButton.isSelected, let facebookID = profile?.facebookID {
            sharedWithAcc.append("fb=\(facebookID)")
        }
        if twitterButton.isSelected, let twitterUserName = profile?.twitterUserName {
            sharedWithAcc.append("tw=\(twitterUserName)")
        }
        if pathButton.isSelected, let pathUserID = profile?.pathUserID {
            sharedWithAcc.append("path=\(pathUserID)")
        }
        review.sharedWithAcc = sharedWithAcc.joined(separator: "|")
        
        // Don't do this, error!
//        try! realm.write { realm.add(review, update: true) }
        
        showLoadingView(in: view, label: "Post review...")
        provider.request(.postReview(review))
            .mapObject(MVReview.self)
            .subscribe { [weak self] event in
                guard let weakSelf = self else { return }
                
                switch event {
                case .next(let review):
                    NotificationCenter.default.post(name: kReviewSubmitedNotification, object: review)
                    
                case .completed:
                    weakSelf.presentSuccessNotificationView(with: "Your review is submitted")
                    
                case .error(let error):
                    weakSelf.presentErrorNotificationView(with: error.localizedDescription)
                }
                
            }
            .disposed(by: disposeBag)
        
        dismiss(animated: true, completion: nil)
    }
    
    func postToFacebook() {
        
        if let movieID = movie?.movieID, let message = textView.text {
            
            let link = String(format: kMovieDetailPageFormatUrl, "\(movieID)")
            let request = GraphRequest(graphPath: "/me/feed", parameters: ["link": link, "message": message], httpMethod: .POST)
            request.start { (response, result) in
                
                switch result {
                case .success:
                    self.presentSuccessNotificationView(with: "Posted to Facebook")
                    
                case .failed(let error):
                    self.presentErrorNotificationView(with: error.localizedDescription)
                }
            }
        }
    }
    
    func postToTwitter() {
        
        if let movieID = movie?.movieID, let message = textView.text,
            let userID = Twitter.sharedInstance().sessionStore.session()?.userID {
            
            let client = TWTRAPIClient(userID: userID)
            let updateEndpoint = "https://api.twitter.com/1.1/statuses/update.json"
            
            let link = String(format: kMovieDetailPageFormatUrl, "\(movieID)")
            let parameters = [
                "status": "\(message) \(link)"
            ]
            var error: NSError?
            
            let request = client.urlRequest(withMethod: "POST", url: updateEndpoint, parameters: parameters, error: &error)
            client.sendTwitterRequest(request) { (_, data, error) in
                
                if let error = error {
                    self.presentErrorNotificationView(with: error.localizedDescription)
                }
                else {
                    self.presentSuccessNotificationView(with: "Posted to Twitter")
                }
            }
        }
    }
    
    // MARK: - Actions
    @IBAction func sendButtonTapped(_ sender: UIBarButtonItem) {
        
        if !validateReviewInputs() { return }
        
        submitReview()
        if facebookButton.isSelected {
            postToFacebook()
        }
        
        if twitterButton.isSelected {
            postToTwitter()
        }
    }
    
    @IBAction func movieButtonTapped(_ sender: UIButton) {
        
        showSearchViewController(keyword: nil, in: nil) { (movie) in
            
            if let movie = movie { self.movie = movie }
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func locationButtonTapped(_ sender: UIButton) {
        view.endEditing(true)
        
        let config = GMSPlacePickerConfig(viewport: nil)
        let viewController = GMSPlacePickerViewController(config: config)
        viewController.delegate = self
        
        present(viewController, animated: true, completion: nil)
    }
    
    @IBAction func pathButtonTapped(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            if let _ = UserManager.shared.profile {
                
                if !UserManager.shared.isConnectedToPath {
                    view.endEditing(true)
                    
                    UserManager.shared.connectToPath(from: self)
                        .subscribe { [weak self] (event) in
                            if let weakSelf = self {
                                
                                switch event {
                                case .next:
                                    break
                                    
                                case .error(let error):
                                    weakSelf.showErrorAlert(error: error, completion: { (_) in })
                                    weakSelf.pathDynamicModal?.closeWithLeansRight()
                                    
                                    sender.isSelected = false
                                    
                                case .completed:
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                                        weakSelf.pathDynamicModal?.closeWithLeansRight()
                                    })
                                }
                            }
                        }
                        .disposed(by: disposeBag)
                }
            }
            else {
                sender.isSelected = false
            }
        }
    }
    
    @IBAction func twitterButtonTapped(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            if let _ = UserManager.shared.profile {
                
                if !UserManager.shared.isConnectedToTwitter {
                    view.endEditing(true)
                    
                    showLoadingView(in: self.view, label: "Connect with Twitter...")
                    UserManager.shared.connectToTwitter(in: self, completion: { (result, error) in
                        self.hideLoadingView()
                        
                        if let result = result, result == true {
                            self.pathDynamicModal?.closeWithLeansRight()
                        }
                        else if let error = error {
                            self.presentErrorNotificationView(with: error.localizedDescription)
                            sender.isSelected = false
                        }
                        else {
                            sender.isSelected = false
                        }
                    })
                }
            }
            else {
                sender.isSelected = false
            }
        }
    }
    
    @IBAction func facebookButtonTapped(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            if let _ = UserManager.shared.profile {
                
                if !UserManager.shared.canPostToFacebook {
                    view.endEditing(true)
                    
                    showLoadingView(in: self.view, label: "Connect with Facebook...")
                    UserManager.shared.askPublishPermissionToFacebook(from: self, completion: { (result, error) in
                        self.hideLoadingView()
                        
                        if let result = result, result == true {
                            self.pathDynamicModal?.closeWithLeansRight()
                        }
                        else if let error = error {
                            self.presentErrorNotificationView(with: error.localizedDescription)
                            sender.isSelected = false
                        }
                        else {
                            sender.isSelected = false
                        }
                    })
                }
            }
            else {
                sender.isSelected = false
            }
        }
    }
    
    @IBAction func likeButtonTapped(_ sender: UIButton) {
        
        positiveRatingViewWidthConstraint.constant = 100
        negativeRatingViewWidthConstraint.constant = 34
        
        positiveRatingView.alpha = 0
        positiveRatingView.isHidden = false
        unlikeButton.alpha = 0
        unlikeButton.isHidden = false
        
        UIView.animate(withDuration: 0.25, animations: {
            
            self.view.layoutIfNeeded()
            self.negativeRatingView.alpha = 0
            self.positiveRatingView.alpha = 1
            self.unlikeButton.alpha = 1
            self.likeButton.alpha = 0
            
        }) { (finished) in
            
            self.negativeRatingView.isHidden = true
            self.likeButton.isHidden = true
        }
        
        isPositiveRating = true
    }
    
    @IBAction func unlikeButtonTapped(_ sender: UIButton) {
        
        positiveRatingViewWidthConstraint.constant = 34
        negativeRatingViewWidthConstraint.constant = 100
        
        negativeRatingView.alpha = 0
        negativeRatingView.isHidden = false
        likeButton.alpha = 0
        likeButton.isHidden = false
        
        UIView.animate(withDuration: 0.25, animations: {
            
            self.view.layoutIfNeeded()
            self.positiveRatingView.alpha = 0
            self.negativeRatingView.alpha = 1
            self.likeButton.alpha = 1
            self.unlikeButton.alpha = 0
            
        }) { (finished) in
            
            self.positiveRatingView.isHidden = true
            self.unlikeButton.isHidden = true
        }
        
        isPositiveRating = false
    }
}

// MARK: - 
extension ReviewComposerViewController: GMSPlacePickerViewControllerDelegate {
    
    // To receive the results from the place picker 'self' will need to conform to
    // GMSPlacePickerViewControllerDelegate and implement this code.
    func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {
        self.place = place
        
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
    }
    
    func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {
        
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UIViewController
extension UIViewController {
    
    func presentReviewComposerViewController() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ReviewComposer") as! ReviewComposerViewController
        
        let navigationController = NavigationController(rootViewController: viewController)
        present(navigationController, animated: true, completion: nil)
    }
}


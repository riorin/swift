//
//  SeatsViewController.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 5/29/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import UIKit
import Cent
import DateToolsSwift

class SeatsViewController: MovreakViewController {

    @IBOutlet weak var movieLabel: UILabel!
    @IBOutlet weak var theaterLabel: UILabel!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    @IBOutlet weak var showMoreButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    
    let kBlitzCheckSeatUrl = "http://blitz.movreak.com/Seats.html"
    let kBlitzSeatsUrlQueryFormat = "cinemaID=%@&movieID=%@&showdate=%@&showtime=%@&audiSuite=%@&movieformat=%@&price=%@"
    
    var movie: MVMovie?
    var scheduledTheater: MVScheduledTheater?
    var scheduledMovie: MVScheduledMovie?
    var theater: MVTheater?
    
    var selectedShowTimeIndex: Int = 0
    var isShowTimesViewExpanded: Bool = false {
        didSet {
            var height: CGFloat = 0
            
            if showTimes.count > 0 {
                let rows = CGFloat(ceil(Double(showTimes.count) / 4.0))
                
                if isShowTimesViewExpanded {
                    height = rows * 30 + (rows - 1) * 8
                    showMoreButton.setTitle("Show less", for: .normal)
                }
                else {
                    height = 30
                    showMoreButton.setTitle("Show more", for: .normal)
                }
            }
            
            collectionViewHeightConstraint.constant = height
            UIView.animate(withDuration: 0.25) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    var movieTitle: String {
        if let title = movie?.title {
            return title
        }
        else if let title = scheduledMovie?.movie?.title {
            return title
        }
        return ""
    }
    
    var theaterName: String {
        if let name = theater?.name {
            return name
        }
        else if let name = scheduledTheater?.theater?.name {
            return name
        }
        return ""
    }
    
    var theaterID: String {
        if let blitzCinID = theater?.blitzCinID {
            return blitzCinID
        }
        else if let blitzCinID = scheduledTheater?.theater?.blitzCinID {
            return blitzCinID
        }
        return ""
    }
    
    var movieID: String {
        if let blitzMovID = movie?.blitzMovID {
            return "\(blitzMovID)"
        }
        else if let blitzMovID = scheduledMovie?.movie?.blitzMovID {
            return "\(blitzMovID)"
        }
        return ""
    }
    
    var showDate: Date {
        if let showDate = scheduledMovie?.showDate {
            return showDate
        }
        else if let showDate = scheduledTheater?.showDate {
            return showDate
        }
        return Date()
    }
    
    var showDateString: String {
        if let showDate = scheduledMovie?.showDate {
            return showDate.format(with: "yyyy-MM-dd")
        }
        else if let showDate = scheduledTheater?.showDate {
            return showDate.format(with: "yyyy-MM-dd")
        }
        return ""
    }
    
    var showTimes: [String] {
        if let showTimes = scheduledMovie?.showTimesArray() {
            return showTimes
        }
        else if let showTimes = scheduledTheater?.showTimesArray() {
            return showTimes
        }
        return []
    }
    
    var showTime: String {
        if selectedShowTimeIndex < showTimes.count {
            return showTimes[selectedShowTimeIndex].strip()
        }
        return ""
    }
    
    var audiSuite: String {
        if let blitzCinType = scheduledMovie?.blitzCinType {
            return blitzCinType
        }
        else if let blitzCinType = scheduledTheater?.blitzCinType {
            return blitzCinType
        }
        else if let blitzCinType = theater?.blitzCinType {
            return blitzCinType
        }
        return ""
    }
    
    var movieformat: String {
        if let movieformat = scheduledMovie?.movieFormat {
            return movieformat
        }
        else if let movieformat = scheduledTheater?.movieFormat {
            return movieformat
        }
        return ""
    }
    
    var price: String {
        if let ticketPrice = scheduledMovie?.ticketPrice.value {
            return "\(ticketPrice)"
        }
        else if let ticketPrice = scheduledTheater?.ticketPrice.value {
            return "\(ticketPrice)"
        }
        return ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
        
        reloadSeats()
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
        
        if navigationController?.viewControllers.first == self {
            let closeButton = UIBarButtonItem(image: UIImage(named: "icn_back"), style: .plain, target: self, action: #selector(SeatsViewController.closeButtonTapped(_:)))
            navigationItem.leftBarButtonItem = closeButton
        }
        
        collectionView.register(UINib(nibName: "ShowTimeViewCell", bundle: nil), forCellWithReuseIdentifier: "ShowTimeCellId")
        isShowTimesViewExpanded = false
        if showTimes.count <= 4 {
            showMoreButton.isHidden = true
        }
    }
    
    func reloadSeats() {
        
        movieLabel.text = movieTitle.uppercased()
        theaterLabel.text = "\(theaterName), \(showTime)"
        
        var checkSeatUrl = kBlitzCheckSeatUrl
        if let url = MVSetting.current()?.checkSeatsURL {
            checkSeatUrl = url
        }
        let seatsUrlQuery = String(format: kBlitzSeatsUrlQueryFormat, theaterID, movieID, showDateString, showTime, audiSuite, movieformat, price)
        
        let urlString = "\(checkSeatUrl)?\(seatsUrlQuery)"
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            
            webView.loadRequest(request)
        }
    }
    
    // MARK: - Actions
    
    @IBAction func showMoreButtonTapped(_ sender: UIButton) {
        isShowTimesViewExpanded = !isShowTimesViewExpanded
    }
}

// MARK: - UIWebViewDelegate
extension SeatsViewController: UIWebViewDelegate {
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        loadingView.startAnimating()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        loadingView.stopAnimating()
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        loadingView.stopAnimating()
    }
}

// MARK: - UICollectionViewDataSource
extension SeatsViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return showTimes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShowTimeCellId", for: indexPath) as! ShowTimeViewCell
        
        cell.timeButton.setTitleColor(UIColor.lightGray, for: .normal)
        cell.timeButton.layer.borderColor = UIColor.lightGray.cgColor
        cell.timeButton.layer.borderWidth = 0.5
        
        let showTimeString = showTimes[indexPath.item].strip()
        cell.timeButton.setTitle(showTimeString, for: .normal)
        
        if let showTime = showTimeString.date(withFormat: "HH:mm") {
            
            let date = Date(year: showDate.year, month: showDate.month, day: showDate.day, hour: showTime.hour, minute: showTime.minute, second: showTime.second)
            
            let now = Date()
            if now.isEarlier(than: date) {
                cell.timeButton.setTitleColor(UIColor.black, for: .normal)
                cell.timeButton.layer.borderColor = UIColor.blue.cgColor
            }
        }
        
        cell.delegate = self
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension SeatsViewController: UICollectionViewDelegate {
    
}

// MARK: - UICollectionViewDelegateFlowLayout
extension SeatsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: floor((collectionView.frame.width - 3 * 8) / 4) , height: 30.0)
    }
}

// MARK: - ShowTimeViewCellDelegate
extension SeatsViewController: ShowTimeViewCellDelegate {
    
    func showTimeViewCellTimeButtontapped(cell: ShowTimeViewCell) {
        
        if let indexPath = collectionView.indexPath(for: cell) {
            
            selectedShowTimeIndex = indexPath.item
            reloadSeats()
        }
    }
}


// MARK: - UIViewController
extension UIViewController {
    
    func showSeatsViewController(with movie: MVMovie, and theater: MVScheduledTheater, showTime index: Int, in navigationController: UINavigationController? = nil) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "Seats") as! SeatsViewController
        viewController.movie = movie
        viewController.scheduledTheater = theater
        viewController.selectedShowTimeIndex = index
        
        var _navigationController: UINavigationController?
        if let navigationController = navigationController {
            _navigationController = navigationController
        }
        else {
            _navigationController = self.navigationController
        }
        _navigationController?.pushViewController(viewController, animated: true)
    }
    
    func showSeatsViewController(in theater: MVTheater, with movie: MVScheduledMovie, showTime index: Int, in navigationController: UINavigationController? = nil) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "Seats") as! SeatsViewController
        viewController.theater = theater
        viewController.scheduledMovie = movie
        viewController.selectedShowTimeIndex = index
        
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

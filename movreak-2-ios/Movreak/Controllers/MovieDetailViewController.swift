//
//  MovieDetailViewController.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 10/17/16.
//  Copyright © 2016 DyCode. All rights reserved.
//

import UIKit
import SDWebImage
import SwiftyJSON
import SafariServices
import Cent
import DateToolsSwift
import MessageUI


enum MovieTabBarItem {
    case showTimes
    case details
    case trailers
    
    var title: String {
        var title = ""
        switch self {
        case .showTimes:
            title = "Showtimes"
        case .details:
            title = "Details"
        case .trailers:
            title = "Trailers"
        }
        return title
    }
}

enum MovieDetailInfoType {
    case synopsis
    case infoTitle
    case info
}

struct MovieDetailInfo {
    var type: MovieDetailInfoType
    var title: String
    var subtitle: String
}

struct MovieDetailCellHeightInfo {
    var indexPath: IndexPath
    var tab: MovieTabBarItem
    var height: CGFloat
}

class MovieDetailViewController: MovreakViewController {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var watchedButton: UIButton!
    
    lazy var headerView: MovieHeaderView = {
        let headerView = Bundle.main.loadNibNamed("MovieHeaderView", owner: nil, options: nil)?.first as! MovieHeaderView
        
        headerView.posterImage = self.movie?.posterImage() ?? MVMovie.defaultPosterImage()
        headerView.titleLabel.text = nil
        headerView.genreLabel.text = nil
        headerView.ratingView.rating = 0
        headerView.durationLabel.text = nil
        headerView.dateLabel.text = nil
        
        headerView.tabBarView.delegate = self
        headerView.tabBarView.dataSource = self
        
        return headerView
    }()
    
    var tabBarItems: [MovieTabBarItem] = [.details]
    var selectedTabBarItem: MovieTabBarItem = .details
    
    var movieID: Int64?
    var movie: MVMovie? {
        didSet {
            movieID = movie?.movieID
        }
    }
    var movieSchedules: [MVMovieSchedule] = [] {
        didSet {
            movie = movieSchedules.first?.movie
            configureTheaters()
        }
    }
    var schTheaters: [MVScheduledTheater] = []
    var movieInfos: MVMovieInfos?
    var trailers: [MVTrailer] = []
    
    var ads: Ads?
    var details: [MovieDetailInfo] = [
        MovieDetailInfo(type: .synopsis, title: "", subtitle: ""),
        MovieDetailInfo(type: .infoTitle, title: "Movie Info", subtitle: ""),
        MovieDetailInfo(type: .info, title: "Loading...", subtitle: ""),
        MovieDetailInfo(type: .infoTitle, title: "Casts & Crews", subtitle: ""),
        MovieDetailInfo(type: .info, title: "Loading...", subtitle: ""),
        MovieDetailInfo(type: .info, title: "", subtitle: ""),
        MovieDetailInfo(type: .info, title: "", subtitle: "")
    ]
    var cellHeightInfos: [MovieDetailCellHeightInfo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupViews()
        
        reloadHeaderSection()
        loadData()
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
        
        tableView.register(UINib(nibName: "ShowTimesViewCell", bundle: nil), forCellReuseIdentifier: "ShowTimesCellId")
        tableView.register(UINib(nibName: "MovieSynopsisViewCell", bundle: nil), forCellReuseIdentifier: "SynopsisCellId")
        tableView.register(UINib(nibName: "MovieInfoTitleViewCell", bundle: nil), forCellReuseIdentifier: "InfoTitleCellId")
        tableView.register(UINib(nibName: "MovieInfoViewCell", bundle: nil), forCellReuseIdentifier: "InfoCellId")
        tableView.register(UINib(nibName: "TrailerViewCell", bundle: nil), forCellReuseIdentifier: "TrailerCellId")
        
        tableView.addSubview(headerView)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = UIScreen.main.bounds.height
        
        watchedButton.layer.cornerRadius = 4
        watchedButton.layer.masksToBounds = true
        watchedButton.layer.borderColor = UIColor.white.cgColor
        watchedButton.layer.borderWidth = 1.0
    }
    
    func loadData() {
        
        if let isAds = movie?.ads.value, isAds == true {
            loadAdsDetail()
        }
        else {
            loadMovieDetail()
        }
    }
    
    func loadAdsDetail() {
        
        if let adsID = movie?.adsID.value {
            
            provider.request(.adsDetail(adsID))
                .subscribe { [weak self] event in
                    guard let weakSelf = self else { return }
                    
                    switch event {
                    case .next(let response):
                        let json = JSON(data: response.data)
                        if json["ads"]["AdsID"].int64 != nil {
                            weakSelf.ads = Ads.from(json: json["ads"])
                            weakSelf.configureAdsDetails()
                        }
                        
                    case .error(let error):
                        print(error.localizedDescription)
                        
                    case .completed:
                        weakSelf.reloadHeaderSection()
                        weakSelf.reloadDetailsSection()
                    }
                }
                .disposed(by: disposeBag)
        }
    }
    
    func loadMovieDetail() {
        
        if let movieID = movieID {
            
            provider.request(.movieDetail(movieID))
                .mapObject(MVMovieDetail.self)
                .subscribe { [weak self] event in
                    guard let weakSelf = self else { return }
                    
                    switch event {
                    case .next(let movieDetail):
                        weakSelf.movie = movieDetail.movie
                        weakSelf.configureDetails()
                        
                    case .error(let error):
                        print(error.localizedDescription)
                        
                    case .completed:
                        weakSelf.reloadHeaderSection()
                        weakSelf.reloadDetailsSection()
                        
                        weakSelf.loadMovieInfos()
                        weakSelf.loadMovieTrailers()
                    }
                }
                .disposed(by: disposeBag)
        }
    }
    
    
    func loadMovieInfos() {
        
        if let movieID = movieID {
            
            provider.request(.movieInfos(movieID))
                .mapArray(MVMovieInfos.self)
                .subscribe { [weak self] event in
                    guard let weakSelf = self else { return }
                    
                    switch event {
                    case .next(let response):
                        let locale = NSLocale.current.identifier
                        let filteredMovieInfos = response.filter { (movieInfos) -> Bool in
                            return movieInfos.locale == locale
                        }
                        if filteredMovieInfos.count > 0 {
                            weakSelf.movieInfos = filteredMovieInfos.first
                        }
                        else {
                            weakSelf.movieInfos = response.first
                        }
                        weakSelf.configureDetails()
                        
                    case .error(let error):
                        print(error.localizedDescription)
                        
                    case .completed:
                        weakSelf.reloadHeaderSection()
                        weakSelf.reloadDetailsSection()
                    }
                }
                .disposed(by: disposeBag)
        }
    }
    
    func loadMovieTrailers() {
        
        if let movieID = movieID {
            
            provider.request(.movieTrailers(movieID))
                .mapArray(MVTrailer.self)
                .subscribe { [weak self] event in
                    guard let weakSelf = self else { return }
                    
                    switch event {
                    case .next(let trailers):
                        weakSelf.trailers = trailers
                        
                    case .error(let error):
                        print(error.localizedDescription)
                        
                    case .completed:
                        weakSelf.reloadHeaderSection()
                        weakSelf.reloadDetailsSection()
                        
                        weakSelf.loadYouTubeVideoDetail()
                        weakSelf.loadTmdbMovieTrailers()
                    }
                }
                .disposed(by: disposeBag)
        }
    }
    
    func loadYouTubeVideoDetail() {
        
        for trailer in trailers {
            if let youtubeVideoID = trailer.youtubeVideoID {
                _ = YouTube.shared.videoDetail(with: youtubeVideoID) { [weak self] (json, error) in
                    guard let weakSelf = self else { return }
                    
//                    if let json = json {
//                        MovieTrailer.updateMovieTrailer(with: json, in: Util.viewContext)
//                        
//                        if let index = weakSelf.trailers.index(of: trailer) {
//                            if weakSelf.selectedTabBarItem == .trailers {
//                                
//                                let indexPath = IndexPath(row: index, section: 0)
//                                weakSelf.tableView.reloadRows(at: [indexPath], with: .automatic)
//                            }
//                        }
//                    }
                }
            }
        }
    }
    
    func loadTmdbMovieTrailers() {
        
        if let tmdbID = movie?.tmdbID {
            
//            tmdbProvider.request(.movieTrailers(tmdbID))
//                .
//                .subscribe { [weak self] event in
//                    guard let weakSelf = self else { return }
//                    
//                    switch event {
//                    case .next(let response):
//                        let json = JSON(data: response.data)
//                        let trailers = MovieTrailer.movieTrailersFromTmdb(with: json, in: Util.viewContext)
//                        weakSelf.trailers += trailers
//                        
//                    case .error(let error):
//                        print(error.localizedDescription)
//                        
//                    case .completed:
//                        weakSelf.reloadHeaderSection()
//                        weakSelf.reloadDetailsSection()
//                        
//                        weakSelf.loadYouTubeVideoDetail()
//                    }
//                }
//                .disposed(by: disposeBag)
        }
    }
    
    func schedule(for theater: MVScheduledTheater) -> MVMovieSchedule? {
       
        let schedules = movieSchedules.filter { (schedule) -> Bool in
            return schedule.theaters.contains(where: { (t) -> Bool in
                return t.scheduledTheaterID == theater.scheduledTheaterID
            })
        }
        return schedules.first
    }
    
    func configureTheaters() {
        
        var theaters: [MVScheduledTheater] = []
        for schedule in movieSchedules {
            theaters += schedule.theaters
        }
        
        self.schTheaters = theaters.sorted(by: { (scheduledTheater) -> Bool in
            var ascending = true
            if let name0 = scheduledTheater.0.theater?.name, let name1 = scheduledTheater.1.theater?.name {
                ascending = name0.compare(name1) == .orderedAscending
            }
            return ascending
        })
    }
    
    func configureDetails() {
        
        var details: [MovieDetailInfo] = [
            MovieDetailInfo(type: .synopsis, title: "", subtitle: ""),
        ]
        
        if let movieInfos = movieInfos?.movieInfos, movieInfos.count > 0 {
            let sortedMovieInfos = movieInfos.sorted(by: { (movieInfos) -> Bool in
                var ascending = true
                if let label0 = movieInfos.0.label, let label1 = movieInfos.1.label {
                    ascending = label0.compare(label1) == .orderedAscending
                }
                return ascending
            })
            
            details.append(MovieDetailInfo(type: .infoTitle, title: "Movie Info", subtitle: ""))
            for info in sortedMovieInfos {
                if let label = info.label, let value = info.value {
                    details.append(MovieDetailInfo(type: .info, title: label, subtitle: value))
                }
            }

        }
        
        if let casts = movieInfos?.casts, casts.count > 0 {
            let sortedCasts = casts.sorted(by: { (movieInfos) -> Bool in
                if let label0 = movieInfos.0.label, let label1 = movieInfos.1.label {
                    return label0.compare(label1) == .orderedAscending
                }
                return true
            })
            
            details.append(MovieDetailInfo(type: .infoTitle, title: "Casts & Crews", subtitle: ""))
            for cast in sortedCasts {
                if let label = cast.label, let value = cast.value {
                    details.append(MovieDetailInfo(type: .info, title: label, subtitle: value))
                }
            }
        }
        
        details.append(MovieDetailInfo(type: .info, title: "", subtitle: ""))
        details.append(MovieDetailInfo(type: .info, title: "", subtitle: ""))
        
        self.details = details
    }
    
    func configureAdsDetails() {
        
        var details: [MovieDetailInfo] = [
            MovieDetailInfo(type: .synopsis, title: "", subtitle: ""),
        ]
        
        if let ads = ads {
            details.append(MovieDetailInfo(type: .infoTitle, title: "[Ads] Info", subtitle: ""))
            if let detailUrl = ads.detailUrl?.strip() {
                details.append(MovieDetailInfo(type: .info, title: "Detail Url", subtitle: detailUrl))
            }
            if let homepage = ads.homepage?.strip() {
                details.append(MovieDetailInfo(type: .info, title: "Home Page", subtitle: homepage))
            }
            if let reservedProperty1 = ads.reservedProperty1?.strip(), !reservedProperty1.isEmpty {
                details.append(MovieDetailInfo(type: .info, title: "Additional Info", subtitle: reservedProperty1))
            }
            if let reservedProperty2 = ads.reservedProperty2?.strip(), !reservedProperty2.isEmpty {
                details.append(MovieDetailInfo(type: .info, title: "Additional Info", subtitle: reservedProperty2))
            }
            if let reservedProperty3 = ads.reservedProperty3?.strip(), !reservedProperty3.isEmpty {
                details.append(MovieDetailInfo(type: .info, title: "Additional Info", subtitle: reservedProperty3))
            }
            if let reservedProperty4 = ads.reservedProperty4?.strip(), !reservedProperty4.isEmpty {
                details.append(MovieDetailInfo(type: .info, title: "Additional Info", subtitle: reservedProperty4))
            }
            if let reservedProperty5 = ads.reservedProperty5?.strip(), !reservedProperty5.isEmpty {
                details.append(MovieDetailInfo(type: .info, title: "Additional Info", subtitle: reservedProperty5))
            }
            
            
            if let adsClient = ads.adsClient {
                details.append(MovieDetailInfo(type: .infoTitle, title: "[Ads] Contact Info", subtitle: ""))
                if let address = adsClient.address?.strip() {
                    details.append(MovieDetailInfo(type: .info, title: "Address", subtitle: address))
                }
                if let buyHere = adsClient.buyHere?.strip() {
                    details.append(MovieDetailInfo(type: .info, title: "Buy Here", subtitle: buyHere))
                }
                if let contactPerson = adsClient.contactPerson?.strip() {
                    details.append(MovieDetailInfo(type: .info, title: "Contact Person", subtitle: contactPerson))
                }
                if let mobilePhone = adsClient.mobilePhone?.strip() {
                    details.append(MovieDetailInfo(type: .info, title: "Mobile Phone", subtitle: mobilePhone))
                }
                if let officePhone = adsClient.officePhone?.strip() {
                    details.append(MovieDetailInfo(type: .info, title: "Office Phone", subtitle: officePhone))
                }
            }
        }
        
        
        details.append(MovieDetailInfo(type: .info, title: "", subtitle: ""))
        details.append(MovieDetailInfo(type: .info, title: "", subtitle: ""))
        
        self.details = details
    }
    
    func reloadHeaderSection() {
        
        if let url = try? movie?.bigPosterUrl?.asURL() {
            SDWebImageManager.shared().downloadImage(with: url, options: [], progress: nil) { (image, _, _, _, _) in
                if let image = image {
                
                    UIView.transition(with: self.headerView, duration: 0.25, options: .transitionCrossDissolve, animations: { 
                        self.headerView.posterImage = image
                    }, completion: nil)
                }
            }
        }
        
        headerView.titleLabel.text = movie?.title?.uppercased().strip()
        if let genre = movie?.genre {
            headerView.genreView.isHidden = false
            headerView.genreLabel.text = genre
        }
        else {
            headerView.genreView.isHidden = true
        }
        headerView.imdbRatingView.isHidden = true
        headerView.ratingView.rating = 0
        if let duration = movie?.duration.value {
            headerView.durationView.isHidden = false
            headerView.durationLabel.text = duration.durationString
        }
        else {
            headerView.durationView.isHidden = true
        }
        if let year = movie?.year.value {
            headerView.dateView.isHidden = false
            headerView.dateLabel.text = "\(year)"
        }
        else {
            headerView.dateView.isHidden = true
        }
        
        var tabBarItems: [MovieTabBarItem] = []
        if schTheaters.count > 0 {
            tabBarItems.append(.showTimes)
        }
        tabBarItems.append(.details)
        if trailers.count > 0 {
            tabBarItems.append(.trailers)
        }
        self.tabBarItems = tabBarItems
        headerView.tabBarView.reloadData()
        
        updateTabBarIndicatorView()
    }
    
    func reloadDetailsSection() {
        
        let contentOffset = tableView.contentOffset
        tableView.reloadData()
        tableView.layoutIfNeeded()
        if tableView.contentSize.height - tableView.frame.height < contentOffset.y {
            tableView.contentOffset = CGPoint(x: 0, y: tableView.contentSize.height - tableView.frame.height)
        }
        else {
            tableView.contentOffset = contentOffset
        }
    }
    
    func updateTabBarIndicatorView() {
        
        if let index = tabBarItems.index(of: selectedTabBarItem) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                self.headerView.tabBarView.setTabIndex(index, animated: true)
            })
        }
    }
    
    // MARK: - Actions
    
    @IBAction func shareButtonTapped(_ sender: UIButton) {
        
        if let movie = movie {
            
            let movieTitle = movie.title ?? ""
            
            let string = String(format: kNowWatchingFormat, movieTitle)
            let url = URL(string: String(format: kMovieDetailPageFormatUrl, "\(movie.movieID)"))
            
            let viewController = UIActivityViewController(activityItems: [string, url!], applicationActivities: nil)
            
            present(viewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func favoriteButtonTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func watchedButtonTapped(_ sender: UIButton) {
        
    }
}

// MARK: - UITableViewDataSource
extension MovieDetailViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var numberOfRows = 0
        
        if selectedTabBarItem == .showTimes {
            numberOfRows = schTheaters.count
        }
        else if selectedTabBarItem == .details {
            numberOfRows = details.count
        }
        else if selectedTabBarItem == .trailers {
            numberOfRows = trailers.count
        }
        
        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var _cell: UITableViewCell!
        
        if selectedTabBarItem == .showTimes {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ShowTimesCellId", for: indexPath) as! ShowTimesViewCell
            cell.selectionStyle = .default
            cell.tag = indexPath.row
            
            let schTheater = schTheaters[indexPath.row]
            cell.placeLabel.text = schTheater.theater?.name?.uppercased()
            if let name = schTheater.theater?.name, let movieFormat = schTheater.movieFormat {
                cell.placeLabel.text = "\(name) (\(movieFormat))".uppercased()
            }
            cell.addressLabel.text = schTheater.theater?.cityName?.uppercased()
            
            cell.priceLabel.text = nil
            if let currency = schTheater.ticketCurrency, let price = schTheater.ticketPrice.value {
                let formatter = NumberFormatter()
                formatter.currencySymbol = currency
                formatter.numberStyle = .currency
                formatter.maximumFractionDigits = 0
                
                if let priceString = formatter.string(from: NSNumber(integerLiteral: price)) {
                    cell.priceLabel.text = "(\(priceString))"
                }
            }
            
            cell.collectionView.dataSource = self
            cell.collectionView.delegate = self
            cell.collectionView.reloadData()
            
            var height: CGFloat = 0
            let showTimes = schTheater.showTimesArray()
            if showTimes.count > 0 {
                let rows = CGFloat(ceil(Double(showTimes.count) / 4.0))
                height = rows * 30 + (rows - 1) * 8
            }
            cell.collectionViewHeightConstraint.constant = height
            
            _cell = cell
        }
        else if selectedTabBarItem == .details {
            
            let detail = details[indexPath.row]
            if detail.type == .synopsis {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "SynopsisCellId", for: indexPath) as! MovieSynopsisViewCell
                
                if let synopsis = movie?.synopsisEnglish, !synopsis.isEmpty {
                    cell.synopsisLabel.text = synopsis
                }
                else {
                    cell.synopsisLabel.text = movie?.synopsis
                }
                
                
                _cell = cell
            }
            else if detail.type == .infoTitle {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "InfoTitleCellId", for: indexPath)
                if let label = cell.viewWithTag(101) as? UILabel {
                    label.text = detail.title
                }
                
                _cell = cell
            }
            else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCellId", for: indexPath)
                
                let titleText = detail.title
                var detailText = NSAttributedString(string: detail.subtitle)
                
                if titleText.uppercased() == "RELEASE DATE", let releaseDate = detailText.string.date() {
                    detailText = NSAttributedString(string: releaseDate.format(with: .medium))
                }
                
                if titleText.uppercased() == "REVENUE" || titleText.uppercased() == "BUDGET" {
                    let number = NSNumber(value: NSString(string: detailText.string).doubleValue)
                    
                    let numberFormatter = NumberFormatter()
                    numberFormatter.formatterBehavior = .behavior10_4
                    numberFormatter.numberStyle = .decimal
                    
                    detailText = NSAttributedString(string: numberFormatter.string(from: number) ?? "")
                }
                
                if detailText.string.isLink || detailText.string.isEmail || detailText.string.isPhoneNumber {
                    let attributedText = NSAttributedString(string: detailText.string, attributes: [NSForegroundColorAttributeName: RGB(6, 69, 173)])
                    detailText = attributedText
                }
                
                let titleLabel = cell.viewWithTag(101) as? UILabel
                titleLabel?.text = titleText
                
                let detailLabel = cell.viewWithTag(102) as? UILabel
                detailLabel?.attributedText = detailText
                
                
                _cell = cell
            }
        }
        else { //if movieDetailTabBarView.selectedTab == .trailers
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "TrailerCellId", for: indexPath) as! TrailerViewCell
            
            let trailer = trailers[indexPath.row]
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
            cell.titleLabel.text = titleText
            cell.subtitleLabel.text = trailer.descripción
            
            cell.thumbImageView.image = nil
            if let urlString = trailer.thumbnailBigUrl {
                if let url = URL(string: urlString) {
                    cell.thumbImageView.sd_setImage(with: url)
                }
            }
            
            cell.webView.isHidden = true
            cell.webView.stopLoading()
            
            cell.playerView.isHidden = true
            cell.playerView.stopVideo()
            
            cell.thumbImageView.isHidden = false
            cell.playButton.isHidden = false
            
            cell.delegate = self
            
            _cell = cell
        }
        
        return _cell
    }
}

// MARK: - UITableViewDelegate
extension MovieDetailViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var height: CGFloat = UITableViewAutomaticDimension
        
        if let cellHeightInfo = cellHeightInfos.filter( { (cellHeightInfo) -> Bool in
            return cellHeightInfo.indexPath == indexPath && cellHeightInfo.tab == selectedTabBarItem
        } ).first {
            height = cellHeightInfo.height
        }
        
        return height
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var height: CGFloat = UITableViewAutomaticDimension
        
        if let cellHeightInfo = cellHeightInfos.filter( { (cellHeightInfo) -> Bool in
            return cellHeightInfo.indexPath == indexPath && cellHeightInfo.tab == selectedTabBarItem
        } ).first {
            height = cellHeightInfo.height
        }
        
        return height
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        cell.backgroundColor = UIColor.clear
        
//        if cellHeightInfos.filter( { (cellHeightInfo) -> Bool in
//            return cellHeightInfo.indexPath == indexPath && cellHeightInfo.tab == selectedTabBarItem
//        } ).count == 0 {
//            
//            let info = MovieDetailCellHeightInfo(indexPath: indexPath, tab: selectedTabBarItem, height: cell.frame.height)
//            cellHeightInfos.append(info)
//        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if selectedTabBarItem == .details {
            
            let detail = details[indexPath.row]
            let value = detail.subtitle
            
            if value.isLink, let url = try? value.asURL() {
                let viewController = SFSafariViewController(url: url)
                present(viewController, animated: true, completion: nil)
            }
            else if value.isPhoneNumber {
                if let url = URL(string: "tel://\(value)"), UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.openURL(url)
                }
            }
            else if value.isEmail {
                let viewController = MFMailComposeViewController()
                viewController.setToRecipients([value])
                viewController.mailComposeDelegate = self
                viewController.delegate = self
                present(viewController, animated: true, completion: nil)
            }
        }
        else if selectedTabBarItem == .trailers {
            
            let trailer = trailers[indexPath.row]
            showTrailerDetailViewController(with: trailer)
        }
        else { //if selectedTabBarItem == .showTimes
            
            if let movie = movie {
                let schTheater = schTheaters[indexPath.row]
                
                let movieTitle = movie.title ?? ""
                let theaterName = schTheater.theater?.name ?? ""
                var ticketPrice = ""
                if let currency = schTheater.ticketCurrency, let price = schTheater.ticketPrice.value {
                    let formatter = NumberFormatter()
                    formatter.currencySymbol = currency
                    formatter.numberStyle = .currency
                    formatter.maximumFractionDigits = 0
                    
                    if let priceString = formatter.string(from: NSNumber(integerLiteral: price)) {
                        ticketPrice = "(\(priceString))"
                    }
                }
                let showTimes = schTheater.showTimesArray().map({ (showTime) -> String in
                    return showTime.strip()
                }).joined(separator: ", ")
                
                let string = String(format: kMovieScheduleFormat, movieTitle, theaterName, ticketPrice, showTimes)
                let url = URL(string: String(format: kMovieDetailPageFormatUrl, "\(movie.movieID)"))
                
                let viewController = UIActivityViewController(activityItems: [string, url!], applicationActivities: nil)
                
                present(viewController, animated: true, completion: nil)
            }
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

// MARK: - CMTabbarViewDatasouce
extension MovieDetailViewController: CMTabbarViewDatasouce {
    
    func tabbarTitles(for tabbarView: CMTabbarView!) -> [String]! {
        return tabBarItems.map { (tabBarItem) -> String in
            return tabBarItem.title
        }
    }
}

// MARK: - CMTabbarViewDelegate
extension MovieDetailViewController: CMTabbarViewDelegate {
    
    func tabbarView(_ tabbarView: CMTabbarView!, didSelectedAt index: Int) {
        selectedTabBarItem = tabBarItems[index]
        reloadDetailsSection()
    }
}

// MARK: - UICollectionViewDataSource
extension MovieDetailViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let cell = collectionView.tableViewCell {
            let schTheater = schTheaters[cell.tag]
            
            let showTimes = schTheater.showTimesArray()
            return showTimes.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShowTimeCellId", for: indexPath) as! ShowTimeViewCell
        
        cell.timeButton.setTitleColor(UIColor.lightGray, for: .normal)
        cell.timeButton.layer.borderColor = UIColor.lightGray.cgColor
        cell.timeButton.layer.borderWidth = 0.5
        
        if let tableViewCell = collectionView.tableViewCell {
            
            let schTheater = schTheaters[tableViewCell.tag]
            let showTime = schTheater.showTimesArray()[indexPath.item].strip()
            cell.timeButton.setTitle(showTime, for: .normal)
            
            let movieSchedule = schedule(for: schTheater)
            
            var showDate = Date()
            if let d = movieSchedule?.showDate {
                showDate = d
            }
            
            if let showTime = showTime.date(withFormat: "HH:mm") {
                
                let date = Date(year: showDate.year, month: showDate.month, day: showDate.day, hour: showTime.hour, minute: showTime.minute, second: showTime.second)
                
                let now = Date()
                if now.isEarlier(than: date) {
                    cell.timeButton.setTitleColor(UIColor.black, for: .normal)
                    cell.timeButton.layer.borderColor = UIColor.blue.cgColor
                }
            }
        }
        
        cell.delegate = self
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension MovieDetailViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MovieDetailViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: floor((collectionView.frame.width - 3 * 8) / 4) , height: 30.0)
    }
}

// MARK: - TrailerViewCellDelegate
extension MovieDetailViewController: TrailerViewCellDelegate {
    
    func trailerViewCellPlayButtonTapped(cell: TrailerViewCell) {
        
        if let indexPath = tableView.indexPath(for: cell) {
            
            let trailer = trailers[indexPath.row]
            
            if let youtubeVideoID = trailer.youtubeVideoID {
                cell.playerView.isHidden = false
                cell.playerView.load(withVideoId: youtubeVideoID)
                
                cell.thumbImageView.isHidden = true
                cell.playButton.isHidden = true
            }
            else if let videoDirectUrl = trailer.videoDirectUrl, videoDirectUrl.isLink, let url = try? videoDirectUrl.asURL() {
                let request = URLRequest(url: url)
                
                cell.webView.isHidden = false
                cell.webView.loadRequest(request)
                
                cell.thumbImageView.isHidden = true
                cell.playButton.isHidden = true
            }
        }
    }
}

// MARK: - ShowTimeViewCellDelegate
extension MovieDetailViewController: ShowTimeViewCellDelegate {
    
    func showTimeViewCellTimeButtontapped(cell: ShowTimeViewCell) {
        
        if let tableViewCell = cell.tableViewCell as? ShowTimesViewCell {
            if let indexPath = tableViewCell.collectionView.indexPath(for: cell), let movie = movie {
                
                let schTheater = schTheaters[tableViewCell.tag]
                
                let movieTitle = movie.title ?? ""
                let theaterName = schTheater.theater?.name ?? ""
                let cityName = schTheater.theater?.cityName ?? ""
                let showTime = schTheater.showTimesArray()[indexPath.item].strip()
                
                var activities: [UIActivity] = []
                if let blitzCinType =  schTheater.blitzCinType, !blitzCinType.isEmpty,
                    schTheater.theater?.ticketing.value == true {
                    
                    let checkSeatActivity = CheckSeatActivity(movie: movie, scheduledTheater: schTheater, showTime: indexPath.item)
                    activities.append(checkSeatActivity)
                }
                
                let string = String(format: kWillWatchFormat, movieTitle, theaterName, cityName, showTime)
                let url = URL(string: String(format: kMovieDetailPageFormatUrl, "\(movie.movieID)"))
                
                let viewController = UIActivityViewController(activityItems: [string, url!], applicationActivities: activities)
                
                present(viewController, animated: true, completion: nil)
            }
            
        }
    }
}

// MARK: - MFMailComposeViewControllerDelegate
extension MovieDetailViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UIViewController
extension UIViewController {
    
    func showMovieDetailViewController(withMovie movie: MVMovie?, in navigationController: UINavigationController? = nil) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "MovieDetail") as! MovieDetailViewController
        viewController.movie = movie
        
        var _navigationController: UINavigationController?
        if let navigationController = navigationController {
            _navigationController = navigationController
        }
        else {
            _navigationController = self.navigationController
        }
        _navigationController?.pushViewController(viewController, animated: true)
    }

    func showMovieDetailViewController(withSchedules movieSchedules: [MVMovieSchedule], in navigationController: UINavigationController? = nil) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "MovieDetail") as! MovieDetailViewController
        viewController.movieSchedules = movieSchedules
        
        var _navigationController: UINavigationController?
        if let navigationController = navigationController {
            _navigationController = navigationController
        }
        else {
            _navigationController = self.navigationController
        }
        _navigationController?.pushViewController(viewController, animated: true)
    }

    func showMovieDetailViewController(withMovieID movieID: Int64?, in navigationController: UINavigationController? = nil) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "MovieDetail") as! MovieDetailViewController
        viewController.movieID = movieID
        
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


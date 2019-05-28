//
//  CinemaDetailViewController.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 1/25/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import UIKit
import RealmSwift
import DateToolsSwift
import Cent
import CoreLocation
import MapKit

class CinemaDetailViewController: MovreakViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    lazy var headerView: CinemaHeaderView = {
        let headerView = Bundle.main.loadNibNamed("CinemaHeaderView", owner: nil, options: nil)?.first as! CinemaHeaderView
        headerView.delegate = self
        
        return headerView
    }()
    
    var theater: MVTheater?
    
    var schMovies: [MVScheduledMovie] = []
    var schedules: [MVTheaterSchedule] = [] {
        didSet {
            theater = schedules.first?.theater
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
        
        reloadHeaderView()
        
        configureMovies()
        loadTheaterDetail()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        configureNavigationBar(with: UIColor.white, barTintColor: nil)
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
        
        tableView.addSubview(headerView)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = UIScreen.main.bounds.width / kGoldenRation
    }
    
    func schedule(for movie: MVScheduledMovie) -> MVTheaterSchedule? {
        
        let schedules = self.schedules.filter { (schedule) -> Bool in
            return schedule.movies.contains(where: { (m) -> Bool in
                return m.scheduledMovieID == movie.scheduledMovieID
            })
        }
        return schedules.first
    }
    
    func configureMovies() {
        
        var movies: [MVScheduledMovie] = []
        for schedule in schedules {
            movies += schedule.movies
        }
        
        self.schMovies = movies.sorted { (movies) -> Bool in
            var ascending = true
            if let title0 = movies.0.movie?.title, let title1 = movies.1.movie?.title {
                ascending = title0.compare(title1) == .orderedAscending
            }
            return ascending
        }
    }
    
    func loadTheaterDetail() {
        guard let theaterID = theater?.theaterID else { return }
        
        provider.request(.theaterDetail(theaterID))
            .mapObject(MVTheaterDetail.self)
            .subscribe { [weak self] event in
                
                switch event {
                case .next(let theaterDetail):
                    if let theater = theaterDetail.theaters.first {
                        self?.theater = theater
                    }
                    
                case .completed:
                    self?.reloadHeaderView()
                    self?.tableView.reloadData()
                    
                case .error(let error):
                    print(error.localizedDescription)
                }
            }
            .disposed(by: disposeBag)
    }
    
    func reloadHeaderView() {
        
        headerView.nameLabel.text = theater?.name
        headerView.cineplexLabel.text = theater?.cineplexID
        if let cineplexID = theater?.cineplexID {
            let cineplex = Cineplex(rawValue: cineplexID)
            headerView.cineplexLabel.text = cineplex?.description
        }
        var address = theater?.address?.stringByDecodingHTMLEntities
        address = address?.replacingOccurrences(of: "\n", with: " ")
        address = address?.trimmingCharacters(in: CharacterSet(charactersIn: "`~!@#$%^&*-_=+'\";:,./"))
        headerView.addressLabel.text = address
        if theater?.mapLat.value != nil && theater?.mapLong.value != nil {
            headerView.directionButton.isHidden = false
        }
        else {
            headerView.directionButton.isHidden = true
        }
        
        headerView.posterImageView.image = MVTheater.defaultCoverImage()
        if let coverPosterUrl = theater?.coverPosterUrl, let url = try? coverPosterUrl.asURL() {
            headerView.posterImageView.sd_setImage(with: url)
        }
    }
    
    func openMaps() {
        
        if let lat = theater?.mapLat.value, let lng = theater?.mapLong.value {
            
            let destination = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lng), addressDictionary: nil)
            let mapItem = MKMapItem(placemark: destination)
            mapItem.name = theater?.name
            
            mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
        }
    }
    
    func openGoogleMaps() {
        
        if let theater = theater {
            
            var strings: [String] = []
            if let name = theater.name { strings.append(name) }
            if let city = theater.cityName { strings.append(city) }
            if let country = theater.countryName { strings.append(country) }
            
            let daddr = strings.joined(separator: ",")
            let urlString = "comgooglemaps://?saddr=&daddr=\(daddr)&directionsmode=driving"
            
            UIApplication.shared.openURL(URL(string: urlString)!)
        }
    }
}

// MARK: - UITableViewDataSource
extension CinemaDetailViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return schMovies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCellId", for: indexPath) as! CinemaMovieViewCell
        cell.selectionStyle = .default
        cell.tag = indexPath.row
        
        let schMovie = schMovies[indexPath.row]
        cell.posterImageView.image = MVMovie.defaultPosterImage()
        if let posterUrl = schMovie.movie?.posterUrl, let url = try? posterUrl.asURL() {
            cell.posterImageView.sd_setImage(with: url, placeholderImage: MVMovie.defaultPosterImage())
        }
        
        cell.titleLabel.text = schMovie.movie?.title?.uppercased()
        if let title = schMovie.movie?.title, let movieFormat = schMovie.movieFormat {
            cell.titleLabel.text = "\(title) (\(movieFormat))".uppercased()
        }
        var genreText = ""
        if let year = schMovie.movie?.year.value {
            genreText = "\(year) "
        }
        if let genre = schMovie.movie?.genre {
            genreText += genre
        }
        cell.genreLabel.text = genreText
        cell.durationLabel.text = schMovie.movie?.duration.value?.durationString
        
        cell.collectionView.dataSource = self
        cell.collectionView.delegate = self
        cell.collectionView.reloadData()
        
        var height: CGFloat = 0
        let showTimes = schMovie.showTimesArray()
        if showTimes.count > 0 {
            let rows = CGFloat(ceil(Double(showTimes.count) / 4.0))
            height = rows * 30 + (rows - 1) * 8
        }
        cell.collectionViewHeightConstraint.constant = height
        
        cell.delegate = self
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CinemaDetailViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let schMovie = schMovies[indexPath.row]
        
        if let theater = theater, let movie = schMovie.movie {
            
            let movieTitle = movie.title ?? ""
            let theaterName = theater.name ?? ""
            var ticketPrice = ""
            if let currency = schMovie.ticketCurrency, let price = schMovie.ticketPrice.value {
                let formatter = NumberFormatter()
                formatter.currencySymbol = currency
                formatter.numberStyle = .currency
                formatter.maximumFractionDigits = 0
                
                if let priceString = formatter.string(from: NSNumber(integerLiteral: price)) {
                    ticketPrice = "(\(priceString))"
                }
            }
            let showTimes = schMovie.showTimesArray().map({ (showTime) -> String in
                return showTime.strip()
            }).joined(separator: ", ")
            
            let string = String(format: kMovieScheduleFormat, movieTitle, theaterName, ticketPrice, showTimes)
            let url = URL(string: String(format: kMovieDetailPageFormatUrl, "\(movie.movieID)"))
            
            let viewController = UIActivityViewController(activityItems: [string, url!], applicationActivities: nil)
            
            present(viewController, animated: true, completion: nil)
        }
    }
}

// MARK: - UICollectionViewDataSource
extension CinemaDetailViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let cell = collectionView.tableViewCell {
            let schMovie = schMovies[cell.tag]
            
            let showTimes = schMovie.showTimesArray()
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
            
            let schMovie = schMovies[tableViewCell.tag]
            let showTime = schMovie.showTimesArray()[indexPath.item].strip()
            cell.timeButton.setTitle(showTime, for: .normal)
            
            let theaterSchedule = schedule(for: schMovie)
            
            var showDate = Date()
            if let d = theaterSchedule?.showDate {
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
extension CinemaDetailViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CinemaDetailViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: floor((collectionView.frame.width - 3 * 8) / 4), height: 30.0)
    }
}

// MARK: - CinemaHeaderViewDelegate
extension CinemaDetailViewController: CinemaHeaderViewDelegate {
    
    func cinemaHeaderViewDirectionButtonTapped(view: CinemaHeaderView) {
        
        if UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!) {
            
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alertController.addAction(UIAlertAction(title: "Open in Maps", style: .default, handler: { (_) in
                self.openMaps()
            }))
            alertController.addAction(UIAlertAction(title: "Open in Google Maps", style: .default, handler: { (_) in
                self.openGoogleMaps()
            }))
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
                
            }))
            
            present(alertController, animated: true, completion: nil)
        }
        else {
            
            openMaps()
        }
    }
}

// MARK: - CinemaMovieViewCellDelegate
extension CinemaDetailViewController: CinemaMovieViewCellDelegate {
    
    func cinemaMovieViewCellMovieButtonTapped(cell: CinemaMovieViewCell) {
        
        let schMovie = schMovies[cell.tag]
        showMovieDetailViewController(withMovieID: schMovie.movie?.movieID)
    }
}

extension CinemaDetailViewController: ShowTimeViewCellDelegate {
    
    func showTimeViewCellTimeButtontapped(cell: ShowTimeViewCell) {
        
        if let tableViewCell = cell.tableViewCell as? CinemaMovieViewCell {
            let schMovie = schMovies[tableViewCell.tag]
            
            if let indexPath = tableViewCell.collectionView.indexPath(for: cell),
                let theater = theater, let movie = schMovie.movie {
                
                let movieTitle = movie.title ?? ""
                let theaterName = theater.name ?? ""
                let cityName = theater.cityName ?? ""
                let showTime = schMovie.showTimesArray()[indexPath.item].strip()
                
                var activities: [UIActivity] = []
                if theater.ticketing.value == true {
                    
                    let checkSeatActivity = CheckSeatActivity(theater: theater, scheduledMovie: schMovie, showTime: indexPath.item)
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

// MARK: - UIViewController
extension UIViewController {
    
    func showCinemaDetailViewController(withSchedules schedules: [MVTheaterSchedule], in navigationController: UINavigationController? = nil) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "CinemaDetail") as! CinemaDetailViewController
        viewController.schedules = schedules
        
        var _navigationController: UINavigationController?
        if let navigationController = navigationController {
            _navigationController = navigationController
        }
        else {
            _navigationController = self.navigationController
        }
        _navigationController?.pushViewController(viewController, animated: true)
    }
    
    func showCinemaDetailViewController(withTheater theater: MVTheater?, in navigationController: UINavigationController? = nil) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "CinemaDetail") as! CinemaDetailViewController
        viewController.theater = theater
        
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

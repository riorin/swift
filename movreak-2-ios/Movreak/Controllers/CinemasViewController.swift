//
//  CinemasViewController.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 8/19/16.
//  Copyright © 2016 DyCode. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import RealmSwift

class CinemasViewController: MovreakViewController {

    weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var dateCityButton: UIButton!
    
    var schedules: [MVTheaterSchedule] = []
    var rawTheaters: [MVTheater] = [] {
        didSet {
            filterCinemas()
        }
    }
    var theaters: [MVTheater] = []
    
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
            
            loadTheaterSchedules()
        }
        
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
            navigationItem.leftBarButtonItem = nil
        }
        
        setupRefreshControl(with: collectionView)
        refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        collectionView.register(UINib(nibName: "CinemaViewCell", bundle: nil), forCellWithReuseIdentifier: "CinemaCellId")
        
        collectionView.emptyDataSetSource = self
        collectionView.emptyDataSetDelegate = self
        titleForEmptyDataSet = "No Cinema :("
        
        NotificationCenter.default.addObserver(self, selector: #selector(CinemasViewController.keyboardWillShow_hide(sender:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CinemasViewController.keyboardWillShow_hide(sender:)), name: .UIKeyboardWillHide, object: nil)
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
    
    func loadTheaterSchedules() {
        
        var city = self.city
        if city == nil { city = LocationManager.shared.city }
        
        if let cityName = city?.cityName {
            
            isLoading = true
            provider.request(.theaterSchedule(date, cityName))
                .mapArray(MVTheaterSchedule.self)
                .subscribe { [weak self] event in
                    
                    switch event {
                    case .next(let schedules):
                        self?.schedules = schedules
                        self?.configureTheaters()
                        
                    case .completed:
                        self?.isLoading = false
                        self?.collectionView.reloadData()
                        self?.refreshControl?.endRefreshing()
                        
                    case .error(let error):
                        self?.presentErrorNotificationView(with: error.localizedDescription)
                        self?.isLoading = false
                        self?.collectionView.reloadData()
                        self?.refreshControl?.endRefreshing()
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
                
                self.loadTheaterSchedules()
                
                viewController.removeFromParentViewController()
                self.pathDynamicModal?.closeWithLeansRight()
            })
        }
    }
    
    func configureTheaters() {
        
        let theaters: [MVTheater] = schedules.flatMap { (theaterSchedule) -> MVTheater? in
            return theaterSchedule.theater
        }
        
        var theaterSet: [MVTheater] = []
        for theater in theaters {
            if !theaterSet.contains { (t) -> Bool in return t.theaterID == theater.theaterID } {
                theaterSet.append(theater)
            }
        }
        
        rawTheaters = theaterSet.sorted { (theaters) -> Bool in
            var ascending = true
            if let name0 = theaters.0.name, let name1 = theaters.1.name {
                ascending = name0 < name1
            }
            return ascending
        }
        
        for theater in rawTheaters {
            provider.request(.theaterDetail(theater.theaterID))
                .mapObject(MVTheaterDetail.self)
                .subscribe { [weak self] event in
                    guard let weakSelf = self else { return }
                    
                    switch event {
                    case .next(let theaterDetail):
                        if let theater = theaterDetail.theaters.first {
                            if let index = weakSelf.theaters.index(of: theater) {
                                let indexPath = IndexPath(item: index, section: 0)
                                weakSelf.collectionView.reloadItems(at: [indexPath])
                            }
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
    
    func filterCinemas() {
    
        if searchBar == nil {
            theaters = rawTheaters
            return
        }
        
        if let text = searchBar.text?.lowercased(), !text.isEmpty {
            let theaters = rawTheaters.filter({ (theater) -> Bool in
                var filtered = false
                
                if let name = theater.name?.lowercased() {
                    filtered = filtered || name.contains(text)
                }
                if let cityName = theater.cityName?.lowercased() {
                    filtered = filtered || cityName.contains(text)
                }
                if let address = theater.address?.lowercased() {
                    filtered = filtered || address.contains(text)
                }
                if let cineplexID = theater.cineplexID?.lowercased() {
                    filtered = filtered || cineplexID.contains(text)
                }
                
                return filtered
            })
            self.theaters = theaters
        }
        else {
            theaters = rawTheaters
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
                
                collectionViewBottomConstraint.constant = height
                UIView.animate(withDuration: duration) {
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    // MARK: - Actions
    
    override func refresh(sender: UIRefreshControl) {
        loadTheaterSchedules()
    }
    
    @IBAction func dateCityButtonTapped(_ sender: UIButton) {
        
        var city = self.city
        if city == nil { city = LocationManager.shared.city }
        
        presentDateCityPickerViewController(date: date, city: city) { (date, city) in
            
            self.date = date; self.city = city
            
            self.dismiss(animated: true, completion: {
                self.refreshControl?.beginRefreshing()
                self.loadTheaterSchedules()
                self.collectionView.reloadEmptyDataSet()
            })
        }
    }
    
    @IBAction func viewTapped(_ sender: UITapGestureRecognizer) {
    
        if sender.state == .ended {
            view.endEditing(true)
        }
    }
}

// MARK: - UICollectionViewDataSource
extension CinemasViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        if rawTheaters.count == 0 {
            return 0
        }
        else {
            return 2
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if section == 0 {
            return 1
        }
        else {
            return theaters.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
         
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchCellId", for: indexPath) as! SearchViewCell
            
            searchBar = cell.searchBar
            searchBar.delegate = self
            
            return cell
        }
        else {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CinemaCellId", for: indexPath) as! CinemaViewCell
            
            let theater = theaters[indexPath.item]
            cell.nameLabel.text = theater.name
            cell.cineplexLabel.text = theater.cineplexID
            if let cineplex = theater.cineplex() {
                cell.cineplexLabel.text = cineplex.description
            }
            var addressText = ""
            if let location = LocationManager.shared.location {
                if let lat = theater.mapLat.value,
                    let lng = theater.mapLong.value {
                    
                    let distance = location.distance(from: CLLocation(latitude: lat, longitude: lng))
                    addressText = "\(distance.distanceString)"
                }
            }
            if let address = theater.address?.stringByDecodingHTMLEntities {
                var addr = address
                addr = addr.replacingOccurrences(of: "\n", with: " ")
                addr = addr.trimmingCharacters(in: CharacterSet(charactersIn: "`~!@#$%^&*-_=+'\";:,./"))
                if addressText.characters.count > 0 {
                    addressText = "\(addressText) | \(addr)"
                }
                else {
                    addressText = addr
                }
            }
            cell.addressLabel.text = addressText
            
            cell.imageView.image = MVTheater.defaultCoverImage()
            if let coverPosterUrl = theater.coverPosterUrl {
                do {
                    let url = try coverPosterUrl.asURL()
                    cell.imageView.sd_setImage(with: url)
                }
                catch {
                    print(error.localizedDescription)
                }
            }
            
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegate
extension CinemasViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.section == 1 {
            
            let theater = theaters[indexPath.item]
            let schedules = self.schedules.filter({ (s) -> Bool in
                return s.theater?.theaterID == theater.theaterID
            })
            
            var navigationController = self.navigationController
            if navigationController?.viewControllers.first == self {
                navigationController = tabBarController?.navigationController
            }
            
            showCinemaDetailViewController(withSchedules: schedules, in: navigationController)
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CinemasViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        if section == 0 {
            return .zero
        }
        else {
            return UIEdgeInsets(top: 8, left: 15, bottom: 15, right: 15)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if indexPath.section == 0 {
            return CGSize(width: UIScreen.main.bounds.width, height: 44)
        }
        else {
            
            let width = UIScreen.main.bounds.width - 30
            let height = width / kGoldenRation
            
            return CGSize(width: width, height: height)
        }
    }
}

// MARK: - 
extension CinemasViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterCinemas()
        collectionView.reloadSections(IndexSet([1]))
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK: - DZNEmptyDataSetDelegate
extension CinemasViewController {
    
    override func emptyDataSet(_ scrollView: UIScrollView!, didTap view: UIView!) {
        
        if !isLoading {
            loadTheaterSchedules()
            collectionView.reloadEmptyDataSet()
        }
    }
}

// MARK: - UIViewController
extension UIViewController {
    
    func showCinemasViewController(in navigationController: UINavigationController? = nil) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "Cinemas") as! CinemasViewController
        
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

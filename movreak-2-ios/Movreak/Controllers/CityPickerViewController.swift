//
//  CityPickerViewController.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 3/17/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import UIKit
import RealmSwift

typealias CityPickerCompletion = (_ viewController: CityPickerViewController, _ city: MVCity) -> Void

class CityPickerViewController: MovreakViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            if searchBar != nil {
                searchBar.delegate = self
                if let aClass = NSClassFromString("UISearchBarBackground"),
                    let subviews = searchBar.subviews.last?.subviews {
                    for view in subviews {
                        if view.isKind(of: aClass) {
                            view.removeFromSuperview()
                        }
                    }
                }
            }
        }
    }
    
    var cities: Results<MVCity> = realm.objects(MVCity.self).sorted(byKeyPath: "cityName")
    
    var completion: CityPickerCompletion = { (viewController, city) in }
    
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
        
//        searchBar.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Helpers
    
    func setupViews() {
        
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        
        NotificationCenter.default.addObserver(self, selector: #selector(CityPickerViewController.cityDidSet(sender:)), name: kCityDidSetNotification, object: nil)
    }
    
    func cityDidSet(sender: Notification) {
        
        if let city = LocationManager.shared.city {
            NotificationCenter.default.removeObserver(self, name: kCityDidSetNotification, object: nil)
            completion(self, city)
        }
    }
}

// MARK: - UITableViewDataSource
extension CityPickerViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CityCellId", for: indexPath)
        
        let city = cities[indexPath.row]
        cell.textLabel?.text = city.cityName?.capitalized
        
        return cell
    }
}

// MARK: - UISearchBarDelegate
extension CityPickerViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        completion(self, cities[indexPath.row])
    }
}

// MARK: - UISearchBarDelegate
extension CityPickerViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.characters.count == 0 {
            cities = realm.objects(MVCity.self).sorted(byKeyPath: "cityName")
        }
        else {
            cities = realm.objects(MVCity.self).sorted(byKeyPath: "cityName")
                .filter("cityName CONTAINS[c] %@ OR countryName CONTAINS[c] %@", searchText, searchText)
        }
        tableView.reloadData()
    }
}

// MARK: - UIViewController
extension UIViewController {
    
    func showCityPickerViewController(in navigationController: UINavigationController? = nil, completion: @escaping CityPickerCompletion) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "CityPicker") as! CityPickerViewController
        viewController.completion = completion
        
        var _navigationController: UINavigationController?
        if let navigationController = navigationController {
            _navigationController = navigationController
        }
        else {
            _navigationController = self.navigationController
        }
        _navigationController?.pushViewController(viewController, animated: true)
    }
    
    func presentCityPickerView(completion: @escaping CityPickerCompletion) -> PathDynamicModal {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let picker = storyboard.instantiateViewController(withIdentifier: "CityPicker") as! CityPickerViewController
        picker.view.frame = CGRect(x: 0, y: 0, width: 315, height: 387)
        picker.completion = completion
        
        picker.view.layer.cornerRadius = 8
        picker.view.layer.masksToBounds = true
        picker.view.layer.borderColor = UIColor.lightGray.cgColor
        picker.view.layer.borderWidth = 0.5
        
        self.addChildViewController(picker)
        
        let pathDynamicModal = PathDynamicModal.show(modalView: picker.view, inView: view)
        pathDynamicModal.closeByTapBackground = false
        pathDynamicModal.closeBySwipeBackground = false
        
        return pathDynamicModal
    }
}

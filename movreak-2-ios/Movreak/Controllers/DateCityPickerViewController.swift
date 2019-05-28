//
//  DateCityPickerViewController.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 11/7/16.
//  Copyright © 2016 DyCode. All rights reserved.
//

import UIKit
import RealmSwift
import DateToolsSwift
import Cent

typealias DateCityPickerCompletion = (_ date: Date, _ city: MVCity) -> Void

class DateCityPickerViewController: MovreakViewController {

    @IBOutlet weak var collectionView: UICollectionView!
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
    
    var dates: [Date] = [
        Date() - TimeChunk(days: 3),
        Date() - TimeChunk(days: 2),
        Date() - TimeChunk(days: 1),
        Date(),
        Date() + TimeChunk(days: 1),
        Date() + TimeChunk(days: 2),
        Date() + TimeChunk(days: 3)
    ]
    var selectedDate: Date = Date() {
        didSet {
            setupDateCityTitle()
        }
    }
    
    var cities: Results<MVCity> = realm.objects(MVCity.self).sorted(byKeyPath: "cityName")
    var selectedCity: MVCity? = LocationManager.shared.city {
        didSet {
            setupDateCityTitle()
        }
    }
    
    var completion: DateCityPickerCompletion = { (date, city) in }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
        setupDateCityTitle()
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(DateCityPickerViewController.keyboardWillShow_hide(sender:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(DateCityPickerViewController.keyboardWillShow_hide(sender:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func setupDateCityTitle() {
        
        var strings: [String] = []
        if let cityName = selectedCity?.cityName?.uppercased() {
            strings.append(cityName)
        }
        if selectedDate.isToday {
            strings.append("TODAY")
        }
        else {
            strings.append(selectedDate.format(with: "dd MMM").uppercased())
        }
        
        title = strings.joined(separator: ", ")
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
                
                tableViewBottomConstraint.constant = height
                UIView.animate(withDuration: duration) {
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        
        guard let city = selectedCity else { return }
        completion(selectedDate, city)
    }
}

// MARK: - UICollectionViewDataSource
extension DateCityPickerViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dates.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DateCellId", for: indexPath)
        
        let date = dates[indexPath.item]
        if let dowLabel = cell.viewWithTag(101) as? UILabel {
            dowLabel.text = date.format(with: "EEE")
            
            if date.isSameDay(date: selectedDate) {
                dowLabel.textColor = k888888Color
            }
            else if date.isToday {
                dowLabel.textColor = UIColor.black
            }
            else if date.isEarlier(than: Date()) {
                dowLabel.textColor = UIColor.lightGray
            }
            else if date.isLater(than: Date()) {
                dowLabel.textColor = UIColor.darkGray
            }
         }
        if let dayLabel = cell.viewWithTag(102) as? UILabel {
            dayLabel.text = date.format(with: "dd")
            
            if date.isSameDay(date: selectedDate) {
                dayLabel.textColor = k888888Color
            }
            else if date.isToday {
                dayLabel.textColor = UIColor.black
            }
            else if date.isEarlier(than: Date()) {
                dayLabel.textColor = UIColor.lightGray
            }
            else if date.isLater(than: Date()) {
                dayLabel.textColor = UIColor.darkGray
            }
        }
        
        return cell
    }
}


// MARK: - UICollectionViewDelegate
extension DateCityPickerViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        selectedDate = dates[indexPath.item]
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension DateCityPickerViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width: CGFloat = (UIScreen.main.bounds.width - 30) / 7
        return CGSize(width: width, height: width)
    }
}

// MARK: - UISearchBarDelegate
extension DateCityPickerViewController: UISearchBarDelegate {
    
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

// MARK: - UITableViewDataSource
extension DateCityPickerViewController: UITableViewDataSource {
    
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
        
        cell.accessoryType = .none
        if city.cityID == selectedCity?.cityID {
            cell.accessoryType = .checkmark
        }
        
        return cell
    }
}

// MARK: - UISearchBarDelegate
extension DateCityPickerViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        selectedCity = cities[indexPath.row]
        tableView.reloadData()
    }
}

// MARK: - UIViewController
extension UIViewController {
    
    func presentDateCityPickerViewController(date: Date?, city: MVCity?, completion: @escaping DateCityPickerCompletion) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "DateCityPicker") as! DateCityPickerViewController
        viewController.completion = completion
        viewController.selectedDate = date ?? Date()
        viewController.selectedCity = city
        
        let navigationController = NavigationController(rootViewController: viewController)
        navigationController.modalTransitionStyle = .crossDissolve
        
        present(navigationController, animated: true, completion: nil)
    }
}

//
//  EditProfileViewController.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 2/9/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import UIKit
import FacebookCore
import TwitterKit
import SwiftyJSON
import RealmSwift

enum ProfileItemType {
    case name
    case location
    case facebook
    case twitter
    case path
    case groupTitle
    case logOut
}

struct ProfileItem {
    var type: ProfileItemType
    var title: String?
    var subtitle: String?
    var icon: UIImage?
    var cellHeight: CGFloat = UITableViewAutomaticDimension
}

class EditProfileViewController: MovreakViewController {
    
    lazy var headerView: EditProfileHeaderView = {
        let headerView = Bundle.main.loadNibNamed("EditProfileHeaderView", owner: nil, options: nil)?.first as! EditProfileHeaderView
        headerView.delegate = self
        
        return headerView
    }()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    
    var profileItems: [ProfileItem] = [
        ProfileItem(type: .name, title: "Name", subtitle: "John Doe", icon: nil, cellHeight: UITableViewAutomaticDimension),
        ProfileItem(type: .location, title: "Location", subtitle: "Bandung, Indonesia", icon: nil, cellHeight: UITableViewAutomaticDimension),
        ProfileItem(type: .groupTitle, title: "Linked Accounts", subtitle: nil, icon: nil, cellHeight: 60),
        ProfileItem(type: .facebook, title: "Facebook", subtitle: nil, icon: UIImage(named: "icn_facebook"), cellHeight: UITableViewAutomaticDimension),
        ProfileItem(type: .twitter, title: "Twitter", subtitle: nil, icon: UIImage(named: "icn_twitter"), cellHeight: UITableViewAutomaticDimension),
//        ProfileItem(type: .path, title: "Path", subtitle: nil, icon: UIImage(named: "icn_path"), cellHeight: UITableViewAutomaticDimension),
        ProfileItem(type: .groupTitle, title: "", subtitle: nil, icon: nil, cellHeight: 60),
        ProfileItem(type: .logOut, title: "Log Out", subtitle: "", icon: nil, cellHeight: 45)
    ]
    
    var profile: MVProfile? {
        return UserManager.shared.profile
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Helpers
    
    func setupViews() {
        
        tableView.addSubview(headerView)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 306
        
        tableView.register(UINib(nibName: "EditProfileViewCell", bundle: nil), forCellReuseIdentifier: "EditProfileCellId")
        tableView.register(UINib(nibName: "ProfileTextFieldViewCell", bundle: nil), forCellReuseIdentifier: "TextFieldCellId")
        tableView.register(UINib(nibName: "ProfileGroupTitleViewCell", bundle: nil), forCellReuseIdentifier: "GroupTitleCellId")
        tableView.register(UINib(nibName: "ProfileSocmedViewCell", bundle: nil), forCellReuseIdentifier: "SocmedCellId")
        
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        
        headerView.coverImageView.image = MVProfile.defaultCoverImage()
        if let coverImageUrl = profile?.coverImageUrl {
            if let url = try? coverImageUrl.asURL() {
                self.headerView.coverImageView.sd_setImage(with: url, placeholderImage: MVProfile.defaultCoverImage())
            }
        }
        
        var photoUrl = ""
        if let bigPhotoUrl = profile?.bigPhotoUrl {
            photoUrl = bigPhotoUrl
        }
        else if let smallPhotoUrl = profile?.photoUrl {
            photoUrl = smallPhotoUrl
        }
        headerView.profileImageView.image = MVProfile.defaultPhoto()
        if let url = try? photoUrl.asURL() {
            headerView.profileImageView.sd_setImage(with: url, placeholderImage: MVProfile.defaultPhoto())
        }
    }
    
    func connectToFacebook() {
        
        if UserManager.shared.isConnectedToFacebook {
            
            // Disconnect
            UserManager.shared.disconnectFromFacebook()
                .subscribe { [weak self] (event) in
                    if let weakSelf = self {
                        
                        switch event {
                        case .next(let response):
                            if let _ = response as? MVProfile {
                            }
                            else if let _ = response as? Bool {
                                NotificationCenter.default.post(name: kUserDidSignInOrOutNotification, object: nil)
                                _ = weakSelf.navigationController?.popViewController(animated: true)
                            }
                            
                        case .error(let error):
                            weakSelf.presentErrorNotificationView(with: error.localizedDescription)
                            
                        case .completed:
                            break
                        }
                    }
                }
                .disposed(by: disposeBag)
        }
        else {
            
            // Connect
            showLoadingView(in: view, label: "Signing-in to Facebook...")
            UserManager.shared.connectToFacebook()
                .subscribe { [weak self] (event) in
                    if let weakSelf = self {
                        
                        switch event {
                        case .next(let response):
                            if let _ = response as? TWTRSession {
                                weakSelf.showLoadingView(in: weakSelf.view, label: "Load Twitter profile...")
                            }
                            else if let _ = response as? JSON {
                                weakSelf.showLoadingView(in: weakSelf.view, label: "Update profile...")
                            }
                            else if let _ = response as? MVProfile {
                            }
                            else {
                                
                            }
                            
                        case .error(let error):
                            weakSelf.hideLoadingView()
                            weakSelf.presentErrorNotificationView(with: error.localizedDescription)
                            
                            if let index = weakSelf.profileItems.index(where: { (profileItem) -> Bool in
                                return profileItem.type == .facebook
                            }) {
                                let indexPath = IndexPath(row: index, section: 0)
                                if let cell = weakSelf.tableView.cellForRow(at: indexPath) as? ProfileSocmedViewCell {
                                    cell.isConnected = false
                                }
                            }
                            
                        case .completed:
                            weakSelf.hideLoadingView()
                        }
                    }
                }
                .disposed(by: disposeBag)
        }
    }
    
    func connectToTwitter() {
        
            if UserManager.shared.isConnectedToTwitter {
                
                // Disconnect
                UserManager.shared.disconnectFromTwitter()
                    .subscribe { [weak self] (event) in
                        if let weakSelf = self {
                            
                            switch event {
                            case .next(let response):
                                if let _ = response as? MVProfile {
                                }
                                else if let _ = response as? Bool {
                                    NotificationCenter.default.post(name: kUserDidSignInOrOutNotification, object: nil)
                                    _ = weakSelf.navigationController?.popViewController(animated: true)
                                }
                                
                            case .error(let error):
                                weakSelf.presentErrorNotificationView(with: error.localizedDescription)
                                
                            case .completed:
                                break
                            }
                        }
                    }
                    .disposed(by: disposeBag)
            }
            else {
            
                // Connect
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
                                    weakSelf.showLoadingView(in: weakSelf.view, label: "Update profile...")
                                }
                                else if let _ = response as? MVProfile {
                                }
                                else {
                                    
                                }
                                
                            case .error(let error):
                                weakSelf.hideLoadingView()
                                weakSelf.presentErrorNotificationView(with: error.localizedDescription)
                                
                                if let index = weakSelf.profileItems.index(where: { (profileItem) -> Bool in
                                    return profileItem.type == .twitter
                                }) {
                                    let indexPath = IndexPath(row: index, section: 0)
                                    if let cell = weakSelf.tableView.cellForRow(at: indexPath) as? ProfileSocmedViewCell {
                                        cell.isConnected = false
                                    }
                                }
                                
                            case .completed:
                                weakSelf.hideLoadingView()
                            }
                        }
                    }
                    .disposed(by: disposeBag)
            }
        
    }
    
    func connectToPath() {
        
        if UserManager.shared.isConnectedToPath {
            
            // Disconnect
            UserManager.shared.disconnectFromPath()
                .subscribe { [weak self] (event) in
                    guard let weakSelf = self else { return }
                    
                    switch event {
                    case .next:
                        break
                        
                    case .error(let error):
                        weakSelf.presentErrorNotificationView(with: error.localizedDescription)
                        
                    case .completed:
                        break
                    }
                }
                .disposed(by: disposeBag)
        }
        else {
            
            // Connect
            UserManager.shared.connectToPath(from: self)
                .subscribe { [weak self] (event) in
                    if let weakSelf = self {
                        
                        switch event {
                        case .next:
                            break
                            
                        case .error(let error):
                            weakSelf.showErrorAlert(error: error, completion: { (_) in })
                            weakSelf.pathDynamicModal?.closeWithLeansRight()
                            
                            if let index = weakSelf.profileItems.index(where: { (profileItem) -> Bool in
                                return profileItem.type == .path
                            }) {
                                let indexPath = IndexPath(row: index, section: 0)
                                if let cell = weakSelf.tableView.cellForRow(at: indexPath) as? ProfileSocmedViewCell {
                                    cell.isConnected = false
                                }
                            }
                            
                        case .completed:
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: { 
                                weakSelf.pathDynamicModal?.closeWithLeansRight()
                            })
                        }
                    }
                }
                .disposed(by: disposeBag)
            
            /*
            guard let profile = Profile.currentProfile(in: viewContext) else {
                showErrorAlert(message: "Please sign-in with Facebook or Twitter first", completion: { (alertAction) in })
                return
            }
            
            pathDynamicModal = presentPathSignInViewController(
                in: view,
                completion: { [weak self] (viewController, pathProfile) in
                    
                    profile.pathUserID = pathProfile.userId
                    
                    viewController.showLoadingView(in: viewController.view, label: "Update profile...")
                    _ = UserManager.shared.updateUserProfile { (profile, error) in
                        viewController.hideLoadingView()
                        
                        self?.pathDynamicModal?.closeWithStraight()
                        viewController.removeFromParentViewController()
                    }
                },
                cancelledCompletion: { [weak self] (viewController, error) in
                    
                    if let error = error {
                        self?.showErrorAlert(error: error, completion: { (_) in })
                        
                        if let index = self?.profileItems.index(where: { (profileItem) -> Bool in
                            return profileItem.type == .path
                        }) {
                            let indexPath = IndexPath(row: index, section: 0)
                            if let cell = self?.tableView.cellForRow(at: indexPath) as? ProfileSocmedViewCell {
                                cell.isConnected = false
                            }
                        }
                    }
                    self?.pathDynamicModal?.closeWithStraight()
                    viewController.removeFromParentViewController()
            })
            pathDynamicModal?.closedHandler = {
                
                if !self.isConnectedToPath {
                    if let index = self.profileItems.index(where: { (profileItem) -> Bool in
                        return profileItem.type == .path
                    }) {
                        let indexPath = IndexPath(row: index, section: 0)
                        if let cell = self.tableView.cellForRow(at: indexPath) as? ProfileSocmedViewCell {
                            cell.isConnected = false
                        }
                    }
                }
                
                self.pathDynamicModal = nil
             }
             */
        }
    }
    
    func change(displayName text: String?) {
        
        guard let displayName = text?.strip(),
            displayName.characters.count > 0 else {
                
                if let index = self.profileItems.index(where: { (profileItem) -> Bool in
                    return profileItem.type == .name
                }) {
                    let indexPath = IndexPath(row: index, section: 0)
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
                return
        }
        
        try! realm.write {
            profile?.displayName = displayName
        }
    }
    
    func editLocation() {
    
        showCityPickerViewController { (_, city) in
            _ = self.navigationController?.popViewController(animated: true)
            
            try! realm.write {
                self.profile?.preferedCity = city.cityName
                self.profile?.preferedCountry = city.countryCode
                if let cityName = city.cityName, let countryName = city.countryName {
                    self.profile?.location = "\(cityName), \(countryName)"
                }
            }
            
            if let index = self.profileItems.index(where: { (profileItem) -> Bool in
                return profileItem.type == .location
            }) {
                let indexPath = IndexPath(row: index, section: 0)
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
    }
    
    func updateUserProfile() {
        
        _ = UserManager.shared.updateUserProfile { (profile, error) in
            
            if let _ = profile {
                NotificationCenter.default.post(name: kReviewSubmitedNotification, object: self, userInfo: nil)
            }
            else if let error = error {
                print(error.localizedDescription)
            }
        }
        
        _ = navigationController?.popViewController(animated: true)
    }
    
    func updateUserProfilePhoto() {
        
        presentImagePickerController(didCancelHandler: { }) { (image) in
            
            if let image = image {
                
                self.headerView.profileLoadingView.startAnimating()
                self.headerView.profileImageView.alpha = 0.5
                self.headerView.profileImageButton.isEnabled = false
                
                UserManager.shared.changeProfileImage(image: image, completion: { [weak self] (result, error) in
                    
                    if let _ = result {
                        NotificationCenter.default.post(name: kReviewSubmitedNotification, object: self, userInfo: nil)
                        
                        self?.headerView.profileLoadingView.stopAnimating()
                        self?.headerView.profileImageView.alpha = 1.0
                        self?.headerView.profileImageView.image = image
                        self?.headerView.profileImageButton.isEnabled = true
                    }
                    else if let error = error {
                        self?.presentErrorNotificationView(with: error.localizedDescription)
                    }
                })
            }
        }
        
//        presentImagePickerController { (assets) in
//            if assets.count > 0 {
//                
//                let asset = assets[0]
//                asset.fetchOriginalImageWithCompleteBlock { (image, _) in
//                    if let image = image {
//                        
//                        self.headerView.profileLoadingView.startAnimating()
//                        self.headerView.profileImageView.alpha = 0.5
//                        self.headerView.profileImageButton.isEnabled = false
//                        
//                        UserManager.shared.changeProfileImage(image: image, completion: { [weak self] (result, error) in
//                            
//                            if let _ = result {
//                                NotificationCenter.default.post(name: kReviewSubmitedNotification, object: self, userInfo: nil)
//                                
//                                self?.headerView.profileLoadingView.stopAnimating()
//                                self?.headerView.profileImageView.alpha = 1.0
//                                self?.headerView.profileImageView.image = image
//                                self?.headerView.profileImageButton.isEnabled = true
//                            }
//                            else if let error = error {
//                                self?.presentErrorNotificationView(with: error.localizedDescription)
//                            }
//                        })
//                    }
//                }
//            }
//        }
    }
    
    func updateUserProfileCover() {

        presentImagePickerController(didCancelHandler: { }) { (image) in
            
            if let image = image {
                
                self.headerView.coverLoadingView.startAnimating()
                self.headerView.coverImageView.alpha = 0.5
                self.headerView.coverImageButton.isEnabled = false
                
                UserManager.shared.changeCoverImage(image: image, completion: { [weak self] (result, error) in
                    
                    if let _ = result {
                        NotificationCenter.default.post(name: kReviewSubmitedNotification, object: self, userInfo: nil)
                        
                        self?.headerView.coverLoadingView.stopAnimating()
                        self?.headerView.coverImageView.alpha = 1.0
                        self?.headerView.coverImageView.image = image
                        self?.headerView.coverImageButton.isEnabled = true
                    }
                    else if let error = error {
                        self?.presentErrorNotificationView(with: error.localizedDescription)
                    }
                })
            }
        }
        
//        presentImagePickerController { (assets) in
//            if assets.count > 0 {
//                
//                let asset = assets[0]
//                asset.fetchOriginalImageWithCompleteBlock { (image, _) in
//                    if let image = image {
//                        
//                        self.headerView.coverLoadingView.startAnimating()
//                        self.headerView.coverImageView.alpha = 0.5
//                        self.headerView.coverImageButton.isEnabled = false
//                        
//                        UserManager.shared.changeCoverImage(image: image, completion: { [weak self] (result, error) in
//                            
//                            if let _ = result {
//                                NotificationCenter.default.post(name: kReviewSubmitedNotification, object: self, userInfo: nil)
//                                
//                                self?.headerView.coverLoadingView.stopAnimating()
//                                self?.headerView.coverImageView.alpha = 1.0
//                                self?.headerView.coverImageView.image = image
//                                self?.headerView.coverImageButton.isEnabled = true
//                            }
//                            else if let error = error {
//                                self?.presentErrorNotificationView(with: error.localizedDescription)
//                            }
//                        })
//                    }
//                }
//            }
//        }
    }
    
    // MARK: - Actions
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        updateUserProfile()
    }
    
}

// MARK: - UITableViewDataSource
extension EditProfileViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profileItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell!
        
        let item = profileItems[indexPath.row]
        switch item.type {
        case .name:
            let _cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCellId", for: indexPath) as! ProfileTextFieldViewCell
            _cell.titleLabel.text = item.title
            _cell.textField.placeholder = item.subtitle
            _cell.textField.text = profile?.displayName
            _cell.textField.delegate = self
            _cell.separatorViewLeadingConstraint.constant = 30
            
            cell = _cell
            
        case .location:
            let _cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCellId", for: indexPath) as! ProfileTextFieldViewCell
            _cell.titleLabel.text = item.title
            _cell.textField.placeholder = item.subtitle
            
            var location = profile?.location
            if let cityName = profile?.preferedCity {
                let cities = realm.objects(MVCity.self).filter("cityName =[c] '\(cityName)'")
                if let city = cities.first, let cityName = city.cityName, let countryName = city.countryName {
                    location = "\(cityName.capitalized), \(countryName.capitalized)"
                }
            }
            _cell.textField.text = location
            
            _cell.textField.isEnabled = false
            _cell.separatorViewLeadingConstraint.constant = 0
            
            cell = _cell
            
        case .groupTitle:
            let _cell = tableView.dequeueReusableCell(withIdentifier: "GroupTitleCellId", for: indexPath) as! ProfileGroupTitleViewCell
            _cell.selectionStyle = .none
            _cell.titleLabel.text = item.title
            _cell.titleLabel.textAlignment = .left
            _cell.titleLabel.textColor = UIColor.black
            _cell.titleLabel.font = kCoreSans17Font
            _cell.separatorViewLeadingConstraint.constant = 0
            
            cell = _cell
            
        case .facebook:
            let _cell = tableView.dequeueReusableCell(withIdentifier: "SocmedCellId", for: indexPath) as! ProfileSocmedViewCell
            _cell.iconImageView.image = item.icon
            _cell.nameLabel.text = item.title
            _cell.separatorViewLeadingConstraint.constant = 30
            
            if UserManager.shared.isConnectedToFacebook {
                _cell.isConnected = true
            }
            else {
                _cell.isConnected = false
            }
            
            _cell.delegate = self
            
            cell = _cell
            
        case .twitter:
            let _cell = tableView.dequeueReusableCell(withIdentifier: "SocmedCellId", for: indexPath) as! ProfileSocmedViewCell
            _cell.iconImageView.image = item.icon
            _cell.nameLabel.text = item.title
            _cell.separatorViewLeadingConstraint.constant = 0
            
            if UserManager.shared.isConnectedToTwitter {
                _cell.isConnected = true
            }
            else {
                _cell.isConnected = false
            }
            
            _cell.delegate = self
            
            cell = _cell
            
        case .path:
            let _cell = tableView.dequeueReusableCell(withIdentifier: "SocmedCellId", for: indexPath) as! ProfileSocmedViewCell
            _cell.iconImageView.image = item.icon
            _cell.nameLabel.text = item.title
            _cell.separatorViewLeadingConstraint.constant = 0
            
            if UserManager.shared.isConnectedToPath {
                _cell.isConnected = true
            }
            else {
                _cell.isConnected = false
            }
            
            _cell.delegate = self
            
            cell = _cell
            
        case .logOut:
            let _cell = tableView.dequeueReusableCell(withIdentifier: "GroupTitleCellId", for: indexPath) as! ProfileGroupTitleViewCell
            _cell.selectionStyle = .default
            _cell.titleLabel.text = item.title
            _cell.titleLabel.textAlignment = .center
            _cell.titleLabel.textColor = UIColor.red
            _cell.titleLabel.font = kCoreSansMedium17Font
            _cell.separatorViewLeadingConstraint.constant = 0
            
            cell = _cell
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension EditProfileViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let item = profileItems[indexPath.row]
        return item.cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = profileItems[indexPath.row]
        switch item.type {
        case .location:
            editLocation()
            
        case .facebook:
            connectToFacebook()
            
        case .twitter:
            connectToTwitter()
            
        case .path:
            connectToPath()
            
        case .logOut:
            UserManager.shared.localSignOut()
            NotificationCenter.default.post(name: kUserDidSignInOrOutNotification, object: nil)
            _ = navigationController?.popViewController(animated: true)
            
        default:
            break
        }
    }
}

// MARK: - EditProfileViewCellDelegate
extension EditProfileViewController: EditProfileHeaderViewDelegate {
    
    func editProfileHeaderViewEditCoverButtonTapped(view: EditProfileHeaderView) {
        updateUserProfileCover()
    }
    
    func editProfileHeaderViewEditPhotoButtonTapped(view: EditProfileHeaderView) {
        updateUserProfilePhoto()
    }
}

// MARK: - EditProfileViewCellDelegate
extension EditProfileViewController: ProfileSocmedViewCellDelegate {

    func profileSocmedViewCellSwitchButtonTapped(cell: ProfileSocmedViewCell) {
        cell.isConnected = !cell.isConnected
        
        if let indexPath = tableView.indexPath(for: cell) {
            
            let item = profileItems[indexPath.row]
            switch item.type {
            case .facebook:
                 connectToFacebook()
                
            case .twitter:
                connectToTwitter()
                
            case .path:
                connectToPath()
                
            default:
                break
            }
        }
    }
}

// MARK: - UITextFieldDelegate
extension EditProfileViewController: UITextFieldDelegate {
 
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if let cell = textField.tableViewCell {
            if let indexPath = tableView.indexPath(for: cell) {
                
                let profileItem = profileItems[indexPath.row]
                switch profileItem.type {
                case .name:
                    change(displayName: textField.text)
                    
                default:
                    break
                }
            }
        }
    }
}

// MARK: - UIViewController
extension UIViewController {
    
    func showEditProfileViewController(in navigationController: UINavigationController? = nil) {
        
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "EditProfile") as! EditProfileViewController
        
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


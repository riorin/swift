//
//  SplashViewController.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 10/3/16.
//  Copyright © 2016 DyCode. All rights reserved.
//

import UIKit
import Moya_ObjectMapper
import RealmSwift
import SwiftyJSON


class SplashViewController: MovreakViewController {

    var clientSettingLoaded: Bool = false
    var supportedCitiesLoaded: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadClientSetting()
        loadSupportedCities()
        LocationManager.shared.updateLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - Helpers
    
    func loadClientSetting() {
        
        provider.request(.clientSetting)
            .mapObject(MVSetting.self)
            .subscribe { [weak self] event in
                
                switch event {
                case .next(let setting):
                    setting.lastRefreshDate = Date()
                    try! realm.write { realm.add(setting, update: true) }
                    
                case .completed:
                    self?.clientSettingLoaded = true
                    self?.endSplashScreen()
                
                case .error(let error):
                    print(error.localizedDescription)
                    self?.clientSettingLoaded = true
                    self?.endSplashScreen()
                }
            }
            .disposed(by: disposeBag)
    }
    
    func loadSupportedCities() {
        
        provider.request(.supportedCity(nil))
            .mapArray(MVCity.self)
            .subscribe { [weak self] (event) in
                
                switch event {
                case .next(let cities):
                    Realm.writeAsync(objects: cities) {
                        self?.supportedCitiesLoaded = true
                        self?.endSplashScreen()
                    }
                    
                case .completed:
                    if LocationManager.shared.city == nil {
                        LocationManager.shared.updateLocation()
                    }
                    
                case .error(let error):
                    print(error.localizedDescription)
                    self?.supportedCitiesLoaded = true
                    self?.endSplashScreen()
                }
            }
            .disposed(by: disposeBag)
    }
    
    func endSplashScreen() {
        if clientSettingLoaded && supportedCitiesLoaded {
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.showMainViewController()
        }
    }
}

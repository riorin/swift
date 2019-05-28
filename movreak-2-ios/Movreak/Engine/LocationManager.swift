//
//  Movreak.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 8/19/16.
//  Copyright © 2016 DyCode. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON
import RealmSwift

typealias MovreakCompletion<T> = (_ result: T?, _ error: Swift.Error?) -> Void

class LocationManager: NSObject {

    class var shared: LocationManager {
        struct Static {
            static let instance: LocationManager = LocationManager()
        }
        return Static.instance
    }
    
    override init() {
        super.init()
        
    }
    
    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.delegate = self
        
        return manager
    }()
    
    var location: CLLocation? {
        didSet {
            if let location = location {
                _ = self.city(with: location) { (result, error) in
                    if let result = result {
                        self.city = result
                    }
                }
            }
        }
    }
    
    var city: MVCity? {
        didSet {
            if city != nil {
                NotificationCenter.default.post(name: kCityDidSetNotification, object: self, userInfo: nil)
            }
        }
    }
    
    // MARK: - Helpers
    func updateLocation() {
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - City
    func city(with location: CLLocation, completion: @escaping MovreakCompletion<MVCity>) -> Request {
        
        let urlString = String(format: kGoogleApiGeocodeUrlFormat, location.coordinate.latitude, location.coordinate.longitude)
        let request = Alamofire.request(urlString).responseData { (response) in
            
            switch response.result {
            case .success(let value):
                let json = JSON(data: value)
                if let results = json["results"].array {
                    
                    DispatchQueue.global().async {
                        
                        let realm = try! Realm()
                        let cityNames = realm.objects(MVCity.self).sorted(byKeyPath: "cityName")
                            .flatMap { (city) -> String? in
                                return city.cityName?.replacingOccurrences(of: " ", with: "").lowercased()
                        }
                        
                        var reverseGeocodedCityNames: [String] = []
                        
                        for result in results {
                            if let addressComponents = result["address_components"].array {
                                for addressComponent in addressComponents {
                                    if let longName = addressComponent["long_name"].string {
                                        
                                        for cityName in cityNames {
                                            if longName.replacingOccurrences(of: " ", with: "").lowercased().contains(cityName) {
                                                reverseGeocodedCityNames.append(cityName)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        DispatchQueue.main.async {
                            
                            let realm = try! Realm()
                            if let cityName = reverseGeocodedCityNames.max() {
                                let realm = try! Realm()
                                self.city = realm.objects(MVCity.self).filter("cityName =[c] %@", cityName).first
                            }
                            
                            if self.city == nil {
                                if let cityName = UserManager.shared.profile?.preferedCity {
                                    self.city = realm.objects(MVCity.self).filter("cityName =[c] %@", cityName).first
                                }
                            }
                            
                            if self.city == nil {
                                if let cityName = UserDefaults.standard.string(forKey: kLastSelectedCity) {
                                    self.city = realm.objects(MVCity.self).filter("cityName =[c] %@", cityName).first
                                }
                            }
                            
                            completion(self.city, nil)
                        }
                    }
                }
                else {
                    completion(nil, nil)
                }
                
            case .failure(let error):
                completion(nil, error)
            }
        }
        
        return request
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        location = locations.last
        if location != nil {
            manager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Swift.Error) {
        print(error.localizedDescription)
    }
}

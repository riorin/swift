//
//  CheckSeatActivity.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 5/29/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import UIKit

class CheckSeatActivity: UIActivity {

    var movie: MVMovie?
    var scheduledTheater: MVScheduledTheater?
    
    var scheduledMovie: MVScheduledMovie?
    var theater: MVTheater?
    
    var showTimeIndex: Int = 0
    
    convenience init(movie: MVMovie, scheduledTheater: MVScheduledTheater, showTime: Int) {
        self.init()
        
        self.movie = movie
        self.scheduledTheater = scheduledTheater
        self.showTimeIndex = showTime
    }
    
    convenience init(theater: MVTheater, scheduledMovie: MVScheduledMovie, showTime: Int) {
        self.init()
        
        self.scheduledMovie = scheduledMovie
        self.theater = theater
        self.showTimeIndex = showTime
    }
    
    override var activityTitle: String? {
        return "Check Seats"
    }
    
    override var activityImage: UIImage? {
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            return UIImage(named: "icn_check_seat")
        }
        else {
            return UIImage(named: "icn_check_seat_ipad")
        }
    }
    
    override var activityType: UIActivityType? {
        return UIActivityType("com.movreak.activity.CheckSeats")
    }
    
    override var activityViewController: UIViewController? {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "Seats") as! SeatsViewController
        
        viewController.movie = movie
        viewController.scheduledTheater = scheduledTheater
        viewController.theater = theater
        viewController.scheduledMovie = scheduledMovie
        viewController.selectedShowTimeIndex = showTimeIndex
        
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalTransitionStyle = .crossDissolve
        return navigationController
    }
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }
}

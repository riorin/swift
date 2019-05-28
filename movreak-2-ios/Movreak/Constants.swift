//
//  Constants.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 8/19/16.
//  Copyright © 2016 DyCode. All rights reserved.
//

import UIKit

let kMovreakAppVersionNumber    = 40900
let kMovreakExclusive           = 0
let kMovreakPremium             = 1

let kGoldenRation: CGFloat = 1.61803
let kMaxThumbs: Int = 4

// MARK: - Date Formats

let kDefaultDateFormat = "yyyy-MM-dd'T'HH:mm:ss"
let kDateFormats: [String] = [
    "dd/MM/yyyy",
    "yyyy-MM-dd",
    "yyyy-MM-dd HH:mm:ss",
    "yyyy-MM-dd'T'HH:mm:ss",
    "yyyy-MM-dd'T'HH:mm:ssZ",
    "yyyy-MM-dd'T'HH:mm:ss'Z'",
    "yyyy-MM-dd'T'HH:mm:ss.SSS",
    "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
    "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
]

// MARK: - Colors
typealias RGBACOLOR = (_ r: Int, _ g: Int, _ b: Int, _ a: Double) -> UIColor
typealias RGBCOLOR  = (_ r: Int, _ g: Int, _ b: Int) -> UIColor
let RGBA: RGBACOLOR = { (r, g, b, a) -> UIColor in
    return UIColor(red: CGFloat(r)/255, green: CGFloat(g)/255, blue: CGFloat(b)/255, alpha: CGFloat(a))
}
let RGB: RGBCOLOR = { (r, g, b) -> UIColor in
    return RGBA(r, g, b, 1.0)
}

let kD4D4D4Color = RGBA(212, 212, 212, 0.6) // navigation bar shadow
let kE8ECF0Color = RGB(232, 236, 240) // view background color
let k35373AColor = RGB(53, 55, 58)
let k35373A05Color = RGBA(53, 55, 58, 0.5)
let k0C5BE8Color = RGB(12, 91, 232)
let k888888Color = RGB(136, 136, 136) // gray font color

// MARK: - Shadowing
let kCornerRadius: CGFloat = 8.0
let kBorderColor: UIColor = UIColor.white
let kBorderWidth: CGFloat = 0.5
let kShadowColor: UIColor = kD4D4D4Color
let kShadowOffset: CGSize = CGSize(width: 0, height: 0.5)
let kShadowRadius: CGFloat = 3
let kShadowOpacity: Float = 1


// MARK: - Images
//let kBgImage = UIImage(named: "bg_movreak")!
//let kBgNavBarImage = UIImage(named: "bg_nav_bar")!

let kDefaultMovieImage = UIImage(named: "img_movie_placeholder")!
let kDefaultBigMovieImage = UIImage(named: "img_movie_placeholder")!

let kDefaultProfileImage = UIImage(named: "img_profile_placeholder")!
let kDefaultCoverProfileImage = UIImage(named: "img_cover_profile_placeholder")!

let kDefaultTheaterImage = UIImage(named: "img_theater_placeholder")!

// MARK: - Fonts
let kCoreSans11Font         = UIFont(name: "CoreSansR35Regular", size: 11)!
let kCoreSans12Font         = UIFont(name: "CoreSansR35Regular", size: 12)!
let kCoreSans13Font         = UIFont(name: "CoreSansR35Regular", size: 13)!
let kCoreSans14Font         = UIFont(name: "CoreSansR35Regular", size: 14)!
let kCoreSans15Font         = UIFont(name: "CoreSansR35Regular", size: 15)!
let kCoreSans17Font         = UIFont(name: "CoreSansR35Regular", size: 17)!
let kCoreSansLight13Font    = UIFont(name: "CoreSansR25Light", size: 13)!
let kCoreSansLight15Font    = UIFont(name: "CoreSansR25Light", size: 15)!
let kCoreSansLight30Font    = UIFont(name: "CoreSansR25Light", size: 30)!
let kCoreSansMedium15Font   = UIFont(name: "CoreSansR45Madium", size: 15)!
let kCoreSansMedium17Font   = UIFont(name: "CoreSansR45Medium", size: 17)!
let kCoreSansBold12Font     = UIFont(name: "CoreSansR55Bold", size: 12)!
let kCoreSansBold13Font     = UIFont(name: "CoreSansR55Bold", size: 13)!
let kCoreSansBold15Font     = UIFont(name: "CoreSansR55Bold", size: 15)!
let kCoreSansBold16Font     = UIFont(name: "CoreSansR55Bold", size: 16)!
let kCoreSansBold17Font     = UIFont(name: "CoreSansR55Bold", size: 17)!
let kCoreSansBold24Font     = UIFont(name: "CoreSansR55Bold", size: 24)!

// MARK: - Account
let kMovreakSvcUsername = "yadi"
let kMovreakSvcPassword = "a"

// MARK: - API Keys
let kTmdbApiKey             = "bbf1da7e107ce6a46c6228cc1e3ffb69"
let kPathClientId           = "62ce9189ae8df59fc1a56583072de16ba73f9d36"
let kPathClientSecret       = "b2cb9b142b6fb69ec48b2849b912c38346aa0705"
let kPathCallbackUrl        = "http://movreak.com/PathApiCallback.ashx"
let kDefaultPathApiMode     = PathApiMode.hybrid
let kTwitterConsumerKey     = "3wAWw4bXxDMwM9766uNAJA"
let kTwitterConsumerSecret  = "hbEMEx7iFVNkDMkl0IdEVyUeI8FKleQvcJzQfTgIlCM"

// MARK: - Intervals
let kClientSettingRefreshTimeInterval: TimeInterval = 60 * 15 //Every 15 mins
let kAppRefreshTimeInterval: TimeInterval = 60 * 60 * 6 //Every 6 hours

// MARK: - Notifications
let kCityDidSetNotification = NSNotification.Name.init(rawValue: "kCityDidSetNotification")
let kDidUpdateLocationNotification = NSNotification.Name.init(rawValue: "kDidUpdateLocationNotification")
let kUserDidSignInOrOutNotification = NSNotification.Name.init(rawValue: "kUserDidSignInOrOutNotification")
let kCardDidRemoveNotification = NSNotification.Name.init(rawValue: "kCardDidRemoveNotification")
let kCardDidAddNotification = NSNotification.Name.init(rawValue: "kCardDidAddNotification")
let kReviewSubmitedNotification = NSNotification.Name.init(rawValue: "kReviewSubmitedNotification")
let kProfileUpdatedNotification = NSNotification.Name.init(rawValue: "kProfileUpdatedNotification")

// MARK: - Movie Credit
let kCreditLabels = ["Cast", "Casts", "Pemain", "Actor", "Actors", "Actress", "Writer", "Writers", "Penulis", "Written by", "Producer", "Producers", "Produser", "Produced by", "Director", "Directors", "Directed by", "Sutradara"]

let kAdsLabels = ["Cast", "Casts", "Pemain", "Actor", "Actors", "Actress", "Writer", "Writers", "Penulis", "Written by", "Producer", "Producers", "Produser", "Produced by", "Director", "Directors", "Directed by", "Sutradara"]

// MARK: - UserDefault Keys
let kAppDidRunOnceKey       = "kAppDidRunOnceKey"
let kLastAppRefreshKey      = "kLastAppRefreshKey"
let kLastSelectedCity       = "kLastSelectedCity"

// MARK: - Sharing
let kWillWatchFormat        = "#WillWatch %@ @ %@ %@, at %@. via @movreak"
let kNowWatchingFormat      = "#nw '%@'.\nvia @movreak"
let kMovieScheduleFormat    = "'%@' at %@ %@. Times: %@ via @movreak"

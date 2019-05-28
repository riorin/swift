//
//  Endpoints.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 8/19/16.
//  Copyright © 2016 DyCode. All rights reserved.
//

import Foundation

let kBaseUrl = "http://api1.movreak.com"
let kNewsBaseUrl = "http://news.movreak.com"
let kCmsBaseUrl = "cgv"

// MARK: - Google APIs
let kGoogleApiGeocodeUrlFormat                  = "https://maps.googleapis.com/maps/api/geocode/json?latlng=%+.6f,%+.6f&key=AIzaSyBI5QVLe6SvT6k5ruwCfEklF44Bjk-Z180"

// MARK: - Client Setting
let kClientSettingPathUrl                       = "/Api/Config/ClientSetting"
let kSupportedCitiesPathUrl                     = "/Api/Cities/Supported"

// MARK: - Home
let kHomePathUrl                                = "/Api/Home"

// MARK: - Movies
let kMovieScheduleByDateAndCityPathUrl          = "/Api/Schedule/Movie"
let kNearbyMovieScheduleByDatePathUrl           = "/Api/Schedule/NearbyMovie"
let kAllNowPlayingMoviesWithNoShowTimePathUrl   = "/Api/Movies/InCinemaNoShowtime"
let kMovieDetailPathUrl                         = "/OData/Movies"
let kMovieInfoPathUrl                           = "/Api/Movie/Infos"
let kMoviePostersPathUrl                        = "/Api/Movie/Posters"
let kMovieSearch                                = "/Api/Movies/Search"
let kMovieSearchByRottenTomatoesIDPathUrl       = "/Api/Movies/SearchById"
let kMovieComingSoonPathUrl                     = "/Api/Movies/ComingSoon"
let kMovieListPathUrl                           = "/Api/MovieList"
let kPopularMoviesPathUrl                       = "/Api/Movies/Popular"

let kMovieDetailPageFormatUrl                   = "http://movreak.com/movie/%@"

// MARK: - Ads
let kAdsDetailPathUrl                           = "/Api/Ads/Detail"

// MARK: - Movie Trailer
let kTrailersPathUrl                            = "/Api/Trailers"
let kMovieTrailerPathUrl                        = "/Api/Trailer"
let kMovieTrailersPathUrl                       = "/Api/Movie/Trailers"
let kMovieTrailerThumbnailSmallUrlFormat        = "\(kBaseUrl)/OData/MovieTrailers(%@L)/SmallThumbnail/$value"
let kMovieTrailerThumbnailBigUrlFormat          = "\(kBaseUrl)/OData/MovieTrailers(%@L)/BigThumbnail/$value"

// MARK: - TMDB
let kTmdbBaseUrl                                = "http://api.themoviedb.org"
let kTmdbMoviePathUrl                           = "/3/movie/%@"
let kTmdbMovieListPathUrl                       = "/3/movie/%@/lists"
let kTmdbConfigPathUrl                          = "/3/configuration"
let kTmdbMovieImagesPathUrl                     = "/3/movie/%@/images"
let kTmdbMovieTrailersPathUrl                   = "/3/movie/%@/trailers"
let kTmdbListPathUrl                            = "/3/list/%@"

// MARK: - Youtube
let kYoutubeVideoFormatUrl                      = "http://www.youtube.com/watch?v=%@" //"https://www.youtube.com/embed/%@?autoplay=1"
let kYouTubeVideoDetailFormatUrl                = "https://www.googleapis.com/youtube/v3/videos?id=%@&part=snippet,player,contentDetails&key=AIzaSyAoYUmGpzYMaptYf0JUlMT0PDDOzM18yIY"

// MARK: - Theaters
let kTheaterScheduleByDateAndCityPathUrl        = "/Api/Schedule/Theater"
let kNearbyTheaterScheduleByDatePathUrl         = "/Api/Schedule/NearbyTheater"
let kTheaterDetailPathUrl                       = "/OData/Theaters"

// MARK: - Reviews
let kAllUserReviewPathUrl                       = "/Api/UserReviews"
let	kUserReviewPostPathUrl                      = "/OData/MovieUserReviews"
let kLikeUserReviewPostPathUrl                  = "/OData/ContentLikes"
let kUnlikeUserReviewPostPathUrl                = "/Api/UserReview/Unlike"
let kFlagUserReviewPostPathUrl                  = "/OData/ContentFlags"
let	kAUserReviewPathUrl                         = "/OData/MovieUserReviews(%@L)"

// MARK: - News
let kNewsCategoriesPathUrl                      = "/api/get_category_index/"
let kNewsGeneralPathUrl                         = "/Api/News/General"
let kNewsMarkReadPath                           = "/Api/News/MarkRead"
let kNewsFeaturedPathUrl                        = "/Api/News/Featured"

// MARK: - Profiles
let kLoginPathUrl                               = "/Api/Login"
let kUserProfilePathUrl                         = "/Api/UserProfile"
let kUserProfileUpdatePathUrl                   = "/Api/UserProfile/Update"
let kUserProfileUpdatePrefsPathUrl              = "/Api/UserProfile/UpdatePreference"
let kUserProfileChangePhotoPathUrl              = "/Api/UserProfile/ChangePhoto"
let kUserProfileUpdateCoverPathUrl              = "/Api/UserProfile/UpdateCover"
let kUserProfileAddDeviceTokenPathUrl           = "/Api/UserProfile/AddDeviceToken"

// MARK: - Watching
let	kMovieWatchingSubmitPathUrl                 = "/OData/MovieWatchings"
let kAMovieWatchingPathUrl                      = "/OData/MovieWatchings(%@L)"
let	kWatchedMoviesPathUrl                       = "/Api/Watchings"
let	kMovieWatchingStatPathUrl                   = "/Api/Watchings/Stat"
let	kRsvpMovieWatchingPathUrl                   = "/Api/Watching/Rsvp"

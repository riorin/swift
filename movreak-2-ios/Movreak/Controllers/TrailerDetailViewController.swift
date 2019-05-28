
//
//  TrailerDetailViewController.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 3/29/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import UIKit

class TrailerDetailViewController: MovreakViewController {

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    @IBOutlet weak var playerView: YTPlayerView!
    @IBOutlet weak var tableView: UITableView!
    
    var trailer: MVTrailer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
        
        if let videoDirectUrl = trailer?.videoDirectUrl, videoDirectUrl.isLink, let url = try? videoDirectUrl.asURL() {
            
            webView.isHidden = true
            playerView.isHidden = true
            
            if videoDirectUrl.contains("youtube") {
                if let youtubeVideoID = trailer?.youtubeVideoID {
                    playerView.isHidden = false
                    playerView.load(withVideoId: youtubeVideoID)
                }
            }
            else {
                let request = URLRequest(url: url)
                webView.isHidden = false
                webView.loadRequest(request)
            }
        }
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
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - Helpers
    
    func setupViews() {
        
        webView.scrollView.isScrollEnabled = false
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 79
        
        tableView.tableFooterView = UIView()
        
        playerView.delegate = self
    }
}

// MARK: - UITableViewDataSource
extension TrailerDetailViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        
        if indexPath.row == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "TitleCellId", for: indexPath)
            cell.selectionStyle = .none
            
            if let label = cell.viewWithTag(101) as? UILabel {
                
                var titleText = ""
                if let title = trailer?.title {
                    titleText = title
                }
                if let shortDesc = trailer?.shortDescription {
                    if titleText.characters.count > 0 {
                        titleText = "\(titleText) - \(shortDesc)"
                    }
                    else {
                        titleText = shortDesc
                    }
                }
                label.text = titleText
            }
        }
        else  if indexPath.row == 1 {
            cell = tableView.dequeueReusableCell(withIdentifier: "DescriptionCellId", for: indexPath)
            cell.selectionStyle = .none
            
            if let label = cell.viewWithTag(101) as? UILabel {
                label.text = trailer?.createdDate?.timeAgoSinceNow
            }
            
            if let label = cell.viewWithTag(102) as? UILabel {
                label.text = trailer?.descripción
            }
        }
        else { //if indexPath.row == 2 {
            cell = tableView.dequeueReusableCell(withIdentifier: "MovieCellId", for: indexPath)
            cell.selectionStyle = .default
            
            if let imageView = cell.viewWithTag(101) as? UIImageView {
                imageView.image = MVMovie.defaultPosterImage()
                if let posterUrl = trailer?.movie?.posterUrl, let url = try? posterUrl.asURL() {
                    imageView.sd_setImage(with: url, placeholderImage: MVMovie.defaultPosterImage())
                }
            }
            
            if let label = cell.viewWithTag(102) as? UILabel {
                label.text = trailer?.movie?.title
            }
            
            if let label = cell.viewWithTag(103) as? UILabel {
                var movieSubtitleText = ""
                if let mpaaRating = trailer?.movie?.mpaaRating {
                    movieSubtitleText = mpaaRating
                }
                if let duration = trailer?.movie?.duration.value?.durationString {
                    if movieSubtitleText.characters.count == 0 { movieSubtitleText = duration }
                    else { movieSubtitleText = "\(movieSubtitleText) | \(duration)"}
                }
                if let genre = trailer?.movie?.genre {
                    if movieSubtitleText.characters.count == 0 { movieSubtitleText = genre }
                    else { movieSubtitleText = "\(movieSubtitleText) | \(genre)"}
                }
                label.text = movieSubtitleText
            }
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension TrailerDetailViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 2 {
            showMovieDetailViewController(withMovie: trailer?.movie)
        }
    }
}

// MARK: - UIWebViewDelegate
extension TrailerDetailViewController: UIWebViewDelegate {
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        loadingView.startAnimating()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        loadingView.stopAnimating()
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        loadingView.stopAnimating()
    }
}

// MARK: - YTPlayerViewDelegate
extension TrailerDetailViewController: YTPlayerViewDelegate {

    
}

// MARK: - UIViewController
extension UIViewController {
    
    func showTrailerDetailViewController(with trailer: MVTrailer?, in navigationController: UINavigationController? = nil) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "TrailerDetail") as! TrailerDetailViewController
        viewController.trailer = trailer
        
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



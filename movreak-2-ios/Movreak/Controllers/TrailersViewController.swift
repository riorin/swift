//
//  TrailersViewController.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 3/29/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import UIKit
import SwiftyJSON
import SafariServices
import AVFoundation
import AVKit

class TrailersViewController: MovreakViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var isFeatured: Bool = false
    var rawTrailers: [MVTrailer] = []
    var trailers: [MVTrailer] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
        
        loadTrailers()
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - Helpers
    
    func setupViews() {
        
        if isFeatured { title = "FEATURED TRAILERS" }
        else { title = "TRAILERS" }
        
        setupRefreshControl(with: tableView)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = UIScreen.main.bounds.width / kGoldenRation
        
        tableView.register(UINib(nibName: "TrailerViewCell", bundle: nil), forCellReuseIdentifier: "TrailerCellId")
        
        tableView.addInfiniteScroll { (collectionView) in
            self.loadMore()
        }
        tableView.setShouldShowInfiniteScrollHandler { (tableView) -> Bool in
            return self.trailers.count > 0
        }
    
        titleForEmptyDataSet = "No Trailer :("
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
    }
    
    func loadTrailers(skip: Int = 0) {
        
        isLoading = true
        provider.request(.trailers(skip, isFeatured))
            .mapArray(MVTrailer.self)
            .subscribe { [weak self] (event) in
                guard let weakSelf = self else { return }
                
                switch event {
                case .next(let trailers):
                    let filteredTrailers = trailers.filter { (trailer) -> Bool in
                        if let videoDirectUrl = trailer.videoDirectUrl, videoDirectUrl.isLink {
                            return true
                        }
                        return false
                    }
                    if skip == 0 {
                        self?.rawTrailers = trailers
                        self?.trailers = filteredTrailers }
                    else {
                        self?.rawTrailers += trailers
                        self?.trailers += filteredTrailers
                    }
                    
                case .error(let error):
                    weakSelf.presentErrorNotificationView(with: error.localizedDescription)
                    weakSelf.isLoading = false
                    weakSelf.refreshControl?.endRefreshing()
                    weakSelf.tableView.finishInfiniteScroll()
                    weakSelf.tableView.reloadData()
                    
                case .completed:
                    weakSelf.isLoading = false
                    weakSelf.refreshControl?.endRefreshing()
                    weakSelf.tableView.finishInfiniteScroll()
                    weakSelf.tableView.reloadData()
                }
            }
            .disposed(by: disposeBag)
    }
    
    func loadMore() {
        loadTrailers(skip: rawTrailers.count)
    }
    
    // MARK: - Actions
    
    override func refresh(sender: UIRefreshControl) {
        loadTrailers()
    }
}

// MARK: - UITableViewDataSource
extension TrailersViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trailers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrailerCellId", for: indexPath) as! TrailerViewCell
        
        let trailer = trailers[indexPath.row]
        var titleText = ""
        if let title = trailer.title {
            titleText = title
        }
        if let shortDesc = trailer.shortDescription {
            if titleText.characters.count > 0 {
                titleText = "\(titleText) - \(shortDesc)"
            }
            else {
                titleText = shortDesc
            }
        }
        cell.titleLabel.text = titleText
        cell.subtitleLabel.text = trailer.descripción
        
        cell.thumbImageView.image = nil
        if let urlString = trailer.thumbnailBigUrl {
            if let url = URL(string: urlString) {
                cell.thumbImageView.sd_setImage(with: url)
            }
        }
        
        cell.webView.isHidden = true
        cell.webView.stopLoading()
        
        cell.playerView.isHidden = true
        cell.playerView.stopVideo()
        
        cell.thumbImageView.isHidden = false
        cell.playButton.isHidden = false
        
        cell.delegate = self
        
        return cell
    }
}

// MARK: - UITableViewDataSource
extension TrailersViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let trailer = trailers[indexPath.row]
        showTrailerDetailViewController(with: trailer)
    }
}

// MARK: - TrailerViewCellDelegate
extension TrailersViewController: TrailerViewCellDelegate {
    
    func trailerViewCellPlayButtonTapped(cell: TrailerViewCell) {
        
        if let indexPath = tableView.indexPath(for: cell) {
            
            let trailer = trailers[indexPath.row]
            
            if let youtubeVideoID = trailer.youtubeVideoID {
                cell.playerView.isHidden = false
                cell.playerView.load(withVideoId: youtubeVideoID)
                
                cell.thumbImageView.isHidden = true
                cell.playButton.isHidden = true
            }
            else if let videoDirectUrl = trailer.videoDirectUrl, videoDirectUrl.isLink, let url = try? videoDirectUrl.asURL() {
                let request = URLRequest(url: url)
                
                cell.webView.isHidden = false
                cell.webView.loadRequest(request)
                
                cell.thumbImageView.isHidden = true
                cell.playButton.isHidden = true
            }
            
        }
    }
}

// MARK: - DZNEmptyDataSetDelegate
extension TrailersViewController {
    
    override func emptyDataSet(_ scrollView: UIScrollView!, didTap view: UIView!) {
        
        if !isLoading {
            loadTrailers()
            tableView.reloadEmptyDataSet()
        }
    }
}

// MARK: - UIViewController
extension UIViewController {
    
    func showTrailersViewController(in navigationController: UINavigationController? = nil, isFeatured: Bool) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "Trailers") as! TrailersViewController
        viewController.isFeatured = isFeatured
        
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

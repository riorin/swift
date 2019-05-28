//
//  NewsListViewController.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 9/15/16.
//  Copyright © 2016 DyCode. All rights reserved.
//

import UIKit
import SwiftyJSON

class NewsListViewController: MovreakViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var featuredNewsList: [MVNews] = []
    var newsList: [MVNews] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
        
        refreshControl?.beginRefreshing()
        loadFeaturedNews()
        loadNews()
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
        
        if navigationController?.viewControllers.first == self {
            navigationItem.leftBarButtonItem = nil
        }
        
        refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        collectionView.register(UINib(nibName: "NewsViewCell", bundle: nil), forCellWithReuseIdentifier: "NewsCellId")
        
        collectionView.emptyDataSetSource = self
        collectionView.emptyDataSetDelegate = self
    }
    
    func loadFeaturedNews(skip: Int = 0) {
        
        cmsProvider.request(.featuredNews(skip))
            .subscribe { [weak self] event in
                guard let weakSelf = self else { return }
                
                switch event {
                case .next(let response):
                    let json = JSON(data: response.data)
                    
                case .error(let error):
                    print(error.localizedDescription)
                    
                case .completed:
                    weakSelf.collectionView.reloadData()
                }
            }
            .disposed(by: disposeBag)
    }
    
    func loadNews(page: Int = 0) {
        
        isLoading = true
        provider.request(.news(page))
            .mapObject(MVNewsList.self)
            .subscribe { [weak self] event in
                guard let wealSelf = self else {
                    return
                }
                
                
                switch event {
                case .next(let newsList):
                    wealSelf.newsList = newsList.posts
                    wealSelf.loadNewsImages()
                    
                case .completed:
                    wealSelf.isLoading = false
                    wealSelf.collectionView.reloadData()
                    
                case .error(let error):
                    wealSelf.isLoading = false
                    wealSelf.collectionView.reloadData()
                    print(error.localizedDescription)
                }
            }
            .disposed(by: disposeBag)
    }
    
    func loadNewsImages() {
        
        for news in newsList {
            if news.images.count == 0 {
                if let newsUrl = news.url, let url = try? newsUrl.asURL() {
                    if newsUrl.contains("youtube.com") && url.path == "/watch" {
                        if let queryItems = url.queryItems {
                            if let v = queryItems["v"] {
                                _ = YouTube.shared.videoDetail(with: v, completion: { [weak self] (json, error) in
                                    guard let weakSelf = self else {
                                        return
                                    }
                                    
                                    if let json = json {
                                        news.updateImages(with: json)
                                        if let index = weakSelf.newsList.index(of: news) {
                                            let indexPath = IndexPath(row: index, section: 1)
                                            weakSelf.collectionView.reloadItems(at: [indexPath])
                                        }
                                    }
                                })
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Actions
    
    override func refresh(sender: UIRefreshControl) {
        loadNews()
    }
    
}

// MARK: - UICollectionViewDataSource

extension NewsListViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        var numberOfSections = 2
        if collectionView != self.collectionView {
            numberOfSections = 1
        }
        return numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        var numberOfItems = 0
        if collectionView == self.collectionView {
            if section == 0 {
                numberOfItems = min(1, featuredNewsList.count)
            }
            else {
                numberOfItems = newsList.count
            }
        }
        else {
            numberOfItems = featuredNewsList.count
        }
        return numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var _cell: UICollectionViewCell!
        if collectionView == self.collectionView {
            
            if indexPath.section == 0 {
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewsListCellId", for: indexPath) as! NewsListViewCell
                
                cell.titleLabel.text = "TOP STORIES"
                
                cell.collectionView.dataSource = self
                cell.collectionView.delegate = self
                
                cell.collectionView.reloadData()
                
                _cell = cell
            }
            else {
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewsCellId", for: indexPath) as! NewsViewCell
                
                let news = newsList[indexPath.item]
                cell.titleLabel.text = news.title?.stringByDecodingHTMLEntities
                cell.sourceLabel.text = news.date?.description
                
                cell.imageView.image = nil
                if let image = news.images.first {
                    if let imageUrl = image.url {
                        if let url = URL(string: imageUrl) {
                            cell.imageView.sd_setImage(with: url)
                        }
                    }
                }
                
                _cell = cell
            }
            
        }
        else {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewsCellId", for: indexPath) as! NewsViewCell
            
            let news = featuredNewsList[indexPath.item]
            cell.titleLabel.text = news.title?.stringByDecodingHTMLEntities
            cell.sourceLabel.text = news.date?.description
            
            cell.imageView.image = nil
            if let image = news.images.first {
                if let imageUrl = image.url {
                    if let url = URL(string: imageUrl) {
                        cell.imageView.sd_setImage(with: url)
                    }
                }
            }
            
            _cell = cell
        }
        
        return _cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "NewsListHeaderViewId", for: indexPath)
        if let label = view.viewWithTag(101) as? UILabel {
            
            if indexPath.section != 1 {
                label.text = nil
            }
            else {
                label.text = "RECENT STORIES"
            }
        }
        
        return view
    }
}

// MARK: - UICollectionViewDelegate

extension NewsListViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        var news: MVNews!
        if collectionView == self.collectionView { news = newsList[indexPath.item] }
        else { news = featuredNewsList[indexPath.item] }
        
        _ = news.images
        
        showNewsDetailViewController(withNews: news, in: navigationController)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension NewsListViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = UIScreen.main.bounds.width - 30
        let height = width * 9 / 21 + 72
        var size = CGSize(width: width, height: height)
        
        if collectionView == self.collectionView {
            if indexPath.section == 0 {
                size = CGSize(width: UIScreen.main.bounds.width, height: height + 70)
            }
        }
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        var size: CGSize = .zero
        if section == 1 && newsList.count > 0 {
            size = CGSize(width: 18, height: 18)
        }
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        var inset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        if collectionView == self.collectionView {
            if section == 0 {
                inset = UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 0)
            }
        }
        else {
            inset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        }
        return inset
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        var lineSpacing: CGFloat = 15
        if collectionView != self.collectionView {
            lineSpacing = 30
        }
        return lineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        var interSpacing: CGFloat = 15
        if collectionView != self.collectionView {
            interSpacing = 30
        }
        return interSpacing
    }
}

// MARK: - DZNEmptyDataSetDelegate
extension NewsListViewController {
    
    override func emptyDataSet(_ scrollView: UIScrollView!, didTap view: UIView!) {
        
        if !isLoading {
            loadFeaturedNews()
            loadNews()
            collectionView.reloadEmptyDataSet()
        }
    }
}

// MARK: - UIViewController

extension UIViewController {
    
    func showNewsListViewController(in navigationController: UINavigationController? = nil) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "NewsList") as! NewsListViewController
        
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


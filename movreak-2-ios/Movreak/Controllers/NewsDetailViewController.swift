//
//  NewsDetailViewController.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 10/17/16.
//  Copyright © 2016 DyCode. All rights reserved.
//

import UIKit
import DateToolsSwift

class NewsDetailViewController: MovreakViewController {

    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            let view = UIView(frame: imageView.bounds)
            view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.backgroundColor = UIColor(white: 0, alpha: 0.5)
            imageView.addSubview(view)
        }
    }
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var webViewHeightConstraint: NSLayoutConstraint!
    
    var news: MVNews?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
        setupContent()
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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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
        
    }
    
    func setupContent() {
        
        if let news = news {
            if let image = news.images.first, let imageUrl = image.url, let url = URL(string: imageUrl) {
                imageView.sd_setImage(with: url)
            }
            
            titleLabel.text = news.title?.stringByDecodingHTMLEntities
            
            var subtitle = ""
            if let source = news.syndicationSource {
                subtitle = source
            }
            if let dateString = news.date?.format(with: "MMMM dd, yyyy") {
                if subtitle.characters.count > 0 {
                    subtitle += " | \(dateString)"
                }
                else {
                    subtitle = dateString
                }
            }
            subtitleLabel.text = subtitle
            
            if let resourcePath = Bundle.main.resourcePath, let resourceUrl = URL(string: resourcePath) {
                let templateUrl = resourceUrl.appendingPathComponent("NewsTemplate.min.html")
                
                do {
                    var templateString = try String(contentsOfFile: templateUrl.absoluteString)
                    
                    let title = news.title ?? ""
                    let fontSize = "size-medium"
                    let originalUrl = news.url ?? ""
                    var domain = ""
                    if let source = news.syndicationSource, let sourceUrl = URL(string: source), let host = sourceUrl.host {
                        domain = host
                    }
                    let author = news.author?.name ?? ""
                    let content = news.content ?? ""
                    
                    templateString = templateString.replacingOccurrences(of: "{{{TITLE}}}", with: title)
                    templateString = templateString.replacingOccurrences(of: "{{{FONT_SIZE}}}", with: fontSize)
                    templateString = templateString.replacingOccurrences(of: "{{{ORIGINAL_URL}}}", with: originalUrl)
                    templateString = templateString.replacingOccurrences(of: "{{{DOMAIN}}}", with: domain)
                    templateString = templateString.replacingOccurrences(of: "{{{AUTHOR}}}", with: author)
                    templateString = templateString.replacingOccurrences(of: "{{{CONTENT}}}", with: content)
                    
                    webView.loadHTMLString(templateString, baseURL: nil)
                }
                catch let error {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func webButtonTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func shareButtonTapped(_ sender: UIButton) {
        
    }
}

// MARK: - 

extension NewsDetailViewController: UIWebViewDelegate {
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        
        let size = webView.scrollView.contentSize
        webViewHeightConstraint.constant = size.height
        webView.scrollView.isScrollEnabled = false
        
        UIView.animate(withDuration: 0.25) { 
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - UIViewController

extension UIViewController {
    
    func showNewsDetailViewController(withNews news: MVNews, in navigationController: UINavigationController? = nil) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "NewsDetail") as! NewsDetailViewController
        viewController.news = news
        
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

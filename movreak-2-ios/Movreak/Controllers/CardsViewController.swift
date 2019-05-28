//
//  CardsViewController.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 10/26/16.
//  Copyright © 2016 DyCode. All rights reserved.
//

import UIKit

protocol CardsViewControllerDelegate {
    func cardsViewController(viewController: CardsViewController, didSelectCardType cardType: CardType)
}

class CardsViewController: MovreakViewController {
    var delegate: CardsViewControllerDelegate?
    
    @IBOutlet weak var tableView: UITableView!
    var cardTypes: [CardType] = [
        .inCinema,
//        .featuredNews,
        .latestReviews,
        .popularMovies,
        .latestTrailers,
        .featuredTrailers,
        .comingSoon,
        .popularMovieList,
        .cinemas
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
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
        
        tableView.tableFooterView = UIView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(CardsViewController.cardDidRemove(sender:)), name: kCardDidRemoveNotification, object: nil)
    }
    
    func cardDidRemove(sender: Notification) {
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension CardsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cardTypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CardCellId", for: indexPath) as! CardViewCell
        
        let cardType = cardTypes[indexPath.row]
        cell.iconImageView.image = cardType.icon
        cell.titleLabel.text = cardType.description
        
        cell.addButton.isHidden = false
        if let card = realm.objects(MVCard.self).filter("sectionID = %@", cardType.rawValue).first {
            if card.isHidden.value == false {
                cell.addButton.isHidden = true
            }
        }
        
        cell.separatorView.isHidden = false
        if indexPath.row == cardTypes.count - 1 {
            cell.separatorView.isHidden = true
        }
        
        cell.delegate = self
        
        return cell
    }
}


// MARK: - UITableViewDelegate
extension CardsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
}

// MARK: - CardViewCellDelegate
extension CardsViewController: CardViewCellDelegate {
    
    func cardViewCellAddButtonTapped(cell: CardViewCell) {
        
        if let indexPath = tableView.indexPath(for: cell) {
            let cardType = cardTypes[indexPath.row]
            
            if let card = realm.objects(MVCard.self).filter("sectionID = %@", cardType.rawValue).first {
                try! realm.write {
                    card.isHidden.value = false
                }
            }
            
            tableView.reloadRows(at: [indexPath], with: .automatic)
            
            if let delegate = delegate {
                delegate.cardsViewController(viewController: self, didSelectCardType: cardType)
            }
            
            NotificationCenter.default.post(name: kCardDidAddNotification, object: nil)
        }
    }
}

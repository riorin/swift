//
//  SearchView.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 7/4/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import UIKit

protocol SearchViewDelegate {
    func searchView(_ searchView: SearchView, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    func searchViewShouldReturn(_ searchView: SearchView) -> Bool
}

class SearchView: UIView {
    var delegate: SearchViewDelegate?
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var textField: UITextField! {
        didSet {
            textField.attributedPlaceholder = NSAttributedString(string: "Seach movie", attributes: [NSFontAttributeName: kCoreSans15Font, NSForegroundColorAttributeName: UIColor.lightGray])
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupViews()
    }
    
    func setupViews() {
        
        containerView.layer.cornerRadius = 4.0
        containerView.layer.masksToBounds = true
        
        textField.delegate = self
    }
    
    static func searchView(with delegate: SearchViewDelegate) -> SearchView {
        
        let searchView = Bundle.main.loadNibNamed("SearchView", owner: nil, options: nil)?.first as! SearchView
        searchView.delegate = delegate
        return searchView
    }
}

extension SearchView: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let delegate = delegate {
            return delegate.searchView(self, shouldChangeCharactersIn: range, replacementString: string)
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if let delegate = delegate {
            return delegate.searchViewShouldReturn(self)
        }
        return true
    }
}

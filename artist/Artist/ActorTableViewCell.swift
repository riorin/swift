//
//  ActorTableViewCell.swift
//  Artist
//
//  Created by Rio Rinaldi on 17/07/18.
//  Copyright © 2018 Rio Rinaldi. All rights reserved.
//

import UIKit

class ActorTableViewCell: UITableViewCell {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var dobLabel: UILabel!
    @IBOutlet weak var namaLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

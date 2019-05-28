//
//  HaberTableViewCell.swift
//  AlamofireAndSwiftyJson
//
//  Created by tolga iskender on 11.08.2018.
//  Copyright © 2018 tolga iskender. All rights reserved.
//

import UIKit
import SDWebImage


class HaberTableViewCell: UITableViewCell {
    @IBOutlet weak var penerbitBerita: UILabel!
    @IBOutlet weak var tanggalBerita: UILabel!
    @IBOutlet weak var gambarBerita: UIImageView!
    @IBOutlet weak var judulBerita: UILabel!
    @IBOutlet weak var isiBerita: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
   
    func setDatatoTableview(penerbitBerita: String, tanggalBerita: String, gambarBerita: String, judulBerita: String, isiBerita: String)
    {
        self.penerbitBerita.text = penerbitBerita
        self.tanggalBerita.text = tanggalBerita
        self.gambarBerita.sd_setImage(with: URL(string: gambarBerita), placeholderImage: nil)
        self.judulBerita.text = judulBerita
        self.isiBerita.text = isiBerita
        self.isiBerita.sizeToFit()
    }

}

//
//  haberModel.swift
//  AlamofireAndSwiftyJson
//
//  Created by tolga iskender on 11.08.2018.
//  Copyright © 2018 tolga iskender. All rights reserved.
//

import Foundation

class BeritaModel {
    var penerbitBerita: String
    var tanggalBerita: String
    var gambarBerita: String
    var judulBerita: String
    var isiBerita: String
    var totalResult : String
    
    init(penerbitBerita: String, tanggalBerita: String, gambarBerita: String, judulBerita: String, isiBerita: String, totalResult: String) {
        self.penerbitBerita = penerbitBerita
        self.tanggalBerita = tanggalBerita
        self.gambarBerita = gambarBerita
        self.judulBerita = judulBerita
        self.isiBerita = isiBerita
        self.totalResult = totalResult
    }
}

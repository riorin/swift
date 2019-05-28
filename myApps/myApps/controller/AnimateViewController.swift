//
//  AnimateViewController.swift
//  myApps
//
//  Created by Rio Rinaldi on 16/04/18.
//  Copyright © 2018 Rio Rinaldi. All rights reserved.
//

import UIKit
import Lottie

class AnimateViewController: UIViewController {
    
    
    @IBOutlet weak var playButtonTapped: UIButton!
    
    private var animation: LOTAnimationView?
    private var muter: LOTAnimationView?
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func anima() {
        muter = LOTAnimationView(name: "SPIN WHEEL_FIN")
        muter?.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        muter?.contentMode = .scaleAspectFit
        muter?.frame = view.bounds
        view.addSubview(muter!)
        muter?.play()
    }
    
    
    @IBAction func playButtonTapped(_ sender: UIButton) {
        anima()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

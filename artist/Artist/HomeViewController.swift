//
//  HomeViewController.swift
//  Artist
//
//  Created by Rio Rinaldi on 17/07/18.
//  Copyright © 2018 Rio Rinaldi. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDataSource {
    
    let url = URL(string: "http://microblogging.wingnity.com/JSONParsingTutorial/jsonActors")
    
    var actors = [Actor]()

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        downloadJSON()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func downloadJSON() {
        guard let downloadURL = url else {return}
        URLSession.shared.dataTask(with: downloadURL) {
            data, URLResponse, error in
            guard let data = data, error == nil, URLResponse != nil else {
                print("somthing Wrong")
                return
            }
            print("downloaded")
            do {
                let decoder = JSONDecoder()
                let downloadActors = try decoder.decode(Actors.self, from: data)
                self.actors = downloadActors.actors
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch {
                print("something wrong ")
            }
        }.resume()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actors.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ActorCell") as? ActorTableViewCell else {
            return UITableViewCell() }
        cell.namaLabel.text = "Nama: " + actors[indexPath.row].name
        cell.dobLabel.text = "DOB: " + actors[indexPath.row].dob
        
        if let imageURL = URL(string: actors[indexPath.row].image){
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: imageURL)
                if let data = data {
                    let image = UIImage(data: data)
                    DispatchQueue.main.async {
                        cell.imgView.image = image
                    }
                }
            }
        }
    return cell
}
}

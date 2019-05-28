//
//  ViewController.swift
//  json4.1
//
//  Created by Rio Rinaldi on 18/07/18.
//  Copyright © 2018 Rio Rinaldi. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    var courses = [Course]()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Course List"
        fetchJSON()
    }
    
    struct Course: Decodable {
        let id: Int
        let name: String
        let link: String
        let numberOfLessons: Int
        let imageUrl: String
    }
    
    fileprivate func fetchJSON() {
        let urlString = "http://api.letsbuildthatapp.com/jsondecodable/courses_snake_case"
        guard let url = URL(string: urlString) else {return}
        URLSession.shared.dataTask(with: url) { (data, _, err) in
            DispatchQueue.main.async {
                if let err = err {
                    print("Failed", err)
                    return
                }
                
                guard let data = data else {return}
                
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    self.courses = try decoder.decode([Course].self, from: data)
                    self.tableView.reloadData()
                } catch let jsonErr {
                    print("Failed", jsonErr)
                }
            }
        } .resume()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courses.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellId")
        let course = courses[indexPath.row]
        cell.textLabel?.text = course.name
        cell.detailTextLabel?.text = String(course.numberOfLessons)
        return cell
    }
}


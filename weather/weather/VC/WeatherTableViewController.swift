//
//  WeatherTableViewController.swift
//  weather
//
//  Created by Rio Rinaldi on 01/05/18.
//  Copyright © 2018 Rio Rinaldi. All rights reserved.
//

import UIKit

class WeatherTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let weatherAPI = WeatherAPIClient()
        let weatherEndpoint = WeatherEndpoint.tenDayForecast(city: "Boston", state: "MA" )
        weatherAPI.weather(with: weatherEndpoint) { (either) in
            switch either {
            case .value(let forecastText):
                print(forecastText)
            case .error(let error):
                print(error)
            }
        }
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "weatherCell", for: indexPath)

         //Configure the cell...

        return cell
    }
    
    
    
}

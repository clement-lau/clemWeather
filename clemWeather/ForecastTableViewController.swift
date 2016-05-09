//
//  ForecastTableViewController.swift
//  clemWeather
//
//  Created by Clement Lau on 5/8/16.
//  Copyright © 2016 clem co. All rights reserved.
//

import Foundation
import UIKit

class ForecastTableViewController: UITableViewController {
    
    var data = [Dictionary<String, AnyObject>]()
    
    enum Unit: Character {
        case F = "F"
        case C = "C"
    }
    var unit = Unit.F
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "ForecastTableCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! DayOverviewTableCell
        let row = indexPath.row
        
        cell.setCellsWithData(data[row], unit: unit.rawValue)
        return cell
    }
    
    func setForecastData(data: Array<Dictionary<String, AnyObject>>) {
        self.data = data
    }
    
    func setUnit(unit: Unit) {
        self.unit = unit
    }
    
}
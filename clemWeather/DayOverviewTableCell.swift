//
//  DayOverviewTableCell.swift
//  clemWeather
//
//  Created by Clement Lau on 5/8/16.
//  Copyright © 2016 clem co. All rights reserved.
//

import Foundation
import UIKit

class DayOverviewTableCell: UITableViewCell {
    
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    
    var data = Dictionary<String, String>()
    
    func setCellsWithData (var d: Dictionary<String, AnyObject>, unit: Character) {
        let date = d["date"] as! String
        d = (d["hourly"]! as! Array)[0]
        let weather: String!
        let weatherDesc = d["weatherDesc"]![0]["value"] as! String
        let iconUrl = d["weatherIconUrl"]![0]["value"] as! String
        let precip = (d["precipMM"] as! String) + " mm"
        
        data["F"] = (d["tempF"] as! String) + "°F" + "  P: " + precip
        data["C"] = (d["tempC"] as! String) + "°C" + "  P: " + precip
        if unit == "F" {
            weather = data["F"]
        } else {
            weather = data["C"]
        }
        let day = getDayOfWeek(date)
        
        let url = NSURL(string: iconUrl)
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {
            data, response, error in
            dispatch_async(dispatch_get_main_queue(), {
                self.weatherIcon.image = UIImage(data: data!)
            })
        }
        task.resume()
        
        dispatch_async(dispatch_get_main_queue(), {
            self.weatherLabel.text = weather
            self.descriptionLabel.text = weatherDesc
            self.dayLabel.text = day
        })
    }
    
    func getDayOfWeek (day: String) -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let date = formatter.dateFromString(day)
        let myCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        if myCalendar!.isDateInToday(date!) {
            return "Today"
        } else if myCalendar!.isDateInTomorrow(date!) {
            return "Tomorrow"
        } else {
            let myComponents = myCalendar?.component(.Weekday, fromDate: date!)
            switch myComponents! {
            case 1:
                return "Sunday"
            case 2:
                return "Monday"
            case 3:
                return "Tuesday"
            case 4:
                return "Wednesday"
            case 5:
                return "Thursday"
            case 6:
                return "Friday"
            case 7:
                return "Saturday"
            default:
                return "some day"
            }
        }
        
    }
}

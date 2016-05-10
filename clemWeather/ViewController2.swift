//
//  ViewController2.swift
//  clemWeather
//
//  Created by Clement Lau on 5/8/16.
//  Copyright © 2016 clem co. All rights reserved.
//

import Foundation
import UIKit

class ViewController2: UIViewController, WeatherRequestDelegate, UINavigationBarDelegate {
    
    //MARK: Properties
    
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var precipLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var unitButton: UIButton!
    @IBOutlet weak var currentWeatherStack: UIStackView!
    @IBOutlet weak var forecastTableView: UITableView!
    
    var searchText: String!
    var forecast = false
    let plist = Plist(name: "data")
    var data = Dictionary<String, String>()
    
    let forecastTableViewController = ForecastTableViewController()
    
    enum Unit {
        case F
        case C
    }
    
    var unit = Unit.F
    
    
    // MARK: Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        WeatherRequest.requestWithSource(self, location: searchText)
        
        activityIndicator.startAnimating()
        
        self.weatherIcon.layer.borderColor = UIColor.blackColor().CGColor
        self.weatherIcon.layer.borderWidth = 2
        self.weatherIcon.layer.cornerRadius = 5.0
        
        let dict = plist.getMutablePlistFile()!
        
        if dict["unit"] as! String == "F" {
            unit = .F
            self.unitButton.setTitle("C", forState: .Normal)
            forecastTableViewController.setUnit(.F)
        } else if dict["unit"] as! String == "C" {
            unit = .C
            self.unitButton.setTitle("F", forState: .Normal)
            forecastTableViewController.setUnit(.F)
        } else {
            dict["unit"] = "F"
            self.unitButton.setTitle("C", forState: .Normal)
            forecastTableViewController.setUnit(.F)
            plist.addValuesToPlistFile(dict)
            unit = .F
        }
        
        forecastTableView.delegate = forecastTableViewController
        forecastTableView.dataSource = forecastTableViewController
        
        forecast = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Class Methods
    
    func requestDidReturn(var d: Dictionary<String, AnyObject>) {
        d = d["data"]! as! Dictionary<String, AnyObject>
        if d["error"] != nil {
            dispatch_async(dispatch_get_main_queue(), {
                self.locationButton.setTitle("location not found", forState: .Normal)
                self.locationButton.enabled = false
                self.locationButton.hidden = false
                self.activityIndicator.stopAnimating()
            })
            return
        }
        forecastTableViewController.setForecastData(d["weather"] as! Array<Dictionary<String, AnyObject>>)
        let loc = d["nearest_area"]![0]["areaName"]!![0]!["value"]!! as! String
        d = d["current_condition"]![0]! as! Dictionary<String, AnyObject>
        let temp: String!
        data["F"] = (d["temp_F"] as! String) + "°F"
        data["C"] = (d["temp_C"] as! String) + "°C"
        if unit == .F {
            temp = data["F"]
        } else {
            temp = data["C"]
        }
        let weatherDesc = d["weatherDesc"]![0]["value"] as! String
        let iconUrl = d["weatherIconUrl"]![0]["value"] as! String
        let precip = "Precip: " + (d["precipMM"] as! String) + " mm"
        
        let url = NSURL(string: iconUrl)
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {
            data, response, error in
            dispatch_async(dispatch_get_main_queue(), {
                self.weatherIcon.image = UIImage(data: data!)
                self.view.backgroundColor = UIColor(patternImage: UIImage(data: data!)!)
            })
        }
        task.resume()
        
        dispatch_async(dispatch_get_main_queue(), {
            self.activityIndicator.stopAnimating()
            
            self.locationButton.setTitle(loc, forState: .Normal)
            self.temperatureLabel.text = temp
            self.descriptionLabel.text = weatherDesc
            self.precipLabel.text = precip
            
            self.currentWeatherStack.hidden = false
            self.locationButton.hidden = false
//            self.temperatureLabel.hidden = false
//            self.descriptionLabel.hidden = false
//            self.precipLabel.hidden = false
            self.unitButton.hidden = false
        })
    }
    
    internal func setText(text: String) {
        searchText = text
    }
    
    func updateTemp() {
        let temp: String!
        if unit == .F {
            temp = data["F"]
        } else {
            temp = data["C"]
        }
        dispatch_async(dispatch_get_main_queue(), {
            self.temperatureLabel.text = temp
        })
    }
    
    @IBAction func switchUnit(sender: UIButton) {
        let dict = plist.getMutablePlistFile()!
        if unit == .F {
            unit = .C
            dict["unit"] = "C"
            dispatch_async(dispatch_get_main_queue(), {
                self.unitButton.setTitle("F", forState: .Normal)
            })
            forecastTableViewController.setUnit(.C)
            if forecast {
                forecastTableView.reloadData()
            }
        } else {
            unit = .F
            dict["unit"] = "F"
            dispatch_async(dispatch_get_main_queue(), {
                self.unitButton.setTitle("C", forState: .Normal)
            })
            forecastTableViewController.setUnit(.F)
            if forecast {
                forecastTableView.reloadData()
            }
        }
        plist.addValuesToPlistFile(dict)
        updateTemp()
    }
    
    @IBAction func switchForecast(sender: UIButton) {
        forecast = !forecast
        if forecast {
            forecastTableView.hidden = false
            currentWeatherStack.hidden = true
            forecastTableView.reloadData()
        } else {
            currentWeatherStack.hidden = false
            forecastTableView.hidden = true
        }
    }
    
    // MARK: Navigational methods
    
    @IBAction func unwindToViewController() {
        self.performSegueWithIdentifier("unwindToViewController", sender: self)
    }
    
    
}
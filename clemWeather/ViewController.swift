//
//  ViewController.swift
//  clemWeather
//
//  Created by Clement Lau on 5/5/16.
//  Copyright © 2016 clem co. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, UISearchBarDelegate, WeatherRequestDelegate {
    
    // MARK: Properties

    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var precipLabel: UILabel!
    @IBOutlet weak var unitButton: UIButton!
    @IBOutlet weak var currentWeatherStack: UIStackView!
    @IBOutlet weak var forecastTableView: UITableView!
    
    let locationManager = CLLocationManager()
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
        
        activityIndicator.startAnimating()
        
        self.weatherIcon.layer.borderColor = UIColor.blackColor().CGColor
        self.weatherIcon.layer.borderWidth = 2
        self.weatherIcon.layer.cornerRadius = 5.0
        
        locationManager.delegate = self
        if CLLocationManager.authorizationStatus() == .NotDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if CLLocationManager.authorizationStatus() == .Denied {
            dispatch_async(dispatch_get_main_queue(), {
                self.locationButton.setTitle("GPS unavailable", forState: .Normal)
                self.activityIndicator.stopAnimating()
            })
        }
        
        let dict = plist.getMutablePlistFile()!
        
        if dict["unit"] as! String == "F" {
            unit = .F
            self.unitButton.setTitle("C", forState: .Normal)
        } else if dict["unit"] as! String == "C" {
            self.unitButton.setTitle("F", forState: .Normal)
            unit = .C
        } else {
            dict["unit"] = "F"
            self.unitButton.setTitle("C", forState: .Normal)
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
    
    //MARK: Location Manager methods
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currLoc = locations.last
        let coord = currLoc?.coordinate
        WeatherRequest.requestWithSource(self, coordinates:coord!)
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        dispatch_async(dispatch_get_main_queue(), {
            self.locationButton.setTitle("GPS unavailable", forState: .Normal)
            self.currentWeatherStack.hidden = false
            self.activityIndicator.stopAnimating()
        })
    }
    
    //MARK: Search Controller methods
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.performSegueWithIdentifier("searchSegue", sender: searchBar)
    }
    
    //MARK: Class methods
    
    func requestDidReturn(var d: Dictionary<String, AnyObject>) {
        d = d["data"]! as! Dictionary<String, AnyObject>
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
    
    //MARK: Navigational methods
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let dest = segue.destinationViewController as! ViewController2
        let text = (sender as! UISearchBar).text!
        dest.setText(text)
    }
    
    @IBAction func unwindToViewController(segue: UIStoryboardSegue) {
        
    }


}


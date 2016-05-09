//
//  WeatherRequest.swift
//  clemWeather
//
//  Created by Clement Lau on 5/6/16.
//  Copyright © 2016 clem co. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation


public class WeatherRequest {
    
    private static var key = "a19475d6095340d7bbe194711160605";
    
    public class func requestWithSource(source:WeatherRequestDelegate, coordinates coord:CLLocationCoordinate2D) {
        var urlString = "https://api.worldweatheronline.com/premium/v1/weather.ashx?"
        urlString += "key=\(key)" // key
        urlString += "&"
        let lat = coord.latitude
        let long = coord.longitude
        urlString += "q=\(lat),\(long)"
        urlString += "&"
        urlString += "num_of_days=5"
        urlString += "&"
        urlString += "includelocation=yes"
        urlString += "&"
        urlString += "tp=24"
        urlString += "&"
        urlString += "mca=no"
        urlString += "&"
        urlString += "format=json"
        
        let url = NSURL(string: urlString)
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {
            data, response, error in
            do {
                let obj = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? [String:AnyObject]
                source.requestDidReturn(obj!)
            } catch _ as NSError {
                print ("trying again")
                requestWithSource(source, coordinates: coord)
            }
        }
        task.resume()
    }
    
    public class func requestWithSource(source:WeatherRequestDelegate, location loc:String) {
        var regex: NSRegularExpression? = nil
        do {
            regex = try NSRegularExpression(pattern: " ", options: [])
        } catch _ as NSError {
            
        }
        let modLoc = regex!.stringByReplacingMatchesInString(loc, options: [], range: NSMakeRange(0, loc.characters.count
            ), withTemplate: "+")
        var urlString = "https://api.worldweatheronline.com/premium/v1/weather.ashx?"
        urlString += "key=\(key)" // key
        urlString += "&"
        urlString += "q=\(modLoc)"
        urlString += "&"
        urlString += "num_of_days=5"
        urlString += "&"
        urlString += "includelocation=yes"
        urlString += "&"
        urlString += "tp=24"
        urlString += "&"
        urlString += "mca=no"
        urlString += "&"
        urlString += "format=json"
        
        let url = NSURL(string: urlString)
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {
            data, response, error in
            do {
                let obj = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? [String:AnyObject]
                source.requestDidReturn(obj!)
            } catch _ as NSError {
                print ("trying again")
                requestWithSource(source, location: loc)
            }
        }
        task.resume()
    }
}
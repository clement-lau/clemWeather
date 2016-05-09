//
//  WeatherRequestDelegate.swift
//  clemWeather
//
//  Created by Clement Lau on 5/6/16.
//  Copyright © 2016 clem co. All rights reserved.
//

import Foundation

public protocol WeatherRequestDelegate {
    func requestDidReturn (data: Dictionary<String, AnyObject>)
}
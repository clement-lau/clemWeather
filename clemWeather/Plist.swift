//
//  Plist.swift
//  clemWeather
//
//  Created by Clement Lau on 5/8/16.
//  Copyright © 2016 clem co. All rights reserved.
//

import Foundation

struct Plist {
    let name:String
    var sourcePath: String? {
        guard let path = NSBundle.mainBundle().pathForResource(name, ofType: "plist") else { return .None }
        return path
    }
    var destPath:String? {
        guard sourcePath != .None else { return .None }
        let dir = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        return (dir as NSString).stringByAppendingPathComponent("\(name).plist")
    }
    init(name:String) {
        self.name = name
        let fileManager = NSFileManager.defaultManager()
        if !fileManager.fileExistsAtPath(destPath!) {
            do {
                try fileManager.copyItemAtPath(sourcePath!, toPath: destPath!)
            } catch let error as NSError { print ("\(error.localizedDescription)"); }
        }
    }
    func getMutablePlistFile() -> NSMutableDictionary?{
        let fileManager = NSFileManager.defaultManager()
        if fileManager.fileExistsAtPath(destPath!) {
            guard let dict = NSMutableDictionary(contentsOfFile: destPath!) else { return .None}
            return dict
        } else {
            return .None
        }
    }
    func addValuesToPlistFile(dictionary:NSDictionary) {
        dictionary.writeToFile(destPath!, atomically: false)
    }
}


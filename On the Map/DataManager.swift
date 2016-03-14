//
//  DataManager.swift
//  On the Map
//
//  Created by Jovit Royeca on 3/12/16.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import Foundation

final class DataManager: NSObject {
    var students = [StudentInformation]()
    var currentStudent:StudentInformation?
    var userData:UserData?
    
    func resetData() {
        students = [StudentInformation]()
        userData = nil
        currentStudent = nil
    }
    
    func updateCurrentStudent(latitude: Double, longitude: Double, mapString: String, mediaURL: NSURL) {
        currentStudent?.latitude = latitude
        currentStudent?.longitude = longitude
        currentStudent?.mapString = mapString
        currentStudent?.mediaURL = mediaURL
    }
    
    // MARK: Custom methods
    class func sharedInstance() -> DataManager {
        struct Singleton {
            static var sharedInstance = DataManager()
        }
        return Singleton.sharedInstance
    }
}

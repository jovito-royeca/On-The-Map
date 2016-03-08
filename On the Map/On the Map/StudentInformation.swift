//
//  StudentInformation.swift
//  On the Map
//
//  Created by Jovit Royeca on 3/8/16.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import Foundation

struct StudentInformation {
    var createdAt:NSDate?
    var firstName:String?
    var lastName:String?
    var latitude:Double?
    var longitude:Double?
    var mapString:String?
    var mediaURL:NSURL?
    var objectId:String?
    var uniqueKey:String?
    var updatedAt:NSDate?
    
    init(dictionary: [String:AnyObject]) {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSZZZZZ"
        
        if let createdAt = dictionary["createdAt"] as? String {
            self.createdAt = formatter.dateFromString(createdAt)
        }
        if let firstName = dictionary["firstName"] as? String {
            self.firstName = firstName
        }
        if let lastName = dictionary["lastName"] as? String {
            self.lastName = lastName
        }
        if let latitude = dictionary["latitude"] as? Double {
            self.latitude = latitude
        }
        if let longitude = dictionary["longitude"] as? Double {
            self.longitude = longitude
        }
        if let mapString = dictionary["mapString"] as? String {
            self.mapString = mapString
        }
        if let mediaURL = dictionary["mediaURL"] as? String {
            self.mediaURL = NSURL(string: mediaURL)
        }
        if let objectId = dictionary["objectId"] as? String {
            self.objectId = objectId
        }
        if let uniqueKey = dictionary["uniqueKey"] as? String {
            self.uniqueKey = uniqueKey
        }
        if let updatedAt = dictionary["updatedAt"] as? String {
            self.updatedAt = formatter.dateFromString(updatedAt)
        }
    }
}
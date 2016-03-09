//
//  StudentInformation.swift
//  On the Map
//
//  Created by Jovit Royeca on 3/8/16.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import Foundation

struct StudentInformation {
    let createdAt:NSDate?
    let firstName:String?
    let lastName:String?
    let latitude:Double?
    let longitude:Double?
    let mapString:String?
    let mediaURL:NSURL?
    let objectId:String?
    let uniqueKey:String?
    let updatedAt:NSDate?
    
    init(dictionary: [String:AnyObject]) {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSZZZZZ"

        if let createdAt = dictionary[Constants.ParseJSONKeys.CreatedAt] as? String {
            self.createdAt = formatter.dateFromString(createdAt)
        } else {
            self.createdAt = nil
        }
        firstName = dictionary[Constants.ParseJSONKeys.FirstName] as? String
        lastName = dictionary[Constants.ParseJSONKeys.LastName] as? String
        latitude = dictionary[Constants.ParseJSONKeys.Latitude] as? Double
        longitude = dictionary[Constants.ParseJSONKeys.Longitude] as? Double
        mapString = dictionary[Constants.ParseJSONKeys.MapString] as? String
        if let mediaURL = dictionary[Constants.ParseJSONKeys.MediaURL] as? String {
            self.mediaURL = NSURL(string: mediaURL)
        } else {
            self.mediaURL = nil
        }
        objectId = dictionary[Constants.ParseJSONKeys.ObjectId] as? String
        uniqueKey = dictionary[Constants.ParseJSONKeys.UniqueKey] as? String
        if let updatedAt = dictionary[Constants.ParseJSONKeys.UpdatedAt] as? String {
            self.updatedAt = formatter.dateFromString(updatedAt)
        } else {
            self.updatedAt = nil
        }
        
        
//        if let createdAt = dictionary["createdAt"] as? String {
//            self.createdAt = formatter.dateFromString(createdAt)
//        }
//        if let firstName = dictionary["firstName"] as? String {
//            self.firstName = firstName
//        }
//        if let lastName = dictionary["lastName"] as? String {
//            self.lastName = lastName
//        }
//        if let latitude = dictionary["latitude"] as? Double {
//            self.latitude = latitude
//        }
//        if let longitude = dictionary["longitude"] as? Double {
//            self.longitude = longitude
//        }
//        if let mapString = dictionary["mapString"] as? String {
//            self.mapString = mapString
//        }
//        if let mediaURL = dictionary["mediaURL"] as? String {
//            self.mediaURL = NSURL(string: mediaURL)
//        }
//        if let objectId = dictionary["objectId"] as? String {
//            self.objectId = objectId
//        }
//        if let uniqueKey = dictionary["uniqueKey"] as? String {
//            self.uniqueKey = uniqueKey
//        }
//        if let updatedAt = dictionary["updatedAt"] as? String {
//            self.updatedAt = formatter.dateFromString(updatedAt)
//        }
    }
}
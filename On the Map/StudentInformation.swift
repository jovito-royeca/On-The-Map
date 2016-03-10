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
    }
}
//
//  StudentInformation.swift
//  On the Map
//
//  Created by Jovit Royeca on 3/8/16.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import Foundation

struct StudentInformation {
    var name:String?
    var latitude:Double?
    var longitude:Double?
    var link:String?
    
    init(dictionary: [String:AnyObject]) {
        name = dictionary["name"] as! String
        latitude = dictionary["latitude"] as! Double
        longitude = dictionary["longitude"] as! Double
        link = dictionary["link"] as! String
        
//        if let releaseDateString = dictionary[TMDBClient.JSONResponseKeys.MovieReleaseDate] as? String where releaseDateString.isEmpty == false {
//            releaseYear = releaseDateString.substringToIndex(releaseDateString.startIndex.advancedBy(4))
//        } else {
//            releaseYear = ""
//        }
    }
}
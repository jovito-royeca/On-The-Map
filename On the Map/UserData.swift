//
//  UserData.swift
//  On the Map
//
//  Created by Jovit Royeca on 3/11/16.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import Foundation

struct UserData {
    var firstName:String?
    var lastName:String?
    var key:String?
    
    init(dictionary: [String:AnyObject]) {
        firstName = dictionary[Constants.UdacityJSONKeys.FirstName] as? String
        lastName = dictionary[Constants.UdacityJSONKeys.LastName] as? String
        key = dictionary[Constants.UdacityJSONKeys.Key] as? String
    }
}
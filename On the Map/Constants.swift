//
//  Constants.swift
//  On the Map
//
//  Created by Jovit Royeca on 3/8/16.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import Foundation

// MARK: - Constants

struct Constants {
    struct Http {
        static let ActionGet               = "GET"
        static let ActionPost              = "POST"
        static let ActionDelete            = "DELETE"
        static let ActionPut               = "PUT"
        static let FieldAccept             = "Accept"
        static let FieldAcceptValue        = "application/json"
        static let FieldContentType        = "Content-Type"
        static let FieldContentTypeValue  = "application/json"
    }
    
    
    // MARK: Udacity
    struct Udacity {
        static let ApiScheme  = "https"
        static let ApiHost    = "www.udacity.com"
        static let ApiPath    = "api"
        static let DataOffset = 5
        static let SignupPage = "https://www.udacity.com/account/auth#!/signup"
    }
    
    // MARK: Udacity Methods
    struct UdacityMethods {
        static let Session  = "session"
        static let UserData = "users/{userId}"
    }
    
    // MARK: Udacity JSON Keys
    struct UdacityJSONKeys {
        static let Username  = "username"
        static let Password  = "password"
        static let Session   = "session"
        static let Account   = "account"
        static let Key       = "key"
        static let ID        = "id"
        static let FirstName = "first_name"
        static let LastName  = "last_name"
        
    }
    
    // MARK: Facebook
    struct Facebook {
        static let DataOffset   = 0
    }
    
    // MARK: Facebook JSON Keys
    struct FacebookJSONKeys {
        static let FacebookMobile = "facebook_mobile"
        static let AccessToken    = "access_token"
    }
    
    // MARK: Parse
    struct Parse {
        static let ApiScheme         = "https"
        static let ApiHost           = "api.parse.com"
        static let ApiPath           = "1/classes"
        static let FieldAppID        = "X-Parse-Application-Id"
        static let FieldAppIDValue   = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let FieldAppKey       = "X-Parse-REST-API-Key"
        static let FieldAppKeyValue  = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let InitialLimit      = 100
        static let SortKey           = "order"
        static let SortValue         = "-updatedAt"
        static let DataOffset        = 0
    }
    
    // MARK: Parse Methods
    struct ParseMethods {
        static let StudentLocation  = "StudentLocation"
    }
    
    // MARK: Parse JSON Keys
    struct ParseJSONKeys {
        static let CreatedAt = "createdAt"
        static let FirstName = "firstName"
        static let LastName  = "lastName"
        static let Latitude  = "latitude"
        static let Longitude = "longitude"
        static let MapString = "mapString"
        static let MediaURL  = "mediaURL"
        static let ObjectId  = "objectId"
        static let UniqueKey = "uniqueKey"
        static let UpdatedAt = "updatedAt"
    }
}

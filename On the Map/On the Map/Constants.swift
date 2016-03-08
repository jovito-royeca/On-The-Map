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
        static let FieldAccept             = "Accept"
        static let FieldAcceptValue        = "application/json"
        static let FieldContentType        = "Content-Type"
        static let FieldContentTypetValue  = "application/json"
    }
    
    
    // MARK: Udacity
    struct Udacity {
        static let ApiScheme = "https"
        static let ApiHost = "www.udacity.com"
        static let ApiPath = "/api"
        static let DataOffset = 5
    }
    
    // MARK: Udacity Methods
    struct UdacityMethods {
        static let Session  = "session"
        static let UserData = "users/{userId}"
    }
    
    // MARK: Faceboo
    struct Facebook {
        static let AppID = "365362206864879"
        static let SchemeSuffix = "onthemap"
    }
    
    // MARK: Parse
    struct Parse {
        static let AppID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let AppKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    }
    
    // MARK: Parse Methods
    struct ParseMethods {
        static let Session  = "session"
        static let UserData = "users/{userId}"
    }
}

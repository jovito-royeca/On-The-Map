//
//  NetworkManager.swift
//  On the Map
//
//  Created by Jovit Royeca on 3/8/16.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import FBSDKLoginKit

final class NetworkManager: NSObject {
    
    var udacitySessionID:String?
    
    // MARK: Udacity API
    func udacityLogin(username: String, password: String, success: (results: AnyObject!) -> Void, failure: (error: NSError?) -> Void) {
        let httpMethod = Constants.Http.ActionPost
        let urlString = "\(Constants.Udacity.ApiScheme)://\(Constants.Udacity.ApiHost)/\(Constants.Udacity.ApiPath)/\(Constants.UdacityMethods.Session)"
        let headers = [Constants.Http.FieldAccept: Constants.Http.FieldAcceptValue,
                       Constants.Http.FieldContentType: Constants.Http.FieldContentTypeValue]
        let body = "{\"udacity\": {\"\(Constants.UdacityJSONKeys.Username)\": \"\(username)\", \"\(Constants.UdacityJSONKeys.Password)\": \"\(password)\"}}"
        
        let preSuccess = { (results: AnyObject!) in
            // weird Xcode Swift warning
            // http://stackoverflow.com/questions/32715160/xcode-7-strange-cast-error-that-refers-to-xcuielement
            if let session = results[Constants.UdacityJSONKeys.Session] as? [String: AnyObject] {
                self.udacitySessionID = session[Constants.UdacityJSONKeys.ID] as? String
            } else {
                self.fail("session key not found", failure: failure)
            }
            
            // weird Xcode Swift warning
            // http://stackoverflow.com/questions/32715160/xcode-7-strange-cast-error-that-refers-to-xcuielement
            if let account = results[Constants.UdacityJSONKeys.Account] as? [String: AnyObject] {
                let key = account[Constants.UdacityJSONKeys.Key] as? String
                
                self.udacityGetUserData(key!, success: success, failure: failure);
                
            } else {
                self.fail("account key not found", failure: failure)
            }
        }
        
        self.exec(httpMethod, urlString: urlString, headers: headers, parameters: nil, values: nil, body: body, dataOffset: Constants.Udacity.DataOffset, isJSON: true, success: preSuccess, failure: failure)
    }
    
    func udacityLogout(success: (results: AnyObject!) -> Void, failure: (error: NSError?) -> Void) {
        let httpMethod = Constants.Http.ActionDelete
        let urlString = "\(Constants.Udacity.ApiScheme)://\(Constants.Udacity.ApiHost)/\(Constants.Udacity.ApiPath)/\(Constants.UdacityMethods.Session)"
        var values = [String: String]()
        
    
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" {
                xsrfCookie = cookie
            }
        }
        if let xsrfCookie = xsrfCookie {
            values["X-XSRF-TOKEN"] = xsrfCookie.value
        }
        
        
        let preSuccess = { (results: AnyObject!) in
            DataManager.sharedInstance().resetData()

            let loginManager = FBSDKLoginManager()
            loginManager.logOut()
            
            success(results: results)
        }
        
        self.exec(httpMethod, urlString: urlString, headers: nil, parameters: nil, values: values, body: nil, dataOffset: Constants.Udacity.DataOffset, isJSON: true, success: preSuccess, failure: failure)
    }
    
    func udacityGetUserData(key: String, success: (results: AnyObject!) -> Void, failure: (error: NSError?) -> Void) {
        let httpMethod = Constants.Http.ActionGet
        let userId = Constants.UdacityMethods.UserData.stringByReplacingOccurrencesOfString("{userId}", withString: key)
        let urlString = "\(Constants.Parse.ApiScheme)://\(Constants.Udacity.ApiHost)/\(Constants.Udacity.ApiPath)/\(userId)"
        
        let preSuccess = { (results: AnyObject!) in
            // weird Xcode Swift warning
            // http://stackoverflow.com/questions/32715160/xcode-7-strange-cast-error-that-refers-to-xcuielement
            if let user = results["user"] as? [String: AnyObject] {
                DataManager.sharedInstance().userData = UserData(dictionary: user)
                success(results: results)
                
            } else {
                self.fail("user key not found", failure: failure)
            }
        }
        
        self.exec(httpMethod, urlString: urlString, headers: nil, parameters: nil, values: nil, body: nil, dataOffset: Constants.Udacity.DataOffset, isJSON: true, success: preSuccess, failure: failure)
    }
    
    // MARK: Parse API
    func parseGetStudentLocations(success: (results: AnyObject!) -> Void, failure: (error: NSError?) -> Void) {
        let httpMethod = Constants.Http.ActionGet
        let urlString = "\(Constants.Parse.ApiScheme)://\(Constants.Parse.ApiHost)/\(Constants.Parse.ApiPath)/\(Constants.ParseMethods.StudentLocation)"
        let headers = [Constants.Parse.FieldAppID: Constants.Parse.FieldAppIDValue,
            Constants.Parse.FieldAppKey: Constants.Parse.FieldAppKeyValue]
        let parameters = [Constants.Parse.SortKey: Constants.Parse.SortValue]
        
        let preSuccess = { (results: AnyObject!) in
            DataManager.sharedInstance().students.removeAll()
            
            // weird Xcode Swift warning
            // http://stackoverflow.com/questions/32715160/xcode-7-strange-cast-error-that-refers-to-xcuielement
            if let r = results["results"] as? [[String:AnyObject]] {
                for dict in r {
                    let student = StudentInformation(dictionary: dict)
                    DataManager.sharedInstance().students.append(student)
                 
                    // let's store the currently logged-in user from the results
                    if let uniqueKey = dict[Constants.ParseJSONKeys.UniqueKey] as? String {
                        if uniqueKey == DataManager.sharedInstance().userData?.key {
                            DataManager.sharedInstance().currentStudent = student
                        }
                    }
                }
                success(results: results)
            }
        }
        
        self.exec(httpMethod, urlString: urlString, headers: headers, parameters: parameters, values: nil, body: nil, dataOffset: Constants.Parse.DataOffset, isJSON: true, success: preSuccess, failure: failure)
    }
    
    func parseCreateStudentLocation(location: CLLocationCoordinate2D, mapString: String, mediaURL: String, success: (results: AnyObject!) -> Void, failure: (error: NSError?) -> Void) {
        let httpMethod = Constants.Http.ActionPost
        let urlString = "\(Constants.Parse.ApiScheme)://\(Constants.Parse.ApiHost)/\(Constants.Parse.ApiPath)/\(Constants.ParseMethods.StudentLocation)"
        let headers = [Constants.Parse.FieldAppID: Constants.Parse.FieldAppIDValue,
            Constants.Parse.FieldAppKey: Constants.Parse.FieldAppKeyValue,
            Constants.Http.FieldContentType: Constants.Http.FieldContentTypeValue]
        
        let body = "{\"\(Constants.ParseJSONKeys.UniqueKey)\": \"\(DataManager.sharedInstance().userData!.key!)\", \"\(Constants.ParseJSONKeys.FirstName)\": \"\(DataManager.sharedInstance().userData!.firstName!)\", \"\(Constants.ParseJSONKeys.LastName)\": \"\(DataManager.sharedInstance().userData!.lastName!)\", \"\(Constants.ParseJSONKeys.MapString)\": \"\(mapString)\", \"\(Constants.ParseJSONKeys.MediaURL)\": \"\(mediaURL)\", \"\(Constants.ParseJSONKeys.Latitude)\": \(location.latitude), \"\(Constants.ParseJSONKeys.Longitude)\": \(location.longitude)}"
        
        let preSuccess = { (results: AnyObject!) in
            self.parseGetStudentLocations(success, failure: failure)
        }

        self.exec(httpMethod, urlString: urlString, headers: headers, parameters: nil, values: nil, body: body, dataOffset: Constants.Parse.DataOffset, isJSON: true, success: preSuccess, failure: failure)
    }
    
    func parseUpdateStudentLocation(location: CLLocationCoordinate2D, mapString: String, mediaURL: String, success: (results: AnyObject!) -> Void, failure: (error: NSError?) -> Void) {
        let httpMethod = Constants.Http.ActionPut
        let urlString = "\(Constants.Parse.ApiScheme)://\(Constants.Parse.ApiHost)/\(Constants.Parse.ApiPath)/\(Constants.ParseMethods.StudentLocation)/\(DataManager.sharedInstance().currentStudent!.objectId!)"
        let headers = [Constants.Parse.FieldAppID: Constants.Parse.FieldAppIDValue,
            Constants.Parse.FieldAppKey: Constants.Parse.FieldAppKeyValue,
            Constants.Http.FieldContentType: Constants.Http.FieldContentTypeValue]
        
        let body = "{\"\(Constants.ParseJSONKeys.MapString)\": \"\(mapString)\", \"\(Constants.ParseJSONKeys.MediaURL)\": \"\(mediaURL)\", \"\(Constants.ParseJSONKeys.Latitude)\": \(location.latitude), \"\(Constants.ParseJSONKeys.Longitude)\": \(location.longitude)}"
        
        let preSuccess = { (results: AnyObject!) in
            if let _ = DataManager.sharedInstance().currentStudent {
                // update the currentStudent information
                DataManager.sharedInstance().updateCurrentStudent(location.latitude, longitude: location.longitude, mapString: mapString, mediaURL: NSURL(string: mediaURL)!)
                var index = 0
                var found = false
                
                // update the student information in students
                for student in DataManager.sharedInstance().students {
                    if student.uniqueKey == DataManager.sharedInstance().currentStudent?.uniqueKey {
                        found = true
                        break
                    }
                    index++
                }
                if found {
                    DataManager.sharedInstance().students.removeAtIndex(index)
                }
                DataManager.sharedInstance().students.insert(DataManager.sharedInstance().currentStudent!, atIndex: 0)
            }
            success(results: results)
        }
        
        self.exec(httpMethod, urlString: urlString, headers: headers, parameters: nil, values: nil, body: body, dataOffset: Constants.Parse.DataOffset, isJSON: true, success: preSuccess, failure: failure)
    }
    
    func parseDeleteStudentLocation(success: (results: AnyObject!) -> Void, failure: (error: NSError?) -> Void) {
        let httpMethod = Constants.Http.ActionDelete
        let urlString = "\(Constants.Parse.ApiScheme)://\(Constants.Parse.ApiHost)/\(Constants.Parse.ApiPath)/\(Constants.ParseMethods.StudentLocation)/\(DataManager.sharedInstance().currentStudent!.objectId!)"
        let headers = [Constants.Parse.FieldAppID: Constants.Parse.FieldAppIDValue,
            Constants.Parse.FieldAppKey: Constants.Parse.FieldAppKeyValue,
            Constants.Http.FieldContentType: Constants.Http.FieldContentTypeValue]
        
        let preSuccess = { (results: AnyObject!) in
            if let _ = DataManager.sharedInstance().currentStudent {
                var index = 0
                var found = false
                
                // remove the student information in students
                for student in DataManager.sharedInstance().students {
                    if student.uniqueKey == DataManager.sharedInstance().currentStudent?.uniqueKey {
                        found = true
                        break
                    }
                    index++
                }
                if found {
                    DataManager.sharedInstance().students.removeAtIndex(index)
                }
                
                // remove the current student
                DataManager.sharedInstance().currentStudent = nil
            }
            success(results: results)
        }
        
        self.exec(httpMethod, urlString: urlString, headers: headers, parameters: nil, values: nil, body: nil, dataOffset: Constants.Parse.DataOffset, isJSON: true, success: preSuccess, failure: failure)
    }
    
    // MARK: Facebook
    func facebookLogin(view: UIViewController, success: (results: AnyObject!) -> Void, failure: (error: NSError?) -> Void) {
        let loginManager = FBSDKLoginManager()
        
        // login first in Facebook to get access token
        loginManager.logInWithReadPermissions(["public_profile"], fromViewController:view, handler: { (result, error) in
            if let _ = error {
                self.fail("Facebook Login Error", failure: failure)
                
            } else {
                
                // then use the access token to sign in to Udacity
                let httpMethod = Constants.Http.ActionPost
                let urlString = "\(Constants.Udacity.ApiScheme)://\(Constants.Udacity.ApiHost)/\(Constants.Udacity.ApiPath)/\(Constants.UdacityMethods.Session)"
                let headers = [Constants.Http.FieldAccept: Constants.Http.FieldAcceptValue,
                    Constants.Http.FieldContentType: Constants.Http.FieldContentTypeValue]
                let body = "{\"\(Constants.FacebookJSONKeys.FacebookMobile)\": {\"\(Constants.FacebookJSONKeys.AccessToken)\": \"\(FBSDKAccessToken.currentAccessToken().tokenString)\"}}"
                
                let preSuccess = { (results: AnyObject!) in
                    // weird Xcode Swift warning
                    // http://stackoverflow.com/questions/32715160/xcode-7-strange-cast-error-that-refers-to-xcuielement
                    if let session = results["session"] as? [String: AnyObject] {
                        self.udacitySessionID = session["id"] as? String
                    } else {
                        self.fail("session key not found", failure: failure)
                    }
                    
                    // weird Xcode Swift warning
                    // http://stackoverflow.com/questions/32715160/xcode-7-strange-cast-error-that-refers-to-xcuielement
                    if let account = results["account"] as? [String: AnyObject] {
                        let key = account["key"] as? String
                        
                        self.udacityGetUserData(key!, success: success, failure: failure);
                        
                    } else {
                        self.fail("account key not found", failure: failure)
                    }
                }
                
                self.exec(httpMethod, urlString: urlString, headers: headers, parameters: nil, values: nil, body: body, dataOffset: Constants.Udacity.DataOffset, isJSON: true, success: preSuccess, failure: failure)
            }
        })
    }
    
    /*!
        @method exec:httpMethod:urlString:headers:parameters:values:body:dataOffset:isJSON:success:failure:
        @abstract Executes an HTTP request
        @param httpMethod the http method i.e GET, POST, @see Constants.Http.ActionXXX
        @param urlString the url of the API
        @param headers HTTP headers
        @param parameters HTTP parameters
        @param values HTTP values
        @param body HTTP body
        @param dataOffset size to skip in the HTTP response @see Constants.Parse.DataOffset
        @param isJSON check if response will be parsed as JSON using NSJSONSerialization
        @param success block to handle response data
        @param failure block to handle error message resturned
    */
    func exec(httpMethod: String!,
               urlString: String!,
                 headers: [String:AnyObject]?,
              parameters: [String:AnyObject]?,
                  values: [String:AnyObject]?,
                    body: String?,
              dataOffset: Int,
                  isJSON: Bool,
                 success: (results: AnyObject!) -> Void,
                 failure: (error: NSError?) -> Void) -> Void {
        
        let components = NSURLComponents(string: urlString)!
        if let parameters = parameters {
            var queryItems = [NSURLQueryItem]()
            
            for (key, value) in parameters {
                let queryItem = NSURLQueryItem(name: key, value: "\(value)")
                queryItems.append(queryItem)
            }
            
            components.queryItems = queryItems
        }
                    
        let request = NSMutableURLRequest(URL: components.URL!)
        
        request.HTTPMethod = httpMethod
                    
        if let headers = headers {
            for (key,value) in headers {
                request.addValue(value as! String, forHTTPHeaderField: key)
            }
        }
                    
        if let values = values {
            for (key,value) in values {
                request.setValue(value as? String, forHTTPHeaderField: key)
            }
        }

        if let body = body {
            request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)
        }
        
                    
        let session = NSURLSession.sharedSession()

        let task = session.dataTaskWithRequest(request) { data, response, error in
            var newData: NSData?
            var parsedResult: AnyObject?
            
            guard (error == nil) else {
                if let errorMessage = error?.userInfo[NSLocalizedDescriptionKey] as? String {
                    self.fail(errorMessage, failure: failure)
                } else {
                    self.fail("\(error)", failure: failure)
                }
                
                return
            }
            
            guard let data = data else {
                self.fail("No data was returned by the request!", failure: failure)
                return
            }
            
            if dataOffset > 0 {
                newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            } else {
                newData = data
            }
            
            if isJSON {
                do {
                    parsedResult = try NSJSONSerialization.JSONObjectWithData(newData!, options: .AllowFragments)
                } catch {
                    self.fail("Could not parse the data as JSON.", failure: failure)
                }
            } else {
                parsedResult = newData
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                // weird Xcode Swift warning
                // http://stackoverflow.com/questions/32715160/xcode-7-strange-cast-error-that-refers-to-xcuielement
                if let errorMessage = parsedResult!["error"] as? String {
                    self.fail(errorMessage, failure: failure)
                    
                } else {
                    self.fail("Your request returned a status code of \((response as? NSHTTPURLResponse)?.statusCode).", failure: failure)
                }
                return
            }
            
            success(results: parsedResult)
        }
        
        task.resume()
    }
    
    // MARK: Custom methods
    func fail(error: String, failure: (error: NSError?) -> Void) {
        print(error)
        let userInfo = [NSLocalizedDescriptionKey : error]
        failure(error: NSError(domain: "exec", code: 1, userInfo: userInfo))
    }
    
    class func sharedInstance() -> NetworkManager {
        struct Singleton {
            static var sharedInstance = NetworkManager()
        }
        return Singleton.sharedInstance
    }
}

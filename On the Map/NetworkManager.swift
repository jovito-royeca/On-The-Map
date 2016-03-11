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

class NetworkManager: NSObject {
    
    var students = [StudentInformation]()
    var currentStudent:StudentInformation?
    var userData:UserData?
    var udacitySessionID:String?
    
    // MARK: Udacity API
    func udacityLogin(username: String, password: String, success: (results: AnyObject!) -> Void, failure: (error: NSError?) -> Void) {
        let httpMethod = Constants.Http.ActionPost
        let urlString = "\(Constants.Udacity.ApiScheme)://\(Constants.Udacity.ApiHost)/\(Constants.Udacity.ApiPath)/\(Constants.UdacityMethods.Session)"
        let headers = [Constants.Http.FieldAccept: Constants.Http.FieldAcceptValue,
                       Constants.Http.FieldContentType: Constants.Http.FieldContentTypeValue]
        let body = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}"
        
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
            self.students = [StudentInformation]()
            self.userData = nil
            self.udacitySessionID = nil

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
                self.userData = UserData(dictionary: user)
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
            self.students.removeAll()
            
            // weird Xcode Swift warning
            // http://stackoverflow.com/questions/32715160/xcode-7-strange-cast-error-that-refers-to-xcuielement
            if let r = results["results"] as? [[String:AnyObject]] {
                for dict in r {
                    let student = StudentInformation(dictionary: dict)
                    self.students.append(student)
                 
                    // let's store the currently logged-in user from the results
                    if let uniqueKey = dict[Constants.ParseJSONKeys.UniqueKey] as? String {
                        if uniqueKey == self.userData?.key {
                            self.currentStudent = student
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
        
        let body = "{\"\(Constants.ParseJSONKeys.UniqueKey)\": \"\(userData!.key!)\", \"\(Constants.ParseJSONKeys.FirstName)\": \"\(userData!.firstName!)\", \"\(Constants.ParseJSONKeys.LastName)\": \"\(userData!.lastName!)\", \"\(Constants.ParseJSONKeys.MapString)\": \"\(mapString)\", \"\(Constants.ParseJSONKeys.MediaURL)\": \"\(mediaURL)\", \"\(Constants.ParseJSONKeys.Latitude)\": \(location.latitude), \"\(Constants.ParseJSONKeys.Longitude)\": \(location.longitude)}"
        
        let preSuccess = { (results: AnyObject!) in
            self.parseGetStudentLocations(success, failure: failure)
        }

        self.exec(httpMethod, urlString: urlString, headers: headers, parameters: nil, values: nil, body: body, dataOffset: Constants.Parse.DataOffset, isJSON: true, success: preSuccess, failure: failure)
    }
    
    func parseUpdateStudentLocation(location: CLLocationCoordinate2D, mapString: String, mediaURL: String, success: (results: AnyObject!) -> Void, failure: (error: NSError?) -> Void) {
        let httpMethod = Constants.Http.ActionPut
        let urlString = "\(Constants.Parse.ApiScheme)://\(Constants.Parse.ApiHost)/\(Constants.Parse.ApiPath)/\(Constants.ParseMethods.StudentLocation)/\(self.currentStudent!.objectId!)"
        let headers = [Constants.Parse.FieldAppID: Constants.Parse.FieldAppIDValue,
            Constants.Parse.FieldAppKey: Constants.Parse.FieldAppKeyValue,
            Constants.Http.FieldContentType: Constants.Http.FieldContentTypeValue]
        
        let body = "{\"\(Constants.ParseJSONKeys.MapString)\": \"\(mapString)\", \"\(Constants.ParseJSONKeys.MediaURL)\": \"\(mediaURL)\", \"\(Constants.ParseJSONKeys.Latitude)\": \(location.latitude), \"\(Constants.ParseJSONKeys.Longitude)\": \(location.longitude)}"
        
        let preSuccess = { (results: AnyObject!) in
            if let _ = self.currentStudent {
                // update the currentStudent information
                self.currentStudent?.latitude = location.latitude
                self.currentStudent?.longitude = location.longitude
                self.currentStudent?.mapString = mapString
                self.currentStudent?.mediaURL = NSURL(string: mediaURL)
                var index = 0
                var found = false
                
                // update the student information in students
                for student in self.students {
                    if student.uniqueKey == self.currentStudent?.uniqueKey {
                        found = true
                        break
                    }
                    index++
                }
                if found {
                    self.students.removeAtIndex(index)
                }
                self.students.insert(self.currentStudent!, atIndex: 0)
            }
            success(results: results)
        }
        
        self.exec(httpMethod, urlString: urlString, headers: headers, parameters: nil, values: nil, body: body, dataOffset: Constants.Parse.DataOffset, isJSON: true, success: preSuccess, failure: failure)
    }
    
    func parseDeleteStudentLocation(success: (results: AnyObject!) -> Void, failure: (error: NSError?) -> Void) {
        let httpMethod = Constants.Http.ActionDelete
        let urlString = "\(Constants.Parse.ApiScheme)://\(Constants.Parse.ApiHost)/\(Constants.Parse.ApiPath)/\(Constants.ParseMethods.StudentLocation)/\(self.currentStudent!.objectId!)"
        let headers = [Constants.Parse.FieldAppID: Constants.Parse.FieldAppIDValue,
            Constants.Parse.FieldAppKey: Constants.Parse.FieldAppKeyValue,
            Constants.Http.FieldContentType: Constants.Http.FieldContentTypeValue]
        
        let preSuccess = { (results: AnyObject!) in
            if let _ = self.currentStudent {
                var index = 0
                var found = false
                
                // remove the student information in students
                for student in self.students {
                    if student.uniqueKey == self.currentStudent?.uniqueKey {
                        found = true
                        break
                    }
                    index++
                }
                if found {
                    self.students.removeAtIndex(index)
                }
                
                // remove the current student
                self.currentStudent = nil
            }
            success(results: results)
        }
        
        self.exec(httpMethod, urlString: urlString, headers: headers, parameters: nil, values: nil, body: nil, dataOffset: Constants.Parse.DataOffset, isJSON: true, success: preSuccess, failure: failure)
    }
    
    // MARK: Facebook
    func facebookLogin(view: UIViewController, success: (results: AnyObject!) -> Void, failure: (error: NSError?) -> Void) {
        let loginManager = FBSDKLoginManager()
        
        loginManager.logInWithReadPermissions(["public_profile"], fromViewController:view, handler: { (result, error) in
            if let _ = error {
                self.fail("Facebook Login Error", failure: failure)
                
            } else {
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
    
    // MARK: HTTP Ops
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

            guard (error == nil) else {
                self.fail(error?.userInfo[NSLocalizedDescriptionKey] as! String, failure: failure)
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                self.fail("Your request returned a status code other than 2xx!", failure: failure)
                return
            }
            
            guard let data = data else {
                self.fail("No data was returned by the request!", failure: failure)
                return
            }
         
            
            var newData: NSData?
            
            if dataOffset > 0 {
                newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            } else {
                newData = data
            }
            
            if isJSON {
                var parsedResult: AnyObject!
                do {
                    parsedResult = try NSJSONSerialization.JSONObjectWithData(newData!, options: .AllowFragments)
                    success(results: parsedResult)
                } catch {
                    self.fail("Could not parse the data as JSON.", failure: failure)
                }
            } else {
                success(results: newData)
            }
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

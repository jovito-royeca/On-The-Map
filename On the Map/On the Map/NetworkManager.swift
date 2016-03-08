//
//  NetworkManager.swift
//  On the Map
//
//  Created by Jovit Royeca on 3/8/16.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import Foundation

class NetworkManager: NSObject {
    
    var students = [StudentInformation]()
    var userID:String?
    var sessionID:String?
    var sessionExpiration:NSDate?
    
    func loginUdacity(username: String, password: String, success: (results: AnyObject!) -> Void, failure: (error: NSError?) -> Void) {
        let httpMethod = Constants.Http.ActionPost
        let urlString = "\(Constants.Udacity.ApiScheme)://\(Constants.Udacity.ApiHost)/\(Constants.Udacity.ApiPath)/\(Constants.UdacityMethods.Session)"
        let headers = [Constants.Http.FieldAccept: Constants.Http.FieldAcceptValue,
                       Constants.Http.FieldContentType: Constants.Http.FieldContentTypetValue]
        
        let body = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}"
        
        let parser = { (result: AnyObject!) in
            if let account = result["account"] as? [String: AnyObject] {
                self.userID = account["key"] as? String
            } else {
                self.fail("account key not found", failure: failure)
            }
            
            if let session = result["session"] as? [String: AnyObject] {
                self.sessionID = session["id"] as? String
            } else {
                self.fail("session key not found", failure: failure)
            }
            
            success(results: result)
        }
        
        self .exec(httpMethod, urlString: urlString, headers: headers, parameters: nil, values: nil, body: body, dataOffset: Constants.Udacity.DataOffset, success: parser, failure: failure)
    }
    
    func logoutUdacity(success: (results: AnyObject!) -> Void, failure: (error: NSError?) -> Void) {
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
        
        self .exec(httpMethod, urlString: urlString, headers: nil, parameters: nil, values: values, body: nil, dataOffset: Constants.Udacity.DataOffset, success: success, failure: failure)
    }
    
    func exec(httpMethod: String!,
               urlString: String!,
                 headers: [String:AnyObject]?,
              parameters: [String:AnyObject]?,
                  values: [String:AnyObject]?,
                    body: String?,
              dataOffset: Int,
                 success: (result: AnyObject!) -> Void,
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
                self.fail("There was an error with your request: \(error)", failure: failure)
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
         
            var parsedResult: AnyObject!
            var newData: NSData?
            
            if dataOffset > 0 {
                newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            } else {
                newData = data
            }
                
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(newData!, options: .AllowFragments)
                success(result: parsedResult)
            } catch {
                self.fail("Could not parse the data as JSON: '\(newData!)'", failure: failure)
            }
        }
        
        task.resume()
    }
    
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

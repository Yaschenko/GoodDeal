//
//  ServerConnectionsManager.swift
//  MyMood
//
//  Created by Yurii on 12/8/15.
//  Copyright © 2015 Nostris. All rights reserved.
//

import Foundation
class ServerConnectionsManager : NSObject, NSURLSessionDelegate{
    var serverUrlString : String!
    lazy var urlSession : NSURLSession! = {return NSURLSession.sharedSession()//NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: self, delegateQueue:NSOperationQueue.mainQueue())
    }()
    
    lazy var backgroundUrlSession : NSURLSession! = {return NSURLSession(configuration: NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("MyMoodBackgroundSession"), delegate: self, delegateQueue:NSOperationQueue.mainQueue())}()
    
    init(server : String!) {
        self.serverUrlString = server
    }
    
    func sendRequest(urlRequest:NSURLRequest!, callback:((result:Bool!, json:AnyObject?)->Void)?) {
        let task:NSURLSessionDataTask = self.urlSession.dataTaskWithRequest(urlRequest, completionHandler: {(data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
            if data != nil {
                print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                var json:AnyObject?
                var result:Bool! = true
                do {
                    json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                }
                catch {
                    json = nil
                    result = false
                }
                if json?.valueForKey("message") != nil {result = false}
                if callback != nil{
                    callback!(result: result, json: json)
                }
            }
        })
        task.resume();
    }
    func sendMultipartData(path path:String!, file:String!, data:[String:String]?, callback:((result:Bool!, json:AnyObject?)->Void)?) {
        let requestUrl:String! = self.serverUrlString+path
        let urlRequest:NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: requestUrl)!)
        let boundarySytring:String! = "Asrf456BGe4h"
        urlRequest.setValue("multipart/form-data; boundary=\(boundarySytring)", forHTTPHeaderField:"Content-Type")
        var httpData:String = ""
        let bodyData:NSMutableData = NSMutableData()
        if data != nil {
            for (key, value) in data! {
                httpData.appendContentsOf("--\(boundarySytring)\r\n")
                httpData.appendContentsOf("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                httpData.appendContentsOf("\(value)\r\n")
            }
        }
        httpData.appendContentsOf("--\(boundarySytring)\r\n")
        httpData.appendContentsOf("Content-Disposition: form-data; name=\"video\"; filename=\"\(file)\"\r\n")
        httpData.appendContentsOf("Content-Type: video/mp4\r\n\r\n")
        bodyData.appendData((httpData as NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
        do {
            let string:String = NSTemporaryDirectory().stringByAppendingString(file)
            let dataFile:NSData? = try NSData(contentsOfURL: NSURL(fileURLWithPath: string), options: NSDataReadingOptions.DataReadingMappedIfSafe)
            if dataFile != nil {
                bodyData.appendData(dataFile!)
            }
        }
        catch {
            print(error)
        }
        bodyData.appendData(("--\(boundarySytring)--\r\n" as NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
        urlRequest.HTTPBody = bodyData
        urlRequest.HTTPMethod = "POST"
        urlRequest.setValue("\(bodyData.length)", forHTTPHeaderField: "Content-Length")
        let token:String? = NSUserDefaults.standardUserDefaults().valueForKey("auth_token") as? String
        if token != nil {
            urlRequest.setValue("Token token=\"\(token!)\"", forHTTPHeaderField:"Authorization")
        }
        self.sendRequest(urlRequest, callback: callback)
    }
    func sendPostRequest(path path:String!, data:[String:String]?, callback:((result:Bool!, json:AnyObject?)->Void)?) {
        let requestUrl:String! = self.serverUrlString+path
        let urlRequest:NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: requestUrl)!)
        var httpData:String = ""
        if data != nil {
            for (key, value) in data! {
                httpData.appendContentsOf(key)
                httpData.appendContentsOf("=")
                httpData.appendContentsOf(value)
                httpData.appendContentsOf("&")
            }
            urlRequest.HTTPBody = (httpData as NSString).dataUsingEncoding(NSUTF8StringEncoding)!
        }
        
        urlRequest.HTTPMethod = "POST"
        let token:String? = NSUserDefaults.standardUserDefaults().valueForKey("auth_token") as? String
        if token != nil {
            urlRequest.setValue("Token token=\"\(token!)\"", forHTTPHeaderField:"Authorization")
        }
        self.sendRequest(urlRequest, callback: callback)
    }
    func sendGetRequest(path path:String!, data:[String:String]?, callback:((result:Bool!, json:AnyObject?)->Void)?) {
        var requestUrl:String! = self.serverUrlString+path
//        let urlRequest:NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: requestUrl)!)
        var httpData:String = "?"
        if data != nil {
            for (key, value) in data! {
                httpData.appendContentsOf(key)
                httpData.appendContentsOf("=")
                httpData.appendContentsOf(value)
                httpData.appendContentsOf("&")
            }
            requestUrl.appendContentsOf(httpData)
        }
        let urlRequest:NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: requestUrl)!)
        urlRequest.HTTPMethod = "GET"
        let token:String? = NSUserDefaults.standardUserDefaults().valueForKey("auth_token") as? String
        if token != nil {
            urlRequest.setValue("Token token=\"\(token!)\"", forHTTPHeaderField:"Authorization")
        }
        self.sendRequest(urlRequest, callback: callback)
    }
    func downloadFile(urlFile:NSURL, callback:((result:Bool!, json:AnyObject?, response:NSURLResponse?)->Void)?) {
        self.urlSession.downloadTaskWithURL(urlFile) { (url:NSURL?, response:NSURLResponse?, error:NSError?) -> Void in
            print(url?.absoluteString)
            if callback == nil {return}
            if error == nil {
                callback!(result: true, json: url, response: response)
            } else {
                callback!(result: false, json: nil, response: response)
            }
        }.resume()
    }
    static let sharedInstance = ServerConnectionsManager(server: "http://gooddeal.my-dis.com/")
//    static let sharedInstance = ServerConnectionsManager(server: "http://c57a7464.ngrok.io/")
}
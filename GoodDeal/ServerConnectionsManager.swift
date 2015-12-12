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
    func sendPostRequest(path path:String!, data:[String:String]?, callback:((result:Bool!, json:AnyObject?)->Void)?) {
        let requestUrl:String! = self.serverUrlString+path
        let urlRequest:NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: requestUrl)!)
        var httpData:String = ""
        if data != nil {
//            requestUrl.appendContentsOf("?")
            for (key, value) in data! {
                httpData.appendContentsOf(key)
                httpData.appendContentsOf("=")
                httpData.appendContentsOf(value)
                httpData.appendContentsOf("&")
            }
            urlRequest.HTTPBody = (httpData as NSString).dataUsingEncoding(NSUTF8StringEncoding)!
        }
        
        urlRequest.HTTPMethod = "POST"
        let task:NSURLSessionDataTask = self.urlSession.dataTaskWithRequest(urlRequest, completionHandler: {(data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
            print(data!)
            if data != nil {
                var json:AnyObject?
                do {
                json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                }
                catch {
                    json = nil
                }
                if callback != nil{
                    callback!(result: true, json: json)
                }
            }
        })
        task.resume();
    }
    static let sharedInstance = ServerConnectionsManager(server: "http://66293395.ngrok.io/")
}
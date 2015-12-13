//
//  ChildrenListViewController.swift
//  GoodDeal
//
//  Created by Yurii on 12/12/15.
//  Copyright © 2015 Nostris. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import MediaPlayer

class ChildrenListViewController: CameraViewController, UITableViewDelegate, UITableViewDataSource {
    var page:Int! = 1
    var hasNextPage:Bool = false
    @IBOutlet var tableView:UITableView!
    var data = [AnyObject]()
    var isLoading:Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadData(1)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadData(page:Int!) {
        self.page = page
        hasNextPage = false
        isLoading = true
        tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: self.data.count, inSection: 0)], withRowAnimation: UITableViewRowAnimation.None)
        ServerConnectionsManager.sharedInstance.sendGetRequest(path: "api/v1/kids", data: ["page":"\(page)"]) { (result:Bool!, json:AnyObject?) -> Void in
            
            self.isLoading = false
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: self.data.count, inSection: 0)], withRowAnimation: UITableViewRowAnimation.None)
            })
            if result == true && json != nil{
                self.hasNextPage = ((json!["links"] as! [AnyObject]).count > 1)
                if (json!["kids"] as! [AnyObject]).count == 0 {
                    self.hasNextPage = false
                    return
                }
                let i1:Int = self.data.count
                self.data += (json!["kids"] as! [AnyObject])
                let i2:Int = self.data.count
                var indexis = [NSIndexPath]()
                for i in i1..<i2 {
                    indexis.append(NSIndexPath(forRow: i, inSection: 0))
                }
                if indexis.count > 0 {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.tableView.insertRowsAtIndexPaths(indexis, withRowAnimation: UITableViewRowAnimation.Automatic)
                    })
                }
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    override func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        self.dismissViewControllerAnimated(true) { () -> Void in
            self.showWaitingIndicatorView()
            self.prepareVideo(info[UIImagePickerControllerMediaURL] as? NSURL) { (result:String?) -> Void in
                if result == nil {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.waitingView.removeFromSuperview()
                    })
                    return
                }
                ServerConnectionsManager.sharedInstance.sendMultipartData(path: "api/v1/kids/\(5)/delivered", file: (result! as NSString).lastPathComponent, data: nil, callback: { (result, json) -> Void in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.waitingView.removeFromSuperview()
                    })
                })
                
            }
            
        }
    }
    func loadVideo(fileUrl:NSURL!) -> AVPlayerViewController! {
        let playerVC:AVPlayerViewController! = AVPlayerViewController()
        playerVC.player = AVPlayer(URL: fileUrl)
        return playerVC
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count+1
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell!
        if indexPath.row == self.data.count {
            cell = tableView.dequeueReusableCellWithIdentifier("LoadCell", forIndexPath: indexPath)
            cell.viewWithTag(1)!.hidden = !self.isLoading
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier("ChildInfoCell", forIndexPath: indexPath)
            cell.textLabel?.text = data[indexPath.row]["name"] as? String
        }
        
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        if indexPath.row == self.data.count {return}
        self.showWaitingIndicatorView()
        ServerConnectionsManager.sharedInstance.downloadFile(NSURL(string: ServerConnectionsManager.sharedInstance.serverUrlString.stringByAppendingString(data[indexPath.row]["video"] as! String))!) { (result, json) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.waitingView.removeFromSuperview()
            })
            if !result || json == nil {return}
            let file:String = self.createTempDirectory()
            do {
                try NSFileManager.defaultManager().copyItemAtURL(json as! NSURL, toURL: NSURL(fileURLWithPath: file))
            } catch {
                
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.presentViewController(self.loadVideo(NSURL(fileURLWithPath: file)), animated: true) { () -> Void in
                    
                }
            })
        }
    }
}

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
protocol ChildCellActionDelegate : NSObjectProtocol {
    func didClickCell(cell:UITableViewCell)
}
class ChildCell: UITableViewCell {
    @IBOutlet weak var button:UIButton!
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var addressLabel:UILabel!
    @IBOutlet weak var childImage:UIImageView!
    var imageUrl:String?
    weak var actionDelegate:protocol<ChildCellActionDelegate>?
    @IBAction func buttonAction() {
        if actionDelegate != nil {
            actionDelegate?.didClickCell(self)
        }
    }
    func downloadImage(imageUrl:String?) {
        if imageUrl == nil {return}
        self.imageUrl = ServerConnectionsManager.sharedInstance.serverUrlString + imageUrl!
        ServerConnectionsManager.sharedInstance.downloadFile(NSURL(string: self.imageUrl!)!, callback: {(result, json, response:NSURLResponse?)->Void in
            if json != nil && result == true && response != nil && response!.URL!.absoluteString == self.imageUrl{
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.childImage.image = UIImage(data: NSData(contentsOfURL: json as! NSURL)!)
                })
            }
        })
    }
}
class ChildrenListViewController: CameraViewController, UITableViewDelegate, UITableViewDataSource, ChildCellActionDelegate {
    var page:Int! = 1
    var hasNextPage:Bool = false
    @IBOutlet weak var tableView:UITableView!
    var data = [AnyObject]()
    var isLoading:Bool = false
    var childId:Int? = nil
    var childIndexPath:NSIndexPath? = nil
    var showIndicator:Bool = true
    var statusType:Int = 2
    @IBOutlet weak var selectStatus2Button:UIButton!
    @IBOutlet weak var selectStatus0Button:UIButton!
    @IBOutlet weak var selectStatus2Arrow:UIImageView!
    @IBOutlet weak var selectStatus0Arrow:UIImageView!
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
        ServerConnectionsManager.sharedInstance.sendGetRequest(path: "api/v1/kids", data: ["page":"\(page)", "status":"\(statusType)"]) { (result:Bool!, json:AnyObject?) -> Void in
            
            self.isLoading = false
            if result == true && json != nil{
                self.hasNextPage = ((json!["links"] as! [AnyObject]).count > 1)
                if (json!["kids"] as! [AnyObject]).count == 0 {
                    self.hasNextPage = false
                    self.showIndicator = false
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.tableView.reloadData()
                    })
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
                        self.showIndicator = false
                        if self.data.count == (json!["kids"] as! [AnyObject]).count || self.page == 1{
                            self.tableView.reloadData()
                        } else {
                            self.tableView.insertRowsAtIndexPaths(indexis, withRowAnimation: UITableViewRowAnimation.Automatic)
                        }
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
            if self.childId == nil {return}
            self.showWaitingIndicatorView()
            self.prepareVideo(info[UIImagePickerControllerMediaURL] as? NSURL) { (result:String?) -> Void in
                if result == nil {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.waitingView.removeFromSuperview()
                    })
                    return
                }
                ServerConnectionsManager.sharedInstance.sendMultipartData(path: "api/v1/kids/\(self.childId!)/delivered", file: (result! as NSString).lastPathComponent, data: nil, callback: { (result, json) -> Void in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.waitingView.removeFromSuperview()
                        self.data.removeAtIndex((self.childIndexPath?.row)!)
                        self.tableView.deleteRowsAtIndexPaths([self.childIndexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
                        self.childIndexPath = nil
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
    func showShareView(url:String!, imageUrl:String?) {
        let truncated = ServerConnectionsManager.sharedInstance.serverUrlString.substringToIndex(ServerConnectionsManager.sharedInstance.serverUrlString.endIndex.predecessor())
        var shareData:[AnyObject] = [NSURL(string: truncated + url)!]
        if imageUrl != nil {
            let img:UIImage? = UIImage(data: NSData(contentsOfURL: NSURL(string:truncated + imageUrl!)!)!)
            if img != nil {
                shareData.append(img!)
            }
        }
        let activityViewController:UIActivityViewController = UIActivityViewController(activityItems: shareData, applicationActivities: nil)
        activityViewController.completionWithItemsHandler = {(str:String?, result:Bool, objects:[AnyObject]?, error:NSError?) -> Void in
            if error != nil {
                let alert : UIAlertController! = UIAlertController(title: "Ошибка", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                
                let defaultAction : UIAlertAction! = UIAlertAction(title: "Готово", style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction) -> Void in
//                    self.navigationController?.popViewControllerAnimated(true)
                })
                alert.addAction(defaultAction)
                self.presentViewController(alert, animated: true, completion: { () -> Void in
                })
                return
            }
//            self.navigationController?.popViewControllerAnimated(true)
        }
        self.presentViewController(activityViewController, animated: true) { () -> Void in
            
        }
        
    }
    func didClickCell(cell: UITableViewCell) {
        childIndexPath = self.tableView.indexPathForCell(cell)!
        print(data[childIndexPath!.row].description)
        if statusType == 2 {
            self.childId = data[childIndexPath!.row]["id"] as? Int
            self.showImagePickerController()
        } else {
            self.showShareView(data[childIndexPath!.row]["links"]!![0]!["href"] as! String, imageUrl: data[childIndexPath!.row]["thumb"] as? String)
        }
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.data.count == 0 && showIndicator {return 1}
        return self.data.count
    }
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == self.data.count-1 && !isLoading && hasNextPage {
            self.loadData(page+1)
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if self.data.count == 0 {
            let cell:UITableViewCell! = tableView.dequeueReusableCellWithIdentifier("LoadCell", forIndexPath: indexPath)
            return cell
        } else {
            let cell:ChildCell! = tableView.dequeueReusableCellWithIdentifier("ChildInfoCell", forIndexPath: indexPath) as! ChildCell
            cell.titleLabel?.text = data[indexPath.row]["name"] as? String
            cell.addressLabel?.text = data[indexPath.row]["address"] as? String
            cell.actionDelegate = self
            cell.downloadImage(data[indexPath.row]["thumb"] as? String)
            if statusType == 2 {
                cell.button.setImage(UIImage(imageLiteral: "check"), forState: UIControlState.Normal)
            } else {
                cell.button.setImage(UIImage(imageLiteral: "shareIcon"), forState: UIControlState.Normal)
            }
            return cell
        }
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        if 0 == self.data.count {return}
        self.showWaitingIndicatorView()
        ServerConnectionsManager.sharedInstance.downloadFile(NSURL(string: ServerConnectionsManager.sharedInstance.serverUrlString.stringByAppendingString(data[indexPath.row]["video"] as! String))!) { (result, json, response) -> Void in
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
                let playerVC:AVPlayerViewController = self.loadVideo(NSURL(fileURLWithPath: file))
                self.presentViewController(playerVC, animated: true) { () -> Void in
                    playerVC.player?.play()
                }
            })
        }
    }
    @IBAction func changeStatusType(sender:UIButton!) {
        if sender == selectStatus2Button && statusType != 2 {
            statusType = 2
            sender.selected = true
            selectStatus0Button.selected = false
            selectStatus2Arrow.hidden = false
            selectStatus0Arrow.hidden = true
        } else if sender == selectStatus0Button && statusType != 0{
            statusType = 0
            sender.selected = true
            selectStatus2Button.selected = false
            selectStatus2Arrow.hidden = true
            selectStatus0Arrow.hidden = false
        }
        self.data.removeAll()
        self.loadData(1)
    }
}

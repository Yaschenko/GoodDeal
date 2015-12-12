//
//  ChildrenListViewController.swift
//  GoodDeal
//
//  Created by Yurii on 12/12/15.
//  Copyright © 2015 Nostris. All rights reserved.
//

import UIKit

class ChildrenListViewController: CameraViewController {
    var page:Int! = 0
    override func viewDidLoad() {
        super.viewDidLoad()
//        ServerConnectionsManager.sharedInstance.sendGetRequest(path: "api/v1/kids", data: ["page":"\(page)"]) { (result, json) -> Void in
//            if result == true {
//                print("sdasdasd")
//            }
//        }
        ServerConnectionsManager.sharedInstance.sendMultipartData(path: "api/v1/kids/\(5)/delivered", file: "", data: nil, callback: { (result, json) -> Void in
            
        })
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
//            weak var weakSelf:CameraViewController?
//            weakSelf = self
            self.prepareVideo(info[UIImagePickerControllerMediaURL] as? NSURL) { (result:String?) -> Void in
                if result != nil {
                    ServerConnectionsManager.sharedInstance.sendMultipartData(path: "api/v1/kids/\(5)/delivered", file: (result! as NSString).lastPathComponent, data: nil, callback: { (result, json) -> Void in
                        
                    })
                }
            }
            
        }
    }
}

//
//  BaseViewController.swift
//  GoodDeal
//
//  Created by Yurii on 12/13/15.
//  Copyright © 2015 Nostris. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    @IBOutlet weak var waitingView:UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func showWaitingIndicatorView() {
        let mainView = UIApplication.sharedApplication().keyWindow
        self.waitingView.frame = (mainView?.bounds)!
        mainView?.addSubview(self.waitingView)
    }
    @IBAction func backAction() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

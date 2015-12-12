//
//  MenuViewController.swift
//  GoodDeal
//
//  Created by Yurii on 12/12/15.
//  Copyright © 2015 Nostris. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let userLogin : String? = NSUserDefaults.standardUserDefaults().valueForKey("login") as? String
        
        if userLogin == nil {
            self.showLoginView()
        } else {
            self.navigationItem.title = userLogin!
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showLoginView() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey("login")
        self.presentViewController(UIStoryboard(name: "Login", bundle: nil).instantiateInitialViewController()!, animated: true, completion: { () -> Void in
            
        })
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

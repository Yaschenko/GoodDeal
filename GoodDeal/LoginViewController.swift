//
//  ViewController.swift
//  GoodDeal
//
//  Created by Yurii on 12/12/15.
//  Copyright © 2015 Nostris. All rights reserved.
//

import UIKit
class CustomTextField:UITextField {
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, 9, 0)
    }
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, 9, 0)
    }
}
class LoginViewController: BaseViewController, UITextFieldDelegate {
    
    @IBOutlet weak var login:CustomTextField!
    @IBOutlet weak var password:CustomTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        login.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).CGColor
        login.layer.borderWidth = 1
        login.layer.cornerRadius = 5
        login.layer.masksToBounds = true
        password.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).CGColor
        password.layer.borderWidth = 1
        password.layer.cornerRadius = 5
        password.layer.masksToBounds = true
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func checkData() -> (result:Bool, error:String?, field:UITextField?) {
        self.view.endEditing(true)
        if login.text == nil || login.text?.characters.count == 0{
            return (false, "Введите электронную почту", login)
        }
        if password.text == nil || password.text?.characters.count == 0{
            return (false, "Введите пароль", password)
        }
        return (true, nil, nil)
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == login {
            password.becomeFirstResponder()
        } else {
            self.loginAction()
        }
        return true
    }
    @IBAction func loginAction() {
        let checkDataResult = self.checkData()
        if checkDataResult.result {
            self.showWaitingIndicatorView()
            ServerConnectionsManager.sharedInstance.sendPostRequest(path: "api/v1/sessions", data: ["email":login.text!, "password":password.text!], callback: {(result:Bool!, json:AnyObject?)->Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.waitingView.removeFromSuperview()
                })
                if result == true {
                    NSUserDefaults.standardUserDefaults().setValue(json!["auth_token"] as! String, forKey: "auth_token")
                    NSUserDefaults.standardUserDefaults().setValue(json!["email"] as! String, forKey: "email")
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.view.endEditing(true)
                        self.dismissViewControllerAnimated(true, completion: { () -> Void in
                            
                        })
                    })
                }
            })
        } else {
            let alert : UIAlertController! = UIAlertController(title: "Ошибка", message: checkDataResult.error, preferredStyle: UIAlertControllerStyle.Alert)
            
            let defaultAction : UIAlertAction! = UIAlertAction(title: "Хорошо", style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction) -> Void in
                checkDataResult.field!.becomeFirstResponder()
            })
            alert.addAction(defaultAction)
            self.presentViewController(alert, animated: true, completion: { () -> Void in
                
            })
        }
    }

}


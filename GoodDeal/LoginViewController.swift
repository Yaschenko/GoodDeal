//
//  ViewController.swift
//  GoodDeal
//
//  Created by Yurii on 12/12/15.
//  Copyright © 2015 Nostris. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var login:UITextField!
    @IBOutlet var password:UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func checkData() -> (result:Bool, error:String?, field:UITextField?) {
        if login.text == nil || login.text?.characters.count == 0{
            return (false, "Введите номер волонтера", login)
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
            NSUserDefaults.standardUserDefaults().setValue(login.text, forKey: "login")
            self.view.endEditing(true)
            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                
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


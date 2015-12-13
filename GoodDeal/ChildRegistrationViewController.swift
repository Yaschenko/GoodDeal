//
//  ChildRegistrationViewController.swift
//  GoodDeal
//
//  Created by Yurii on 12/12/15.
//  Copyright © 2015 Nostris. All rights reserved.
//

import UIKit

class ChildRegistrationViewController: CameraViewController, UITextFieldDelegate, UITextViewDelegate {
    @IBOutlet weak var name:UITextField!
    @IBOutlet weak var age:UITextField!
    @IBOutlet weak var address:UITextField!
    @IBOutlet weak var prize:UITextView!
    @IBOutlet weak var bottomConstraint:NSLayoutConstraint!
    @IBOutlet weak var topConstraint:NSLayoutConstraint!
    var keyboard:Bool!
    let bottomConstraintDefaultValue:CGFloat! = 65
    var needSend:Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        keyboard = false
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShowNotification:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHideNotification:", name: UIKeyboardWillHideNotification, object: nil)
        prize.layer.borderWidth = 1
        prize.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).CGColor
        
        name.layer.borderWidth = 1
        name.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).CGColor
        let nameText = NSAttributedString(string: "ФИО", attributes: [NSForegroundColorAttributeName:UIColor.whiteColor()])
        name.attributedPlaceholder = nameText
        
        age.layer.borderWidth = 1
        age.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).CGColor
        let ageText = NSAttributedString(string: "Возраст", attributes: [NSForegroundColorAttributeName:UIColor.whiteColor()])
        age.attributedPlaceholder = ageText

        address.layer.borderWidth = 1
        address.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).CGColor
        let addressText = NSAttributedString(string: "Адрес", attributes: [NSForegroundColorAttributeName:UIColor.whiteColor()])
        address.attributedPlaceholder = addressText
        
//        prize.layer.masksToBounds = true
//        prize.layer.cornerRadius = 5
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func keyboardWillShowNotification(notification:NSNotification) {
        if !prize.isFirstResponder(){return}
        keyboard = true
        let info:[NSObject : AnyObject]? = notification.userInfo
        if info == nil {return;}
        let kbSize:CGSize = (info![UIKeyboardFrameEndUserInfoKey]?.CGRectValue.size)!
        bottomConstraint.constant = bottomConstraintDefaultValue + kbSize.height
        topConstraint.constant = 0 - kbSize.height
        self.view.layoutIfNeeded()
        
    }
    func keyboardWillHideNotification(notification:NSNotification) {
        keyboard = false
        bottomConstraint.constant = bottomConstraintDefaultValue
        topConstraint.constant = 0
        self.view.layoutIfNeeded()
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }

    func send() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.showWaitingIndicatorView()
        }
        ServerConnectionsManager.sharedInstance.sendMultipartData(path: "api/v1/kids", file: (self.videoFile! as NSString).lastPathComponent, data: ["name":name.text!,"age":age.text!,"description":prize.text!, "address":address.text!], callback: { (result:Bool!, json:AnyObject?)->Void in
            if json != nil {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.waitingView.removeFromSuperview()
                    let alert : UIAlertController! = UIAlertController(title: "Готово", message: "Письмо отправлено", preferredStyle: UIAlertControllerStyle.Alert)
                    
                    let defaultAction : UIAlertAction! = UIAlertAction(title: "Хорошо", style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction) -> Void in
                        self.navigationController?.popViewControllerAnimated(true)
                    })
                    alert.addAction(defaultAction)
                    self.presentViewController(alert, animated: true, completion: { () -> Void in
                    })
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.waitingView.removeFromSuperview()
                    let alert : UIAlertController! = UIAlertController(title: "Ошибка", message: "Письмо не отправлено", preferredStyle: UIAlertControllerStyle.Alert)
                    
                    let defaultAction : UIAlertAction! = UIAlertAction(title: "Хорошо", style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction) -> Void in
                    })
                    alert.addAction(defaultAction)
                    self.presentViewController(alert, animated: true, completion: { () -> Void in
                    })
                })
            }
        })
    }
    override func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        videoFile = nil
//        imagePickerButton.setTitle("Изменить видео обращение", forState: UIControlState.Normal)
        self.dismissViewControllerAnimated(true) { () -> Void in
            weak var weakSelf:ChildRegistrationViewController?
            weakSelf = self
            self.prepareVideo(info[UIImagePickerControllerMediaURL] as? NSURL) { (result:String?) -> Void in
                if result != nil && weakSelf != nil {
                    weakSelf!.videoFile = result!
                    if weakSelf!.needSend == true {self.send()}
                }
            }

        }
    }
    func checkData() -> (result:Bool, error:String?, field:UIView?){
        if name.text == nil || name.text?.characters.count == 0{
            return (false, "Введите ФИО", name)
        }
        if age.text == nil || age.text?.characters.count == 0{
            return (false, "Введите возраст", age)
        }
        if address.text == nil || address.text?.characters.count == 0{
            return (false, "Введите адрес", address)
        }
        if prize.text == nil || prize.text?.characters.count == 0{
            return (false, "Введите описание подарка", prize)
        }
        return (true, nil, nil)
    }
    @IBAction func sendLetter() {
        let checkDataResult = self.checkData()
        needSend = checkDataResult.result
        if !needSend {
            let alert : UIAlertController! = UIAlertController(title: "Ошибка", message: checkDataResult.error, preferredStyle: UIAlertControllerStyle.Alert)
            
            let defaultAction : UIAlertAction! = UIAlertAction(title: "Хорошо", style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction) -> Void in
                checkDataResult.field!.becomeFirstResponder()
            })
            alert.addAction(defaultAction)
            self.presentViewController(alert, animated: true, completion: { () -> Void in
                
            })
        } else if videoFile != nil {
            self.send()
        } else {
            needSend = false
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

}

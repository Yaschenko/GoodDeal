//
//  ChildRegistrationViewController.swift
//  GoodDeal
//
//  Created by Yurii on 12/12/15.
//  Copyright © 2015 Nostris. All rights reserved.
//

import UIKit
import MobileCoreServices

class ChildRegistrationViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet var name:UITextField!
    @IBOutlet var age:UITextField!
    @IBOutlet var address:UITextField!
    @IBOutlet var prize:UITextView!
    @IBOutlet var imagePickerButton:UIButton!
    @IBOutlet var bottomConstraint:NSLayoutConstraint!
    var videoFile:String?
    lazy var imagePicker:UIImagePickerController! = {
        let picker:UIImagePickerController! = UIImagePickerController()
        picker.sourceType = UIImagePickerControllerSourceType.Camera
        picker.mediaTypes = [kUTTypeMovie as String]
        picker.allowsEditing = false
        picker.delegate = self
        return picker
    }()
    var keyboard:Bool!
    let bottomConstraintDefaultValue:CGFloat! = 8
    
    override func viewDidLoad() {
        super.viewDidLoad()
        keyboard = false
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShowNotification:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHideNotification:", name: UIKeyboardWillHideNotification, object: nil)
        prize.layer.borderWidth = 1
        prize.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).CGColor
        prize.layer.masksToBounds = true
        prize.layer.cornerRadius = 5
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func keyboardWillShowNotification(notification:NSNotification) {
        keyboard = true
        let info:[NSObject : AnyObject]? = notification.userInfo
        if info == nil {return;}
        let kbSize:CGSize = (info![UIKeyboardFrameEndUserInfoKey]?.CGRectValue.size)!
        bottomConstraint.constant = bottomConstraintDefaultValue + kbSize.height
        self.view.layoutIfNeeded()
        
    }
    func keyboardWillHideNotification(notification:NSNotification) {
        keyboard = false
        bottomConstraint.constant = bottomConstraintDefaultValue
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
    @IBAction func showImagePickerController() {
        self.view.endEditing(true)
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            self.presentViewController(self.imagePicker, animated: true, completion: { () -> Void in
                
            })
        }
        else {
            let alert : UIAlertController! = UIAlertController(title: "Ошибка", message: "Не получилось загрузить камеру", preferredStyle: UIAlertControllerStyle.Alert)
            
            let defaultAction : UIAlertAction! = UIAlertAction(title: "Хорошо", style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction) -> Void in
            })
            alert.addAction(defaultAction)
            self.presentViewController(alert, animated: true, completion: { () -> Void in
                
            })
        }
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true) { () -> Void in
            
        }
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
//        print(info.description)
        
        videoFile = info[UIImagePickerControllerMediaURL] as? String
        if videoFile != nil {
            imagePickerButton.setTitle("Изменить видео обращение", forState: UIControlState.Normal)
        }
        self.dismissViewControllerAnimated(true) { () -> Void in
            
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

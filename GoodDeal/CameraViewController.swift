//
//  CameraViewController.swift
//  GoodDeal
//
//  Created by Yurii on 12/13/15.
//  Copyright © 2015 Nostris. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVFoundation

class CameraViewController: BaseViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var imagePickerButton:UIButton?

    var videoFile:String?
    lazy var imagePicker:UIImagePickerController! = {
        let picker:UIImagePickerController! = UIImagePickerController()
        picker.sourceType = UIImagePickerControllerSourceType.Camera
        picker.mediaTypes = [kUTTypeMovie as String]
        picker.allowsEditing = false
        picker.delegate = self
        picker.videoQuality = UIImagePickerControllerQualityType.TypeMedium
        picker.videoMaximumDuration = 30
        return picker
    }()
    override func viewDidLoad() {
        super.viewDidLoad()

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
    func createTempDirectory() -> String {
        let tempDirectoryTemplate:String = NSTemporaryDirectory().stringByAppendingString("file\(Int(NSDate().timeIntervalSince1970)).mp4")
        return tempDirectoryTemplate
    }
    func createTempDirectoryWithExtantion(extantion:String!) -> String {
        let tempDirectoryTemplate:String = NSTemporaryDirectory().stringByAppendingString("file\(Int(NSDate().timeIntervalSince1970)).\(extantion)")
        return tempDirectoryTemplate
    }
    func prepareVideo(url:NSURL?, callback:(result:String?)->Void) {
        if url != nil {
            weak var weakSelf:CameraViewController?
            weakSelf = self
            let exportSession:AVAssetExportSession = AVAssetExportSession(asset: AVAsset(URL: url!), presetName: AVAssetExportPresetMediumQuality)!
            exportSession.outputFileType = AVFileTypeMPEG4
            exportSession.outputURL = NSURL(fileURLWithPath: self.createTempDirectory())
            exportSession.exportAsynchronouslyWithCompletionHandler({ () -> Void in
                switch exportSession.status {
                case AVAssetExportSessionStatus.Completed:
                    if weakSelf != nil {
                        callback(result: exportSession.outputURL?.absoluteString)
                    }
                    break
                default:
                    callback(result: nil)
                    break
                    
                }
            })
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true) { () -> Void in
            
        }
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

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        videoFile = nil
//        imagePickerButton.setTitle("Изменить видео обращение", forState: UIControlState.Normal)
        self.dismissViewControllerAnimated(true) { () -> Void in
            weak var weakSelf:CameraViewController?
            weakSelf = self
            self.prepareVideo(info[UIImagePickerControllerMediaURL] as? NSURL) { (result:String?) -> Void in
                if result != nil && weakSelf != nil {
                    weakSelf!.videoFile = result!
                }
            }
            
        }
    }
}

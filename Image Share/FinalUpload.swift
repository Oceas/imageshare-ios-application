//
//  FinalUpload.swift
//  Image Share
//
//  Created by Deni on 6/11/16.
//  Copyright © 2016 ImageShare. All rights reserved.
//

import Foundation
import UIKit
import Photos
import Alamofire
import MBProgressHUD

class FinalUpload: UIViewController{
    var PhotosObjects = [Photoz]()
    var dataRecieved = [PHAsset]()
    var i:Int = 0
    var queue:dispatch_queue_t?
    var progcount:Int = 0
    var loadingNotification:MBProgressHUD = MBProgressHUD()
    
    
    @IBOutlet weak var DisplayPhoto: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let swipeRight = UISwipeGestureRecognizer()
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        swipeRight.addTarget(self, action: #selector (FinalUpload.Swipe_Right))
        let swipeLeft = UISwipeGestureRecognizer()
        swipeLeft.addTarget(self, action: #selector (FinalUpload.Swipe_Left))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        
        DisplayPhoto.addGestureRecognizer(swipeRight)
        DisplayPhoto.addGestureRecognizer(swipeLeft)
        DisplayPhoto.userInteractionEnabled = true
        for _ in 0 ... ((dataRecieved.count) - 1){
            if let temp = dataRecieved.popLast(){
            PhotosObjects.append(Photoz(Asset: temp))
            }
        }
        DisplayPhoto.image = UIImage(data: (PhotosObjects[i].PJpeg()))
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
    }
    @IBAction func Back(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func ServerStuff(sender: UIBarButtonItem) {
        self.loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        self.loadingNotification.mode = MBProgressHUDMode.Determinate
        self.loadingNotification.labelText = "Uploading"
        self.loadingNotification.dimBackground = true
        self.loadingNotification.progress = 0.00
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { [unowned self] in
            for num in 0 ... (self.PhotosObjects.count - 1){
        self.FileTransfer(self.PhotosObjects[num].PJpeg(),date:num.description)
            }
        }
    }
    
    func FileTransfer(Photoobject:NSData,date:String){
        if let userID = KeychainWrapper.stringForKey("UserID"){
            Alamofire.upload(.POST, "http://cop4331project.tk/android_api/uploadimage.php", multipartFormData:{
                multipartFormData in
                multipartFormData.appendBodyPart(data: userID.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name :"userId")
                    multipartFormData.appendBodyPart(data: Photoobject, name: "fileToUpload[]",
                    fileName: ("\(date).jpg"), mimeType: "image/jpeg")
                }, encodingCompletion: { encodingResult in
                    switch encodingResult {
                    case .Success(let upload, _, _):
                        upload.responseJSON { response in
                            //debugPrint(response)
                            if response.result.isSuccess{
                            dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                                self.progcount += 1
                                self.loadingNotification.progress = (Float(self.progcount)/Float(self.PhotosObjects.count))
                                if (self.progcount == self.PhotosObjects.count){
                                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                                    self.progcount = 0
                                    let alert = UIAlertController(title: "Success!", message: "\(self.PhotosObjects.count) Photos Uploaded", preferredStyle: .Alert)
                                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:{
                                        (data) -> Void in
                                        self.performSegueWithIdentifier("UploadComplete", sender: self)
                                    }))
                                    self.presentViewController(alert, animated: true, completion:nil)
                                }
                            }
                        }
                            else{
                                dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                                    self.loadingNotification.progress = 0.0
                                    MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                                    let alert = UIAlertController(title: "Connection Lost!", message: "Error! \(self.progcount) Photos Uploaded", preferredStyle: .Alert)
                                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:nil))
                                    self.presentViewController(alert, animated: true, completion:nil)
                                }
                            }
                    }
                    case .Failure(_)://let encodingError):
                        //print(encodingError)
                        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                        self.loadingNotification.progress = 0.0
                        MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                        let alert = UIAlertController(title: "Connection Lost!", message: "Error! \(self.progcount) Photos Uploaded", preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:nil))
                        self.presentViewController(alert, animated: true, completion:nil)
                        }
                    }
                }
            )
        }
    }
    
    func Swipe_Right(){
        if (self.i + 1) <= (PhotosObjects.count-1){
            self.i += 1
        }
        else{
            self.i = 0
        }
        self.changePhoto()
    }
    
    func Swipe_Left(){
        if (self.i - 1) >= 0{
            self.i -= 1
        }
        else{
            self.i = (PhotosObjects.count - 1)
        }
        self.changePhoto()
    }
    
    func changePhoto(){
        DisplayPhoto.image = UIImage(data: (PhotosObjects[i].PJpeg()))
    }
    

}

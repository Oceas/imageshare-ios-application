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

class FinalUpload: UIViewController, selectAlbumDelegate, UIPopoverPresentationControllerDelegate{
    var PhotosObjects = [Photoz]()
    var dataRecieved = [PHAsset]()
    var photoData = [NSData]()
    var i:Int = 0
    var queue:dispatch_queue_t?
    var progcount:Int = 0
    var loadingNotification:MBProgressHUD = MBProgressHUD()
    var AlbumRecieved:NSString?
    var request: Alamofire.Request?
    
    @IBOutlet weak var Captions: UITextView!
    
    @IBOutlet weak var DisplayPhoto: UIImageView!
    
    var imageOrientation:UIImageOrientation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.imageOrientation=DisplayPhoto.image?.imageOrientation
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Upload", style: .Plain  , target: self, action: #selector (FinalUpload.UploadComplete(_:)))
        self.Captions.hidden=true
        let swipeRight = UISwipeGestureRecognizer()
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        swipeRight.addTarget(self, action: #selector (FinalUpload.Swipe_Right))
        let swipeLeft = UISwipeGestureRecognizer()
        swipeLeft.addTarget(self, action: #selector (FinalUpload.Swipe_Left))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        
        DisplayPhoto.addGestureRecognizer(swipeRight)
        DisplayPhoto.addGestureRecognizer(swipeLeft)
        DisplayPhoto.userInteractionEnabled = true
        for z in 0 ... ((dataRecieved.count) - 1){
            if let temp = dataRecieved.popLast(){
            PhotosObjects.append(Photoz(Asset: temp))
            self.photoData.append(PhotosObjects[z].PJpeg())
            }
        }
        //DisplayPhoto.
        DisplayPhoto.image=UIImage(data: (PhotosObjects[i].PJpeg()))?.kf_normalizedImage()
        //DisplayPhoto.image?.kf_normalizedImage() //= UIImage(data: (PhotosObjects[i].PJpeg()))
        if let cap = self.PhotosObjects[i].Comments{
            self.Captions.text = cap
        }else{
            self.Captions.text = "Enter Caption!"
        }
    }
    /*
    func correctlyOrientedImage() -> UIImage {
        if self.imageOrientation == UIImageOrientation.Up {
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.drawInRect(CGRectMake(0, 0, self.size.width, self.size.height))
        var normalizedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return normalizedImage;
    }
    */
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
    }
    
    @IBAction func AddCaption(sender: AnyObject) {
        self.Captions.hidden = !self.Captions.hidden.boolValue
    }
    
    func UploadComplete(sender:UIBarButtonItem){
        if let cap = self.PhotosObjects[i].Comments{
            if (self.Captions.text != cap){
                self.PhotosObjects[i].Comments = self.Captions.text
            }
        }
        else{
            self.PhotosObjects[i].Comments = self.Captions.text
        }
        self.performSegueWithIdentifier("PopTable", sender: sender)
    }
    
    

    
    func Swipe_Right(){
        if let cap = self.PhotosObjects[i].Comments{
            if (self.Captions.text != cap){
                self.PhotosObjects[i].Comments = self.Captions.text
            }
        }
        else{
            self.PhotosObjects[i].Comments = self.Captions.text
        }
        if (self.i + 1) <= (PhotosObjects.count-1){
            self.i += 1
        }
        else{
            self.i = 0
        }
        self.changePhoto()
    }
    
    func Swipe_Left(){
        if let cap = self.PhotosObjects[i].Comments{
            if (self.Captions.text != cap){
                self.PhotosObjects[i].Comments = self.Captions.text
            }
        }
        else{
            self.PhotosObjects[i].Comments = self.Captions.text
        }
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
        if let cap = self.PhotosObjects[i].Comments{
            self.Captions.text = cap
        }else{
            self.Captions.text = "Enter Caption!"
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "PopTable"
        {
            let vc = segue.destinationViewController as! selectAlbum
            vc.delegate = self
            
            let controller = vc.popoverPresentationController
            
            if controller != nil
            {
                controller?.delegate = self
            }
        }
    }
    
    func saveText(strText:NSString){
        print(strText)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(FinalUpload.cancelupload))
        self.loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        self.loadingNotification.mode = MBProgressHUDMode.Determinate
        self.loadingNotification.labelText = "Uploading"
        self.loadingNotification.detailsLabelText = "Tap to Cancel"
        self.loadingNotification.dimBackground = true
        self.loadingNotification.progress = 0.00
        self.loadingNotification.addGestureRecognizer(tapGesture)
        self.newUpload(strText as String)
        /*
         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)){ [unowned self] in
        for PhotosOBJS in self.PhotosObjects{
               self.FileTransfer(PhotosOBJS.PJpeg(),date:self.i.description,albumId: strText as String)
                }
            }
 */
        }

    func cancelupload(){
        self.request?.cancel()
        self.loadingNotification.progress = 0
        MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
        let alert = UIAlertController(title: "Upload Stopped", message: "User Stopped Upload", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:nil))
        self.presentViewController(alert, animated: true, completion:nil)
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    func delay(delay: Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    func newUpload(albumId:String){
        if let userID = KeychainWrapper.stringForKey("UserID"){
             Alamofire.upload(.POST, "http://imageshare.io/api/v1/uploadimage.php", multipartFormData:{
                multipartFormData in
                multipartFormData.appendBodyPart(data: userID.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name :"userId")
                multipartFormData.appendBodyPart(data: albumId.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name :"albumId")
                
                for PhotosOBJ in self.PhotosObjects{
                    let photo_data = PhotosOBJ.PJpeg()
                    if (photo_data.length > 0) {
                multipartFormData.appendBodyPart(data:photo_data, name: "fileToUpload[]",
                    fileName:("\(photo_data.length).jpg"), mimeType: "image/jpeg")
                    }
                }
                
                }, encodingCompletion: { encodingResult in
                    switch encodingResult {
                    case .Success(let upload, _, _):
                        upload.validate()
                    self.request = upload
                        upload.progress({bytesWritten, totalBytesWritten, totalBytesExpectedToWrite in
                            self.loadingNotification.progress = (Float(totalBytesWritten)/Float(totalBytesExpectedToWrite))
                            if (totalBytesWritten == totalBytesExpectedToWrite){
                                dispatch_async(dispatch_get_main_queue()) {
                                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                                let alert = UIAlertController(title: "Success!", message: "Photos Succesfully Uploaded", preferredStyle: .Alert)
                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:{
                                    (data) -> Void in
                                    self.performSegueWithIdentifier("UploadComplete", sender: self)
                                }))
                                self.presentViewController(alert, animated: true, completion:nil)
                                }
                            }
                    })
                        upload.responseJSON { response in
                            debugPrint(response)
                        }
                    case .Failure(let encodingError):
                        print(encodingError)
                        dispatch_async(dispatch_get_main_queue()) {
                        MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                        }
                    }
            })
        }
    }
}
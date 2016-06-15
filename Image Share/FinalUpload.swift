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


class FinalUpload: UIViewController {
    var PhotosObjects = [Photoz]()
    var dataRecieved = [PHAsset]()
    var i:Int = 0
    var queue:dispatch_queue_t?
    
    @IBOutlet weak var DisplayPhoto: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
          print(dataRecieved.count)
        
        
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
        print(PhotosObjects.count)
        DisplayPhoto.image = UIImage(data: (PhotosObjects[i].PJpeg()))
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
    }
    @IBAction func Back(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func ServerStuff(sender: UIBarButtonItem) {
         self.queue = dispatch_queue_create("PhotoMover", DISPATCH_QUEUE_CONCURRENT)
         dispatch_async(self.queue!, {
        self.FileTransfer()
        })
    }
    
    func FileTransfer(){
        print("done")
        if let userID = KeychainWrapper.stringForKey("UserID"){
            print(userID)
            Alamofire.upload(.POST, "http://cop4331project.tk/android_api/uploadimage.php", multipartFormData:{
                multipartFormData in
                multipartFormData.appendBodyPart(data: userID.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name :"userId")
                //multipartFormData.appendBodyPart(data: self.PhotosObjects[0].PJpeg(), name: "fileToUpload[]")
                multipartFormData.appendBodyPart(data: self.PhotosObjects[0].PJpeg(), name: "fileToUpload[]",
                    fileName: "image.jpg", mimeType: "image/jpeg")
                }, encodingCompletion: { encodingResult in
                    switch encodingResult {
                    case .Success(let upload, _, _):
                        upload.responseJSON { response in
                            debugPrint(response)
                        }
                    case .Failure(let encodingError):
                        print(encodingError)
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

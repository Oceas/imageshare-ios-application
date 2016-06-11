//
//  Photoz.swift
//  Image Share
//
//  Created by Deni on 6/10/16.
//  Copyright © 2016 ImageShare. All rights reserved.
//

import Foundation
import UIKit
import Photos
import CoreLocation

class Photoz: NSObject {

    private var timeStamp:NSDate?
    private var Asset:PHAsset?
    private var Comments:String?
    
    init (Asset:PHAsset, Comments:String) {
        self.Asset = Asset
        self.Comments = Comments
    }
    
    func displayAlertMessage(alertTitle:String, alertDescription:String) -> Void {
        let errorAlert = UIAlertView(title:alertTitle, message:alertDescription, delegate:nil, cancelButtonTitle:"OK")
        errorAlert.show()
    }
    
    func PLocation() -> CLLocation{
        return (self.Asset?.location)!
    }
    
    func Pcomment() -> String{
        return self.Comments!
    }
    
    func Ptime() -> String{
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter.stringFromDate(self.timeStamp!)
    }
    
    func PJpeg() -> NSData{
        let imageRequestOptions = PHImageRequestOptions()
        imageRequestOptions.networkAccessAllowed = true
        imageRequestOptions.synchronous = true
        imageRequestOptions.deliveryMode = .HighQualityFormat
        imageRequestOptions.resizeMode = .Exact
        var Picturedata:NSData?
        
        PHImageManager.defaultManager().requestImageDataForAsset(self.Asset!, options: imageRequestOptions, resultHandler: {(data,dataUti,orientation,info) -> Void in
            Picturedata = data
            })
        return Picturedata!
    }
}








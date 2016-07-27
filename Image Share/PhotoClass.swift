//
//  PhotoClass.swift
//  Image Share
//
//  Created by Deni on 7/17/16.
//  Copyright © 2016 ImageShare. All rights reserved.
//

import Foundation
import Alamofire
import Haneke
import UIKit
import Photos
import CoreLocation


class PhotoClass:NSObject{
    
    private var PhotoURL:String!
    private var PhotoName:String!
    private var PhotoDesc:String!
    private var PhotoID:String!
    
    init(PhotoURL:String, PhotoName:String, PhotoDesc:String,PhotoID:String){
        self.PhotoURL = PhotoURL
        self.PhotoName = PhotoName
        self.PhotoDesc = PhotoDesc
        self.PhotoID = PhotoID
    }
    
    func getphotoID() -> String{
        return self.PhotoID
    }
    
    func Updatedesc(PDesc:String){
        self.PhotoDesc = PDesc
    }
    
    func UpdateName(PName:String){
        self.PhotoName = PName
    }
    
    func getDesc() -> String{
        return self.PhotoDesc
    }
    
    func getName() -> String{
        return self.PhotoName
    }
    
    func getURL() -> String{
        return self.PhotoURL
    }
    
}
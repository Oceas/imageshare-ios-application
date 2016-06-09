//
//  PhotoAlbums.swift
//  Image Share
//
//  Created by Deni on 6/8/16.
//  Copyright © 2016 ImageShare. All rights reserved.
//

import Foundation
import Photos
import CoreData
import CoreImage

class PhotoAlbums{
    
    var timeStamp:String?
    var Asset:PHAsset?
    var Comments:String?
    
    init (Asset:PHAsset,timeStamp:String, Comments:String) {
        self.Asset = Asset
        self.timeStamp = timeStamp
        self.Comments = Comments
    }
    
}
//
//  CellManager.swift
//  Image Share
//
//  Created by Deni on 7/13/16.
//  Copyright © 2016 ImageShare. All rights reserved.
//


import UIKit
import Alamofire
import Photos


class CellManager{
    
    
    static let sharedManager = CellManager()
    
    private var cachedIndices = NSIndexSet()
    let cachePreheatSize = 1
    var imageCache  = PHCachingImageManager()
    var targetSize = CGSize(width: 125, height: 125)
    var contentMode = PHImageContentMode.AspectFill
    
    
    func updateVisibleCells(visibleCells: [NSIndexPath],images: [PHAsset]) {
        let updatedCache = NSMutableIndexSet()
        for path in visibleCells {
            updatedCache.addIndex(path.item)
        }
        let minCache = max(0, updatedCache.firstIndex - cachePreheatSize)
        let maxCache = min(images.count - 1, updatedCache.lastIndex + cachePreheatSize)
        updatedCache.addIndexesInRange(NSMakeRange(minCache, maxCache - minCache + 1))
        
        // Which indices can be chucked?
        self.cachedIndices.enumerateIndexesUsingBlock {
            index, _ in
            if !updatedCache.containsIndex(index) {
                let asset = images[index]
                self.imageCache.stopCachingImagesForAssets([asset], targetSize: self.targetSize, contentMode: self.contentMode, options: nil)

            }
        }
        
        // And which are new?
        updatedCache.enumerateIndexesUsingBlock {
            index, _ in
            if !self.cachedIndices.containsIndex(index) {
                let asset = images[index]
                self.imageCache.startCachingImagesForAssets([asset], targetSize: self.targetSize, contentMode: self.contentMode, options: nil)
            }
        }
        cachedIndices = NSIndexSet(indexSet: updatedCache)
    }

}
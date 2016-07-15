//
//  CellManager.swift
//  Image Share
//
//  Created by Deni on 7/13/16.
//  Copyright © 2016 ImageShare. All rights reserved.
//


import UIKit
import Alamofire
import AlamofireImage
import Photos


class CellManager{
    
    
    static let sharedManager = CellManager()
    
    let decoder = DecodeUtility()
    let photoCache = AutoPurgingImageCache(
        memoryCapacity: 100 * 1024 * 1024,
        preferredMemoryUsageAfterPurge: 60 * 1024 * 1024
    )
    private var cachedIndices = NSIndexSet()
    let cachePreheatSize = 1
    var imageCache  = PHCachingImageManager()
    var targetSize = CGSize(width: 125, height: 125)
    var contentMode = PHImageContentMode.AspectFill
    
    
    func getNetworkImage(urlString: String, completion: (UIImage -> Void)) -> (RequestImages) {
        let queue = decoder.queue.underlyingQueue
        let request = Alamofire.request(.GET, urlString)
        let imageRequest = RequestImages(request: request)
        imageRequest.request.response(
            queue: queue,
            responseSerializer: Request.imageResponseSerializer(),
            completionHandler: { response in
                guard let image = response.result.value else {
                    return
                }
                let decodeOperation = self.decodeImage(image) { image in
                    completion(image)
                    self.cacheImage(image, urlString: urlString)
                }
                imageRequest.decodeOperation = decodeOperation
            }
        )
        return imageRequest
    }
    
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
    
    
    func decodeImage(image: UIImage, completion: (UIImage -> Void)) -> DecodeOperation {
        let decodeOperation = DecodeOperation(image: image, decoder: self.decoder, completion: completion)
        self.decoder.queue.addOperation(decodeOperation)
        return decodeOperation
    }
    
    func cacheImage(image: Image, urlString: String) {
        photoCache.addImage(image, withIdentifier: urlString)
    }
    
    func cachedImage(urlString: String) -> Image? {
        return photoCache.imageWithIdentifier(urlString)
    }
}
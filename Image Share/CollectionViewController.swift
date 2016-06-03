//
//  CollectionViewController.swift
//  Image Share
//
//  Created by Deni on 5/27/16.
//  Copyright © 2016 ImageShare. All rights reserved.
//

import UIKit
import Photos
import CoreData
import CoreImage

class CollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    var dataPassed:PHAssetCollection?
    var photos:Array<PHAsset> = Array <PHAsset>()
    
    @IBOutlet weak var Collection: UICollectionView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        Collection.dataSource = self
        Collection.delegate = self

        let fetchOptions = PHFetchOptions()
        let album = PHAsset.fetchAssetsInAssetCollection(dataPassed!, options: fetchOptions)
        
        for i in 0 ... (album.count - 1){
            photos.append(album.objectAtIndex(i) as! PHAsset)
        }
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        let orientation: UIInterfaceOrientationMask = [UIInterfaceOrientationMask.Portrait, UIInterfaceOrientationMask.Portrait]
        return orientation
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    /*
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return photos.count
    }
    */
    
    /*
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let kWhateverHeightYouWant = 110
        return CGSizeMake(CGFloat(kWhateverHeightYouWant), CGFloat(kWhateverHeightYouWant))
    }
    */
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell2", forIndexPath: indexPath) as! CollectionViewCell
        let data = photos[indexPath.row]
        
        let imageRequestOptions = PHImageRequestOptions()
        imageRequestOptions.networkAccessAllowed = true
        imageRequestOptions.synchronous = true
        imageRequestOptions.deliveryMode = .FastFormat
        imageRequestOptions.resizeMode = .Exact
        
        PHImageManager.defaultManager().requestImageForAsset(
            data,
            targetSize: (cell.thumb?.intrinsicContentSize())!,
            contentMode: .AspectFill,
            options: imageRequestOptions,
            resultHandler: { (img, info) -> Void in
                cell.thumb?.image = img
        })

        return cell
    }

    // MARK: UICollectionViewDelegate
    
     func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
     return true
     }

    
    /*
     // Uncomment this method to specify if the specified item should be selected
     override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
     override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
     return false
     }
     
     override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
     return false
     }
     
     override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
     
     }
     */

}

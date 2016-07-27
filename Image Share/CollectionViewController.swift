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

class CollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    var dataPassed:PHAssetCollection?
    var photos:Array<PHAsset> = Array <PHAsset>()
    var SelectOption:Bool = false
    var Backbutton:UIBarButtonItem?
    var Selectbutton:UIBarButtonItem?
    var Cancelbutton:UIBarButtonItem?
    var Uploadbutton:UIBarButtonItem?
    var Updateitems:Array<NSIndexPath> = Array<NSIndexPath>()
    var popimage:UIImage?
    let dismissButton:UIButton! = UIButton(type:.Custom)
    var SelectedPhotos = [PHAsset]()
    
    var Zoom:NSIndexPath?{
        didSet{
            
            if Zoom != nil {
                let data = photos[(Zoom?.row)!]
            
            let imageRequestOptions = PHImageRequestOptions()
            imageRequestOptions.networkAccessAllowed = true
            imageRequestOptions.synchronous = true
            imageRequestOptions.deliveryMode = .HighQualityFormat
            imageRequestOptions.resizeMode = .Exact
            
            let size = self.view.frame.width
            let dsize = CGSizeMake(size, self.view.frame.height)
            
            PHImageManager.defaultManager().requestImageForAsset(
                data,
                targetSize: dsize,
                contentMode: .AspectFill,
                options: imageRequestOptions,
                resultHandler: { (img, info) -> Void in
                    self.popimage = img
            })

            view.backgroundColor = UIColor(
                red: 0.8,
                green: 0.5,
                blue: 0.2,
                alpha: 1.0)
            //add the image
            if popimage != nil{
                let myImageView = UIImageView(image: popimage)
                myImageView.bounds = self.view.bounds
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(CollectionViewController.closePop))
                myImageView.addGestureRecognizer(tapGesture)
                myImageView.userInteractionEnabled = true
                myImageView.tag = 100
                self.view.addSubview(myImageView)
            
                }
            }
        }
    }
    


    @IBOutlet weak var Collection: UICollectionView!


    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = dataPassed?.localizedTitle
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Select", style: .Plain, target: self, action: #selector(CollectionViewController.Selecting(_:)))
        Backbutton = self.navigationItem.backBarButtonItem
        Selectbutton = self.navigationItem.rightBarButtonItem
        //self.NavBar.title = dataPassed?.localizedTitle
        //Backbutton = self.NavBar.leftBarButtonItem
        //Selectbutton = self.NavBar.rightBarButtonItem
        Uploadbutton = UIBarButtonItem(title: "Upload", style: .Plain, target: self, action: #selector(CollectionViewController.Uploading(_:)))
        Cancelbutton = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: #selector(CollectionViewController.Canceling(_:)))
        Collection.dataSource = self
        Collection.delegate = self
        Collection.scrollEnabled = true
        Collection.allowsMultipleSelection = SelectOption
        let fetchOptions = PHFetchOptions()
        let album = PHAsset.fetchAssetsInAssetCollection(dataPassed!, options: fetchOptions)
        
        //self.NavBar.rightBarButtonItem?.action = #selector(CollectionViewController.Selecting(_:))
        
        
        for i in 0 ... (album.count - 1){
            photos.append(album.objectAtIndex(i) as! PHAsset)
        }
    }
    
    /*
    override func viewDidAppear(animated: Bool) {
    Collection.reloadData()
    
    }
 */
    override func viewWillLayoutSubviews() {
        super.viewDidLayoutSubviews()
       Collection.collectionViewLayout.invalidateLayout()
    }
    
    func closePop(){
        if let viewWithTag = self.view.viewWithTag(100) {
            viewWithTag.removeFromSuperview()
            Zoom = nil
        }
    }
    
    func Uploading(sender: UIBarButtonItem) {
        if SelectedPhotos.count == 0 {
            let alert = UIAlertController(title: "Error", message: "No Photos Selected", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler:nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else {
        performSegueWithIdentifier("toUpload", sender: SelectedPhotos)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "toUpload") {
            let svc = segue.destinationViewController as! FinalUpload
            svc.dataRecieved = self.SelectedPhotos
        }
    }
    
    func Canceling(sender: UIBarButtonItem) {
        SelectOption = false
        self.navigationItem.leftBarButtonItem = Backbutton
        self.navigationItem.rightBarButtonItem = Selectbutton
        //NavBar.leftBarButtonItem = Backbutton
        //NavBar.rightBarButtonItem = Selectbutton
        Collection.allowsMultipleSelection = SelectOption
        for indexPath in Collection.indexPathsForSelectedItems()!{
            self.Collection.deselectItemAtIndexPath(indexPath, animated: false)
        }
        Collection.selectItemAtIndexPath(nil, animated: true, scrollPosition: .None)
        //self.Collection.reloadData()
    }
    func Selecting(sender: UIBarButtonItem){
        SelectOption = true
        self.navigationItem.leftBarButtonItem = Cancelbutton
        self.navigationItem.rightBarButtonItem = Uploadbutton
        //NavBar.leftBarButtonItem = Cancelbutton
        //NavBar.rightBarButtonItem = Uploadbutton
        Collection.allowsMultipleSelection = SelectOption
        //self.Collection.reloadData()
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
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let picDimension = self.view.frame.size.width/3
        return CGSizeMake(picDimension, picDimension)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    func collectionView(collectionView: UICollectionView,
                          layout collectionViewLayout: UICollectionViewLayout,
                                 minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat{
        return 0
    }
    
    func collectionView(collectionView: UICollectionView,
                          layout collectionViewLayout: UICollectionViewLayout,
                                 minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat{
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
 
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell2", forIndexPath: indexPath) as! CollectionViewCell
        let data = photos[indexPath.row]
        
        cell.imageManager = CellManager.sharedManager.imageCache
        cell.imageAsset = data
        cell.selectedBackgroundView?.addSubview(UIImageView.init(image: UIImage.init(named: "Selected")))

        return cell
    }

    // MARK: UICollectionViewDelegate
 

    
    
     // Uncomment this method to specify if the specified item should be selected
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        if SelectOption{
            return true
        }
        if Zoom == indexPath{
            Zoom = nil
        }
        else{
          Zoom = indexPath
        }
        return false
     }
    
    
    /*
     // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
     override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
     return false
     }
 */

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if SelectOption {
            let ph_image = photos[indexPath.row]
            SelectedPhotos.append(ph_image)
        }
        
    }
    
    func collectionView(collectionView: UICollectionView,
                        didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        
        if SelectOption {
            if let foundIndex = find(SelectedPhotos, rAsset: photos[indexPath.row]) {
                SelectedPhotos.removeAtIndex(foundIndex)
            }
        }
    }
    
    func find(Assets:Array<PHAsset>,rAsset:PHAsset)-> Int?{

      return Assets.indexOf(rAsset)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let indexPaths = Collection.indexPathsForVisibleItems()
        CellManager.sharedManager.updateVisibleCells(indexPaths as [NSIndexPath]!,images:self.photos)
    }

}

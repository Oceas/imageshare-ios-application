//
//  StoriesTab.swift
//  Image Share
//
//  Created by Deni on 7/21/16.
//  Copyright © 2016 ImageShare. All rights reserved.
//

import UIKit
import Alamofire
import Kingfisher

class MomentsTab: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var StoryCollection: UICollectionView!

    var AlbumCollection = [NSString]()
    var cellData = [CellContent]()
    
    struct CellContent {
        var ID:String!
        var PhotoURL:NSString!
        var ActualID:String!
        init(ID:String,PhotoURL:NSString,ActualID:String){
            self.ID = ID
            self.PhotoURL = PhotoURL
            self.ActualID = ActualID
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cellData.removeAll()
        self.AlbumCollection.removeAll()
        self.StoryCollection.delegate = self
        self.StoryCollection.dataSource = self
        self.UserAlbums(){_ in
            self.StoryCollection.reloadData()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        self.cellData.removeAll()
        self.AlbumCollection.removeAll()
    }
    func clearLoggedinFlagInUserDefaults() {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.removeObjectForKey("userLoggedIn")
        defaults.synchronize()
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        let orientation: UIInterfaceOrientationMask = [UIInterfaceOrientationMask.Portrait, UIInterfaceOrientationMask.Portrait]
        return orientation
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.cellData.count
    }
    
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Story", forIndexPath: indexPath) as! StoryCell
        
        let cells = cellData[indexPath.row]
        let URLString = cells.PhotoURL
        let URL = NSURL(string:URLString as String)!
        //cell.coverphoto.hnk_setImageFromURL(URL)
        //cell.coverphoto.hnk_setImageFromURL(URL, format: Format<UIImage>(name: "original"))
        cell.coverphoto.kf_setImageWithURL(URL)
        cell.caption.text = cells.ID
        
        return cell
    }
    
    
    func UserAlbums(completion: (result: String) -> Void){
        var count = 0
        let queue = dispatch_queue_create("com.imageshare.getalbums", DISPATCH_QUEUE_SERIAL)
        if let USERID = KeychainWrapper.stringForKey("UserID"){
            Alamofire.request(.POST, "http://imageshare.io/api/v1/getalbums.php", parameters: ["userId":USERID]) .responseJSON { response in
                if let jsn = response.result.value {
                    if let returnval = jsn as? [String:AnyObject]{
                        if let AlbumInfo = returnval["albums"] as? NSArray{
                            for albums in AlbumInfo{
                                dispatch_async(queue) { () -> Void in
                                if let album = albums as? [String:AnyObject]{
                                    if let albumID = album["albumId"] as? NSString{
                                        if let albumz_name = album["albumName"] as? String {
                                            self.albumCover(albumID,completion:{fifth in
                                                dispatch_async(dispatch_get_main_queue(), {
                                                    count += 1
                                                })
                                                if fifth != "nothing"{
                                                    self.populateData(albumz_name, datatwo: fifth,datathree: albumID as String)
                                                    dispatch_async(dispatch_get_main_queue(), {
                                                        if count == AlbumInfo.count{
                                                            completion(result: "done")
                                                        }
                                                    })
                                                }
                                                else{
                                                    dispatch_async(dispatch_get_main_queue(), {
                                                        if count == AlbumInfo.count{
                                                            completion(result: "done")
                                                        }
                                                    })
                                                }
                                            })
                                        }
                                    }
                                }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func albumCover(idAlbum:NSString,completion: (result: String) -> Void){
        if let USERID = KeychainWrapper.stringForKey("UserID"){
            //for album in self.AlbumCollection{
            Alamofire.request(.POST, "http://imageshare.io/api/v1/getalbumdetail.php", parameters: ["userId":USERID,"albumId":idAlbum]) .responseJSON { response in // 1
                if let jsn = response.result.value {
                    //print(jsn)
                    if let first = jsn as? [String:AnyObject]{
                        if let second = first["album"] as? NSDictionary{
                            // print(second)
                            if let third = second["images"] as? NSArray{
                                //print(third)
                                if let fourth = third.firstObject as? NSDictionary{
                                    if let fifth = fourth["imageLocation"] as? NSString{
                                        //print(fifth)
                                        completion(result: fifth as String)
                                    }
                                    
                                }else{completion(result:"nothing")}
                                
                            }
                        }
                    }
                }
                // print(self.cellData.count)
            }
            //}
            
        }
    }

    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("PhotoAlbum", sender: cellData[indexPath.row].ActualID)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "PhotoAlbum") {
            let svc = segue.destinationViewController as! online_albums
            svc.DataPassed = sender as! String
        }
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let picDimension = self.view.frame.size.width/2
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
    
    func populateData(dataone:String,datatwo:NSString,datathree:String){
        self.cellData.append(CellContent(ID: dataone, PhotoURL: datatwo,ActualID: datathree))
    }
    

}

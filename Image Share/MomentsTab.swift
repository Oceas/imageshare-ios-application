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
    var selected = true
    var StoryCatch = [String]()
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
        self.StoryCatch.removeAll()
        self.StoryCollection.delegate = self
        self.StoryCollection.dataSource = self
        self.UserAlbums(){_ in
            self.StoryCollection.reloadData()
        }
    }
    
    

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
    }
    
    func clearLoggedinFlagInUserDefaults() {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.removeObjectForKey("userLoggedIn")
        defaults.synchronize()
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }

    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.cellData.count
    }
    
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Story", forIndexPath: indexPath) as! StoryCell
        
        let cells = cellData[indexPath.row]
        
        if (cells.PhotoURL=="Blank"){
            cell.coverphoto.image = UIImage(named: "Blank")?.kf_normalizedImage()
        }
        else{
        let URLString = cells.PhotoURL
        let URL = NSURL(string:URLString as String)!
        cell.coverphoto.kf_setImageWithURL(URL)
        }
        cell.caption.text = cells.ID
        cell.deleting.hidden = self.selected
        
        return cell
    }
    
    
    func UserAlbums(completion: (result: String) -> Void){
        var count = 0
        if let USERID = KeychainWrapper.stringForKey("UserID"){
            Alamofire.request(.POST, "http://imageshare.io/api/v1/getalbums.php", parameters: ["userId":USERID]) .responseJSON { response in
                if let jsn = response.result.value {
                    if let returnval = jsn as? [String:AnyObject]{
                        if let AlbumInfo = returnval["albums"] as? NSArray{
                            for albums in AlbumInfo{
                                if let album = albums as? [String:AnyObject]{
                                    if let albumID = album["albumId"] as? String{
                                        if let albumz_name = album["albumName"] as? String {
                                            self.albumCover(albumID,completion:{fifth in
                                                    count += 1
                                                if fifth != "nothing"{
                                                    self.populateData(albumz_name, datatwo: fifth,datathree: albumID)
                                                        if count == AlbumInfo.count{
                                                            completion(result: "done")
                                                        }
                                                }
                                                else{
                                                    self.populateData(albumz_name, datatwo: "Blank",datathree: albumID)
                                                        if count == AlbumInfo.count{
                                                            completion(result: "done")
                                                    }
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
    
    @IBAction func deleteselection(sender: AnyObject) {
        self.selected = !self.selected
        self.StoryCollection.reloadData()
    }

    func albumCover(idAlbum:String,completion: (result: String) -> Void){
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
                                    if let fifth = fourth["imageLocation"] as? String{
                                        //print(fifth)
                                        completion(result: fifth)
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
        if(!self.selected){
            let alert = UIAlertController(title: "Delete Moment", message: "Are You Sure You Want To Permanently Remove This Moment?", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { _ in
                self.RemoveAlbum(self.cellData[indexPath.row].ActualID,comp:{ _ in
                    KingfisherManager.sharedManager.cache.removeImageForKey(self.cellData[indexPath.row].PhotoURL as String)
                    self.viewDidLoad()
                    /*
                     self.contains.removeAtIndex(indexPath.row)
                     self.cellData.removeAtIndex(indexPath.row)
                     self.Stories_Collection.reloadData()
                     */
                })
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler:nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }else{
        performSegueWithIdentifier("PhotoAlbum", sender: cellData[indexPath.row].ActualID)
        }
    }
    
    func RemoveAlbum(ID:String,comp:(result:String)->Void){
        if let USERID = KeychainWrapper.stringForKey("UserID"){
            //for album in self.AlbumCollection{
            Alamofire.request(.POST, "http://imageshare.io/api/v1/deletealbum.php", parameters: ["userId":USERID,"albumId":ID]) .responseJSON { response in // 1
                if let jsn = response.result.value {
                    //print(jsn)
                    comp(result: "done")
                }
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "PhotoAlbum") {
            let svc = segue.destinationViewController as! UINavigationController
            let detailController = svc.topViewController as! online_albums
            detailController.DataPassed = sender as! String
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
    
    func populateData(dataone:String,datatwo:String,datathree:String){
        if(!self.StoryCatch.contains(datathree)){
        self.StoryCatch.append(datathree)
        self.cellData.append(CellContent(ID: dataone, PhotoURL: datatwo,ActualID: datathree))
        }
    }
    

}

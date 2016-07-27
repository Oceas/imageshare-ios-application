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

class StoriesTab: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var Stories_Collection: UICollectionView!

    
    var AlbumCollection = [NSString]()
    var StoryData = [StoryContent]()
    var cellData = [CellContent]()
    
    struct CellContent {
        var ID:String!
        var StoryID:String!
        var StoryName:String!
        var PhotoURL:String!
        var ActualID:String!
        init(ID:String,PhotoURL:String,ActualID:String,StoryID:String,StoryName:String){
            self.ID = ID
            self.PhotoURL = PhotoURL
            self.ActualID = ActualID
            self.StoryID = StoryID
            self.StoryName = StoryName
        }
    }
    
    struct StoryContent{
        var ID:String!
        var Name:String!
        init(ID:String,Name:String){
            self.ID = ID
            self.Name = Name
        }
    }
    
    override func viewDidLoad() {
        self.cellData.removeAll()
        self.StoryData.removeAll()
        self.AlbumCollection.removeAll()
        super.viewDidLoad()
        self.cellData.removeAll()
        self.StoryData.removeAll()
        self.Stories_Collection.delegate = self
        self.Stories_Collection.dataSource = self
        self.getAllStories({_ in
            self.Stories_Collection.reloadData()
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        //super.viewDidAppear(true)
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.viewDidAppear(true)
        self.cellData.removeAll()
        self.StoryData.removeAll()
        self.AlbumCollection.removeAll()
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
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Momentum", forIndexPath: indexPath) as! MomentsCell
        
        let cells = cellData[indexPath.row]
        let URLString = cells.PhotoURL
        let URL = NSURL(string:URLString)!
        //cell.coverphoto.hnk_setImageFromURL(URL)
        //cell.coverphoto.hnk_setImageFromURL(URL, format: Format<UIImage>(name: "original"))
        cell.coverphoto.kf_setImageWithURL(URL)
        cell.caption.text = cells.StoryName
        
        return cell
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
                               // print(third)
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
    
    func Moment_to_Story(aID:String,sID:String, completion: (result: String) -> Void){
        if let userID = KeychainWrapper.stringForKey("UserID"){
            Alamofire.request(.POST, "http://imageshare.io/api/v1/addalbumtostory.php", parameters: ["userId":userID,"storyId":sID,"albumId":aID]) .responseJSON { response in // 1
                if let jsn = response.result.value as? NSDictionary {
                    //print(jsn)
                    if let errortyp = jsn["error"] as? Int{
                        if (errortyp == 0){
                            completion(result: "done")
                        }
                    }
                }
            }
        }
    }
    
    func getAllStories(completion: (result: String) -> Void){
        var count = 0
        let queue = dispatch_queue_create("com.imageshare.getapi", DISPATCH_QUEUE_SERIAL)
        if let userID = KeychainWrapper.stringForKey("UserID"){
            Alamofire.request(.POST, "http://imageshare.io/api/v1/getstories.php", parameters: ["userId":userID]) .responseJSON { response in
                if let jsn = response.result.value {
                    if let albuminfo = jsn as? [String: AnyObject]{
                        if let suc = albuminfo["error"] as? NSInteger{
                            if (suc == 0){
                                if let stories = albuminfo["stories"] as? NSArray{
                                    if(stories.count == 0){completion(result: "done")}
                                    for item in stories{
                                        dispatch_async(queue) { () -> Void in
                                        if let details = item as? [String: AnyObject]{
                                            if let sID = details["storyId"] as? String{
                                                if let sName = details["storyName"] as? String{
                                                    self.StoryData.append(StoryContent(ID: sID, Name: sName))
                                                    self.getStoryDetail(sID,thename:sName,completion:{ _ in
                                                      dispatch_async(dispatch_get_main_queue(), {
                                                        count += 1
                                                    if count == stories.count{
                                                        completion(result: "done")
                                                        }
                                                        })
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
        }
    }
    
    func getStoryDetail(sID:String,thename:String,completion: (result: String) -> Void){
        if let userID = KeychainWrapper.stringForKey("UserID"){
            //print(userID)
            Alamofire.request(.POST, "http://imageshare.io/api/v1/getstorydetail.php", parameters: ["userId":userID,"storyId":sID]) .responseJSON { response in // 1
                if let jsn = response.result.value as? NSDictionary {
                    //print(jsn)
                    if let errortyp = jsn["error"] as? Int{
                        if (errortyp == 0){
                            if let storylayer = jsn["story"] as? NSDictionary{
                                if let moments = storylayer["momments"] as? NSArray{
                                    if moments.count == 0{completion(result: "done")}
                                    for moment in moments{
                                        if let detail = moment as? NSDictionary{
                                            //print(detail)
                                            if let MID = detail["albumId"] as? String{
                                                if let Mname = detail["albumName"] as? String{
                                                    self.albumCover(MID,completion:{fifth in
                                                        if fifth != "nothing"{
                                                            self.populateData(Mname, datatwo: fifth,datathree: MID,datafour:sID,datafive:thename)

                                                                completion(result: "done")
                                                            }
                                                        else{
                                                            if ((moments.indexOfObject(moment) + 1) == moments.count)
                                                            {
                                                                completion(result: "done")
                                                                
                                                            }
                                                        }
                                                    })
                                                }

                                            }
                                        }
                                    }
                                }else{completion(result: "done")}
                            }
                        }
                    }
                }
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("openstory", sender: cellData[indexPath.row].StoryID)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "openstory") {
            let svc = segue.destinationViewController as! UINavigationController
            let detailController = svc.topViewController as! TableStorytoMoment
            detailController.datapassed = sender as? String
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
    
    func populateData(dataone:String,datatwo:String,datathree:String,datafour:String,datafive:String){
        self.cellData.append(CellContent(ID: dataone, PhotoURL: datatwo,ActualID: datathree,StoryID: datafour,StoryName: datafive))
    }

}

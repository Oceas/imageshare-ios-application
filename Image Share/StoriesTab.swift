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

    var queue:dispatch_queue_t?
    var contains = [String]()
    var selected = true
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
        super.viewDidLoad()
        self.cellData.removeAll()
        self.StoryData.removeAll()
        self.AlbumCollection.removeAll()
        self.contains.removeAll()
        self.Stories_Collection.delegate = self
        self.Stories_Collection.dataSource = self
        self.getAllStories({_ in
            //dispatch_suspend(self.queue!)
            dispatch_async(dispatch_get_main_queue(),{
            self.Stories_Collection.reloadData()
            })
            //print(self.cellData.count)
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
     override func viewWillAppear(animated: Bool){
        super.viewWillAppear(true)
    }

    @IBAction func deleteSelection(sender: AnyObject) {
        self.selected = !self.selected
        self.Stories_Collection.reloadData()
        //print(self.cellData.count)
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
    /*
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let indexPaths = Stories_Collection.indexPathsForVisibleItems()
        Stories_Collection.reloadItemsAtIndexPaths(indexPaths)
    }
    */
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Momentum", forIndexPath: indexPath) as! MomentsCell
        
        let cells = cellData[indexPath.row]
        
        if cells.PhotoURL == "Blank"{
        cell.coverphoto.image = UIImage(named: "Blank")?.kf_normalizedImage()
        }
        else{
        let URLString = cells.PhotoURL
        let URL = NSURL(string:URLString)!
        //cell.coverphoto.hnk_setImageFromURL(URL)
        //cell.coverphoto.hnk_setImageFromURL(URL, format: Format<UIImage>(name: "original"))
        cell.coverphoto.kf_setImageWithURL(URL)
        }
        cell.caption.text = cells.StoryName
        cell.deleting.hidden = self.selected
        //cell.selectedBackgroundView?.addSubview(UIImageView.init(image: UIImage.init(named: "DeleteRed")))
        
        return cell
    }
    
    func albumCover(idAlbum:NSString,completion: (result: String) -> Void){
        if let USERID = KeychainWrapper.stringForKey("UserID"){
            //for album in self.AlbumCollection{
            Alamofire.request(.POST, "http://imageshare.io/api/v1/getalbumdetail.php", parameters: ["userId":USERID,"albumId":idAlbum]) .responseJSON { response in // 1
                if let jsn = response.result.value {
                    //print(jsn)
                    if let first = jsn as? [String:AnyObject]{
                        //print(first)
                        if let second = first["album"] as? NSDictionary{
                             //print(second)
                            if let third = second["images"] as? NSArray{
                               //print(third)
                                if let fourth = third.firstObject as? NSDictionary{
                                    
                                    if let fifth = fourth["imageLocation"] as? String{
                                        //print(fifth)
                                        completion(result: fifth)
                                    }
                                    
                                }
                                
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
       
        if let userID = KeychainWrapper.stringForKey("UserID"){
            Alamofire.request(.POST, "http://imageshare.io/api/v1/getstories.php", parameters: ["userId":userID]) .responseJSON { response in
                if let jsn = response.result.value {
                    if let albuminfo = jsn as? [String: AnyObject]{
                        if let suc = albuminfo["error"] as? NSInteger{
                            if (suc == 0){
                                if let stories = albuminfo["stories"] as? NSArray{
                                    if(stories.count == 0){completion(result: "done")}
                                    for item in stories{
                                        
                                        if let details = item as? [String: AnyObject]{
                                            if let sID = details["storyId"] as? String{
                                                if let sName = details["storyName"] as? String{
                                                    self.getStoryDetail(sID,thename:sName,completion:{ _ in
                                                        count += 1
                                                        self.StoryData.append(StoryContent(ID: sID, Name: sName))
                                                    if count == stories.count {
                                                        completion(result: "done")
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
    }
    
    func getStoryDetail(sID:String,thename:String,completion: (result: String) -> Void){
        var counts = 0
        if let userID = KeychainWrapper.stringForKey("UserID"){
            //print(userID)
            Alamofire.request(.POST, "http://imageshare.io/api/v1/getstorydetail.php", parameters: ["userId":userID,"storyId":sID]) .responseJSON { response in // 1
                if let jsn = response.result.value as? NSDictionary {
                    //print(jsn)
                    if let errortyp = jsn["error"] as? Int{
                        if (errortyp == 0){
                            if let storylayer = jsn["story"] as? NSDictionary{
                                if let moments = storylayer["momments"] as? NSArray{
                                    if moments.count == 0{self.populateData("empty", datatwo:"Blank",datathree: "empty",datafour:sID,datafive:thename)
                                        completion(result: "done")}
                                    for moment in moments{
                                        if let detail = moment as? NSDictionary{
                                            //print(detail)
                                            if let MID = detail["albumId"] as? String{
                                                if let Mname = detail["albumName"] as? String{
                                                    self.albumCover(MID,completion:{fifth in
                                                        counts += 1
                                                        if fifth != "nothing"{
                                                            self.populateData(Mname, datatwo: fifth,datathree: MID,datafour:sID,datafive:thename)
                                                                //print(counts)
                                                                completion(result: "done")
                                                        }else{if counts == moments.count{
                                                            //print("Hi")
                                                            self.populateData(Mname, datatwo:"Blank",datathree: MID,datafour:sID,datafive:thename)
                                                            completion(result:"done")}}
                                                        
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
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if(!self.selected){
        let alert = UIAlertController(title: "Delete Story", message: "Are You Sure You Want To Permanently Remove This Story?", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { _ in
                self.RemoveStory(self.cellData[indexPath.row].StoryID,comp:{ _ in
                    KingfisherManager.sharedManager.cache.removeImageForKey(self.cellData[indexPath.row].PhotoURL)
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
        performSegueWithIdentifier("openstory", sender: cellData[indexPath.row].StoryID)
        }
    }
    
    func RemoveStory(ID:String,comp:(result:String)->Void){
        if let userID = KeychainWrapper.stringForKey("UserID"){
            //print(userID)
            Alamofire.request(.POST, "http://imageshare.io/api/v1/deletestory.php", parameters: ["userId":userID,"storyId":ID]) .responseJSON { response in // 1
                if let jsn = response.result.value as? NSDictionary {
                   // print(jsn)
                    comp(result:"Done")
                }
            }
        }
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
        if(!self.contains.contains(datafour)){
        self.contains.append(datafour)
        self.cellData.append(CellContent(ID: dataone, PhotoURL: datatwo,ActualID: datathree,StoryID: datafour,StoryName: datafive))
        }
    }

}

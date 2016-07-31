//
//  TableStorytoMoment.swift
//  Image Share
//
//  Created by Deni on 7/26/16.
//  Copyright © 2016 ImageShare. All rights reserved.
//

import UIKit
import Alamofire
import Kingfisher

class TableStorytoMoment: UITableViewController {

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
    
    var StoryDesc:String!
    
    @IBOutlet weak var STORY_DESC: UILabel!
    var cellData = [CellContent]()
    var datapassed:String?
    
    @IBOutlet var TheTable: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.translucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.0/255.0, green:180/255.0, blue:220/255.0, alpha: 1.0)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Home", style: .Plain, target: self, action: #selector(TableStorytoMoment.sendmeback(_:)))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: #selector(TableStorytoMoment.editstory(_:)))
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.cellData.removeAll()
        self.TheTable.delegate = self
        self.TheTable.dataSource = self
        self.getStoryDetail(datapassed!, completion:{ Aname in
            self.TheTable.reloadData()
            self.navigationItem.title = Aname
            self.STORY_DESC.text = self.StoryDesc
            //print(self.cellData)
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.cellData.count
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        let orientation: UIInterfaceOrientationMask = [UIInterfaceOrientationMask.Portrait, UIInterfaceOrientationMask.Portrait]
        return orientation
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    func sendmeback(sender:UIBarButtonItem){
        self.performSegueWithIdentifier("Sentback", sender: sender)
    }
    
    func editstory(sender:UIBarButtonItem){
        self.performSegueWithIdentifier("toEdit", sender: sender)
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AnotherCell", forIndexPath: indexPath) as! storytomomentCell
        
        let data = cellData[indexPath.row]
        let URLString = data.PhotoURL
        let URL = NSURL(string:URLString)!
        //cell.coverphoto.hnk_setImageFromURL(URL)
        //cell.coverphoto.hnk_setImageFromURL(URL, format: Format<UIImage>(name: "original"))
        cell.thepic.kf_setImageWithURL(URL)
        cell.thecaption.text = data.ID
        return cell
    }
    
    func getStoryDetail(sID:String,completion: (result: String) -> Void){
        var count = 0
        let queue = dispatch_queue_create("com.imageshare.io/api/v1/getstorydetail.php", DISPATCH_QUEUE_SERIAL)
        if let userID = KeychainWrapper.stringForKey("UserID"){
            //print(userID)
            Alamofire.request(.POST, "http://imageshare.io/api/v1/getstorydetail.php", parameters: ["userId":userID,"storyId":sID]) .responseJSON { response in // 1
                if let jsn = response.result.value as? NSDictionary {
                    if let errortyp = jsn["error"] as? Int{
                        if (errortyp == 0){
                            if let storylayer = jsn["story"] as? NSDictionary{
                                if let storyd = storylayer["storyDesc"] as? String{
                                    self.StoryDesc = storyd
                                if let thename = storylayer["storyName"] as? String{
                                if let moments = storylayer["momments"] as? NSArray{
                                    if moments.count == 0{completion(result: thename)}
                                    for moment in moments{
                                        dispatch_async(queue) { () -> Void in
                                        if let detail = moment as? NSDictionary{
                                            //print(detail)
                                            if let MID = detail["albumId"] as? String{
                                                if let Mname = detail["albumName"] as? String{
                                                    self.albumCover(MID,completion:{fifth in
                                                        dispatch_async(dispatch_get_main_queue(), {
                                                            count += 1
                                                            })
                                                        if fifth != "nothing"{
                                                            dispatch_async(dispatch_get_main_queue(), {
                                                            self.populateData(Mname, datatwo: fifth,datathree: MID,datafour:sID,datafive:thename)
                                                                if count == moments.count{
                                                                    completion(result: thename)
                                                                }
                                                            })
                                                        }
                                                        else{
                                                                dispatch_async(dispatch_get_main_queue(), {
                                                                    if count == moments.count{
                                                                        completion(result: thename)
                                                                    }
                                                                })
                                                        }
                                                    })
                                                }
                                                
                                            }
                                        }
                                        }
                                    }
                                }else{completion(result: thename)}
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
    
    func populateData(dataone:String,datatwo:String,datathree:String,datafour:String,datafive:String){
        self.cellData.append(CellContent(ID: dataone, PhotoURL: datatwo,ActualID: datathree,StoryID: datafour,StoryName: datafive))
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //let cell = tableView.dequeueReusableCellWithIdentifier("AnotherCell", forIndexPath: indexPath) as! storytomomentCell
        
        performSegueWithIdentifier("toAlbum", sender: self.cellData[indexPath.row].ActualID)

    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            self.deletealbum(self.cellData[indexPath.row].ActualID,handler: {_ in 
            KingfisherManager.sharedManager.cache.removeImageForKey(self.cellData[indexPath.row].PhotoURL)
            self.cellData.removeAtIndex(indexPath.row)
            self.TheTable.reloadData()
            })
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "toAlbum") {
            /*
            let svc = segue.destinationViewController as! UINavigationController
            let detailController = svc.topViewController as! online_albums
            detailController.DataPassed = sender as! String
 */
            let svc = segue.destinationViewController as! online_albums
            svc.DataPassed = sender as! String
        }
        
        if (segue.identifier == "toEdit"){
            let svc = segue.destinationViewController as! EditStories
            svc.DataRecieved = self.datapassed! as String
        }
    }
    
    func deletealbum(idAlbum:String,handler: (result: String) -> Void){
        if let USERID = KeychainWrapper.stringForKey("UserID"){
            //for album in self.AlbumCollection{
            Alamofire.request(.POST, "http://imageshare.io/api/v1/deletealbum.php", parameters: ["userId":USERID,"albumId":idAlbum]) .responseJSON { response in // 1
                if let jsn = response.result.value {
                    //print(jsn)
                    handler(result: "done")
                }
            }
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

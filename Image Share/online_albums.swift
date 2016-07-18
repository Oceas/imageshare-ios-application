//
//  online_albums.swift
//  Image Share
//
//  Created by Deni on 7/15/16.
//  Copyright © 2016 ImageShare. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import Haneke

class online_albums: UIViewController,UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var NavTitle: UINavigationItem!
    @IBOutlet weak var AlbumDesc: UILabel!
    @IBOutlet weak var ThePhotoTable: UITableView!
    
    var DataPassed:String!
    var PhCollection = [PhotoDetails]()
    var PClass = [PhotoClass]()
    
    let imageDownloader = ImageDownloader(
        configuration: ImageDownloader.defaultURLSessionConfiguration(),
        downloadPrioritization: .FIFO,
        maximumActiveDownloads: 4,
        imageCache: AutoPurgingImageCache()
    )
    
    
    struct PhotoDetails{
        var PhURL:String!
        var PhDesc:String!
        var PhName:String!
        
        init(PhURL:String){
            self.PhURL = PhURL
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ThePhotoTable.delegate = self
        self.ThePhotoTable.dataSource = self
        
        self.albumCover(DataPassed, completion:{ _ in
            self.ThePhotoTable.reloadData()
        })
    }
    
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        let orientation: UIInterfaceOrientationMask = [UIInterfaceOrientationMask.Portrait, UIInterfaceOrientationMask.Portrait]
        return orientation
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.PClass.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("onlineCell", forIndexPath: indexPath) as! Photo_Online
        
        let data = self.PClass[indexPath.row]
        let URL = NSURL(string:data.getURL())!
        cell.PH_Image.hnk_setImageFromURL(URL)
        //cell.PH_Image.af_setImageWithURL(URL)
        return cell
    }
    

    
    func albumCover(idAlbum:String,completion: (result: String) -> Void){
        if let USERID = KeychainWrapper.stringForKey("UserID"){
            //for album in self.AlbumCollection{
            Alamofire.request(.POST, "http://imageshare.io/api/getalbumdetail.php", parameters: ["userId":USERID,"albumId":idAlbum]) .responseJSON { response in // 1
                if let jsn = response.result.value {
                    if let first = jsn as? [String:AnyObject]{
                        if let second = first["album"] as? NSDictionary{
                            // print(second)
                            if let third = second["images"] as? NSArray{
                                for albumphotos in third{
                                    //print(albumphotos)
                                    if let PhotoInfo = albumphotos as? NSDictionary{
                                        if let photoURL = PhotoInfo["imageLocation"] as? String{
                                            if let photoName = PhotoInfo["imageName"] as? String{
                                                if let photoDesc = PhotoInfo["imageDesc"] as? String{
                                            self.PClass.append(PhotoClass(PhotoURL: photoURL, PhotoName: photoName, PhotoDesc: photoDesc))
                                                    if (third.indexOfObject(albumphotos) == third.count - 1){
                                                        completion(result: "done")
                                                    }
                                                }
                                                else{
                                                      self.PClass.append(PhotoClass(PhotoURL: photoURL, PhotoName: photoName, PhotoDesc: "Enter Caption!"))
                                                    if (third.indexOfObject(albumphotos) == third.count - 1){
                                                        completion(result: "done")
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
      performSegueWithIdentifier("Pslide", sender:self)
    }
 
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "Pslide") {
            let PhotoDict:NSDictionary = [
                "Position": (ThePhotoTable.indexPathForSelectedRow?.row)!,
                "Collection":self.PClass
            ]
            let svc = segue.destinationViewController as! SlideshowView
            svc.PhotoPassed = PhotoDict
        }
    }

    
    }

    
    
    /*
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "Package") {
            let svc = segue.destinationViewController as! CollectionViewController
            let button = sender as! TableViewCell
            let indexPath = Table.indexPathForCell(button)
            svc.dataPassed = TableData[indexPath!.row].Album
        }
    }
 */


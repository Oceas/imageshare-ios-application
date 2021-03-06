//
//  online_albums.swift
//  Image Share
//
//  Created by Deni on 7/15/16.
//  Copyright © 2016 ImageShare. All rights reserved.
//

import UIKit
import Alamofire
import Haneke
import Kingfisher

class online_albums: UIViewController,UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var AlbumDesc: UILabel!
    @IBOutlet weak var ThePhotoTable: UITableView!
    
    var DataPassed:String!
    var PhCollection = [PhotoDetails]()
    var PClass = [PhotoClass]()
    
    
    struct PhotoDetails{
        var PhURL:String!
        var PhDesc:String!
        var PhName:String!
        
        init(PhURL:String){
            self.PhURL = PhURL
        }
    }
    
    var albumDescription:String!
    var albumTitle:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.PhCollection.removeAll()
        //self.PClass.removeAll()
        self.ThePhotoTable.delegate = self
        self.ThePhotoTable.dataSource = self
        self.navigationController?.navigationBar.translucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.0/255.0, green:180/255.0, blue:220/255.0, alpha: 1.0)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Home", style: .Plain, target: self, action: #selector(online_albums.returntomain(_:)))
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.PhCollection.removeAll()
        self.PClass.removeAll()

        self.albumCover(DataPassed, completion:{ _ in
        self.AlbumDesc.text = self.albumDescription
        self.navigationItem.title = self.albumTitle
        self.ThePhotoTable.reloadData()
        })
    }
    
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
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
        let KURL = NSURL(string:data.getURL())!
        cell.PH_Image.kf_setImageWithURL(KURL)
        //cell.PH_Image.hnk_setImageFromURL(URL)
        //cell.PH_Image.af_setImageWithURL(URL)
        return cell
    }
    

    
    func albumCover(idAlbum:String,completion: (result: String) -> Void){
        if let USERID = KeychainWrapper.stringForKey("UserID"){
            //for album in self.AlbumCollection{
            Alamofire.request(.POST, "http://imageshare.io/api/v1/getalbumdetail.php", parameters: ["userId":USERID,"albumId":idAlbum]) .responseJSON { response in // 1
                if let jsn = response.result.value {
                   // print(jsn)
                    if let first = jsn as? [String:AnyObject]{
                        if let second = first["album"] as? NSDictionary{
                             //print(second)
                            if let thisName = second["name"] as? String?{
                                self.albumTitle = thisName
                            if let thisDisc = second["desc"] as? String{
                                self.albumDescription = thisDisc
                            if let third = second["images"] as? NSArray{
                                if third.count == 0 {completion(result:"done")}
                                for albumphotos in third{
                                    //print(albumphotos)
                                    if let PhotoInfo = albumphotos as? NSDictionary{
                                        if let photoURL = PhotoInfo["imageLocation"] as? String{
                                            if let photoName = PhotoInfo["imageName"] as? String{
                                                //print(photoURL)
                                                if let photoID = PhotoInfo["imageId"] as? String{
                                                if let photoDesc = PhotoInfo["imageDesc"] as? String{
                                                    self.PClass.append(PhotoClass(PhotoURL: photoURL, PhotoName: photoName, PhotoDesc: photoDesc,PhotoID:photoID))
                                                    if (third.indexOfObject(albumphotos) == third.count - 1){
                                                        completion(result: "done")
                                                    }
                                                }
                                                else{
                                                      self.PClass.append(PhotoClass(PhotoURL: photoURL, PhotoName: photoName, PhotoDesc: "Enter Caption!",PhotoID: photoID))
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
                //"PhotoID":
            ]
            let svc = segue.destinationViewController as! SlideshowView
            svc.PhotoPassed = PhotoDict
        }
    }
    
    func returntomain(sender:UIBarButtonItem){
        self.performSegueWithIdentifier("LETSGOHOME", sender: sender)
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



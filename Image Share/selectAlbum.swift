//
//  selectAlbum.swift
//  Image Share
//
//  Created by Deni on 7/21/16.
//  Copyright © 2016 ImageShare. All rights reserved.
//

import UIKit
import Kingfisher
import Alamofire
import Eureka
import CoreLocation
import MapKit

protocol selectAlbumDelegate
{
    func saveText(strText : NSString)
}

class selectAlbum:FormViewController{
    var delegate:selectAlbumDelegate?
    var albumname = [String]()
    var storyname = [String]()
    var sMomentName:String!
    var sMomentDesc:String!
    var sMomentLoc:String!
    var sStoryName:String!
    var sStoryDesc:String!
    var sStoryLoc:String!
    var SStruct = [sInfo]()
    var MStruct = [mInfo]()
    var CurrentVal:String!
    var MCval:String!
    
    struct sInfo{
        var name:String!
        var ID:String!
        
        init(name:String,ID:String){
            self.name = name
            self.ID = ID
        }
    }
    struct mInfo{
        var name:String!
        var ID:String!
        init(name:String,ID:String){
            self.name = name
            self.ID = ID
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(selectAlbum.completed))
        self.getAllStories({_ in
            self.albumname.append("New Story")
            //self.getAllStories({_ in
            self.storyname.append("Create Moment")
            self.CurrentVal = self.albumname.first
            self.MCval = self.storyname.first
            self.SStruct.append(sInfo(name: "New Story", ID: "NONE"))
            self.MStruct.append(mInfo(name: "Create Moment", ID: "NONE"))
            print(self.albumname)
            self.form +++ Section("Story Selection")
                <<< PushRow<String>("CurrentStories") {
                    $0.title = "Select Story"
                    $0.options = self.albumname
                    $0.value = self.albumname.first
                    $0.selectorTitle = "Select Story"
                    } .onChange { [weak self] row in
                        if let changed = row.value {
                            self!.CurrentVal = changed
                            if(self!.CurrentVal != "New Story"){
                            self!.storyname.removeAll()
                            //self!.storyname.removeAll(keepCapacity: true)
                            self!.MStruct.removeAll()
                            self!.storyname.append("Create Moment")
                            self!.MStruct.append(mInfo(name: "Create Moment", ID: "NONE"))
                            self!.MCval = "Create Moment"
                            self!.getStoryDetail(self!.SStruct[self!.albumname.indexOf(self!.CurrentVal)!].ID,completion: { _ in
                                    self!.form.rowByTag("CurrentMoments")!.updateCell()
                                })
                            }
                            else{
                                self!.storyname.removeAll()
                                //self!.storyname.removeAll(keepCapacity: true)
                                self!.MStruct.removeAll()
                                self!.storyname.append("Create Moment")
                                self!.MStruct.append(mInfo(name: "Create Moment", ID: "NONE"))
                                self!.MCval = "Create Moment"
                                self!.form.rowByTag("CurrentMoments")!.updateCell()
                            }
                        }
                        else{
                            row.value = "New Story"
                            self!.CurrentVal = row.value
                        }
                    }
                +++ Section("Create New Story"){
                    $0.hidden = Condition.Predicate(NSPredicate(format: "$CurrentStories != 'New Story'")) //"$CurrentAlbums != 'None'"
                }
                <<< NameRow("Story Name") {
                    $0.title = "Story Name"
                }
                <<< TextAreaRow("Story Description") {
                    $0.placeholder = $0.tag
                    $0.textAreaHeight = .Dynamic(initialTextViewHeight: 50)
                }
                <<< TextRow("SLocation") {
                    $0.title = "Location"
                }
                
                +++ Section("Moment Selection")
                
                <<< PushRow<String>("CurrentMoments") { row in
                    row.title = "Select Moment"
                    row.options = self.storyname
                    row.value = self.storyname.first
                    row.selectorTitle = "Select Moment"
                    //row.updateCell()
                    
                    if(self.CurrentVal != "New Story"){
                        row.options = self.storyname
                        row.value = self.MCval
                        //self.MCval = self?.MCval
                        //self.getStoryDetail(self.SStruct[self.albumname.indexOf(self.CurrentVal)!].ID,completion: { _ in
                            //self.MStruct.append(mInfo(name: "Create Moment", ID: "NONE"))
                            //self.storyname.removeAll(keepCapacity: true)
                            //row.options = self.storyname
                            //row.value = self.MCval
                            //self.MCval = self.storyname.last
                            //row.updateCell()
                        //})
                    }
                    
                    }.onChange { [weak self] row in
                        row.options = self!.storyname
                        if let val = row.value {
                            row.value = val
                            self?.MCval = val
                        }
                        else{
                            row.value = self!.storyname.first
                            self?.MCval = self?.storyname.first
                        }
                        row.reload()
                    } .cellUpdate{cell, row in
                            //print(self.storyname.count)
                            row.options = self.storyname
                            row.value = self.MCval
                            //self.MCval = self.storyname.last
                            row.reload()
                    }.cellSetup({cell,row in
                        self.getStoryDetail(self.SStruct[self.albumname.indexOf(self.CurrentVal)!].ID,completion: { _ in
                            //self.MStruct.append(mInfo(name: "Create Moment", ID: "NONE"))
                            //self.storyname.removeAll(keepCapacity: true)
                            row.options = self.storyname
                            row.value = self.MCval
                            //self.MCval = self.storyname.last
                            //row.updateCell()
                        })
                    })
                
                +++ Section("Create New Moment"){
                    $0.hidden = Condition.Predicate(NSPredicate(format: "$CurrentMoments != 'Create Moment'"))
                }
                
                <<< NameRow("Moment Name") {
                    $0.title = "Create New Moment"
                }
                <<< TextAreaRow("Moment Description") {
                    $0.placeholder = $0.tag
                    $0.textAreaHeight = .Dynamic(initialTextViewHeight: 50)
                }
                <<< TextRow("MLocation") {
                    $0.title = "Location"
            }
            
            //})
            })
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }

    
    func completed(){
        let data = self.form.values(includeHidden: false)
        if let currentstories = data["CurrentStories"] as? String{
        if let currentmoments = data["CurrentMoments"] as? String{
            //Create Story
            if currentstories == "New Story"{
                //Story Location
                if let sloc = data["SLocation"] as? String{
                    self.sStoryLoc = sloc
                }else{self.sStoryLoc = "N/A"}
                
                if let sdec = data["Story Description"] as? String{
                    self.sStoryDesc = sdec
                }else{self.sStoryDesc = "N/A"}
                if let snam = data["Story Name"] as? String{
                    self.sStoryName = snam
                }else{
                    let alert = UIAlertController(title: "Error!", message: "Must Add Story Name", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:nil))
                    self.presentViewController(alert, animated: true, completion:nil)
                    return
                }
                if let mloc = data["MLocation"] as? String{
                    self.sMomentLoc = mloc
                }else{self.sMomentLoc = "N/A"}
                
                if let mdec = data["Moment Description"] as? String{
                    self.sMomentDesc = mdec
                }else{self.sMomentDesc = "N/A"}
                if let mnam = data["Moment Name"] as? String{
                    self.sMomentName = mnam
                }else{
                    let alert = UIAlertController(title: "Error!", message: "Must Add Moment Name", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:nil))
                    self.presentViewController(alert, animated: true, completion:nil)
                    return
                }
                //print(self.sStoryName)
                self.CreateStoryAPI({ id_story in
                    print("step1")
                    self.CreateAlbumAPI({ id_moment in
                        print("step2")
                        self.Moment_to_Story(id_moment, sID: id_story, completion:{ _ in
                            print("Story & Moment Created and linked")
                            self.delegate?.saveText(id_moment)
                            self.navigationController?.popViewControllerAnimated(true)
                        })
                    })
                })
            }
            //Adding New moment to Current story
            else if (currentmoments == "Create Moment"){
                if let mloc = data["MLocation"] as? String{
                    self.sMomentLoc = mloc
                }else{self.sMomentLoc = "N/A"}
                
                if let mdec = data["Moment Description"] as? String{
                    self.sMomentDesc = mdec
                }else{self.sMomentDesc = "N/A"}
                if let mnam = data["Moment Name"] as? String{
                    self.sMomentName = mnam
                }else{
                    let alert = UIAlertController(title: "Error!", message: "Must Add Moment Name", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:nil))
                    self.presentViewController(alert, animated: true, completion:nil)
                    return
                }
                //print(self.sStoryName)
                    self.CreateAlbumAPI({ id_moment in
                        self.Moment_to_Story(id_moment, sID: self.SStruct[self.albumname.indexOf(self.CurrentVal)!].ID, completion:{ _ in
                            print("Moment Created and added to existing story")
                            self.delegate?.saveText(id_moment)
                            self.navigationController?.popViewControllerAnimated(true)
                        })
                    })

                }
                //Add photos to album
            else{
                self.delegate?.saveText(self.MStruct[self.storyname.indexOf(self.MCval)!].ID)
                self.navigationController?.popViewControllerAnimated(true)
            }
            }
        }
    }
 
    func getAllStories(completion: (result: String) -> Void){
            if let userID = KeychainWrapper.stringForKey("UserID"){
                Alamofire.request(.POST, "http://imageshare.io/api/v1/getstories.php", parameters: ["userId":userID]) .responseJSON { response in
                    if let jsn = response.result.value {
                        //print(jsn)
                        if let albuminfo = jsn as? [String: AnyObject]{
                            if let suc = albuminfo["error"] as? NSInteger{
                                if (suc == 0){
                                    if let stories = albuminfo["stories"] as? NSArray{
                                        if(stories.count == 0){completion(result: "done")}
                                        for item in stories{
                                             if let details = item as? [String: AnyObject]{
                                                if let sID = details["storyId"] as? String{
                                                if let sName = details["storyName"] as? String{
                                                    self.albumname.append(sName)
                                                    self.SStruct.append(sInfo(name: sName, ID:sID ))
                                                    if ((stories.indexOfObject(item) + 1) == stories.count)
                                                    {
                                                        //print(self.albumname)
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

    func GetAllAlbums(completion: (result: String) -> Void){
        if let userID = KeychainWrapper.stringForKey("UserID"){
            Alamofire.request(.POST, "http://imageshare.io/api/v1/getalbums.php", parameters: ["userId":userID]) .responseJSON { response in
                if let jsn = response.result.value {
                    if let albuminfo = jsn as? [String: AnyObject]{
                        if let suc = albuminfo["error"] as? NSInteger{
                            if (suc == 0){
                                if let albums = albuminfo["albums"] as? NSArray{
                                    if(albums.count == 0){completion(result: "done")}
                                    for album in albums{
                                        if let details = album as? [String: AnyObject]{
                                            if let album_ID = details["albumId"] as? String{
                                                if let album_name = details["albumName"] as? String{
                                                    self.albumname.append(album_name)
                                                     self.MStruct.append(mInfo(name: album_name, ID: album_ID))
                                                    if ((albums.indexOfObject(album) + 1) == albums.count)
                                                    {
                                                        //print(self.albumname)
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
    
    func CreateAlbumAPI(completion: (result: String) -> Void){
        if let userID = KeychainWrapper.stringForKey("UserID"){
            Alamofire.request(.POST, "http://imageshare.io/api/v1/createalbum.php", parameters: ["userId":userID,"albumName":self.sMomentName!,"albumDesc":self.sMomentDesc!,"location":self.sMomentLoc!]) .responseJSON { response in // 1
                if let jsn = response.result.value {
                   //print(jsn)
                    if let albuminfo = jsn as? NSDictionary{
                        if let errortyp = albuminfo["error"] as? Int{
                            if (errortyp == 0){
                                if let Sid = albuminfo["albumId"] as? String{
                                    completion(result:Sid)
                                }
                                }
                            }
                        }
                    }
                }
            }
        }
    
    func CreateStoryAPI(completion: (result: String) -> Void){
            if let userID = KeychainWrapper.stringForKey("UserID"){
                Alamofire.request(.POST, "http://imageshare.io/api/v1/createstory.php", parameters: ["userId":userID,"storyName":self.sStoryName!,"storyDesc":self.sStoryDesc!,"location":self.sStoryLoc!]) .responseJSON { response in // 1
                    if let jsn = response.result.value {
                        //print(jsn)
                        if let albuminfo = jsn as? NSDictionary{
                            if let errortyp = albuminfo["error"] as? Int{
                                if (errortyp == 0){
                                    if let Sid = albuminfo["storyId"] as? String{
                                    completion(result:Sid)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    
    func getStoryDetail(sID:String,completion: (result: String) -> Void){
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
                                       // print(detail)
                                        if let MID = detail["albumId"] as? String{
                                            if let Mname = detail["albumName"] as? String{
                                                //print(Mname)
                                                self.storyname.append(Mname)
                                                self.MStruct.append(mInfo(name: Mname, ID: MID))
                                                if ((moments.indexOfObject(moment) + 1) == moments.count)
                                                {
                                                    //print(self.albumname)
                                                    completion(result: "done")
                                                    
                                                }
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
    
    func Moment_to_Story(aID:String,sID:String, completion: (result: String) -> Void){
        if let userID = KeychainWrapper.stringForKey("UserID"){
            Alamofire.request(.POST, "http://imageshare.io/api/v1/addalbumtostory.php", parameters: ["userId":userID,"storyId":sID,"albumId":aID]) .responseJSON { response in // 1
                if let jsn = response.result.value as? NSDictionary {
                    print(jsn)
                    if let errortyp = jsn["error"] as? Int{
                        if (errortyp == 0){
                            completion(result: "done")
                        }
                    }
                }
            }
        }
    }
}



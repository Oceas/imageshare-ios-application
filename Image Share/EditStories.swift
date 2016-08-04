//
//  EditStories.swift
//  Image Share
//
//  Created by Deni on 7/27/16.
//  Copyright © 2016 ImageShare. All rights reserved.
//

import UIKit
import Kingfisher
import Alamofire
import Eureka

class EditStories: FormViewController {

    var DataRecieved:String?
    var storyDesc = "N/A"
    var storyName:String!
    var storyLocation = "N/A"
    var momentsR = [String]()
    var momentsD = NSMutableDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: #selector(EditStories.saveChanges(_:)))
        
        
        self.getStoryDetail(DataRecieved!, completion: { _ in
            dispatch_async(dispatch_get_main_queue(),{
                self.navigationItem.title = self.storyName
                self.form +++ Section("Story Details")
                    <<< NameRow("Story Name") {
                        $0.title = "Story Name"
                        $0.value = self.storyName
                        }.cellUpdate({cell,row in
                            row.value = self.storyName
                        })
                    <<< TextAreaRow("Story Description") {
                        $0.title = "Story Description"
                        $0.textAreaHeight = .Dynamic(initialTextViewHeight: 50)
                        $0.value = self.storyDesc
                        }.cellUpdate({cell,row in
                            row.value = self.storyDesc
                        })
                    <<< TextRow("SLocation") {
                        $0.title = "Location"
                        $0.value = self.storyLocation
                        }.cellUpdate({cell,row in
                            row.value = self.storyLocation
                        })
                    +++ Section("Select Moments to Delete")
                    <<< MultipleSelectorRow<String>("DeleteMoments") {
                        $0.title = "Moments"
                        $0.options = self.momentsR
                        $0.value = nil
                        }
                        .onPresent { from, to in
                            to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: from, action: #selector(EditStories.multipleSelectorDone(_:)))
                }
            })
    })

         // Do any additional setup after loading the view.
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }

    
    func multipleSelectorDone(item:UIBarButtonItem) {
        navigationController?.popViewControllerAnimated(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func saveChanges(sender:UIBarButtonItem){
        let data = self.form.values()
        //print(data)
        if let Moments = data["DeleteMoments"] as? Set<String>{
            //print(Moments)
            for moment in Moments {
                if let MID = self.momentsD.valueForKey(moment) as? String{
                    self.deleteMoments(MID)
                }
            }
        }
        if let newName = data["Story Name"] as? String{
            self.storyName = newName
        }
        if let newDesc = data["Story Description"] as? String{
            self.storyDesc = newDesc
        }
        if let newLoc = data["SLocation"] as? String{
            self.storyLocation = newLoc
        }
        self.editstories()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func deleteMoments(ID:String){
        if let userID = KeychainWrapper.stringForKey("UserID"){
            Alamofire.request(.POST, "http://imageshare.io/api/v1/deletealbum.php", parameters: ["userId":userID,"albumId":ID]) .responseJSON { response in // 1
                if let _ = response.result.value {
                    
                }
            }
        }
    }
    
    func editstories(){
        if let userID = KeychainWrapper.stringForKey("UserID"){
            Alamofire.request(.POST, "http://imageshare.io/api/v1/editstory.php", parameters: ["userId":userID,"storyName":self.storyName,"storyDesc":self.storyDesc,"location":self.storyLocation,"storyId":DataRecieved!])
            .validate()
            .responseJSON{ response in
                // print(response.result.value)
            }
        }
    }
    
    func getStoryDetail(sID:String,completion: (result: String) -> Void){
        if let userID = KeychainWrapper.stringForKey("UserID"){

            Alamofire.request(.POST, "http://imageshare.io/api/v1/getstorydetail.php", parameters: ["userId":userID,"storyId":sID])
                .validate()
                .responseJSON { response in switch response.result {
                case .Success(let JSON):
                    let response = JSON as! NSDictionary
                    //print(response)
                    let storylayer = response.objectForKey("story") as! NSDictionary
                    self.storyName = storylayer.objectForKey("storyName") as! String
                    self.storyLocation = storylayer.objectForKey("storyLocation") as! String
                    self.storyDesc = storylayer.objectForKey("storyDesc") as! String
                    let moments = storylayer.objectForKey("momments") as! NSArray
                    for moment in moments{
                    let details = moment as! NSDictionary
                    self.momentsR.append(details["albumName"] as! String)
                    self.momentsD.setValue(details["albumId"] as! String, forKey: details["albumName"] as! String)
                    }
                    completion(result: "done")
                    /*
                   if let err = jsn["error"] as? Int{
                        if(err == 0){
                         if let storylayer = jsn["story"] as? NSDictionary{
                            if let sName = storylayer["storyName"] as? String{
                                self.storyName = sName
                                if let sDesc = storylayer["storyDesc"] as? String{
                                    self.storyDesc = sDesc
                                    }
                                if let sLoc = storylayer["storyLoction"] as? String{
                                    self.storyLocation = sLoc
                                    }
                                if let moments = storylayer["momments"] as? NSArray{
                                    if moments.count == 0{completion(result: "done")}
                                    for moment in moments{
                                       if let details = moment as? NSDictionary{
                                        if let aID = details["albumId"] as? String{
                                            if let aName = details["albumName"] as? String{
                                                self.momentsR.append(aName)
                                                self.momentsD.setValue(aName, forKey: aID)
                                                if(moments.indexOfObject(moment) == (moments.count - 1)){completion(result: "done")}
                                                }
                                            }
                                            }
                                        }
                                }
                                
                                }
                            }
                        }else{completion(result: "Error")}
                        
                    }*/
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                }
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

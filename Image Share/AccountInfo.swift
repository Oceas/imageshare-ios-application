//
//  AccountInfo.swift
//  Image Share
//
//  Created by Deni on 6/6/16.
//  Copyright © 2016 ImageShare. All rights reserved.
//

import UIKit
import Alamofire
import BTNavigationDropdownMenu

class AccountInfo: UIViewController {
    @IBOutlet weak var Email: UILabel!
    @IBOutlet weak var StorageCap: UILabel!
    @IBOutlet weak var StorageLeft: UILabel!
    @IBOutlet weak var Username: UILabel!
    
    var menuView:BTNavigationDropdownMenu!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let items = ["Home", "Upload", "Account Info", "LogOut"]
        self.navigationController?.navigationBar.translucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.0/255.0, green:180/255.0, blue:220/255.0, alpha: 1.0)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        menuView = BTNavigationDropdownMenu(navigationController: self.navigationController, title: items[2], items: items)
        menuView.cellHeight = 50
        menuView.cellBackgroundColor = self.navigationController?.navigationBar.barTintColor
        menuView.cellSelectionColor = UIColor(red: 0.0/255.0, green:160.0/255.0, blue:195.0/255.0, alpha: 1.0)
        menuView.keepSelectedCellColor = true
        menuView.cellTextLabelColor = UIColor.whiteColor()
        menuView.cellTextLabelFont = UIFont(name: "Avenir-Heavy", size: 17)
        menuView.cellTextLabelAlignment = .Left // .Center // .Right // .Left
        menuView.arrowPadding = 15
        menuView.animationDuration = 0.5
        menuView.maskBackgroundColor = UIColor.blackColor()
        menuView.maskBackgroundOpacity = 0.3
        menuView.didSelectItemAtIndexHandler = {(indexPath: Int) -> () in
            switch indexPath {
            case 0:
                self.mainmen()
            case 1:
                self.Uploading()
            case 2:
                return
            case 3:
                self.loggingout()
            default:
                return
            }
        }
        
        self.navigationItem.titleView = menuView
        self.UserInformation(){nUser,eUser,pUser in
            self.Email.text = eUser
            self.Username.text = eUser
            self.StorageCap.text = nUser
            self.StorageLeft.text = pUser
        }
    }
    
    func loggingout(){
        self.clearLoggedinFlagInUserDefaults()
        self.performSegueWithIdentifier("The_Log", sender: self)
    }
    
    func Uploading(){
        self.performSegueWithIdentifier("The_Upload", sender: self)
    }
    
    func mainmen(){
        self.performSegueWithIdentifier("The_Main", sender: self)
    }
    
    func clearLoggedinFlagInUserDefaults() {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.removeObjectForKey("userLoggedIn")
        defaults.synchronize()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func UpdatePassword(sender: AnyObject) {
    }
    
    func UserInformation(completion: (nUser: String,eUser: String,pUser: String) -> Void){
        if let userID = KeychainWrapper.stringForKey("UserID"){
            Alamofire.request(.POST, "http://imageshare.io/api/v1/getuserinfo.php", parameters: ["userId":userID]) .responseJSON { response in // 1
                if let jsn = response.result.value {
                    if let first = jsn as? NSDictionary{
                        if let second = first["error"] as? Int{
                            if (second == 0){
                                if let third = first["user"] as? NSDictionary{
                                    if let name = third ["name"] as? String {
                                        if let email = third ["email"] as? String {
                                            if let phone = third ["phone"] as? String {
                                                completion(nUser: name,eUser: email,pUser: phone)
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

//
//  AccountInfo.swift
//  Image Share
//
//  Created by Deni on 6/6/16.
//  Copyright © 2016 ImageShare. All rights reserved.
//

import UIKit
import Alamofire

class AccountInfo: UIViewController {
    @IBOutlet weak var Email: UILabel!
    @IBOutlet weak var StorageCap: UILabel!
    @IBOutlet weak var StorageLeft: UILabel!
    @IBOutlet weak var Username: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Account Info"
        self.UserInformation(){nUser,eUser,pUser in
            self.Email.text = eUser
            self.Username.text = eUser
            self.StorageCap.text = nUser
            self.StorageLeft.text = pUser
        }
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

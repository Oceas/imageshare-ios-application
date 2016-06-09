//
//  MenuMain.swift
//  Image Share
//
//  Created by Deni on 6/6/16.
//  Copyright © 2016 ImageShare. All rights reserved.
//

import UIKit

class MenuMain: UIViewController {
    @IBOutlet weak var Upload: UIButton!
    @IBOutlet weak var ViewPhotos: UIButton!
    @IBOutlet weak var Account: UIButton!
    @IBOutlet weak var SpaceLeft: UIProgressView!


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    /*
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if defaults.objectForKey("userLoggedIn") == nil {
            if let loginController = self.storyboard?.instantiateViewControllerWithIdentifier("Login"){
                self.presentViewController(loginController, animated: true, completion: nil)
            }
        }
        else {
            // check if API token has expired
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            let userTokenExpiryDate : String? = Keys.passwordForAccount("Auth_Token_Expiry", service: "KeyChainService")
            let dateFromString : NSDate? = dateFormatter.dateFromString(userTokenExpiryDate!)
            let now = NSDate()
            
            let comparision = now.compare(dateFromString!)
            
            // logout and ask user to sign in again if token is expired
            if comparision != NSComparisonResult.OrderedAscending {
                self.lgtap()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logoutBtnTapped(sender: UIButton) {
        self.lgtap()
    }
   
    func lgtap(){
        clearLoggedinFlagInUserDefaults()
        clearAPITokensFromKeyChain()
        shouldFetchNewData = true
        self.viewDidAppear(true)
    }


    // 1. Clears the NSUserDefaults flag
    func clearLoggedinFlagInUserDefaults() {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.removeObjectForKey("userLoggedIn")
        defaults.synchronize()
    }
    
    // 3. Clears API Auth token from Keychain
    func clearAPITokensFromKeyChain () {
        // clear API Auth Token
        if let userToken = Keys.passwordForAccount("Auth_Token", service: "KeyChainService") {
            Keys.deletePasswordForAccount(userToken, account: "Auth_Token", service: "KeyChainService")
        }
        
        // clear API Auth Expiry
        if let userTokenExpiryDate = Keys.passwordForAccount("Auth_Token_Expiry",
                                                                       service: "KeyChainService") {
            Keys.deletePasswordForAccount(userTokenExpiryDate, account: "Auth_Token_Expiry",
                                                    service: "KeyChainService")
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
*/
}

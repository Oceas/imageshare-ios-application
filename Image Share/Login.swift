//
//  ViewController.swift
//  Image Share
//
//  Created by Deni on 5/27/16.
//  Copyright © 2016 ImageShare. All rights reserved.
//

import UIKit
import Photos
import CoreData
import CoreImage
import Alamofire
import SwiftyJSON

class Login: UIViewController {
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var ForgotPass: UIButton!
    @IBOutlet weak var Register: UIButton!

    let HttpCLAZ = HTTPRequests()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateUserLoggedInFlag() {
        // Update the NSUserDefaults flag
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject("loggedIn", forKey: "userLoggedIn")
        defaults.synchronize()
    }
    
    func saveApiTokenInKeychain(tokenDict:NSDictionary) {
        // Store API AuthToken and AuthToken expiry date in KeyChain
        tokenDict.enumerateKeysAndObjectsUsingBlock({ (dictKey, dictObj, stopBool) -> Void in
            let myKey = dictKey as! String
            let myObj = dictObj as! String
            
            if myKey == "api_authtoken" {
                Keys.setPassword(myObj, account: "Auth_Token", service: "KeyChainService")
            }
            
            if myKey == "authtoken_expiry" {
                Keys.setPassword(myObj, account: "Auth_Token_Expiry", service: "KeyChainService")
            }
        })
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func SignIn(sender: AnyObject) {
        
        if (self.username.text?.characters.count) < 1 && (self.password.text?.characters.count) < 1{
            self.displayAlertMessage("Error", alertDescription: "Please Enter Login Information")
        }
        else{
            self.makeSignInRequest(username.text!, userPassword: password.text!)
            
        }
    }

    func displayAlertMessage(alertTitle:String, alertDescription:String) -> Void {
        let errorAlert = UIAlertView(title:alertTitle, message:alertDescription, delegate:nil, cancelButtonTitle:"OK")
        errorAlert.show()
    }
    
    func makeSignInRequest(userEmail:String, userPassword:String) {
        // Create HTTP request and set request Body
        let httpRequest = HttpCLAZ.buildRequest("login.php", method: "POST", authType: HTTPRequestAuthType.HTTPBasicAuth)
        
       // httpRequest.HTTPBody = "{\"email\":\"\(self.username.text)\",\"password\":\"\(encrypted_password)\"}".dataUsingEncoding(NSUTF8StringEncoding);
        //httpRequest.HTTPBody = ("email="+self.username.text!+"&password=" + encrypted_password!).dataUsingEncoding(NSUTF8StringEncoding)
        httpRequest.HTTPBody = ("{\"email\":\"\(self.username.text)\",\"password\":\"\(self.password.text)\"}").dataUsingEncoding(NSUTF8StringEncoding)
        
        HttpCLAZ.sendRequest(httpRequest, completion: {(data:NSData!, error:NSError!) in
            // Display error
            if error != nil {
                let errorMessage = self.HttpCLAZ.getErrorMessage(error)
                self.displayAlertMessage("Error", alertDescription: errorMessage as String)
                
                return
            }
            self.updateUserLoggedInFlag()
            do
            {
            if let responseDict = try NSJSONSerialization.JSONObjectWithData(data,
                options: NSJSONReadingOptions.AllowFragments) as? NSDictionary {
            var _ : Bool
            
            // save API AuthToken and ExpiryDate in Keychain
            self.saveApiTokenInKeychain(responseDict)
            self.performSegueWithIdentifier("dismissLogin", sender: self)
                }
            }
            
        catch let jsonerror as NSError {
            print(jsonerror)
            }
        })
    }
}


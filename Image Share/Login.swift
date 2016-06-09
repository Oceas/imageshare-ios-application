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


class Login: UIViewController {
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var ForgotPass: UIButton!
    @IBOutlet weak var Register: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func UserLogIn(){
        self.updateUserLoggedInFlag()
        self.performSegueWithIdentifier("dismissLogin", sender: self)
    }
    
    
    @IBAction func SignIn(sender: UIButton) {
        if (self.username.text?.characters.count) < 1 && (self.password.text?.characters.count) < 1{
            self.displayAlertMessage("Error", alertDescription: "Please Enter Login Information")
        }
        else{
            Alamofire.request(.POST, "http://cop4331project.tk/android_api/login.php", parameters: ["email":self.username.text!,"password":self.password.text!]) .responseJSON { response in // 1
                //print(response.request)  // original URL request
                //print(response.response) // URL response
                //print(response.data)     // server data
                //print(response.result)   // result of response serialization
                
                if let jsn = response.result.value {
                    if let checkpoint = jsn as? [String: AnyObject]{
                        if let i = checkpoint["error"] as? NSInteger{
                            if (i == 0){
                                self.saveApiTokenInKeychain(self.password.text!,password:self.password.text!)
                                self.UserLogIn()
                            }
                            else{
                                self.displayAlertMessage("Error", alertDescription: checkpoint["message"] as! NSString as String)
                            }
                        }
                    }
                }
            }
        }
    }

    func displayAlertMessage(alertTitle:String, alertDescription:String) -> Void {
        let errorAlert = UIAlertView(title:alertTitle, message:alertDescription, delegate:nil, cancelButtonTitle:"OK")
        errorAlert.show()
    }

    func updateUserLoggedInFlag() {
        // Update the NSUserDefaults flag
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject("loggedIn", forKey: "userLoggedIn")
        defaults.synchronize()
    }
    
    func saveApiTokenInKeychain(username:String,password:String) {
        // Store Password
        Keys.setPassword(password, account:username, service: "KeyChainService")
    }
}


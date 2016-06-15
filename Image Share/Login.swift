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
import LocalAuthentication


class Login: UIViewController {
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var ForgotPass: UIButton!
    @IBOutlet weak var Register: UIButton!
    @IBOutlet weak var Touch: UISwitch!
    var Pass:UITextField?
    var User:UITextField?
    var Uid:NSString?

    override func viewDidLoad() {
        super.viewDidLoad()
        Touch.addTarget(self, action: #selector(Login.TouchSetting), forControlEvents: UIControlEvents.ValueChanged)
        encryption()
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if defaults.boolForKey("TouchEnabled"){
            Touch.on = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func TouchSetting(){
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(self.Touch.on, forKey: "TouchEnabled")
        defaults.synchronize()
        if self.Touch.on {
            self.registerThumbID()
        }
        else{
            self.username.text?.removeAll()
            self.password.text?.removeAll()
            self.DeleteUserInfo()
        }
    }
    
    func UsernameTextField(textField: UITextField!)
    {
        textField.placeholder = "Username"
        User = textField
    }
    
    func PasswordTextField(textField: UITextField!)
    {
        textField.placeholder = "Password"
        textField.secureTextEntry = true
        Pass = textField
    }
    
    func registerThumbID(){
        
        let NewUserAlert = UIAlertController(title:"UserInfo", message:"Enter Login Crudentials", preferredStyle: UIAlertControllerStyle.Alert)
        NewUserAlert.addTextFieldWithConfigurationHandler(UsernameTextField)
        NewUserAlert.addTextFieldWithConfigurationHandler(PasswordTextField)
        NewUserAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler:{
            (data) -> Void in
            self.Touch.on = false
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setBool(self.Touch.on, forKey: "TouchEnabled")
            defaults.synchronize()
        }))
        NewUserAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:{
            (data) -> Void in
            self.username.text = self.User?.text
            self.password.text = self.Pass?.text
            self.serverLog()
        }))
        self.presentViewController(NewUserAlert, animated: true, completion: nil)
 
    }
    
    func UserLogIn(){
        self.updateUserLoggedInFlag()
        self.performSegueWithIdentifier("dismissLogin", sender: self)
    }
    
    
    @IBAction func SignIn(sender: UIButton) {
        //self.encryption()
        self.serverLog()
    }
    
    func serverLog(){
        if (self.username.text?.characters.count) < 1 && (self.password.text?.characters.count) < 1{
            self.displayAlertMessage("Error", alertDescription: "Please Enter Login Information")
            if self.Touch.on {
                self.registerThumbID()
            }
        }
        else{
            Alamofire.request(.POST, "http://cop4331project.tk/android_api/login.php", parameters: ["email":self.username.text!,"password":self.password.text!]) .responseJSON { response in // 1
                //print(response.request)  // original URL request
                //print(response.response) // URL response
                //print(response.data)     // server data
                //print(response.result)   // result of response serialization
                
                if let jsn = response.result.value {
                    if let checkpoint = jsn as? [String: AnyObject]{
                        print(checkpoint)
                        if let i = checkpoint["error"] as? NSInteger{
                            if (i == 0){
                                if let ui = checkpoint["uid"] as? NSString{
                                self.Uid = ui
                                self.SetUserInfo()
                                self.UserLogIn()
                                }
                            }
                            else{
                                self.displayAlertMessage("Error", alertDescription: checkpoint["message"] as! NSString as String)
                                if self.Touch.on {
                                    self.Touch.on = false
                                    let defaults = NSUserDefaults.standardUserDefaults()
                                    defaults.setBool(self.Touch.on, forKey: "TouchEnabled")
                                    defaults.synchronize()
                                }
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
    
    func encryption(){
        let defaults = NSUserDefaults.standardUserDefaults()
        if(defaults.boolForKey("TouchEnabled")){
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.DeviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "LogIn By TouchID"
            
            context.evaluatePolicy(.DeviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                [unowned self] (success: Bool, authenticationError: NSError?) -> Void in
                
                dispatch_async(dispatch_get_main_queue()) {
                    if success {
                        self.RetrieveInfo()
                        self.serverLog()
                    } else {
                        if let error = authenticationError {
                            if error.code == LAError.UserFallback.rawValue {
                                //FALL BACK IF CANCLED
                                self.Touch.on = false
                                let defaults = NSUserDefaults.standardUserDefaults()
                                defaults.setBool(self.Touch.on, forKey: "TouchEnabled")
                                defaults.synchronize()
                            }
                        }
                        return
                        //self.displayAlertMessage("Authentication failed", alertDescription:"Your fingerprint could not be verified; please try again.")
                    }
                }
            }
        } else {
            self.displayAlertMessage("Touch ID not available", alertDescription:"Your device is not configured for Touch ID.")
            self.Touch.on = false
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setBool(self.Touch.on, forKey: "TouchEnabled")
            defaults.synchronize()
            //self.Touch.hidden = true
        }
        }
    }
    
    func RetrieveInfo() {
        if let utext = KeychainWrapper.stringForKey("username") {
            if let ptext = KeychainWrapper.stringForKey("password") {
            self.username.text = utext
            self.password.text = ptext
            }
        }
    }
    
    func SetUserInfo() {
            KeychainWrapper.setString(self.username.text!, forKey: "username")
            KeychainWrapper.setString(self.password.text!, forKey: "password")
            KeychainWrapper.setString(self.Uid! as String, forKey: "UserID")
    }
    
    func DeleteUserInfo() {
        KeychainWrapper.removeObjectForKey("username")
        KeychainWrapper.removeObjectForKey("password")
        KeychainWrapper.removeObjectForKey("UserID")
    }

}

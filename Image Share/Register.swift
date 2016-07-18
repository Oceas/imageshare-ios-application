//
//  Register.swift
//  Image Share
//
//  Created by Deni on 6/3/16.
//  Copyright © 2016 ImageShare. All rights reserved.
//

import UIKit
import Alamofire

class Register: UIViewController {
    
    @IBOutlet weak var Fname: UITextField!
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var Email: UITextField!
    @IBOutlet weak var Password: UITextField!
    @IBOutlet weak var RPassword: UITextField!


    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func Create(sender: UIButton) {
        if Fname.text == "" || phoneNumber.text == "" || Email.text == "" || Password.text == "" || RPassword.text == ""{
            
            let alert = UIAlertController(title: "Invaled Entry", message: "Please Complete All Form Data", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler:{ (ACTION :UIAlertAction!)in
                print()
            }))
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
        
        else{
            if Password.text != RPassword.text{
                let alert = UIAlertController(title: "Error", message: "Passwords Don't Match", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler:{ (ACTION :UIAlertAction!)in
                    print()
                }))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            
            else{
                //Send to Server
                Alamofire.request(.POST, "http://imageshare.io/api/register.php", parameters: ["name":self.Fname.text!,"email":self.Email.text!,"password":self.Password.text!,"phone_number":self.phoneNumber.text!]) .responseJSON { response in // 1
                    
                    //print(response.request)  // original URL request
                    //print(response.response) // URL response
                    //print(response.data)     // server data
                    //print(response.result)   // result of response serialization
 
                    if let jsn = response.result.value {
                        //print(jsn)
                        if let content = jsn as? NSDictionary{
                            if let i = content["error"] as? Int{
                                if i == 0{
                                    self.successfull()
                                }
                                else{
                                    if let messages = content["message"] as? String{
                                    let alert = UIAlertController(title: "Error", message: messages, preferredStyle: UIAlertControllerStyle.Alert)
                                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler:{ (ACTION :UIAlertAction!)in
                                        print()
                                    }))
                                    self.presentViewController(alert, animated: true, completion: nil)
                                    }
                                }
                            }
                        }
                    }
                }
                
            }
        }
        
    }
        
        func successfull(){
            let alert = UIAlertController(title: "Success", message: "Check Email For Activation Link!", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler:{ (ACTION :UIAlertAction!)in
                print()
            }))
            self.presentViewController(alert, animated: true, completion: nil)
            Fname.text?.removeAll(keepCapacity: false)
            phoneNumber.text?.removeAll(keepCapacity: false)
            Email.text?.removeAll(keepCapacity: false)
            Password.text?.removeAll(keepCapacity: false)
            RPassword.text?.removeAll(keepCapacity: false)
        }

}

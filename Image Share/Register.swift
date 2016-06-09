//
//  Register.swift
//  Image Share
//
//  Created by Deni on 6/3/16.
//  Copyright © 2016 ImageShare. All rights reserved.
//

import UIKit

class Register: UIViewController {
    
    @IBOutlet weak var Fname: UITextField!
    @IBOutlet weak var Lname: UITextField!
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
        if Fname.text == "" || Lname.text == "" || Email.text == "" || Password.text == "" || RPassword.text == ""{
            
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
                
                let alert = UIAlertController(title: "Success", message: "Account Created", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler:{ (ACTION :UIAlertAction!)in
                    print()
                }))
                self.presentViewController(alert, animated: true, completion: nil)
                Fname.text?.removeAll(keepCapacity: false)
                Lname.text?.removeAll(keepCapacity: false)
                Email.text?.removeAll(keepCapacity: false)
                Password.text?.removeAll(keepCapacity: false)
                RPassword.text?.removeAll(keepCapacity: false)
                
            }
        }
        
    }


}

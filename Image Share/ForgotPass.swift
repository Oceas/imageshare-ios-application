//
//  ForgotPass.swift
//  Image Share
//
//  Created by Deni on 6/3/16.
//  Copyright © 2016 ImageShare. All rights reserved.
//

import UIKit

class ForgotPass: UIViewController {

    @IBOutlet weak var Email: UITextField!
   
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func Submit(sender: UIButton) {
        
        if Email.text == "" {
            let alert = UIAlertController(title: "Invaled Entry", message: "Enter Valid Email", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler:{ (ACTION :UIAlertAction!)in
                print()
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else{
            let alert = UIAlertController(title: "Email Sent!", message: "If Email is valid, link to password reset is sent", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler:{ (ACTION :UIAlertAction!)in
                print()
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }


}

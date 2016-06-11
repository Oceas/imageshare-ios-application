//
//  MenuMain.swift
//  Image Share
//
//  Created by Deni on 6/6/16.
//  Copyright © 2016 ImageShare. All rights reserved.
//

import UIKit
import LocalAuthentication

class MenuMain: UIViewController {
    @IBOutlet weak var Upload: UIButton!
    @IBOutlet weak var ViewPhotos: UIButton!
    @IBOutlet weak var Account: UIButton!
    @IBOutlet weak var SpaceLeft: UIProgressView!


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        //super.viewDidAppear(true)
        let defaults = NSUserDefaults.standardUserDefaults()

        
        if defaults.objectForKey("userLoggedIn") == nil {
           self.singout()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func Logoutt(sender: UIButton) {
        self.lgtap()
    }
    
   
    func lgtap(){
        clearLoggedinFlagInUserDefaults()
        self.singout()
    }


    // 1. Clears the NSUserDefaults flag
    func clearLoggedinFlagInUserDefaults() {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.removeObjectForKey("userLoggedIn")
        defaults.synchronize()
    }
    
    func singout(){
        self.performSegueWithIdentifier("signingOut", sender: self)
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

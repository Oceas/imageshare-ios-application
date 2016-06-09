//
//  AccountInfo.swift
//  Image Share
//
//  Created by Deni on 6/6/16.
//  Copyright © 2016 ImageShare. All rights reserved.
//

import UIKit

class AccountInfo: UIViewController {
    @IBOutlet weak var Email: UILabel!
    @IBOutlet weak var StorageCap: UILabel!
    @IBOutlet weak var StorageLeft: UILabel!
    @IBOutlet weak var Username: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func UpdatePassword(sender: AnyObject) {
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

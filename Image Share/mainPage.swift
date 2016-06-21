//
//  mainPage.swift
//  Image Share
//
//  Created by Deni on 6/20/16.
//  Copyright © 2016 ImageShare. All rights reserved.
//

import UIKit
import BTNavigationDropdownMenu
import LocalAuthentication

class mainPage: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    @IBOutlet weak var StoryCollection: UICollectionView!

    var menuView: BTNavigationDropdownMenu!
    override func viewDidLoad() {
        super.viewDidLoad()
            let items = ["Home", "Upload", "Account Info", "LogOut", "Top Picks"]
            self.navigationController?.navigationBar.translucent = false
            self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.0/255.0, green:180/255.0, blue:220/255.0, alpha: 1.0)
            self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
            
            menuView = BTNavigationDropdownMenu(navigationController: self.navigationController, title: items[0], items: items)
            menuView.cellHeight = 50
            menuView.cellBackgroundColor = self.navigationController?.navigationBar.barTintColor
            menuView.cellSelectionColor = UIColor(red: 0.0/255.0, green:160.0/255.0, blue:195.0/255.0, alpha: 1.0)
            menuView.keepSelectedCellColor = true
            menuView.cellTextLabelColor = UIColor.whiteColor()
            menuView.cellTextLabelFont = UIFont(name: "Avenir-Heavy", size: 17)
            menuView.cellTextLabelAlignment = .Left // .Center // .Right // .Left
            menuView.arrowPadding = 15
            menuView.animationDuration = 0.5
            menuView.maskBackgroundColor = UIColor.blackColor()
            menuView.maskBackgroundOpacity = 0.3
            menuView.didSelectItemAtIndexHandler = {(indexPath: Int) -> () in
                print("Did select item at index: \(indexPath)")
                switch indexPath {
                case 0:
                    return
                case 1:
                    self.Uploading()
                case 2:
                    self.accountInfo()
                case 3:
                    self.loggingout()
                default:
                    return
                }
            }
            
            self.navigationItem.titleView = menuView
        }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        let defaults = NSUserDefaults.standardUserDefaults()
        if defaults.objectForKey("userLoggedIn") == nil {
            self.loggingout()
        }
    }
    
    func loggingout(){
        self.clearLoggedinFlagInUserDefaults()
        self.performSegueWithIdentifier("Log_Out", sender: self)
    }
    
    func Uploading(){
        self.performSegueWithIdentifier("Uploading", sender: self)
    }
    
    func accountInfo(){
        self.performSegueWithIdentifier("AccountInfo", sender: self)
    }
    
    func clearLoggedinFlagInUserDefaults() {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.removeObjectForKey("userLoggedIn")
        defaults.synchronize()
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        let orientation: UIInterfaceOrientationMask = [UIInterfaceOrientationMask.Portrait, UIInterfaceOrientationMask.Portrait]
        return orientation
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Story", forIndexPath: indexPath) as! StoryCell
        
        return cell
    }


}

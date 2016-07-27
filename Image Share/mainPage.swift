//
//  mainPage.swift
//  Image Share
//
//  Created by Deni on 6/20/16.
//  Copyright © 2016 ImageShare. All rights reserved.
//

import UIKit
import BTNavigationDropdownMenu
import Alamofire
import LocalAuthentication
import Haneke
import Kingfisher

class mainPage: UIViewController{
    @IBOutlet weak var StoryCollection: UICollectionView!
    @IBOutlet weak var UserPhoto: UIImageView!
    @IBOutlet weak var Tags: UILabel!
    @IBOutlet weak var Name: UILabel!
    @IBOutlet weak var Description: UITextView!

    
    @IBOutlet weak var ContainerItem: UIView!
    weak var currentViewController: UIViewController?


    var menuView: BTNavigationDropdownMenu!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.currentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("Stories")
        self.currentViewController!.view.translatesAutoresizingMaskIntoConstraints = false
        self.addChildViewController(self.currentViewController!)
        self.addSubview(self.currentViewController!.view, toView: self.ContainerItem)
        self.currentViewController!.view.reloadInputViews()
        self.currentViewController!.view.setNeedsLayout()

            let items = ["Home", "Upload", "Account Info", "LogOut"]
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
        let tap = UITapGestureRecognizer(target: self, action: #selector(mainPage.edit_ProfilePic))
        self.UserPhoto.addGestureRecognizer(tap)
        self.UserPhoto.userInteractionEnabled = true
        self.UserInformation({ namez in
            self.Name.text = namez
            
        })
        self.currentViewController?.reloadInputViews()
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        let defaults = NSUserDefaults.standardUserDefaults()
        if defaults.objectForKey("userLoggedIn") == nil {
            self.loggingout()
        }
        
    }
    
    @IBAction func Tabviewer(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            let newViewController = self.storyboard?.instantiateViewControllerWithIdentifier("Stories")
            newViewController!.view.translatesAutoresizingMaskIntoConstraints = false
            self.cycleFromViewController(self.currentViewController!, toViewController: newViewController!)
            self.currentViewController = newViewController
        }
        else {
            let newViewController = self.storyboard?.instantiateViewControllerWithIdentifier("Moments")
            newViewController!.view.translatesAutoresizingMaskIntoConstraints = false
            self.cycleFromViewController(self.currentViewController!, toViewController: newViewController!)
            self.currentViewController = newViewController
        }

    }
    func edit_ProfilePic(){
        
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
    
    func cycleFromViewController(oldViewController: UIViewController, toViewController newViewController: UIViewController) {
        oldViewController.willMoveToParentViewController(nil)
        self.addChildViewController(newViewController)
        self.addSubview(newViewController.view, toView:self.ContainerItem!)
        newViewController.view.alpha = 0
        //newViewController.viewDidLoad()
        newViewController.view.reloadInputViews()
        newViewController.view.setNeedsLayout()
        UIView.animateWithDuration(0.5, animations: {
            newViewController.view.alpha = 1
            oldViewController.view.alpha = 0
            },
                                   completion: { finished in
                                    //oldViewController.viewDidDisappear(true)
                                    oldViewController.view.removeFromSuperview()
                                    oldViewController.removeFromParentViewController()
                                    newViewController.didMoveToParentViewController(self)
        })
    }
    
    func addSubview(subView:UIView, toView parentView:UIView) {
        parentView.addSubview(subView)
        
        var viewBindingsDict = [String: AnyObject]()
        viewBindingsDict["subView"] = subView
        parentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[subView]|",
            options: [], metrics: nil, views: viewBindingsDict))
        parentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[subView]|",
            options: [], metrics: nil, views: viewBindingsDict))
    }

    func UserInformation(completion: (nUser: String) -> Void){
        if let userID = KeychainWrapper.stringForKey("UserID"){
            Alamofire.request(.POST, "http://imageshare.io/api/v1/getuserinfo.php", parameters: ["userId":userID])
                .responseJSON { response in // 1
                if let jsn = response.result.value {
                    //print(jsn)
                    if let first = jsn as? NSDictionary{
                        if let second = first["error"] as? Int{
                            if (second == 0){
                                if let third = first["user"] as? NSDictionary{
                                    if let name = third ["name"] as? String {
                                        completion(nUser: name)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}


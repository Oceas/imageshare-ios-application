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
import AlamofireImage

class mainPage: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    @IBOutlet weak var StoryCollection: UICollectionView!
    @IBOutlet weak var UserPhoto: UIImageView!
    @IBOutlet weak var Tags: UILabel!
    @IBOutlet weak var Name: UILabel!
    @IBOutlet weak var Description: UITextView!
    @IBOutlet weak var Searcher: UISearchBar!
    var AlbumCollection = [NSString]()
    var cellData = [CellContent]()
    
    struct CellContent {
        var ID:String!
        var PhotoURL:NSString!
        init(ID:String,PhotoURL:NSString){
            self.ID = ID
            self.PhotoURL = PhotoURL
        }
    }

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
        self.UserInformation(){ namez in
            self.Name.text = namez
            
        }
        //self.StoryCollection.delegate = self
        //self.StoryCollection.dataSource = self
        self.UserAlbums(){_ in
           //print(self.cellData.count)
            //self.StoryCollection.reloadData()
            self.StoryCollection.delegate = self
            self.StoryCollection.dataSource = self
            }
        }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        let defaults = NSUserDefaults.standardUserDefaults()
        if defaults.objectForKey("userLoggedIn") == nil {
            self.loggingout()
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
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.cellData.count
    }
    
    /*
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        StoryCollection.collectionViewLayout.invalidateLayout()
    }
*/
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Story", forIndexPath: indexPath) as! StoryCell
        
        let cells = cellData[indexPath.row]

        
        
        cell.configure(cells.PhotoURL as String, cname: cells.ID)

        return cell
    }
    
    func UserAlbums(completion: (result: String) -> Void){
        if let USERID = KeychainWrapper.stringForKey("UserID"){
        Alamofire.request(.POST, "http://imageshare.io/api/getalbums.php", parameters: ["userId":USERID]) .responseJSON { response in
                if let jsn = response.result.value {
                    if let returnval = jsn as? [String:AnyObject]{
                        if let AlbumInfo = returnval["albums"] as? NSArray{
                            for albums in AlbumInfo{
                                if let album = albums as? [String:AnyObject]{
                                    if let albumID = album["albumId"] as? NSString{
                                        if let albumz_name = album["albumName"] as? String {
                                        self.albumCover(albumID){(fifth: String) in
                                            self.populateData(albumz_name, datatwo: fifth)
                                            if ((AlbumInfo.indexOfObject(albums) + 1) == AlbumInfo.count){
                                            completion(result: "done")
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
        }
    }
    
    func albumCover(idAlbum:NSString,completion: (result: String) -> Void){
        if let USERID = KeychainWrapper.stringForKey("UserID"){
            //for album in self.AlbumCollection{
            Alamofire.request(.POST, "http://imageshare.io/api/getalbumdetail.php", parameters: ["userId":USERID,"albumId":idAlbum]) .responseJSON { response in // 1
                if let jsn = response.result.value {
                        if let first = jsn as? [String:AnyObject]{
                            if let second = first["album"] as? NSDictionary{
                               // print(second)
                                if let third = second["images"] as? NSArray{
                                    //print(third)
                                    if let fourth = third.firstObject as? NSDictionary{
                                        if let fifth = fourth["imageLocation"] as? NSString{
                                             completion(result: fifth as String)
                                        }
                                        
                                    }
                                    
                                }
                            }
                        }
                }
               // print(self.cellData.count)
            }
        //}

        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let picDimension = self.view.frame.size.width/2
        return CGSizeMake(picDimension, picDimension)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat{
        return 0
    }
    
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat{
        return 0
    }
    
    func populateData(dataone:String,datatwo:NSString){
    self.cellData.append(CellContent(ID: dataone, PhotoURL: datatwo))
    }
    
    func UserInformation(completion: (nUser: String) -> Void){
        if let userID = KeychainWrapper.stringForKey("UserID"){
            Alamofire.request(.POST, "http://imageshare.io/api/getuserinfo.php", parameters: ["userId":userID]) .responseJSON { response in // 1
                if let jsn = response.result.value {
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


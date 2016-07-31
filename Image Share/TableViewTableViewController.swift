//
//  TableViewTableViewController.swift
//  Image Share
//
//  Created by Deni on 5/27/16.
//  Copyright © 2016 ImageShare. All rights reserved.
//

import UIKit
import Photos
import CoreData
import CoreImage
import BTNavigationDropdownMenu
import LocalAuthentication



class TableViewTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    @IBOutlet weak var Table: UITableView!
    
    
    //Table Array
    var TableData:Array< datastruct > = Array < datastruct >()
    
    //Table data
    struct datastruct
    {

        var Album:PHAssetCollection?
        var Photoz:PHAsset?
        var thumbnail:UIImage?
        var name:String?
        
        init(inphoto:PHAssetCollection, ass:PHAsset, title:String)
        {
            Album = inphoto
            Photoz = ass
            name = title
        }
    }

    var menuView:BTNavigationDropdownMenu!
    override func viewDidLoad() {
        super.viewDidLoad()

        let items = ["Home", "Upload", "Account Info", "LogOut"]
        self.navigationController?.navigationBar.translucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.0/255.0, green:180/255.0, blue:220/255.0, alpha: 1.0)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        menuView = BTNavigationDropdownMenu(navigationController: self.navigationController, title: items[1], items: items)
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
                self.gohome()
            case 1:
                return
            case 2:
                self.accountInfo()
            case 3:
                self.loggingout()
            default:
                return
            }
        }
        self.navigationItem.titleView = menuView
        //self.navigationItem.title = "Albums"
        //self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Home", style: .Plain, target: self, action: #selector(TableViewTableViewController.gohome(_:)))
        Table.delegate = self
        Table.dataSource = self
        //Table.rowHeight = UITableViewAutomaticDimension
        Table.scrollEnabled = true
        setupPhotos()
    }
    
    override func viewDidAppear(animated: Bool) {
                Table.reloadData()
        
    }
    
    func accountInfo(){
        self.performSegueWithIdentifier("account_info", sender: self)
    }
    
    func loggingout(){
        self.clearLoggedinFlagInUserDefaults()
        self.performSegueWithIdentifier("log_outs", sender: self)
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return TableData.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! TableViewCell
        var data = TableData[indexPath.row]
        
        if data.thumbnail == nil {
            let imageRequestOptions = PHImageRequestOptions()
            imageRequestOptions.networkAccessAllowed = true
            imageRequestOptions.synchronous = true
            imageRequestOptions.deliveryMode = .HighQualityFormat
            
            PHImageManager.defaultManager().requestImageForAsset(
                data.Photoz!,
                targetSize: (cell.CoverImage?.intrinsicContentSize())!,
                contentMode: .AspectFit,
                options: imageRequestOptions,
                resultHandler: { (img, info) -> Void in
                    data.thumbnail = img
                    cell.CoverImage?.image = data.thumbnail
                    cell.AlbumName?.text = data.name
            })
        } else {
            cell.CoverImage?.image = data.thumbnail
            cell.AlbumName?.text = data.name
        }
        
        return cell
    }
    
    private func setupPhotos() {
        let fetchOptions = PHFetchOptions()
        
        let smartAlbums = PHAssetCollection.fetchAssetCollectionsWithType(.SmartAlbum, subtype: .Any, options: fetchOptions)
        
        let topLevelfetchOptions = PHFetchOptions()
        
        let topLevelUserCollections = PHCollectionList.fetchTopLevelUserCollectionsWithOptions(topLevelfetchOptions)
        
        let allAlbums = [topLevelUserCollections, smartAlbums]
        
        for i in 0 ..< allAlbums.count {
            let result = allAlbums[i]
            
            result.enumerateObjectsUsingBlock { (asset, index, stop) -> Void in
                if let a = asset as? PHAssetCollection {
                    let opts = PHFetchOptions()
                    
                    if #available(iOS 9.0, *) {
                        opts.fetchLimit = 1
                    }
                    
                    let ass = PHAsset.fetchAssetsInAssetCollection(a, options: opts)
                    if let b = ass.firstObject as? PHAsset {
                        self.TableData.append(datastruct(inphoto: a, ass: b, title: a.localizedTitle!))
                    }
                }
                
                if i == (allAlbums.count - 1) && index == (result.count - 1) {
                    self.TableData.sortInPlace({ (a, b) -> Bool in
                        return a.Album!.localizedTitle > b.Album!.localizedTitle
                    })
                    self.Table.reloadData()
                }
            }
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "Package") {
            let svc = segue.destinationViewController as! CollectionViewController
            let button = sender as! TableViewCell
            let indexPath = Table.indexPathForCell(button)
            svc.dataPassed = TableData[indexPath!.row].Album
        }
    }
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func gohome(){
        performSegueWithIdentifier("goinghome", sender: self)
    }

}

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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        Table.delegate = self
        Table.dataSource = self
        //Table.rowHeight = UITableViewAutomaticDimension
        Table.scrollEnabled = true
        setupPhotos()
    }
    
    override func viewDidAppear(animated: Bool) {
                Table.reloadData()
        
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

}

//
//  PopOverTableViewController.swift
//  Image Share
//
//  Created by Deni on 6/29/16.
//  Copyright © 2016 ImageShare. All rights reserved.
//

import UIKit
import Alamofire
import LocalAuthentication

protocol PopOverTableViewControllerDelegate
{
    func saveText(strText : NSString)
}

class PopOverTableViewController: UITableViewController {
    
    var TableData:Array<AlbumData> = Array<AlbumData>()
    
    struct AlbumData{
        var name:String?
        var identity:String?
        
        init(name:String,identity:String){
            self.name = name
            self.identity = identity
        }
    }
    
    @IBOutlet var MyTable: UITableView!
    var delegate:PopOverTableViewControllerDelegate?
    var NewAlbumName:UITextField?
    var AlbumDesc:UITextField?
    var sAlbumName:NSString?
    var sAlbumDesc:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.MyTable.delegate = self
        self.MyTable.dataSource = self
        self.MyTable.scrollEnabled = true
        self.GetAllAlbums(){ _ in
           self.MyTable.reloadData()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
/*
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

*/
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return TableData.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Celli", forIndexPath: indexPath) as! PopOverTableViewCell
        
        let data = self.TableData[indexPath.row]
        
        cell.Album_Name.text = data.name
        cell.albumid = data.identity

        return cell
    }

    @IBAction func CreateTheAlbum(sender: AnyObject) {
        
        let alert = UIAlertController(title: "Create Album", message: "Enter Album Name and Description", preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler(NewAlbum)
        alert.addTextFieldWithConfigurationHandler(NewAlbumDesc)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler:nil))
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:{
            (data) -> Void in
            self.sAlbumName = self.NewAlbumName?.text
            self.sAlbumDesc = self.AlbumDesc?.text
            self.CreateAlbumAPI()
        }))
        self.presentViewController(alert, animated: true, completion:nil)
    }
    
    func NewAlbum(textField: UITextField!)
    {
        textField.placeholder = "Album Name"
        textField.secureTextEntry = false
        NewAlbumName = textField
    }
    
    func NewAlbumDesc(textField: UITextField!){
        textField.placeholder = "Album Description"
        textField.secureTextEntry = false
        AlbumDesc = textField
    }
    
    func CreateAlbumAPI(){
        if let userID = KeychainWrapper.stringForKey("UserID"){
            Alamofire.request(.POST, "http://imageshare.io/api/createalbum.php", parameters: ["userId":userID,"albumName":self.sAlbumName!,"albumDesc":self.sAlbumDesc!]) .responseJSON { response in // 1
            if let jsn = response.result.value {
                print(jsn)
               if let albuminfo = jsn as? NSDictionary{
                if let errortyp = albuminfo["error"] as? Int{
                    if (errortyp == 0){
                        if((self.delegate) != nil){
                            if let albumnumber = albuminfo["albumId"] as? NSString{
                                dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                                self.delegate?.saveText(albumnumber)
                                self.dismissViewControllerAnimated(true, completion: nil)
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
    
    func GetAllAlbums(completion: (result: String) -> Void){
        if let userID = KeychainWrapper.stringForKey("UserID"){
        Alamofire.request(.POST, "http://imageshare.io/api/getalbums.php", parameters: ["userId":userID]) .responseJSON { response in
                if let jsn = response.result.value {
                    if let albuminfo = jsn as? [String: AnyObject]{
                        if let suc = albuminfo["error"] as? NSInteger{
                            if (suc == 0){
                                if let albums = albuminfo["albums"] as? NSArray{
                                    for album in albums{
                                        if let details = album as? [String: AnyObject]{
                                            if let album_ID = details["albumId"] as? String{
                                                if let album_name = details["albumName"] as? String{
                                                    self.TableData.append(AlbumData(name: album_name, identity: album_ID))
                                                    if ((albums.indexOfObject(album) + 1) == albums.count)
                                                    {
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
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

            self.delegate?.saveText(self.TableData[indexPath.row].identity! as NSString)
            self.dismissViewControllerAnimated(true, completion: nil)
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

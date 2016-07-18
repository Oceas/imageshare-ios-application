//
//  SlideshowView.swift
//  Image Share
//
//  Created by Deni on 7/17/16.
//  Copyright © 2016 ImageShare. All rights reserved.
//

import UIKit
import Alamofire
import Haneke
import AlamofireImage
import AlamofireNetworkActivityIndicator
import Kingfisher


class SlideshowView: UIViewController {

    @IBOutlet weak var NavBar: UINavigationBar!
    @IBOutlet weak var bottombar: UIToolbar!
    @IBOutlet weak var PhotoTitle: UINavigationItem!
    @IBOutlet weak var Trashbtn: UIBarButtonItem!
    @IBOutlet weak var DisplayIMG: UIImageView!
    @IBOutlet weak var PhotoComments: UITextView!


    
    var PhotoPassed:NSDictionary!
    var i = 0
    var isPlaying = false
    var PhotoDetails:Array<PhotoClass> = Array<PhotoClass>()
    var timer = NSTimer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //let imageDownloader = UIImageView.af_sharedImageDownloader


        let swipeRight = UISwipeGestureRecognizer()
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        swipeRight.addTarget(self, action: #selector (SlideshowView.Swipe_Right))
        let swipeLeft = UISwipeGestureRecognizer()
        swipeLeft.addTarget(self, action: #selector (SlideshowView.Swipe_Left))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        let taptap = UITapGestureRecognizer()
        taptap.addTarget(self, action: #selector(SlideshowView.togglehide))


        DisplayIMG.addGestureRecognizer(swipeRight)
        DisplayIMG.addGestureRecognizer(swipeLeft)
        DisplayIMG.addGestureRecognizer(taptap)
        DisplayIMG.userInteractionEnabled = true
        self.DisplayIMG.kf_showIndicatorWhenLoading = true
        

       // print(self.PhotoPassed)

        
        openDict({ _ in
            //print(self.PhotoDetails)
            self.PhotoTitle.title = self.PhotoDetails[self.i].getName()
            var address = [String]()
            //let PURL = NSURL(string: self.PhotoDetails[self.i].getURL())!
            //self.DisplayIMG.hnk_setImageFromURL(PURL, format: Format<UIImage>(name: "original"))
            for item in self.PhotoDetails{
            //self.setImageWith(NSURLRequest(URL: NSURL(string: item.getURL())!))
                address.append(item.getURL())
            }
            self.setImageWith(address)
            //self.DisplayIMG.af_setImageWithURL(PURL)
            self.DisplayIMG.kf_setImageWithURL(NSURL(string: self.PhotoDetails[self.i].getURL())!,
                placeholderImage: nil,
                optionsInfo: [.Transition(ImageTransition.Fade(1.5))])
            self.PhotoComments.text = self.PhotoDetails[self.i].getDesc()
            
        })
        }
    func openDict(comp:(result:String) -> Void){
        if let pos = PhotoPassed["Position"] as? Int{
            if let PhotoCollection = PhotoPassed["Collection"] as? Array<PhotoClass>{
                self.i = pos
                self.PhotoDetails = PhotoCollection
                comp(result:"done")
            }
        }
    }
    
    func Swipe_Right(){
        if (self.i + 1) <= (PhotoDetails.count - 1){
            self.i += 1
        }
        else{
            self.i = 0
        }
        self.changePhoto()
    }
    
    func Swipe_Left(){
        if (self.i - 1) >= 0{
            self.i -= 1
        }
        else{
            self.i = (PhotoDetails.count - 1)
        }
        self.changePhoto()
    }
    
    func setImageWith(request:[String]) {
        
        
        let urls = request.map { NSURL(string: $0)! }
        let prefetcher = ImagePrefetcher(urls: urls, optionsInfo: [.Transition(ImageTransition.Fade(1.5))], progressBlock: nil, completionHandler: {
            (skippedResources, failedResources, completedResources) -> () in
            //print("These resources are prefetched: \(completedResources)")
        })
        prefetcher.start()
        //let URLRequest = NSURLRequest(URL: request)
/*
        self.imageDownloader.downloadImage(URLRequest: request) { response in
            if let image = response.result.value {
                self.imageDownloader.imageCache?.addImage(image, withIdentifier:request.URLString)
            }
        }*/
    }
    

    func changePhoto(){
        let NURL = NSURL(string: self.PhotoDetails[self.i].getURL())!
       // self.DisplayIMG.hnk_cancelSetImage()
        //print(self.PhotoDetails[self.i].getName())
        //self.DisplayIMG.image = nil
    
        self.DisplayIMG.kf_setImageWithURL(NSURL(string: self.PhotoDetails[self.i].getURL())!,
                                           placeholderImage: nil,
                                           optionsInfo: [.Transition(ImageTransition.Fade(1.5))])
       // self.DisplayIMG.hnk_setImageFromURL(NURL)
      /*  self.DisplayIMG.af_setImageWithURL(
            NURL,
            placeholderImage: nil,
            filter: nil,
            imageTransition: .CrossDissolve(1.5),
            runImageTransitionIfCached: true,
            completion:({Result in
                if let imager = Result.data{
                   self.DisplayIMG.image = UIImage(data: imager)
                }
                if self.isPlaying{
                    self.slideshow()
                }
            })
        )
        */
       //self.DisplayIMG.hnk_setImageFromURL(NURL, format: Format<UIImage>(name: "original"))
        /*
        self.DisplayIMG.nk_displayImage(nil)
        self.DisplayIMG.nk_cancelLoading()
        self.setImageWith(ImageRequest(URL: NURL))
        */
        self.PhotoTitle.title = self.PhotoDetails[self.i].getName()
        self.PhotoComments.text = self.PhotoDetails[self.i].getDesc()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func Playbtn(sender: AnyObject) {
        self.isPlaying = !self.isPlaying
        if(self.isPlaying){
            self.bottombar.items![2] = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Stop, target: self, action: #selector(SlideshowView.Playbtn(_:)))
            self.slideshow()
        }
        else{
            self.bottombar.items![2] = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Play, target: self, action: #selector(SlideshowView.Playbtn(_:)))
            self.stopSlide()
            self.timer.invalidate()
        }
    }
    
    @IBAction func goBack(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func stopSlide(){
        self.NavBar.hidden = false
        self.PhotoComments.hidden = false
        self.bottombar.hidden = false
    }
    
    func slideshow(){
        self.NavBar.hidden = true
        self.PhotoComments.hidden = true
        self.bottombar.hidden = true
        self.timer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: #selector(SlideshowView.Swipe_Right), userInfo: nil, repeats: true)
    }
    
    func togglehide(){
        self.NavBar.hidden = !self.NavBar.hidden.boolValue
        self.PhotoComments.hidden = !self.PhotoComments.hidden.boolValue
        self.bottombar.hidden = !self.bottombar.hidden.boolValue
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

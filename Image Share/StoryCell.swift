//
//  StoryCell.swift
//  Image Share
//
//  Created by Deni on 6/21/16.
//  Copyright © 2016 ImageShare. All rights reserved.
//

import Alamofire
import AlamofireImage
import Foundation
import UIKit

class StoryCell: UICollectionViewCell {
    @IBOutlet weak var coverphoto: UIImageView!
    
    @IBOutlet weak var Album_Name: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    var photoURL:String!
    var photoname:String!
    var request: RequestImages?
    
    
    func configure(photoURL:String, cname:String) {
        self.photoURL = photoURL
        self.photoname = cname
        self.reset()
        self.loadImage()
    }
    
    func reset() {
        coverphoto.image = nil
        request?.cancel()
        Album_Name.hidden = true
    }
    
    func loadImage() {
        if let image = CellManager.sharedManager.cachedImage(photoURL!) {
            if let thumb = UIImageJPEGRepresentation(image, 0.5){
            populateCell(UIImage(data: thumb)!)
            return
            }
        }
        self.downloadImage()
    }
    
    func downloadImage() {
        loadingIndicator.startAnimating()
        let urlString = photoURL
        request = CellManager.sharedManager.getNetworkImage(urlString) { image in
            if let thumb = UIImageJPEGRepresentation(image, 0.5){
            self.populateCell(UIImage(data: thumb)!)
            }
        }
    }
    
    func populateCell(image: UIImage) {
        loadingIndicator.stopAnimating()
        coverphoto.image = image
        Album_Name.text = self.photoname
        Album_Name.hidden = false
    }
    

    
}

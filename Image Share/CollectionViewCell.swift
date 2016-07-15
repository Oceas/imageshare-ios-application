//
//  CollectionViewCell.swift
//  Image Share
//
//  Created by Deni on 5/30/16.
//  Copyright © 2016 ImageShare. All rights reserved.
//


import UIKit
import Photos
import CoreData
import CoreImage

class CollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var thumb: UIImageView!
    @IBOutlet weak var Check:UIImageView!
    
    var imageManager: PHImageManager?
    
    var imageAsset: PHAsset? {
        didSet {
            self.imageManager?.requestImageForAsset(imageAsset!, targetSize: CGSize(width: 125, height: 125), contentMode: .AspectFill, options: nil) { image, info in
                self.thumb.image = image
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selected = false
    }
    
    override var selected : Bool {
        didSet {
            self.Check.image = selected ? UIImage.init(named: "Selected") : nil
        }
    }
}

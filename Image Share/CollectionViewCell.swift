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

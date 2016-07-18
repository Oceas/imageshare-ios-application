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
import Haneke
import Kingfisher

class StoryCell: UICollectionViewCell {
    var coverphoto: UIImageView!
    var caption:UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initHelper()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initHelper()
    }
    
    func initHelper() {
        coverphoto = UIImageView(frame: self.contentView.bounds)
        coverphoto.clipsToBounds = true
        coverphoto.contentMode = .ScaleAspectFill
        coverphoto.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        coverphoto.kf_showIndicatorWhenLoading = true
        caption = UILabel(frame: CGRect(x: CGFloat(20), y: CGFloat(150), width: CGFloat(200), height: self.contentView.bounds.height/3))
        caption.clipsToBounds = true
        caption.contentMode = .ScaleToFill
        caption.textColor = UIColor.whiteColor()
        self.contentView.addSubview(coverphoto)
        self.contentView.addSubview(caption)
    }
    
    override func prepareForReuse() {
        coverphoto.kf_cancelDownloadTask()
        coverphoto.image = nil
        caption.text?.removeAll(keepCapacity: false)
    }

    
}

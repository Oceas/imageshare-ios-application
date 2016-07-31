//
//  StoryCell.swift
//  Image Share
//
//  Created by Deni on 6/21/16.
//  Copyright © 2016 ImageShare. All rights reserved.
//

import Alamofire
import Foundation
import UIKit
import Kingfisher

class StoryCell: UICollectionViewCell {
    var coverphoto: UIImageView!
    var caption:UILabel!
    var deleting: UIImageView!
    
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
        coverphoto.contentMode = .ScaleToFill
        coverphoto.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        coverphoto.kf_showIndicatorWhenLoading = true
        deleting = UIImageView(frame: CGRect(x: 150, y: 20, width: 20, height: 20))
        deleting.clipsToBounds = true
        deleting.contentMode = .ScaleAspectFill
        //deleting.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        deleting.image = UIImage(named: "DeleteRed")
        deleting.hidden = true
        caption = UILabel(frame: CGRect(x: CGFloat(20), y: CGFloat(150), width: CGFloat(200), height: self.contentView.bounds.height/3))
        caption.clipsToBounds = true
        caption.contentMode = .ScaleToFill
        caption.textColor = UIColor.whiteColor()
        caption.backgroundColor = UIColor(red: 45/255.0, green:0/255.0, blue:220/255.0, alpha: 0.5)
        self.contentView.addSubview(coverphoto)
        self.contentView.addSubview(deleting)
        self.contentView.addSubview(caption)
    }
    
    override func prepareForReuse() {
        coverphoto.kf_cancelDownloadTask()
        coverphoto.image = nil
        caption.text?.removeAll(keepCapacity: false)
    }

    
}

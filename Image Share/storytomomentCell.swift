//
//  storytomomentCell.swift
//  Image Share
//
//  Created by Deni on 7/26/16.
//  Copyright © 2016 ImageShare. All rights reserved.
//

import UIKit
import Alamofire
import Kingfisher

class storytomomentCell: UITableViewCell {
    @IBOutlet weak var thepic: UIImageView!
    @IBOutlet weak var thecaption: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        thepic.kf_cancelDownloadTask()
        thepic.image = nil
        thecaption.text?.removeAll(keepCapacity: false)
    }


}

//
//  PopOverTableViewCell.swift
//  Image Share
//
//  Created by Deni on 6/29/16.
//  Copyright © 2016 ImageShare. All rights reserved.
//

import UIKit

class PopOverTableViewCell: UITableViewCell {
    @IBOutlet weak var Album_Name: UILabel!
    var albumid:String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

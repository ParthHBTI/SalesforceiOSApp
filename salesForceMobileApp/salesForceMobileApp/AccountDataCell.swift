//
//  AccountDataCell.swift
//  salesForceMobileApp
//
//  Created by HemendraSingh on 20/10/16.
//  Copyright © 2016 Salesforce. All rights reserved.
//

import UIKit

class AccountDataCell: UITableViewCell {

    @IBOutlet weak var TitleLbl: UILabel!
    @IBOutlet weak var TitleNameLbl: UILabel!
    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var userFeedName: UILabel!
    @IBOutlet weak var feedDateStatus: UILabel!
    @IBOutlet weak var likeImage: UIImageView!
    @IBOutlet weak var commentImage: UIImageView!
    @IBOutlet weak var totalLike: UILabel!
    @IBOutlet weak var totalComment: UILabel!
    @IBOutlet weak var shareText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

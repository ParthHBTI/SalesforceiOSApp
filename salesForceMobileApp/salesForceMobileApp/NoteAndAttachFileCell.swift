//
//  NoteAndAttachFileCell.swift
//  salesForceMobileApp
//
//  Created by mac on 18/11/16.
//  Copyright © 2016 Salesforce. All rights reserved.
//

import UIKit

class NoteAndAttachFileCell: UITableViewCell {

    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var delButton: UIButton!
    @IBOutlet weak var fileType: UILabel!
    @IBOutlet weak var fileTitle: UILabel!
    @IBOutlet weak var fileModifyDate: UILabel!
    @IBOutlet weak var fileCreatedBy: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

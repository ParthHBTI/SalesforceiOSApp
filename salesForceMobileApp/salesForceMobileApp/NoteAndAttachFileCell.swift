//
//  NoteAndAttachFileCell.swift
//  salesForceMobileApp
//
//  Created by mac on 18/11/16.
//  Copyright © 2016 Salesforce. All rights reserved.
//

import UIKit

class NoteAndAttachFileCell: UITableViewCell {

    @IBOutlet weak var attachPhoto: UIImageView!
    @IBOutlet weak var attachAndNoteFileName: UILabel!
    @IBOutlet weak var attachNoteTime: UILabel!
    @IBOutlet weak var attachNoteFileSize: UILabel!
    @IBOutlet weak var attachFileExt: UILabel!
       override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

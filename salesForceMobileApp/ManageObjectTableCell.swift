//
//  ManageObjectTableCell.swift
//  salesForceMobileApp
//
//  Created by HemendraSingh on 15/12/16.
//  Copyright © 2016 Salesforce. All rights reserved.
//

import UIKit

class ManageObjectTableCell: UITableViewCell {
    
    @IBOutlet weak var ObjectName: UILabel!
    @IBOutlet weak var ObjectValueTxtField: UITextField!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

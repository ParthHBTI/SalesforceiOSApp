//
//  DataTableViewCell.swift
//  SlideMenuControllerSwift
//
//  Created by Yuji Hato on 11/8/15.
//  Copyright © 2015 Yuji Hato. All rights reserved.
//

import UIKit

struct DataTableViewCellData {
    
    init(imageUrl: String, text: String) {
        self.imageUrl = imageUrl
        self.text = text
    }
    var imageUrl: String
    var text: String
}

class DataTableViewCell : BaseTableViewCell {
    
    @IBAction func convertLead(sender: AnyObject) {
        
    }
    @IBOutlet weak var dataImage: UIImageView!
    @IBOutlet weak var dataText: UILabel!
    @IBOutlet weak var detailText: UILabel!
    @IBOutlet weak var notConnectedImage: UIImageView!
    
    @IBOutlet weak var convertButton: UIButton!
    
    override func awakeFromNib() {
        convertButton.layer.cornerRadius = 4.0
        convertButton.layer.borderWidth = 1
        convertButton.clipsToBounds = true
    }
    
    override class func height() -> CGFloat {
        return 80
    }
    
    override func setData(data: Any?) {
        if let data = data as? DataTableViewCellData {
            self.dataImage.setRandomDownloadImage(80, height: 80)
            self.dataText.text = data.text
        }
    }
}

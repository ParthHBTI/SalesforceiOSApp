//
//  UITableViewController.swift
//  salesForceMobileApp
//
//  Created by HemendraSingh on 08/11/16.
//  Copyright © 2016 Salesforce. All rights reserved.
//

import UIKit

extension UITableViewController {
    
    override func setNavigationBarItem() {
        self.leftBarButtonWithImage(UIImage(named: "back_NavIcon")!)
        //self.leftBarButtonWithImage(UIImage(named: "back_icon")!)
    }
    
     func leftBarButtonWithImage(buttonImage: UIImage) {
        let leftButton: UIBarButtonItem = UIBarButtonItem(image: buttonImage, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.toggleLeft))
        navigationItem.leftBarButtonItem = leftButton;
    }
    
    override public func toggleLeft() {
        self.navigationController?.popViewControllerAnimated(true)
    }
}



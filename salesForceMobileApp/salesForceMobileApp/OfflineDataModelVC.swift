//
//  OfflineDataModelVC.swift
//  salesForceMobileApp
//
//  Created by mac on 12/01/17.
//  Copyright © 2017 Salesforce. All rights reserved.
//

import UIKit

class OfflineDataModelVC: UIViewController {


    class func offlineDataModel() {
        attachAndNoteData()
    }
    
    class func attachAndNoteData() {
        if let arrayOfObjectsData = defaults.objectForKey(offlineAttachKey) as? NSData {
            attachOfflineDic = NSKeyedUnarchiver.unarchiveObjectWithData(arrayOfObjectsData)! as! NSMutableDictionary
        }
        if let arrayOfObjectsData = defaults.objectForKey(onlineAttachKey) as? NSData {
            attachOnlineDic = NSKeyedUnarchiver.unarchiveObjectWithData(arrayOfObjectsData)! as! NSMutableDictionary
        }

    }
}

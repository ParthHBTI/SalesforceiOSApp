//
//  Lead.swift
//  salesForceMobileApp
//
//  Created by HemendraSingh on 25/10/16.
//  Copyright © 2016 Salesforce. All rights reserved.
//

import UIKit

class Lead: NSObject, NSCoding {
    
    var lastName: String?
    var company: String?
    var status: String?
//    var phone: String?
//    var title: String?
    
    
    init(inDict:NSDictionary) {
        super.init()
        self.lastName = inDict["LastName"] as? String
        self.company = inDict["Company"] as? String
        self.status = inDict["Status"] as? String
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.lastName, forKey: "LastName")
        aCoder.encodeObject(self.company, forKey: "Company")
        aCoder.encodeObject(self.status, forKey: "Status")
    }
    
    /*init(lastName: NSString, name: NSString, status: NSString) {
        self.lastName = lastName as String
        self.company = name as String
        self.status = status as String
        
    }*/
    
    class func initWithArray (inArr: NSArray) -> NSArray {
        let allValues:NSMutableArray = []
        for inDictNew in inArr {
            allValues.addObject(Lead(inDict: inDictNew as! NSDictionary))
        }
        return allValues
    }

    required init(coder aDecoder: NSCoder) {
        self.lastName = aDecoder.decodeObjectForKey("LastName") as? String
        self.company = aDecoder.decodeObjectForKey("Company") as? String
        self.status = aDecoder.decodeObjectForKey("Status") as? String
    }
}

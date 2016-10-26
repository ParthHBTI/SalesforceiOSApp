//
//  LeadData.swift
//  salesForceMobileApp
//
//  Created by mac on 25/10/16.
//  Copyright © 2016 Salesforce. All rights reserved.
//

import UIKit

class LeadData: NSObject {
    
    var company: String?
    var lastName: String?
    var status: String?
    
    init(inDict:NSDictionary) {
        super.init()
        self.company = inDict["Company"] as? String
        self.lastName = inDict["LastName"] as? String
        self.status = inDict["Status"] as? String
    }
    
    class func initWithArray (inArr: NSArray) -> NSArray {
        let allValues:NSMutableArray = []
        for inDictNew in inArr {
            allValues.addObject(LeadData(inDict: inDictNew as! NSDictionary))
        }
        return allValues
    }
    
    func encodeWithCoder(aCoder: NSCoder!) {
        aCoder.encodeObject(self.company, forKey: "Company")
        aCoder.encodeObject(self.lastName, forKey: "LastName")
        aCoder.encodeObject(self.status, forKey: "Status")
    }
    
    init(coder aDecoder: NSCoder!) {
        self.company = aDecoder.decodeObjectForKey("Company") as? String
        self.lastName = aDecoder.decodeObjectForKey("LastName") as? String
        self.status = aDecoder.decodeObjectForKey("Status") as? String
    }
    
    override init() {
        
    }

}

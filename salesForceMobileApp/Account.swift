//
//  Account.swift
//  salesForceMobileApp
//
//  Created by HemendraSingh on 06/12/16.
//  Copyright © 2016 Salesforce. All rights reserved.
//

import UIKit

class Account: NSObject {
    
    var account_Name: String?
    var billing_Street: String?
    var billing_City: String?
    var billing_State: String?
    var billing_Country: String?
    var billing_PostalCode: String?
    
    init(inDict:NSDictionary) {
        super.init()
        self.account_Name = inDict["accountName"] as? String
        self.billing_Street = inDict["billingStreet"] as? String
        self.billing_City = inDict["billingCity"] as? String
        self.billing_State = inDict["billingState"] as? String
        self.billing_Country = inDict["billingCountry"] as? String
        self.billing_PostalCode = inDict["billingPostalCode"] as? String
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.account_Name, forKey: "accountName")
        aCoder.encodeObject(self.billing_Street, forKey: "billingStreet")
        aCoder.encodeObject(self.billing_City, forKey: "billingCity")
        aCoder.encodeObject(self.billing_State, forKey: "billingState")
        aCoder.encodeObject(self.billing_Country, forKey: "billingCountry")
        aCoder.encodeObject(self.billing_PostalCode, forKey: "billingPostalCode")
    }
    
    
    class func initWithArray (inArr: NSArray) -> NSArray {
        let allValues:NSMutableArray = []
        for inDictNew in inArr {
            allValues.addObject(Lead(inDict: inDictNew as! NSDictionary))
        }
        return allValues
    }
    
    required init(coder aDecoder: NSCoder) {
        self.account_Name = aDecoder.decodeObjectForKey("accountName") as? String
        self.billing_Street = aDecoder.decodeObjectForKey("billingStreet") as? String
        self.billing_City = aDecoder.decodeObjectForKey("billingCity") as? String
        self.billing_State = aDecoder.decodeObjectForKey("billingState") as? String
        self.billing_Country = aDecoder.decodeObjectForKey("billingCountry") as? String
        self.billing_PostalCode = aDecoder.decodeObjectForKey("billingPostalCode") as? String
    }

}

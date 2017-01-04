//
//  OffLineSetupData.swift
//  salesForceMobileApp
//
//  Created by mac on 29/12/16.
//  Copyright © 2016 Salesforce. All rights reserved.
//

import Foundation
import SalesforceSDKCore
import SalesforceNetwork
import SalesforceRestAPI
import MBProgressHUD

class OffLineSetupData: NSObject {

    
    
   class func setupForAddObject() {
        
        downloadSchemaForPage(ObjectDataType.leadValue.rawValue)
        downloadSchemaForPage(ObjectDataType.contactValue.rawValue)
        downloadSchemaForPage(ObjectDataType.opportunityValue.rawValue)
        downloadSchemaForPage(ObjectDataType.accountValue.rawValue)
    }
    
    
  class  func downloadSchemaForPage(objectType:String) {
        
        let schemaKey = "\(objectType)_\(SchemaKeySuffix)"
        
        if exDelegate.isConnectedToNetwork() {
            let request = SFRestAPI.sharedInstance().requestForQuery("Select Name, (Select Name, Display_Name__c,Display_order__c, Input_Type__c, Picker_Value__c, IsMandatory__c from FieldInfos__r Order by Display_order__c ASC ) from Master_Object__c Where name = '\(objectType)'" )
            SFRestAPI.sharedInstance().sendRESTRequest(request, failBlock: { error in
                print(error)
                }, completeBlock: { response in
                    print(response)
                    let arr = ((response!["records"]) as? NSArray)!
                    if  arr.count > 0 {
                        if (response!["records"]!.valueForKey("FieldInfos__r")?.objectAtIndex(0).valueForKey("records")?.count > 0 ) {
                            let midarr = arr.valueForKey("FieldInfos__r") as! NSArray
                            let objDataArr = (midarr.objectAtIndex(0).valueForKey("records") as! NSArray).mutableCopy() as! NSMutableArray
                            let arrOfLeadData = NSKeyedArchiver.archivedDataWithRootObject(objDataArr)
                            defaults.setObject(arrOfLeadData, forKey: schemaKey)
                        }
                       
                    }
            })
        } else {
            
        }
        
    }

}
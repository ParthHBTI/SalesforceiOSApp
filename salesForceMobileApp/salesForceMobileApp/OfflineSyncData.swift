//
//  OfflineShrinkData.swift
//  salesForceMobileApp
//
//  Created by mac on 13/12/16.
//  Copyright © 2016 Salesforce. All rights reserved.
//

import UIKit
import ZKSforce
import SalesforceSDKCore

class OfflineSyncData: UIViewController {

//    var  client:ZKSforceClient?


    
    class func syncOffLineDataToServer() {
        OfflineShrinkData(ObjectDataType.leadValue.rawValue)
        OfflineShrinkData(ObjectDataType.contactValue.rawValue)
        OfflineShrinkData(ObjectDataType.opportunityValue.rawValue)
        OfflineShrinkData(ObjectDataType.accountValue.rawValue)
        OfflineShrinkData1(ObjectDataType.attachment.rawValue)
    }

 class   func OfflineShrinkData(objType: String) {
    
    var oppOfflineArr = []
    if let arrayOfObjectsData = defaults.objectForKey("\(objType)\(OffLineKeySuffix)") as? NSData {
            oppOfflineArr = NSKeyedUnarchiver.unarchiveObjectWithData(arrayOfObjectsData)! as! NSArray
            
        }
    
    if  oppOfflineArr.count > 0 {
        let   client = fatchClient()
        let dataArr: NSMutableArray =  []
        for val in oppOfflineArr {
            let account: AnyObject = ZKSObject.withType(objType)
            let objectDic = NSMutableDictionary()
            for (key, val) in (val as? NSDictionary)! {
                objectDic.setObject(key, forKey: KeyName)
                objectDic.setObject(val, forKey: KeyValue)
                account.setFieldValue(objectDic[KeyValue] as? String, field: objectDic[KeyName] as? String)
            }
            dataArr.addObject(account)
        }
        client.performCreate(dataArr as [AnyObject], failBlock: { exp in
            print(exp)
            }, completeBlock: { results in
                print(results)
                for  resultV  in results {
                    let result = resultV as? ZKSaveResult
                    print(result?.errors )
                    print(result?.id )
                    print(result?.success)
                    defaults.removeObjectForKey("\(objType)\(OffLineKeySuffix)")
                    let nc = NSNotificationCenter.defaultCenter()
                    nc.postNotificationName("\(objType)\(NotificationSuffix)",
                        object: nil,
                        userInfo: ["message":"Hello there!", "date":NSDate()])
                }
        })
    }
}
    
    
    class   func OfflineShrinkData1(objType: String) {
        
        var offlineAttachmentDic = NSDictionary()
        if let arrayOfObjectsData = defaults.objectForKey(offlineAttachKey) as? NSData {
            offlineAttachmentDic = NSKeyedUnarchiver.unarchiveObjectWithData(arrayOfObjectsData)! as! NSDictionary
            
        }
       
        if  offlineAttachmentDic.count > 0 {
            let   client = fatchClient()
            let dataArr: NSMutableArray =  []
                for (key, _) in offlineAttachmentDic {
                     let attachment: AnyObject = ZKSObject.withType(objType)
                    let dataArray = offlineAttachmentDic.valueForKey(key as! String)
                    for element in (dataArray as? NSArray)! {
                        attachment.setFieldValue(element["Name"] as? String, field: "Name")
                        attachment.setFieldValue(element["Body"] as? String, field: "Body")
                        attachment.setFieldValue(element["ParentId"] as? String, field: "ParentId")
                    }
                     dataArr.addObject(attachment)
                }
            client.performCreate(dataArr as [AnyObject], failBlock: { exp in
                print(exp)
                }, completeBlock: { results in
                    print(results)
                    for  resultV  in results {
                        let result = resultV as? ZKSaveResult
                        print(result?.errors )
                        print(result?.id )
                        print(result?.success)
                        defaults.removeObjectForKey(offlineAttachKey)
                }
            })
        }
        
        
    }
    
    
    
   class func fatchClient() -> ZKSforceClient {
     let   client = ZKSforceClient()
        let authoCordinater =    SFAuthenticationManager.sharedManager().coordinator.credentials
        client.loginWithRefreshToken(authoCordinater.refreshToken, authUrl:  authoCordinater.identityUrl, oAuthConsumerKey: RemoteAccessConsumerKey)
        return client
    }
}

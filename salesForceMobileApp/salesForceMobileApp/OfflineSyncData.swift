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
        dispatch_async(dispatch_get_main_queue(), {
            OfflineShrinkData(ObjectDataType.leadValue.rawValue)
            OfflineShrinkData(ObjectDataType.contactValue.rawValue)
            OfflineShrinkData(ObjectDataType.opportunityValue.rawValue)
            OfflineShrinkData(ObjectDataType.accountValue.rawValue)
        })
        onlineShrinkData(ObjectDataType.leadValue.rawValue)
        onlineShrinkData(ObjectDataType.contactValue.rawValue)
        onlineShrinkData(ObjectDataType.opportunityValue.rawValue)
        onlineShrinkData(ObjectDataType.accountValue.rawValue)
        onlineDeleteObjects()
    }

    
    class   func onlineShrinkData(objType: String) {
        var onlineArr = []
        if let arrayOfObjectsData = defaults.objectForKey("\(objType)\(OnLineKeySuffix)") as? NSData {
            onlineArr = NSKeyedUnarchiver.unarchiveObjectWithData(arrayOfObjectsData)! as! NSArray
        }
        let   client = fatchClient()
        let dataArr: NSMutableArray =  []
        var k = 0
        for _ in onlineArr {
            let account: AnyObject = ZKSObject.withType(objType)
            let objectDic = NSMutableDictionary()
            let keyExist = (onlineArr.objectAtIndex(k)["editKey"]!)
            if  (keyExist != nil) {
                for (key, val) in (onlineArr.objectAtIndex(k)["editKey"] as? NSDictionary)! {
                    objectDic.setObject(key, forKey: KeyName)
                    objectDic.setObject(val, forKey: KeyValue)
                    account.setFieldValue(objectDic[KeyValue] as? String, field: objectDic[KeyName] as? String)
                }
                account.setFieldValue(onlineArr.objectAtIndex(k)["Id"]! as? String, field: "Id")
                dataArr.addObject(account)
            }
            k += 1;
        }
        
        client.performUpdate(dataArr as [AnyObject], failBlock: { exp in
            print(exp)
            }, completeBlock: { results in
                print(results)
                for  resultV  in results {
                    let result = resultV as? ZKSaveResult
                    print(result?.errors )
                    print(result?.id )
                    print(result?.success)
                    defaults.removeObjectForKey("\(objType)\(OffLineKeySuffix)")
                }
        })
    }
    
 class   func OfflineShrinkData(objType: String) {
    var oppOfflineArr = []
    if let arrayOfObjectsData = defaults.objectForKey("\(objType)\(OffLineKeySuffix)") as? NSData {
            oppOfflineArr = NSKeyedUnarchiver.unarchiveObjectWithData(arrayOfObjectsData)! as! NSArray
            
        }
    
    if  oppOfflineArr.count > 0 {
        let   client = fatchClient()
        let dataArr: NSMutableArray =  []
        let offLineObjectIdsArr = oppOfflineArr.valueForKey("Id")
        
        var attachmenetDic = NSMutableDictionary()
        if let arrayOfObjectsData = defaults.objectForKey(offlineAttachKey) as? NSData {
            attachmenetDic = NSKeyedUnarchiver.unarchiveObjectWithData(arrayOfObjectsData)!.mutableCopy() as! NSMutableDictionary
        }
        
        for val in oppOfflineArr {
            let account: AnyObject = ZKSObject.withType(objType)
            let objectDic = NSMutableDictionary()
            for (key, val) in (val as? NSDictionary)! {
                if key as! String != "Id" {
                    objectDic.setObject(key, forKey: KeyName)
                    objectDic.setObject(val, forKey: KeyValue)
                    account.setFieldValue(objectDic[KeyValue] as? String, field: objectDic[KeyName] as? String)
                }
            }
            dataArr.addObject(account)
        }
        client.performCreate(dataArr as [AnyObject], failBlock: { exp in
            print(exp)
            }, completeBlock: { results in
                print(results)
                var k = 0
                for  resultV  in results {
                    let result = resultV as? ZKSaveResult
                    print(result?.errors )
                    print(result?.id )
                    print(result?.success)
                    
                    ////////////Attachment Dic
                    let offlineObjectId = offLineObjectIdsArr.objectAtIndex(k) as! String
                    let actualObjecId = result?.id
                    
                    if let val = attachmenetDic[offlineObjectId] {
                        if let attachArr = val as? NSArray {
//                            
//                            for var attachDic in attachArr {
//                                 attachDic = attachDic.mutableCopy()
//                                 attachDic.setObject(actualObjecId, forKey: "ParentId")
//                            
//                            }
                        
                            attachmenetDic.setObject(attachArr, forKey: actualObjecId!)
                            attachmenetDic.removeObjectForKey(offlineObjectId)
                            print("value is not nil")
                        } else {
                            print("value is nil")
                        }
                    } else {
                        print("key is not present in dict")
                    }
                    
                   // attachmenetDic
                    
                    //////
                
                    defaults.removeObjectForKey("\(objType)\(OffLineKeySuffix)")
                    let nc = NSNotificationCenter.defaultCenter()
                    nc.postNotificationName("\(objType)\(NotificationSuffix)",
                        object: nil,
                        userInfo: ["message":"Hello there!", "date":NSDate()])
                    k += 1
                }
                defaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(attachmenetDic), forKey: offlineAttachKey)
                print(attachOfflineDic)
                OfflineShrinkData1(ObjectDataType.attachment.rawValue)

        })
    }
}
    
    
    class   func OfflineShrinkData1(objType: String) {
        var onlineAttachmenetDic = NSDictionary()
        if let arrayOfObjectsData = defaults.objectForKey(offlineAttachKey) as? NSData {
            onlineAttachmenetDic = NSKeyedUnarchiver.unarchiveObjectWithData(arrayOfObjectsData)! as! NSDictionary
        }
        if  onlineAttachmenetDic.count > 0 {
            let   client = fatchClient()
            let dataArr: NSMutableArray =  []
                for (key, _) in onlineAttachmenetDic {
                    let attachment: AnyObject = ZKSObject.withType(objType)
                    let dataArray = onlineAttachmenetDic.valueForKey(key as! String)
                        for element in (dataArray as? NSArray)! {
                            attachment.setFieldValue(element["Name"] as? String, field: "Name")
                            attachment.setFieldValue(element["Body"] as? String, field: "Body")
                            attachment.setFieldValue(key as? String, field: "ParentId")
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
    
    class func onlineDeleteObjects() {
        var onlineData: AnyObject = []
        if let arrayOfObjectsData = defaults.objectForKey(onlineDeletsObjectsKey) as? NSData {
            onlineData = (NSKeyedUnarchiver.unarchiveObjectWithData(arrayOfObjectsData))!
            
        }
            let   client = fatchClient()
        client.performDelete(onlineData as! [AnyObject], failBlock: {
            exp in
            print(exp)
            }, completeBlock: {
                results in
                print(results)
                for  resultV  in results {
                    let result = resultV as? ZKDeleteResult
                    print(result?.errors )
                    print(result?.id )
                    print(result?.success)
                    defaults.removeObjectForKey(onlineDeletsObjectsKey)
                }
        })
}
    
   class func fatchClient() -> ZKSforceClient {
     let   client = ZKSforceClient()
        let authoCordinater =    SFAuthenticationManager.sharedManager().coordinator.credentials
        client.loginWithRefreshToken(authoCordinater.refreshToken, authUrl:  authoCordinater.identityUrl, oAuthConsumerKey: RemoteAccessConsumerKey)
        return client
    }
}

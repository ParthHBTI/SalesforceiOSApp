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
            onlineAttachDataShrink(ObjectDataType.attachment.rawValue)
            SyncOnlineNotesData(ObjectDataType.noteValue.rawValue)
            
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
    var OfflineDataArr = []
    if let arrayOfObjectsData = defaults.objectForKey("\(objType)\(OffLineKeySuffix)") as? NSData {
            OfflineDataArr = NSKeyedUnarchiver.unarchiveObjectWithData(arrayOfObjectsData)! as! NSArray
        }
    
    
    if  OfflineDataArr.count > 0 {
        let   client = fatchClient()
        let dataArr: NSMutableArray =  []
        let offLineObjectIdsArr = OfflineDataArr.valueForKey("Id")
        
        var keyMatchDic = NSMutableDictionary()
        if let offlineOnlineMatchDic = (defaults.objectForKey(offlineAttachKey) as? NSData) {
         keyMatchDic = NSKeyedUnarchiver.unarchiveObjectWithData( offlineOnlineMatchDic) as! NSMutableDictionary
        }
        ////
        var notesKeyMatchDic = NSMutableDictionary()
        if let offlineOnlineMatchDic = (defaults.objectForKey(offlineNotesKey) as? NSData) {
            notesKeyMatchDic = NSKeyedUnarchiver.unarchiveObjectWithData( offlineOnlineMatchDic) as! NSMutableDictionary
        }
        
        ////
        for val in OfflineDataArr {
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
                var onlineAttachmenetDic = NSMutableDictionary()
                if let arrayOfObjectsData = defaults.objectForKey(onlineAttachKey) as? NSData {
                    onlineAttachmenetDic = NSKeyedUnarchiver.unarchiveObjectWithData(arrayOfObjectsData)! as! NSMutableDictionary
                }
                var onlineNotesDic = NSMutableDictionary()
                if let arrayOfObjectsData = defaults.objectForKey(onlineNotesKey) as? NSData {
                    onlineNotesDic = NSKeyedUnarchiver.unarchiveObjectWithData(arrayOfObjectsData)! as! NSMutableDictionary
                }
                for  resultV  in results {
                    let result = resultV as? ZKSaveResult
                    print(result?.errors )
                    print(result?.id )
                    print(result?.success)
                    let actualObjecId = result?.id
                    let offlineObjectId = offLineObjectIdsArr.objectAtIndex(k) as? String

                    if  keyMatchDic.count > 0 {
                        // for offline attachments
                        if let val = keyMatchDic[offlineObjectId!] {
                            if let attachArr = val as? NSArray {
                                onlineAttachmenetDic.setObject(attachArr, forKey: actualObjecId!)
                                keyMatchDic.removeObjectForKey(offlineObjectId!)
                                print("value is not nil")
                            } else {
                                print("value is nil")
                            }
                        } else {
                            print("key is not present in dict")
                        }
                    }
                    
                    //// for offline Notes
                    if notesKeyMatchDic.count > 0 {
                        if let val = notesKeyMatchDic[offlineObjectId!] {
                            if let attachArr = val as? NSArray {
                                onlineNotesDic.setObject(attachArr, forKey: actualObjecId!)
                                notesKeyMatchDic.removeObjectForKey(offlineObjectId!)
                                print("value is not nil")
                            } else {
                                print("value is nil")
                            }
                        } else {
                            print("key is not present in dict")
                        }
                    }
                
                    defaults.removeObjectForKey("\(objType)\(OffLineKeySuffix)")
                    let nc = NSNotificationCenter.defaultCenter()
                    nc.postNotificationName("\(objType)\(NotificationSuffix)",
                        object: nil,
                        userInfo: ["message":"Hello there!", "date":NSDate()])
                    k += 1
                }
                defaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(keyMatchDic), forKey: offlineAttachKey)
                defaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(onlineAttachmenetDic), forKey: onlineAttachKey)
                onlineAttachDataShrink(ObjectDataType.attachment.rawValue)
                defaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(notesKeyMatchDic), forKey: offlineNotesKey)
                defaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(onlineNotesDic), forKey: onlineNotesKey)
                SyncOnlineNotesData(ObjectDataType.noteValue.rawValue)
        })
    }
    }
    

    class   func onlineAttachDataShrink(objType: String) {
        var onlineAttachmenetDic = NSMutableDictionary()
        if let arrayOfObjectsData = defaults.objectForKey(onlineAttachKey) as? NSData {
            onlineAttachmenetDic = NSKeyedUnarchiver.unarchiveObjectWithData(arrayOfObjectsData)! as! NSMutableDictionary
        }
        if  onlineAttachmenetDic.count > 0 {
            let   client = fatchClient()
            let dataArr: NSMutableArray =  []
            for (key,value) in onlineAttachmenetDic {
                let attachmentArr = value as? NSArray
                for var dic in attachmentArr! {
                    let attachment: AnyObject = ZKSObject.withType(objType)
                        attachment.setFieldValue(dic["Name"] as? String, field: "Name")
                        attachment.setFieldValue(dic["Body"] as? String, field: "Body")
                        attachment.setFieldValue(key as? String, field: "ParentId")
                    dataArr.addObject(attachment)
                }
                }
            if dataArr.count > 0 {
            client.performCreate(dataArr as [AnyObject], failBlock: { exp in
                    print(exp)
                    }, completeBlock: { results in
                        print(results)
                        for  resultV  in results {
                            let result = resultV as? ZKSaveResult
                            print(result?.errors )
                            print(result?.id )
                            print(result?.success)
                            if ((result?.id) != nil) {
                            }
                        }
                        defaults.removeObjectForKey(onlineAttachKey)
                })
            }
        }
    }
    
    
    class func SyncOnlineNotesData(ObjType: String) {
        var onlineNotesDic = NSMutableDictionary()
        if let arrayOfObjectsData = defaults.objectForKey(onlineNotesKey) as? NSData {
            onlineNotesDic = NSKeyedUnarchiver.unarchiveObjectWithData(arrayOfObjectsData)! as! NSMutableDictionary
        }
        if  onlineNotesDic.count > 0 {
            let   client = fatchClient()
            let dataArr: NSMutableArray =  []
            for (key,value) in onlineNotesDic {
                let notesArr = value as? NSArray
                for var dic in notesArr! {
                    let note: AnyObject = ZKSObject.withType(ObjType)
                    note.setFieldValue(dic["Title"] as? String, field: "Title")
                    note.setFieldValue(dic["Body"] as? String, field: "Body")
                    note.setFieldValue(key as? String, field: "ParentId")
                    dataArr.addObject(note)
                }
            }
            if dataArr.count > 0 {
                client.performCreate(dataArr as [AnyObject], failBlock: { exp in
                    print(exp)
                    }, completeBlock: { results in
                        print(results)
                        for  resultV  in results {
                            let result = resultV as? ZKSaveResult
                            print(result?.errors )
                            print(result?.id )
                            print(result?.success)
                            if ((result?.id) != nil) {
                            }
                        }
                        dispatch_async(dispatch_get_main_queue(), {
                            defaults.removeObjectForKey(onlineNotesKey)
                        })
                })
            }
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

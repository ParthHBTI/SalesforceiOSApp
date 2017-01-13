//
//  OfflineDataModelVC.swift
//  salesForceMobileApp
//
//  Created by mac on 12/01/17.
//  Copyright © 2017 Salesforce. All rights reserved.
//

import UIKit
import SalesforceRestAPI

class OfflineDataModelVC: UIViewController {


    class func getOffLineAttachmentDic() -> NSMutableDictionary? {
        return loadDataWithKey(offlineAttachKey)
    }
    
    class func getOffLineNotesDic() -> NSMutableDictionary? {
        return loadDataWithKey(offlineNotesKey)
    }
    
    
    class func getOnlineAttachmentDic() -> NSMutableDictionary? {
        return loadDataWithKey(onlineAttachKey)
    }
    
    class func getOnlineeNotesDic() -> NSMutableDictionary? {
        return loadDataWithKey(onlineNotesKey)
    }
    
    
    
    class func loadDataWithKey(key:String) -> NSMutableDictionary {
        
        var infoDataDic =  NSMutableDictionary()
        if let infoObjectData = defaults.objectForKey(key) as? NSData {
            infoDataDic = NSKeyedUnarchiver.unarchiveObjectWithData(infoObjectData)! as! NSMutableDictionary
        }
        return infoDataDic
    }
    
    
       
class  func getNotesList(leadID: String , completeService: NotesResponseBlock) {
        if exDelegate.isConnectedToNetwork() {
            let query = "SELECT Body,CreatedDate,Id,Title FROM Note Where ParentId = '\(leadID)'"
            let reqs = SFRestAPI.sharedInstance().requestForQuery(query)
            SFRestAPI.sharedInstance().sendRESTRequest(reqs, failBlock: {
                erro in
                print(erro)
                }, completeBlock: { response in
                    print(response)
                    completeService(response!["records"]  as? Array)
                    //attachmentArr = response!["records"]
            })
        }
    }
    
    
    class  func getAttachmentList(leadID: String, completeService: AttachmentResponseBlock) {
        if exDelegate.isConnectedToNetwork() {
            
            let attachQuery = "SELECT ContentType,IsDeleted,IsPrivate,LastModifiedDate,Name FROM Attachment Where ParentId = '\(leadID)'"
            let attachReq = SFRestAPI.sharedInstance().requestForQuery(attachQuery)
            SFRestAPI.sharedInstance().sendRESTRequest(attachReq, failBlock: {
                erro in
                print(erro)
                }, completeBlock: { response in
                    print(response)
                    completeService(response!["records"]  as? Array)
            })
        }
    }
    
   }

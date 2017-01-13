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


    class func offlineDataModel() {
        if let arrayOfObjectsData = defaults.objectForKey(offlineAttachKey) as? NSData {
            attachOfflineDic = NSKeyedUnarchiver.unarchiveObjectWithData(arrayOfObjectsData)! as! NSMutableDictionary
        }
        if let arrayOfObjectsData = defaults.objectForKey(offlineNotesKey) as? NSData {
            offlineNotesDic = NSKeyedUnarchiver.unarchiveObjectWithData(arrayOfObjectsData)! as! NSMutableDictionary
        }
    }
    
    class func onlineDataModel() {
        if let arrayOfObjectsData = defaults.objectForKey(onlineAttachKey) as? NSData {
            attachOnlineDic = NSKeyedUnarchiver.unarchiveObjectWithData(arrayOfObjectsData)! as! NSMutableDictionary
        }
        
        if let arrayOfObjectsData = defaults.objectForKey(onlineNotesKey) as? NSData {
            onlineNotesDic = NSKeyedUnarchiver.unarchiveObjectWithData(arrayOfObjectsData)! as! NSMutableDictionary
        }
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

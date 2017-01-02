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

    var  client:ZKSforceClient?

    func leadOfflineShrinkData(dataArray: NSMutableArray) {
        client = fatchClient()
        let dataArr: NSMutableArray =  []
        for countData in dataArray {
            
        let lead: AnyObject = ZKSObject.withType("Lead")
            lead.setFieldValue(countData[KeyValue] as? String, field: KeyName)
//            lead.setFieldValue(countData["Company"] as? String, field: "Company")
//            lead.setFieldValue(countData["Status"] as? String, field: "Status")
            dataArr.addObject(lead)
        }
        client?.performCreate(dataArr as! [AnyObject], failBlock: { exp in
            print(exp)
            }, completeBlock: { results in
                print(results)
                for var resultV  in results {
                    //                  let result = results.last as? ZKSaveResult
                    let result = resultV as? ZKSaveResult
                    print(result?.errors )
                    print(result?.id )
                    print(result?.success)
                    defaults.removeObjectForKey("\(ObjectDataType.leadValue.rawValue)\(OffLineKeySuffix)")
                }
        })

    }

    func accOfflineShrinkData(dataArray: NSMutableArray) {
        client = fatchClient()
        let account: AnyObject = ZKSObject.withType("Account")
        let dataArr: NSMutableArray =  []
        for val in dataArray {
                let objectDic = NSMutableDictionary()
                for (key, val) in (val as? NSDictionary)! {
                    objectDic.setObject(key, forKey: KeyName)
                    objectDic.setObject(val, forKey: KeyValue)
                    account.setFieldValue(objectDic[KeyValue] as? String, field: objectDic[KeyName] as? String)
            }
            dataArr.addObject(account)
        }
        client?.performCreate(dataArr as! [AnyObject], failBlock: { exp in
            print(exp)
            }, completeBlock: { results in
                print(results)
                for var resultV  in results {
                    //                  let result = results.last as? ZKSaveResult
                    let result = resultV as? ZKSaveResult
                    print(result?.errors )
                    print(result?.id )
                    print(result?.success)
                    defaults.removeObjectForKey("\(ObjectDataType.accountValue.rawValue)\(OffLineKeySuffix)")
                }
        })

    }
    
    func contactOfflineShrinkData(dataArray: NSMutableArray) {
        client = fatchClient()
        let dataArr: NSMutableArray =  []
        for countData in dataArray {
            let contact: AnyObject = ZKSObject.withType("Contact")
            contact.setFieldValue(countData["FirstName"] as? String, field: "FirstName")
            contact.setFieldValue(countData["LastName"] as? String, field: "LastName")
            contact.setFieldValue(countData["Email"] as? String, field: "Email")
            contact.setFieldValue(countData["Phone"] as? String, field: "Phone")
            dataArr.addObject(contact)
        }
        client?.performCreate(dataArr as! [AnyObject], failBlock: { exp in
            print(exp)
            }, completeBlock: { results in
                print(results)
                for var resultV  in results {
                    //                  let result = results.last as? ZKSaveResult
                    let result = resultV as? ZKSaveResult
                    print(result?.errors )
                    print(result?.id )
                    print(result?.success)
                    defaults.removeObjectForKey(ContactOfLineDataKey)
                }
        })

    }
    
    func oppOflineShrinkData(dataArray: NSMutableArray) {
        client = fatchClient()
        let dataArr: NSMutableArray =  []
        for countData in dataArray {
            let opportunity: AnyObject = ZKSObject.withType("Opportunity")
            opportunity.setFieldValue(countData["Name"] as? String, field: "Name")
            opportunity.setFieldValue(countData["CloseDate"] as? String, field: "CloseDate")
            opportunity.setFieldValue(countData["Amount"] as? String, field: "Amount")
            opportunity.setFieldValue(countData["StageName"] as? String, field: "StageName")
            dataArr.addObject(opportunity)
        }
        client?.performCreate(dataArr as! [AnyObject], failBlock: { exp in
            print(exp)
            }, completeBlock: { results in
                print(results)
                for var resultV  in results {
                    let result = resultV as? ZKSaveResult
                    print(result?.errors )
                    print(result?.id )
                    print(result?.success)
                    defaults.removeObjectForKey(ObjectDataType.opportunityValue.rawValue)
                }
        })
    }
    
  func fatchClient() -> ZKSforceClient {
    client = ZKSforceClient()
    let authoCordinater =    SFAuthenticationManager.sharedManager().coordinator.credentials
    client?.loginWithRefreshToken(authoCordinater.refreshToken, authUrl:  authoCordinater.identityUrl, oAuthConsumerKey: RemoteAccessConsumerKey)
    return client!
    }
}

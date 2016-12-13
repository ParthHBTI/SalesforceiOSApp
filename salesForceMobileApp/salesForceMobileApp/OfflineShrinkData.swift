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

class OfflineShrinkData: UIViewController {

    var  client:ZKSforceClient?

    func leadOfflineShrinkData(dataArray: NSMutableArray) {
        client = fatchClient()
        let dataArr: NSMutableArray =  []
        for countData in dataArray {
            let lead: AnyObject = ZKSObject.withType("Lead")
            lead.setFieldValue(countData["LastName"] as? String, field: "LastName")
            lead.setFieldValue(countData["Company"] as? String, field: "Company")
            lead.setFieldValue(countData["Status"] as? String, field: "Status")
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
                    defaults.removeObjectForKey(LeadOfLineDataKey)
                }
        })

    }

    func accOfflineShrinkData(dataArray: NSMutableArray) {
        client = fatchClient()
        let dataArr: NSMutableArray =  []
        for countData in dataArray {
            let account: AnyObject = ZKSObject.withType("Account")
            account.setFieldValue(countData["Name"] as? String, field: "Name")
            account.setFieldValue(countData["BillingStreet"] as? String, field: "BillingStreet")
            account.setFieldValue(countData["BillingCity"] as? String, field: "BillingCity")
            account.setFieldValue(countData["BillingState"] as? String, field: "BillingState")
            account.setFieldValue(countData["BillingCountry"] as? String, field: "BillingCountry")
            account.setFieldValue(countData["BillingPostalCode"] as? String, field: "BillingPostalCode")
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
                    defaults.removeObjectForKey(AccOfflineDataKey)
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
                    defaults.removeObjectForKey(OppOfflineDataKey)
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

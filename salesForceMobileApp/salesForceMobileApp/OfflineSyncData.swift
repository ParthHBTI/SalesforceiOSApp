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


    func OfflineShrinkData(dataArray: NSMutableArray, objType: String) {
        client = fatchClient()
        let dataArr: NSMutableArray =  []
        for val in dataArray {
            let account: AnyObject = ZKSObject.withType(objType)
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
                    defaults.removeObjectForKey("\(objType)\(OffLineKeySuffix)")
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

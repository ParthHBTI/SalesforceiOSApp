//
//  ExecuteQuery.swift
//  salesForceMobileApp
//
//  Created by mac on 26/10/16.
//  Copyright © 2016 Salesforce. All rights reserved.
//

import UIKit
import SalesforceRestAPI
import SystemConfiguration
import MBProgressHUD


@objc public protocol ExecuteQueryDelegate {
    optional func executeQuery()
}

class ExecuteQuery: UIViewController, SFRestDelegate {
    
    internal weak var delegate : ExecuteQueryDelegate?
    var resArr:AnyObject = NSMutableArray()
    
    
    func request(request: SFRestRequest, didLoadResponse jsonResponse: AnyObject) {
        print(jsonResponse)
        resArr = jsonResponse["records"] as! [NSDictionary]
        self.log(.Debug, msg: "request:didLoadResponse: #records: \(resArr.count)")
        dispatch_async(dispatch_get_main_queue(), {
        let str = self.removeSpecialCharsFromString(request.queryParams!.debugDescription)
           let newStr = String(str.substringFromIndex(str.startIndex.advancedBy(2)))
            if newStr == leadRequest  {
                let arrOfLeadData = NSKeyedArchiver.archivedDataWithRootObject(self.resArr)
                defaults.setObject(arrOfLeadData, forKey: "\(ObjectDataType.leadValue.rawValue)\(OnLineKeySuffix)")
            } else if newStr == accountRequest {
                let arrOfLeadData = NSKeyedArchiver.archivedDataWithRootObject(self.resArr)
                defaults.setObject(arrOfLeadData, forKey: "\(ObjectDataType.accountValue.rawValue)\(OnLineKeySuffix)")
            } else if newStr == contactRequest {
                let arrOfLeadData = NSKeyedArchiver.archivedDataWithRootObject(self.resArr)
                defaults.setObject(arrOfLeadData, forKey: "\(ObjectDataType.contactValue.rawValue)\(OnLineKeySuffix)")
            } else {
                let arrOfLeadData = NSKeyedArchiver.archivedDataWithRootObject(self.resArr)
                defaults.setObject(arrOfLeadData, forKey: "\(ObjectDataType.opportunityValue.rawValue)\(OnLineKeySuffix)")
            }
            
        })
        delegate?.executeQuery!()
    }
    
    func removeSpecialCharsFromString(text: String) -> String {
        let okayChars : Set<Character> =
            Set("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ, =.0123456789".characters)
        return String(text.characters.filter {okayChars.contains($0) })
    }
    
    func request(request: SFRestRequest, didFailLoadWithError error: NSError)
    {
        self.log(.Debug, msg: "didFailLoadWithError: \(error)")
        // Add your failed error handling here
    }
    
    func requestDidCancelLoad(request: SFRestRequest)
    {
        self.log(.Debug, msg: "requestDidCancelLoad: \(request)")
        // Add your failed error handling here
    }
    
    func requestDidTimeout(request: SFRestRequest)
    {
        self.log(.Debug, msg: "requestDidTimeout: \(request)")
        // Add your failed error handling here
    }

    func leadQueryDe(typeObject: AnyObject)  {
        if (typeObject as! String == "Lead" )  {
            let request = SFRestAPI.sharedInstance().requestForQuery(leadRequest)
            SFRestAPI.sharedInstance().send(request, delegate: self);
        } else if (typeObject as! String == "Account") {
            let request = SFRestAPI.sharedInstance().requestForQuery(accountRequest)
            SFRestAPI.sharedInstance().send(request, delegate: self);
        } else if (typeObject as! String == "Contact") {
            let request = SFRestAPI.sharedInstance().requestForQuery(contactRequest)
            SFRestAPI.sharedInstance().send(request, delegate: self);
        } else if (typeObject as! String == "Opportunity") {
            let request = SFRestAPI.sharedInstance().requestForQuery(opporchunityRequest)
            SFRestAPI.sharedInstance().send(request, delegate: self);
        }
     
    }
    
    func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    

}

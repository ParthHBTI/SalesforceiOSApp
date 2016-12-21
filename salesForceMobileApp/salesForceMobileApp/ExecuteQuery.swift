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
//public enum selectObject: String {
//    case lead = "lead"
//    case account = "account"
//    case contact = "contact"
//    case opporchunity = "opporchunity"
//}

@objc public protocol ExecuteQueryDelegate {
    optional func executeQuery()
}

class ExecuteQuery: UIViewController, SFRestDelegate {
    
    internal weak var delegate : ExecuteQueryDelegate?
    var resArr:AnyObject = NSMutableArray()
    var leadRequest = "SELECT Address,City,Company,CreatedDate,FirstName,Id,IsConverted,LastName,LeadSource,MobilePhone,Name,Phone,PostalCode,State,Status,Title FROM Lead Order by CreatedDate DESC"
   var accountRequest = "SELECT Owner.Name,AccountNumber,Fax,LastModifiedDate,Name,Ownership,Phone,Type,Website,Id,BillingCity,BillingCountry,BillingPostalCode,BillingState,BillingStreet FROM Account  Order by CreatedDate DESC"
    var contactRequest = "SELECT  Salutation,Owner.Name,Birthdate,Email,Fax,Name,Phone,Id,FirstName,LastName FROM Contact  Order by CreatedDate DESC"
    var opporchunityRequest = "SELECT Owner.Name,Amount,CloseDate,CreatedDate,IsClosed,IsDeleted,IsPrivate,LastModifiedDate,LeadSource,Name,Probability,StageName,Type,Id FROM Opportunity Order by CreatedDate DESC"
    
    func request(request: SFRestRequest, didLoadResponse jsonResponse: AnyObject) {
        print(jsonResponse)
        resArr = jsonResponse["records"] as! [NSDictionary]
        self.log(.Debug, msg: "request:didLoadResponse: #records: \(resArr.count)")
        dispatch_async(dispatch_get_main_queue(), {
        let str = self.removeSpecialCharsFromString(request.queryParams!.debugDescription)
           let newStr = String(str.substringFromIndex(str.startIndex.advancedBy(2)))
            if newStr == self.leadRequest  {
                let arrOfLeadData = NSKeyedArchiver.archivedDataWithRootObject(self.resArr)
                defaults.setObject(arrOfLeadData, forKey: LeadOnLineDataKey)
            } else if newStr == self.accountRequest {
                let arrOfLeadData = NSKeyedArchiver.archivedDataWithRootObject(self.resArr)
                defaults.setObject(arrOfLeadData, forKey: AccOnlineDataKey)
            } else if newStr == self.contactRequest {
                let arrOfLeadData = NSKeyedArchiver.archivedDataWithRootObject(self.resArr)
                defaults.setObject(arrOfLeadData, forKey: ContactOnLineDataKey)
            } else {
                let arrOfLeadData = NSKeyedArchiver.archivedDataWithRootObject(self.resArr)
                defaults.setObject(arrOfLeadData, forKey: OppOnlineDataKey)
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
        if (typeObject as! String == "lead" )  {
            let request = SFRestAPI.sharedInstance().requestForQuery(leadRequest)
            SFRestAPI.sharedInstance().send(request, delegate: self);
        } else if (typeObject as! String == "account") {
            let request = SFRestAPI.sharedInstance().requestForQuery(accountRequest)
            SFRestAPI.sharedInstance().send(request, delegate: self);
        } else if (typeObject as! String == "contact") {
            let request = SFRestAPI.sharedInstance().requestForQuery(contactRequest)
            SFRestAPI.sharedInstance().send(request, delegate: self);
        } else if (typeObject as! String == "opporchunity") {
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
    
//    func showServerHUD() {
//        let loading = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
//        loading.mode = MBProgressHUDMode.Indeterminate
//        loading.detailsLabelText = "Uploading Data from Server"
//        loading.hide(true, afterDelay: 2)
//        loading.removeFromSuperViewOnHide = true
//    }
//    
//    func showLocalHUD() {
//        let loading = MBProgressHUD.showHUDAddedTo(self.navigationController?.view, animated: true)
//        loading.mode = MBProgressHUDMode.Indeterminate
//        loading.detailsLabelText = "Uploading Data from Local"
//        loading.hide(true, afterDelay: 2)
//        loading.removeFromSuperViewOnHide = true
//    }

}

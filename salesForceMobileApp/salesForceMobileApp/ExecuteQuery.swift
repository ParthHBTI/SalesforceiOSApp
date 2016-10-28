//
//  ExecuteQuery.swift
//  salesForceMobileApp
//
//  Created by mac on 26/10/16.
//  Copyright © 2016 Salesforce. All rights reserved.
//

import UIKit
import SalesforceRestAPI

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
    var resArr:AnyObject = []
    var leadRequest = "SELECT Company,Email,Name,Phone,Title,Address FROM Lead limit 20"
   var accountRequest = "SELECT AccountNumber,Fax,LastModifiedDate,Name,Ownership,Phone,Type,Website FROM Account Limit 10"
    var contactRequest = "SELECT Birthdate,Email,Fax,Name,Phone FROM Contact"
    var opporchunityRequest = "SELECT Amount,CloseDate,CreatedDate,IsClosed,IsDeleted,IsPrivate,LastModifiedDate,LeadSource,Name,Probability,StageName,Type FROM Opportunity Limit 10"
    
    func request(request: SFRestRequest, didLoadResponse jsonResponse: AnyObject) {
        print(jsonResponse)
        resArr = jsonResponse["records"] as! [NSDictionary]
        self.log(.Debug, msg: "request:didLoadResponse: #records: \(resArr.count)")
        dispatch_async(dispatch_get_main_queue(), {
            let defaults = NSUserDefaults.standardUserDefaults()
            let leadDataKey = "leadListData"
            let arrOfLeadData = NSKeyedArchiver.archivedDataWithRootObject(self.resArr)
            defaults.setObject(arrOfLeadData, forKey: leadDataKey)
        })
        delegate?.executeQuery!()
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
}

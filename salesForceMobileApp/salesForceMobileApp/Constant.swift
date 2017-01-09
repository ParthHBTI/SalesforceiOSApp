//
//  Constant.swift
//  salesForceMobileApp
//
//  Created by mac on 22/12/16.
//  Copyright © 2016 Salesforce. All rights reserved.
//

import Foundation


//"Lead"


enum ObjectDataType: String {
    case leadValue = "Lead"
    case accountValue = "Account"
    case contactValue = "Contact"
    case opportunityValue = "Opportunity"
    case attachment = "Attachment"
}

let KeyValue = "KeyValue"
let KeyName  = "KeyName"
var globalIndex = 0


let TextFieldType = "Textpicker"
let DatePicker    = "Datepicker"
let AccountPIcker = "AccountPicker"

let SchemaKeySuffix = "SchemaKey"
let OffLineKeySuffix = "OffLineDataKey"
let OnLineKeySuffix = "OnLineDataKey"
let offlineAttachKey = "offlineAttachKey"
let NotificationSuffix = "NotificationSuffixKey"
let onlineDeletsObjectsKey = "onlineDeletsObjectsKey"


var keyForOffLine = ""
let obj = OfflineSyncData()

let AccountPIckerQuery = "SELECT Id, Name FROM RecentlyViewed WHERE Type IN ('Account')  "

var leadRequest = "SELECT Address,City,Company,CreatedDate,FirstName,Id,IsConverted,LastName,LeadSource,MobilePhone,Name,Phone,PostalCode,State,Status,Title FROM Lead Order by CreatedDate DESC"

var accountRequest = "SELECT Owner.Name,AccountNumber,Fax, LastModifiedDate,Name,Ownership,Phone,Type,Website,Id,BillingCity,BillingCountry,BillingPostalCode,BillingState,BillingStreet  FROM Account  Order by CreatedDate DESC"

var contactRequest = "SELECT AccountId, Birthdate, Account.Name, CleanStatus, Email, Fax, FirstName, LastName, Id, LastReferencedDate, Name, Phone FROM Contact Order by CreatedDate DESC"

var opporchunityRequest = "SELECT Owner.Name,Amount,Account.Name,CloseDate,CreatedDate,IsClosed,IsDeleted,IsPrivate,LastModifiedDate,LeadSource,Name,Probability,StageName,Type,Id FROM Opportunity Order by CreatedDate DESC"





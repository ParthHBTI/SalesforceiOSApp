//
//  Constant.swift
//  salesForceMobileApp
//
//  Created by mac on 22/12/16.
//  Copyright © 2016 Salesforce. All rights reserved.
//

import Foundation

let TextFieldType = "Textpicker"
let DatePicker = "Datepicker"
let AccountPIcker = "AccountPicker"

let SchemaKeySuffix = "SchemaKey"
let OffLineKeySuffix = "OfLineDataKey"


let LeadOnLineDataKey = "LeadOnLineDataKey"
let LeadOfLineDataKey = "LeadOfLineDataKey"
let OppOnLineDataKey = "OpportunityOnlineDataKey"
let OppOffLineDataKey = "OpportunityOfflineDataKey"

let AccOnLineDataKey = "AccOnlineDataKey"
let AccOffLineDataKey = "AccOfflineDataKey"


let AccountPIckerQuery = "SELECT Id, Name FROM RecentlyViewed WHERE Type IN ('Account')  "

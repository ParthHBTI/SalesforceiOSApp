//
//  OpporchunityViewController.swift
//  salesForceMobileApp
//
//  Created by mac on 17/10/16.
//  Copyright © 2016 Salesforce. All rights reserved.
//

import UIKit
import SalesforceNetwork
import SalesforceRestAPI
import SalesforceSDKCore
import SmartStore.SalesforceSDKManagerWithSmartStore
import SmartSync
import SmartStore

class CreateNewOpportunityVC: UIViewController, SFRestDelegate {

    @IBOutlet weak var opportunityName: UITextField!
    @IBOutlet weak var closeDate: UITextField!
    @IBOutlet weak var amount: UITextField!
    @IBOutlet weak var stage: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveAction(sender: AnyObject) {
        
        let fields = [
            "Name" : opportunityName.text!,
            "CloseDate" : closeDate.text!,
            "Amount" : amount.text!,
            "StageName" : stage.text!,
        ]
        SFRestAPI.sharedInstance().performCreateWithObjectType("Opportunity", fields: fields, failBlock: { err in
            dispatch_async(dispatch_get_main_queue(), {
                let alert = UIAlertView.init(title: "Error", message: err?.localizedDescription , delegate: self, cancelButtonTitle: "OK")
                alert.show()
                print(err?.localizedDescription)
            })
            print( (err))
        }) { succes in
            print(succes)
        }

        
    }
    
    @IBAction func cancelAction(sender: AnyObject) {
    }
    
}

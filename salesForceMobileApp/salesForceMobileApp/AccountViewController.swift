//
//  AccountViewController.swift
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

class AccountViewController: UIViewController {

    @IBOutlet weak var accountName: UITextField!
    @IBOutlet weak var accountAddress: UITextField!
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
            "Name" : accountName.text!,
            "ShippingAddress" : accountAddress.text!,
        ]
        SFRestAPI.sharedInstance().performCreateWithObjectType("Account", fields: fields, failBlock: { err in
            dispatch_async(dispatch_get_main_queue(), {
                let alert = UIAlertView.init(title: "Error", message: err?.localizedDescription , delegate: self, cancelButtonTitle: "OK")
                alert.show()
            })
            print( (err))
        }) { succes in
            print(succes)
        }

    }

    @IBAction func cancelAction(sender: AnyObject) {
    }
   
}

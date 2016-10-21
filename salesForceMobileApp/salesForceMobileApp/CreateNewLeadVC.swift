//
//  LeadViewController.swift
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

class CreateNewLeadVC: UIViewController {

    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var companyName: UITextField!
    @IBOutlet weak var leadStatus: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: view.frame.size.height );
        scrollView.setNeedsDisplay()
        // Do any additional setup after loading the view.
    }

    override func viewDidLayoutSubviews()  {
        super.viewDidLayoutSubviews()
        self.scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: view.frame.size.height + 100);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveAction(sender: AnyObject) {
        
        let fields = [
            "LastName" : lastName.text!,
            "Company" : companyName.text!,
            "Status" : leadStatus.text!,
        ]
        SFRestAPI.sharedInstance().performCreateWithObjectType("Lead", fields: fields, failBlock: { err in
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

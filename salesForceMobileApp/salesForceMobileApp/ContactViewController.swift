//
//  RightViewController.swift
//  SlideMenuControllerSwift
//
//  Created by Yuji Hato on 12/3/14.
//

import UIKit
import SalesforceNetwork
import SalesforceRestAPI
import SalesforceSDKCore
import SmartStore.SalesforceSDKManagerWithSmartStore
import SmartSync
import SmartStore

class ContactViewController : UIViewController, SFRestDelegate {
    
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var fax: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func saveAction(sender: AnyObject) {
        
            let fields = [
           "FirstName" : firstName.text!,
            "LastName" : lastName.text!,
            "Email" : email.text!,
           "Phone" : phone.text!,
           "Fax" : fax.text!
        ]
        SFRestAPI.sharedInstance().performCreateWithObjectType("Contact", fields: fields, failBlock: { err in
            dispatch_async(dispatch_get_main_queue(), {
                let alert = UIAlertView.init(title: "Error", message: err?.localizedDescription , delegate: self, cancelButtonTitle: "OK")
                alert.show()
                })
            print( (err))
            self.requestForResources()
        }) { succes in
                        print(succes)
        }
           }
    
    func requestForResources() -> SFRestRequest {
        print(SFRestRequest)
        return SFRestRequest.init()
    }
    
    @IBAction func cancelAction(sender: AnyObject) {
        
    }
    
}

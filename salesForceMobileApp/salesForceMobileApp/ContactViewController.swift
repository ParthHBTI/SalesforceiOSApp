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
           "FirstName" : firstName,
            "LastName" : lastName,
            "Email" : email,
           "Phone" : phone,
           "Fax" : fax
        ]
        SFRestAPI.sharedInstance().performCreateWithObjectType("Contacts", fields: fields, failBlock: { err in
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

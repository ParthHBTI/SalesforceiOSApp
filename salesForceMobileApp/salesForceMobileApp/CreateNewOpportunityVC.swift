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
import MBProgressHUD


class CreateNewOpportunityVC: UIViewController, SFRestDelegate,ExecuteQueryDelegate {
    
    @IBOutlet weak var opportunityName: UITextField!
    @IBOutlet weak var closeDate: UITextField!
    @IBOutlet weak var amount: UITextField!
    @IBOutlet weak var stage: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var exDelegate: ExecuteQuery = ExecuteQuery()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: view.frame.size.height );
        scrollView.setNeedsDisplay()
        let backBarButtonItem:UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "back"), style: .Plain, target: self, action: #selector(CreateNewOpportunityVC.backAction))
        self.navigationItem.setLeftBarButtonItem(backBarButtonItem, animated: true)
        // Do any additional setup after loading the view.
    }
    
    func backAction() {
        for controller: UIViewController in self.navigationController!.viewControllers {
            if (controller is OpportunityViewController) {
                self.navigationController!.popToViewController(controller, animated: true)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews()  {
        super.viewDidLayoutSubviews()
        self.scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: view.frame.size.height + 100);
    }
    
    @IBAction func saveAction(sender: AnyObject) {
        
        
        if exDelegate.isConnectedToNetwork() {
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
        else {
            let loading = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            loading.mode = MBProgressHUDMode.Indeterminate
            //loading.mode = MBProgressHUDMode.Text
            loading.detailsLabelText = "Please check your Internet connection!"
            loading.hide(true, afterDelay: 2)
            loading.removeFromSuperViewOnHide = true
        }
    }
    
    @IBAction func cancelAction(sender: AnyObject) {
        
    }
    
     func touchesShouldCancelInContentView(view: UIView) -> Bool {
        return false
    }
}

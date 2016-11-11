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


class CreateNewOpportunityVC: TextFieldViewController, SFRestDelegate,ExecuteQueryDelegate {
    
    @IBOutlet weak var opportunityName: UITextField!
    @IBOutlet weak var closeDate: UITextField!
    @IBOutlet weak var amount: UITextField!
    @IBOutlet weak var stage: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var cancleBtn: UIButton!
    
    var exDelegate: ExecuteQuery = ExecuteQuery()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        opportunityName.delegate = self
        closeDate.delegate = self
        amount.delegate = self
        stage.delegate = self
        self.setNavigationBarItem()
        self.scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: view.frame.size.height );
        scrollView.setNeedsDisplay()
        /*let backBarButtonItem:UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "back"), style: .Plain, target: self, action: #selector(CreateNewOpportunityVC.backAction))
         self.navigationItem.setLeftBarButtonItem(backBarButtonItem, animated: true)*/
        // Do any additional setup after loading the view.
        let navColor = navigationController?.navigationBar.barTintColor
        saveBtn.backgroundColor = navColor
        saveBtn.layer.cornerRadius = 5.0
        cancleBtn.backgroundColor = navColor
        cancleBtn.layer.cornerRadius = 5.0
    }
    
    /*func backAction() {
     for controller: UIViewController in self.navigationController!.viewControllers {
     if (controller is OpportunityViewController) {
     self.navigationController!.popToViewController(controller, animated: true)
     }
     }
     }*/
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews()  {
        super.viewDidLayoutSubviews()
        self.scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: view.frame.size.height + 100);
    }
    
    @IBAction func saveAction(sender: AnyObject) {
        let oppNameStr = self.opportunityName.text!
        let closeDateStr = self.closeDate.text!
        let amountStr = self.amount.text!
        let stageStr = self.stage.text!
        let charSet = NSCharacterSet.whitespaceCharacterSet()
        let oppNameWhiteSpaceSet = oppNameStr.stringByTrimmingCharactersInSet(charSet)
        let closeDateWhiteSpaceSet = closeDateStr.stringByTrimmingCharactersInSet(charSet)
        let amountWhiteSpaceSet = amountStr.stringByTrimmingCharactersInSet(charSet)
        let stageWhiteSpaceSet = stageStr.stringByTrimmingCharactersInSet(charSet)
        if exDelegate.isConnectedToNetwork() {
            if self.opportunityName.text!.isEmpty == true || self.closeDate.text!.isEmpty == true || self.amount.text!.isEmpty == true || self.stage.text!.isEmpty == true {
                let loading = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                loading.mode = MBProgressHUDMode.Text
                loading.hide(true, afterDelay: 2)
                loading.removeFromSuperViewOnHide = true
                loading.detailsLabelText = "please give all values"
                self.animateSubmitBtnOnWrongSubmit()
            } else if oppNameWhiteSpaceSet == "" || amountWhiteSpaceSet == "" || stageWhiteSpaceSet == "" || closeDateWhiteSpaceSet == "" {
                let loading = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                loading.mode = MBProgressHUDMode.Text
                loading.hide(true, afterDelay: 2)
                loading.removeFromSuperViewOnHide = true
                loading.detailsLabelText = "You entered white spaces only"
                self.animateSubmitBtnOnWrongSubmit()
            } else {
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
    
    
    override func setNavigationBarItem() {
        self.leftBarButtonWithImage(UIImage(named: "back_NavIcon")!)
    }
    
    func leftBarButtonWithImage(buttonImage: UIImage) {
        let leftButton: UIBarButtonItem = UIBarButtonItem(image: buttonImage, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.toggleLeft))
        navigationItem.leftBarButtonItem = leftButton;
    }
    
    override func toggleLeft() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func animateSubmitBtnOnWrongSubmit(){
        let bounds = self.saveBtn.bounds
        UIView.animateWithDuration(1.0, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 10, options: .CurveEaseOut, animations: {
            self.saveBtn.bounds = CGRect(x: bounds.origin.x - 20, y: bounds.origin.y, width: bounds.size.width, height: bounds.size.height)
            self.saveBtn.enabled = true
            }, completion: nil)
    }
}

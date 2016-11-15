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
import MBProgressHUD

class CreateNewAccountVC: TextFieldViewController, UIScrollViewDelegate, ExecuteQueryDelegate {
    
    @IBOutlet weak var accountName: UITextField!
    @IBOutlet weak var accountAddress: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var cancleBtn: UIButton!
    var flag: Bool = false
    var accountDataDic:AnyObject = []
    
    var exDelegate: ExecuteQuery = ExecuteQuery()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        accountName.delegate = self
        accountAddress.delegate = self
        setNavigationBarItem()
        self.scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: view.frame.size.height );
        scrollView.setNeedsDisplay()
        /*let backBarButtonItem:UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "back"), style: .Plain, target: self, action: #selector(CreateNewAccountVC.backAction))
         self.navigationItem.setLeftBarButtonItem(backBarButtonItem, animated: true)*/
        let navBarSaveBtn: UIBarButtonItem = UIBarButtonItem(title: "Save", style: .Plain, target: self, action: #selector(updateAccountAction))
        let navColor = navigationController?.navigationBar.barTintColor
        saveBtn.backgroundColor = navColor
        saveBtn.layer.cornerRadius = 5.0
        cancleBtn.backgroundColor = navColor
        cancleBtn.layer.cornerRadius = 5.0
        if flag == true {
            self.accountName.text = accountDataDic["Name"] as? String
            self.accountAddress.text = accountDataDic["BillingAddress"] as? String
            self.saveBtn.hidden = true
            self.cancleBtn.hidden = true
            title = "Update Account"
            self.navigationItem.setRightBarButtonItem(navBarSaveBtn, animated: true)
        }
    }
    
    /*func backAction() {
     for controller: UIViewController in self.navigationController!.viewControllers {
     if (controller is AccountViewController) {
     self.navigationController!.popToViewController(controller, animated: true)
     }
     }
     }*/
    
    override func viewDidLayoutSubviews()  {
        super.viewDidLayoutSubviews()
        self.scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: view.frame.size.height + 100);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveAction(sender: AnyObject) {
        let accountNameStr = self.accountName.text!
        let accountAddStr = self.accountAddress.text!
        let charSet = NSCharacterSet.whitespaceCharacterSet()
        let accountNameWhiteSpaceSet = accountNameStr.stringByTrimmingCharactersInSet(charSet)
        let accountAddWhiteSpaceSet = accountAddStr.stringByTrimmingCharactersInSet(charSet)
        if exDelegate.isConnectedToNetwork() {
            if accountName.text!.isEmpty == true || accountAddress.text!.isEmpty == true {
                let loading = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                loading.mode = MBProgressHUDMode.Text
                loading.hide(true, afterDelay: 2)
                loading.removeFromSuperViewOnHide = true
                loading.detailsLabelText = "please give all values"
                self.animateSubmitBtnOnWrongSubmit()
            } else if accountAddWhiteSpaceSet == "" || accountNameWhiteSpaceSet == "" {
                let loading = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                loading.mode = MBProgressHUDMode.Text
                loading.hide(true, afterDelay: 2)
                loading.removeFromSuperViewOnHide = true
                loading.detailsLabelText = "You entered white spaces only"
                self.animateSubmitBtnOnWrongSubmit()
            } else {
                let fields = [
                    "Name" : accountName.text!,
                    "BillingAddress" : accountAddress.text!,
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
    
    //update account record
    func updateAccountAction() {
        let params = [
            "Name" : accountName.text!,
            "BillingAddress" : accountAddress.text!,
            ]
        SFRestAPI.sharedInstance().performUpdateWithObjectType("Account", objectId: (accountDataDic["Id"] as? String)!, fields: params, failBlock: { err in
            dispatch_async(dispatch_get_main_queue(), {
                let alert = UIAlertView.init(title: "Error", message: err?.localizedDescription , delegate: self, cancelButtonTitle: "OK")
                alert.show()
            })
            print( (err))
        }){ succes in
            dispatch_async(dispatch_get_main_queue(), {
                let loading = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                loading.mode = MBProgressHUDMode.Indeterminate
                //loading.mode = MBProgressHUDMode.Text
                loading.detailsLabelText = "Updated Successfully!"
                loading.hide(true, afterDelay: 2)
                loading.removeFromSuperViewOnHide = true
            })
        }
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

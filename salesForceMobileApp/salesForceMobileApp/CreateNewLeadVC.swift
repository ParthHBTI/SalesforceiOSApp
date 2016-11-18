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
import MBProgressHUD

class CreateNewLeadVC: TextFieldViewController, ExecuteQueryDelegate {
    
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var companyName: UITextField!
    @IBOutlet weak var leadStatus: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var cancleBtn: UIButton!
    var flag: Bool = false
    var leadDataDict:AnyObject = []
    
    var exDelegate: ExecuteQuery = ExecuteQuery()
    override func viewDidLoad() {
        super.viewDidLoad()
        print(leadDataDict)
        lastName.delegate = self
        companyName.delegate = self
        leadStatus.delegate = self
        setNavigationBarItem()
        self.scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: view.frame.size.height );
        scrollView.setNeedsDisplay()
        //let backBarButtonItem:UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "back"), style: .Plain, target: self, action: #selector(CreateNewLeadVC.backAction))
        //self.navigationItem.setLeftBarButtonItem(backBarButtonItem, animated: true)
        let navBarSaveBtn: UIBarButtonItem = UIBarButtonItem(title: "Update", style: .Plain, target: self, action: #selector(updateLeadAction))
        let navColor = navigationController?.navigationBar.barTintColor
        saveBtn.backgroundColor = navColor
        saveBtn.layer.cornerRadius = 5.0
        cancleBtn.backgroundColor = navColor
        cancleBtn.layer.cornerRadius = 5.0
        title = "New Lead"
        if self.flag == true {
            companyName.text = leadDataDict["Company"] as? String
            lastName.text = leadDataDict["LastName"] as? String
            leadStatus.text = leadDataDict["Status"] as? String
            saveBtn.hidden = true
            cancleBtn.hidden = true
            title = "Edit Lead"
            self.navigationItem.setRightBarButtonItem(navBarSaveBtn, animated: true)
        }
        
        // Do any additional setup after loading the view.
    }
    
    /*func backAction() {
     for controller: UIViewController in self.navigationController!.viewControllers {
     if (controller is LeadViewController) {
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
        let loading = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        loading.mode = MBProgressHUDMode.Indeterminate
        if exDelegate.isConnectedToNetwork() {
            if self.isSubmittedCorrectVal() {
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
                    dispatch_async(dispatch_get_main_queue(), {
                        loading.mode = MBProgressHUDMode.Text
                        loading.detailsLabelText = "Successfully Created Lead Record"
                        loading.removeFromSuperViewOnHide = true
                        loading.hide(true, afterDelay: 2)
                        self.lastName.text = nil
                        self.companyName.text = nil
                        self.leadStatus.text = nil
                        })
               
               
                                    }
            }
        } else {
            let loading = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            loading.mode = MBProgressHUDMode.Indeterminate
            loading.detailsLabelText = "Please check your Internet connection!"
            loading.hide(true, afterDelay: 2)
            loading.removeFromSuperViewOnHide = true
        }
    }
    
    
    @IBAction func cancelAction(sender: AnyObject) {
        
        
    }
    
    //Update lead record
    func updateLeadAction() {
        if exDelegate.isConnectedToNetwork() {
            if self.isSubmittedCorrectVal() {
                let params = [
                    "LastName" : lastName.text!,
                    "Company" : companyName.text!,
                    "Status" : leadStatus.text!,
                    ]
                SFRestAPI.sharedInstance().performUpdateWithObjectType("Lead", objectId: (leadDataDict["Id"] as? String)!, fields: params, failBlock: { err in
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
        } else {
            let loading = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            loading.mode = MBProgressHUDMode.Indeterminate
            loading.detailsLabelText = "Please check your Internet connection!"
            loading.hide(true, afterDelay: 2)
            loading.removeFromSuperViewOnHide = true
        }
    }
    
    
    func isSubmittedCorrectVal() -> Bool {
        let charSet = NSCharacterSet.whitespaceCharacterSet()
        let lastNameWhiteSpaceSet = self.lastName.text!.stringByTrimmingCharactersInSet(charSet)
        let companyNameWhiteSpaceSet = self.companyName.text!.stringByTrimmingCharactersInSet(charSet)
        let leadStatusWhiteSpaceSet = self.leadStatus.text!.stringByTrimmingCharactersInSet(charSet)
        if lastName.text!.isEmpty == true || companyName.text!.isEmpty == true || leadStatus.text!.isEmpty == true {
            let loading = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            loading.mode = MBProgressHUDMode.Text
            loading.hide(true, afterDelay: 2)
            loading.removeFromSuperViewOnHide = true
            loading.detailsLabelText = "please give all values"
            self.animateSubmitBtnOnWrongSubmit()
            return false
        } else if lastNameWhiteSpaceSet == "" || companyNameWhiteSpaceSet == "" || leadStatusWhiteSpaceSet == "" {
            let loading = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            loading.mode = MBProgressHUDMode.Text
            loading.hide(true, afterDelay: 2)
            loading.removeFromSuperViewOnHide = true
            loading.detailsLabelText = "You entered white spaces only"
            self.animateSubmitBtnOnWrongSubmit()
            return false
        }
        return true
    }
    
    
    override func setNavigationBarItem() {
        self.leftBarButtonWithImage(UIImage(named: "back_NavIcon")!)
        //self.leftBarButtonWithImage(UIImage(named: "back_icon")!)
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
    
    
    //delegate for text field
    func textField(textField: UITextField,
                   shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let prospectiveText = (currentText as NSString).stringByReplacingCharactersInRange(range, withString: string)
        if string.characters.count == 0 {
            if prospectiveText.characters.count <= 30 {
                lastName.layer.borderWidth = 2.0
                lastName.layer.borderColor = UIColor.clearColor().CGColor
            }
            return true
        }
        switch textField {
        case  lastName:
            if prospectiveText.characters.count > 30 {
                lastName.layer.borderWidth = 2.0
                lastName.layer.borderColor = UIColor.redColor().CGColor
            } else {
                lastName.layer.borderColor = UIColor.clearColor().CGColor
            }
            return true
        case companyName:
            return prospectiveText.characters.count <= 30
            
        case leadStatus:
            return prospectiveText.characters.count <= 10
            
        default:
            return true
        }
    }
}
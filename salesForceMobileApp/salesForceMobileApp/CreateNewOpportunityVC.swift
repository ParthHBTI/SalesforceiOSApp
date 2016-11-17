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
    var datePickerView: UIDatePicker = UIDatePicker()
    var currentDate:NSDate = NSDate()
    var dateVal: String = " "
    var flag:Bool = false
    var flag1:Bool = false
    var flag2:Bool = false
    var opportunityDataDic:AnyObject = []
    
    var exDelegate: ExecuteQuery = ExecuteQuery()
    
    func nullToNil(value : AnyObject?) -> AnyObject? {
        if value is NSNull {
            return nil
        } else {
            return value
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dispatch_async(dispatch_get_main_queue(), {
        self.dateVal = self.closeDate.text!
            })
        //print(dateVal)
        opportunityName.delegate = self
        //closeDate.delegate = self
        amount.delegate = self
        stage.delegate = self
        closeDate.inputView = datePickerView
        datePickerView.minimumDate = currentDate
        datePickerView.datePickerMode = UIDatePickerMode.Date
        datePickerView.addTarget(self, action: #selector(CreateNewOpportunityVC.datePickerValueChanged), forControlEvents: UIControlEvents.ValueChanged)
        self.setNavigationBarItem()
        self.scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: view.frame.size.height );
        scrollView.setNeedsDisplay()
        ///
        //let toolbar: UIToolbar = UIToolbar(frame: CGRectMake(0, 0, 320, 44))
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.BlackOpaque
        //toolBar.barTintColor = self.navigationController?.navigationBar.barTintColor
        toolBar.translucent = true
        toolBar.tintColor = UIColor.whiteColor()
        toolBar.sizeToFit()
        let doneBtn: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(self.doneAction))
        doneBtn.accessibilityFrame = (frame: CGRectMake(250/255.0, 0/255.0, 106.0/255, 53.0/25))
        let spaceBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let cancelBtn = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(self.toolBarCancelAction))
        toolBar.setItems([cancelBtn,spaceBtn,doneBtn], animated: true)
        closeDate.inputAccessoryView = toolBar
        /*let backBarButtonItem:UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "back"), style: .Plain, target: self, action: #selector(CreateNewOpportunityVC.backAction))
         self.navigationItem.setLeftBarButtonItem(backBarButtonItem, animated: true)*/
        // Do any additional setup after loading the view.
        let navBarSaveBtn: UIBarButtonItem = UIBarButtonItem(title: "Update", style: .Plain, target: self, action: #selector(updateOpportunityAction))
        let navColor = navigationController?.navigationBar.barTintColor
        saveBtn.backgroundColor = navColor
        saveBtn.layer.cornerRadius = 5.0
        cancleBtn.backgroundColor = navColor
        cancleBtn.layer.cornerRadius = 5.0
        title = "New Opportunity"
        if flag == true {
            var opportunityAmount:NSNumber = NSInteger()
            if  let _  = nullToNil( opportunityDataDic["Amount"]) {
                opportunityAmount =  (opportunityDataDic["Amount"] as? NSNumber)!
            }
            //let amount:NSNumber = (opportunityDataDic["Amount"] as? NSNumber)!
            self.opportunityName.text = opportunityDataDic["Name"] as? String
            self.closeDate.text = opportunityDataDic["CloseDate"] as? String
            self.amount.text = String(opportunityAmount)
            self.stage.text = opportunityDataDic["StageName"] as? String
            self.saveBtn.hidden = true
            self.cancleBtn.hidden = true
            title = "Edit Opportunity"
            self.navigationItem.setRightBarButtonItem(navBarSaveBtn, animated: true)
        }
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
        let charSet = NSCharacterSet.whitespaceCharacterSet()
        let oppNameWhiteSpaceSet = self.opportunityName.text!.stringByTrimmingCharactersInSet(charSet)
        let closeDateWhiteSpaceSet = self.closeDate.text!.stringByTrimmingCharactersInSet(charSet)
        let amountWhiteSpaceSet = self.amount.text!.stringByTrimmingCharactersInSet(charSet)
        let stageWhiteSpaceSet = self.stage.text!.stringByTrimmingCharactersInSet(charSet)
        let loading = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        if exDelegate.isConnectedToNetwork() {
            if self.opportunityName.text!.isEmpty == true || self.closeDate.text!.isEmpty == true || self.amount.text!.isEmpty == true || self.stage.text!.isEmpty == true {
                loading.mode = MBProgressHUDMode.Text
                loading.hide(true, afterDelay: 2)
                loading.removeFromSuperViewOnHide = true
                loading.detailsLabelText = "please give all values"
                self.animateSubmitBtnOnWrongSubmit()
            } else if oppNameWhiteSpaceSet == "" || amountWhiteSpaceSet == "" || stageWhiteSpaceSet == "" || closeDateWhiteSpaceSet == "" {
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
                    dispatch_async(dispatch_get_main_queue(), {
                        loading.mode = MBProgressHUDMode.Text
                        loading.detailsLabelText = "Successfully Created Opporcunity Record"
                        loading.removeFromSuperViewOnHide = true
                        loading.hide(true, afterDelay: 2)
                        self.opportunityName.text = nil
                        self.closeDate.text = nil
                        self.amount.text = nil
                        self.stage.text = nil
                    })
                    
                    
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
    
    func doneAction() {
        self.flag1 = true
        let datePickerView:UIDatePicker = UIDatePicker()
        self.datePickerValueChanged(datePickerView)
        //datePickerView.addTarget(self, action: #selector(CreateNewOpportunityVC.datePickerValueChanged), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func toolBarCancelAction() {
        self.flag2 = true
        let datePickerView:UIDatePicker = UIDatePicker()
        self.datePickerValueChanged(datePickerView)
        
    }
    
    @IBAction func closeDateTxtFieldEditing(sender: UITextField) {
        let todaysDate = NSDate()
        self.closeDate.text = self.dateVal
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.minimumDate = todaysDate
        datePickerView.datePickerMode = UIDatePickerMode.Date
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(CreateNewOpportunityVC.datePickerValueChanged), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func datePickerValueChanged(sender: UIDatePicker) {
        let dateFormatter:NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        if flag1 == true {
            //closeDate.text = dateFormatter.stringFromDate(sender.date)
            closeDate.text = self.closeDate.text
            closeDate.resignFirstResponder()
            self.dateVal = self.closeDate.text!
        } else if flag2 == true {
            closeDate.text = self.dateVal
            closeDate.resignFirstResponder()
        } else {
            closeDate.text = dateFormatter.stringFromDate(sender.date)
        }
        flag1 = false
        flag2 = false
    }
    
    func updateOpportunityAction() {
        //let dateFormate = self.closeDate.text!
        let params = [
            "Name" : opportunityName.text!,
            "CloseDate" : closeDate.text!,
            "Amount" : amount.text!,
            "StageName" : stage.text!
        ]
        SFRestAPI.sharedInstance().performUpdateWithObjectType("Opportunity", objectId: (opportunityDataDic["Id"] as? String)!, fields: params, failBlock: { err in
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

//
//  CreateObjectViewController.swift
//  salesForceMobileApp
//
//  Created by mac on 15/12/16.
//  Copyright © 2016 Salesforce. All rights reserved.
//

let FieldValueKey = "FieldValue"

import UIKit
import SalesforceSDKCore
import SalesforceNetwork
import SalesforceRestAPI
import MBProgressHUD
var leadStatusValues: AnyObject = []

class CreateObjectViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SFRestDelegate, AccountListDelegate, UITextFieldDelegate {
    var textFieldIndexPath : NSIndexPath?
    @IBOutlet weak var tableView: UITableView!
    var objDataArr = NSMutableArray()
    var objectType = String()
    
    var delegate: CreateNewLeadDelegate?
    var status = String()
    var presentTextField = UITextField()
    func nullToNil(value : AnyObject?) -> AnyObject? {
        if value is NSNull {
            return nil
        } else {
            return value
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPickerView()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        setupDatePicker()
        
        let request = SFRestAPI.sharedInstance().requestForQuery("Select Name, (Select Name, Display_Name__c,Display_order__c from FieldInfos__r Order by Display_order__c ASC ) from Master_Object__c Where name = '\(objectType)'" )
        SFRestAPI.sharedInstance().sendRESTRequest(request, failBlock: { error in
            print(error)
            
            }, completeBlock: { response in
                print(response)
                let arr = ((response!["records"]) as? NSArray)!
                  let midarr = arr.valueForKey("FieldInfos__r") as! NSArray
                self.objDataArr = (midarr.objectAtIndex(0).valueForKey("records") as! NSArray).mutableCopy() as! NSMutableArray
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                })
        })
        self.tableView.separatorColor = UIColor.clearColor()
        // Do any additional setup after loading the view.
    }
   
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objDataArr.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let Identifier = "cellIdentifier"
            let cell = tableView.dequeueReusableCellWithIdentifier(Identifier) as? CreateObjectsCell
        cell!.fieldLabel.text = self.objDataArr[indexPath.row].valueForKey("Display_Name__c") as? String
        if let valueToShow =  self.objDataArr[indexPath.row].valueForKey(FieldValueKey){
            cell!.objectTextField.text = valueToShow as? String
        } else {
          cell!.objectTextField.text = ""
        }
             return cell!
            
    }
    
    
    func textFieldDidEndEditing(textField: UITextField)  {
        let pointInTable = textField.convertPoint(textField.bounds.origin, toView: self.tableView)
        let textFieldIndexPath = self.tableView.indexPathForRowAtPoint(pointInTable)
        let objectDic = objDataArr.objectAtIndex((textFieldIndexPath?.row)!).mutableCopy() as? NSMutableDictionary
        objectDic?.setObject(textField.text!, forKey: FieldValueKey)
        objDataArr.replaceObjectAtIndex((textFieldIndexPath?.row)!, withObject: objectDic!)
    }
    
    @IBAction func saveAction(sender: AnyObject) {
        if objectType == "Lead" {
            saveDataOnLeadObject()
        } else if objectType == "Account"{
            saveDataOnAccountObject()
        } else if objectType == "Contact"{
            saveDataOnContactObject()
        } else {
            saveDataOnOpportunity()
        }
    }

    func  saveDataOnLeadObject() {
        self.view.endEditing(true)
        var  fields = [String: AnyObject]()
        for   data in self.objDataArr {
            let keyExists = data[FieldValueKey] as? String
            fields[ (data["Name"] as? String)!] = data[FieldValueKey]
        }
        
        let loading = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        loading.mode = MBProgressHUDMode.Indeterminate
        loading.detailsLabelText = "Lead is creating!"
        loading.removeFromSuperViewOnHide = true

        
        SFRestAPI.sharedInstance().performCreateWithObjectType("Lead", fields: fields, failBlock: {error in
            
            loading.hide(true, afterDelay: 1)
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                let alert = UIAlertView.init(title: "Error", message: error!.localizedDescription , delegate: self, cancelButtonTitle: "OK")
                alert.show()            }
           
            }, completeBlock: { succes in
                
                print(succes)
                dispatch_async(dispatch_get_main_queue(), {
                    loading.hide(true, afterDelay: 1)
                    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0 * Double(NSEC_PER_SEC)))
                    dispatch_after(delayTime, dispatch_get_main_queue()) {
                        self.navigationController?.popViewControllerAnimated(true)
                    }
                })
        })
    }
  
    func saveDataOnAccountObject(){
        self.view.endEditing(true)
        var  fields = [String: AnyObject]()
        for data in self.objDataArr {
            fields[ (data["Name"] as? String)!] = data[FieldValueKey]
        }
        let loading = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        loading.mode = MBProgressHUDMode.Indeterminate
        loading.detailsLabelText = "Account is creating!"
        loading.removeFromSuperViewOnHide = true
        
        SFRestAPI.sharedInstance().performCreateWithObjectType("Account", fields: fields, failBlock: {error in
            let alert = UIAlertView.init(title: "Error", message: error!.localizedDescription , delegate: self, cancelButtonTitle: "OK")
            alert.show()
            
            }, completeBlock: { succes in
                dispatch_async(dispatch_get_main_queue(), {
                    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0 * Double(NSEC_PER_SEC)))
                    dispatch_after(delayTime, dispatch_get_main_queue()) {
                        self.navigationController?.popViewControllerAnimated(true)
                    }
                })
        })

    }
    
    func saveDataOnContactObject() {
        self.view.endEditing(true)
        var  fields = [String: AnyObject]()
        for data in self.objDataArr {
            fields[ (data["Name"] as? String)!] = data[FieldValueKey]
        }
        let loading = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        loading.mode = MBProgressHUDMode.Indeterminate
        loading.detailsLabelText = "Contact is creating!"
        loading.removeFromSuperViewOnHide = true
        
        SFRestAPI.sharedInstance().performCreateWithObjectType("Contact", fields: fields, failBlock: {error in
            let alert = UIAlertView.init(title: "Error", message: error!.localizedDescription , delegate: self, cancelButtonTitle: "OK")
            alert.show()
            }, completeBlock: { succes in
                dispatch_async(dispatch_get_main_queue(), {
                    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0 * Double(NSEC_PER_SEC)))
                    dispatch_after(delayTime, dispatch_get_main_queue()) {
                        self.navigationController?.popViewControllerAnimated(true)
                    }
                })
        })

    }
    
    func saveDataOnOpportunity() {
        self.view.endEditing(true)
        var  fields = [String: AnyObject]()
        for data in self.objDataArr {
            fields[ (data["Name"] as? String)!] = data[FieldValueKey]
        }
        let loading = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        loading.mode = MBProgressHUDMode.Indeterminate
        loading.detailsLabelText = "Opportunity is creating!"
        loading.removeFromSuperViewOnHide = true
        
        SFRestAPI.sharedInstance().performCreateWithObjectType("Opportunity", fields: fields, failBlock: {error in
            let alert = UIAlertView.init(title: "Error", message: error!.localizedDescription , delegate: self, cancelButtonTitle: "OK")
            alert.show()
            }, completeBlock: { succes in
                dispatch_async(dispatch_get_main_queue(), {
                    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0 * Double(NSEC_PER_SEC)))
                    dispatch_after(delayTime, dispatch_get_main_queue()) {
                        self.navigationController?.popViewControllerAnimated(true)
                    }
                })
        })

    }
    
    
    
     func textFieldDidBeginEditing(textField: UITextField) {
        let pointInTable = textField.convertPoint(textField.bounds.origin, toView: self.tableView)
         textFieldIndexPath = self.tableView.indexPathForRowAtPoint(pointInTable)
        presentTextField = textField
        
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        presentTextField = textField
        let pointInTable = textField.convertPoint(textField.bounds.origin, toView: self.tableView)
        textFieldIndexPath = self.tableView.indexPathForRowAtPoint(pointInTable)
        
        if objDataArr.objectAtIndex((textFieldIndexPath?.row)!)["Name"] as? String == "Status"{
            self.leadStatusPickListValues()
            return false
        }
        
        if objDataArr.objectAtIndex((textFieldIndexPath?.row)!)["Name"] as? String == "CloseDate"{
             presentTextField.resignFirstResponder()
            chooseDOB()
        return false
        }
        return true
    }
    
    @IBAction func leadStatusPickListValues() {
        
        let reqq = SFRestAPI.sharedInstance().requestForQuery("SELECT ApiName FROM LeadStatus")
        SFRestAPI.sharedInstance().sendRESTRequest(reqq, failBlock: {_ in
            print("Error")
            }, completeBlock: {response in
                print(response)
                leadStatusValues = response!["records"]
                dispatch_async(dispatch_get_main_queue(), {
                     self.chooseGender()
                })
        })
    }
    
    var picker = GMPicker()
    
    var datePicker = GMDatePicker()
    var dateFormatter = NSDateFormatter()
    
    func chooseGender(){
        picker.setupGender()
        picker.show(inVC: self)
    }
   
    
    func chooseYear(){
        picker.setupYears()
        picker.show(inVC: self)
    }
    
    func chooseDOB(){
        datePicker.show(inVC: self)
    }

    
}


extension CreateObjectViewController: GMDatePickerDelegate {
    
    func gmDatePicker(gmDatePicker: GMDatePicker, didSelect date: NSDate){
        print(date)
        presentTextField.text = dateFormatter.stringFromDate(date)
    }
    func gmDatePickerDidCancelSelection(gmDatePicker: GMDatePicker) {
        
    }
    
    private func setupDatePicker() {
        
        datePicker.delegate = self
        
        datePicker.config.startDate = NSDate()
        
        datePicker.config.animationDuration = 0.5
        
        datePicker.config.cancelButtonTitle = "Cancel"
        datePicker.config.confirmButtonTitle = "Confirm"
        
        datePicker.config.contentBackgroundColor = UIColor(red: 253/255.0, green: 253/255.0, blue: 253/255.0, alpha: 1)
        datePicker.config.headerBackgroundColor = UIColor(red: 244/255.0, green: 244/255.0, blue: 244/255.0, alpha: 1)
        datePicker.config.confirmButtonColor = UIColor.blackColor()
        datePicker.config.cancelButtonColor = UIColor.blackColor()
        
    }
}

extension CreateObjectViewController: GMPickerDelegate {
    
    func gmPicker(gmPicker: GMPicker, didSelect string: String) {
        presentTextField.text = string
    }
    
    func gmPickerDidCancelSelection(gmPicker: GMPicker){
        
    }
    
    private func setupPickerView(){
        
        picker.delegate = self
        picker.config.animationDuration = 0.5
        
        picker.config.cancelButtonTitle = "Cancel"
        picker.config.confirmButtonTitle = "Confirm"
        
        picker.config.contentBackgroundColor = UIColor(red: 253/255.0, green: 253/255.0, blue: 253/255.0, alpha: 1)
        picker.config.headerBackgroundColor = UIColor(red: 244/255.0, green: 244/255.0, blue: 244/255.0, alpha: 1)
        picker.config.confirmButtonColor = UIColor.blackColor()
        picker.config.cancelButtonColor = UIColor.blackColor()
        
    }
    
}

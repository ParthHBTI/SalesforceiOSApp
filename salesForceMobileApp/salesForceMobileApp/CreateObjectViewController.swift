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
class CreateObjectViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SFRestDelegate {
   

    @IBOutlet weak var tableView: UITableView!
    var objDataArr = NSMutableArray()
    var objectType = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let request = SFRestAPI.sharedInstance().requestForQuery("Select Name, (Select Name, Display_Name__c,Display_order__c from FieldInfos__r) from Master_Object__c Where name = '\(objectType)'")
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
        for data in self.objDataArr {
            fields[ (data["Name"] as? String)!] = data[FieldValueKey]
           
        }
        SFRestAPI.sharedInstance().performCreateWithObjectType("Lead", fields: fields, failBlock: {error in
            let alert = UIAlertView.init(title: "Error", message: error!.localizedDescription , delegate: self, cancelButtonTitle: "OK")
            alert.show()
            }, completeBlock: { succes in
                dispatch_async(dispatch_get_main_queue(), {
                    let loading = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                    loading.mode = MBProgressHUDMode.Indeterminate
                    loading.detailsLabelText = "Lead is creating!"
                    loading.removeFromSuperViewOnHide = true
                    loading.hide(true, afterDelay: 2)
                    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
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
        SFRestAPI.sharedInstance().performCreateWithObjectType("Account", fields: fields, failBlock: {error in
            let alert = UIAlertView.init(title: "Error", message: error!.localizedDescription , delegate: self, cancelButtonTitle: "OK")
            alert.show()
            
            }, completeBlock: { succes in
                dispatch_async(dispatch_get_main_queue(), {
                    let loading = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                    loading.mode = MBProgressHUDMode.Indeterminate
                    loading.detailsLabelText = "Account is creating!"
                    loading.removeFromSuperViewOnHide = true
                    loading.hide(true, afterDelay: 2)
                    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
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

        SFRestAPI.sharedInstance().performCreateWithObjectType("Contact", fields: fields, failBlock: {error in
            let alert = UIAlertView.init(title: "Error", message: error!.localizedDescription , delegate: self, cancelButtonTitle: "OK")
            alert.show()
            }, completeBlock: { succes in
                dispatch_async(dispatch_get_main_queue(), {
                    let loading = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                    loading.mode = MBProgressHUDMode.Indeterminate
                    loading.detailsLabelText = "Contact is creating!"
                    loading.removeFromSuperViewOnHide = true
                    loading.hide(true, afterDelay: 2)
                    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
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
        SFRestAPI.sharedInstance().performCreateWithObjectType("Opportunity", fields: fields, failBlock: {error in
            let alert = UIAlertView.init(title: "Error", message: error!.localizedDescription , delegate: self, cancelButtonTitle: "OK")
            alert.show()
            }, completeBlock: { succes in
                dispatch_async(dispatch_get_main_queue(), {
                    let loading = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                    loading.mode = MBProgressHUDMode.Indeterminate
                    loading.detailsLabelText = "Opportunity is creating!"
                    loading.removeFromSuperViewOnHide = true
                    loading.hide(true, afterDelay: 2)
                    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
                    dispatch_after(delayTime, dispatch_get_main_queue()) {
                        self.navigationController?.popViewControllerAnimated(true)
                    }
                })
        })

    }
    
    
    
     func textFieldDidBeginEditing(textField: UITextField) {
        if objDataArr.valueForKey("Name") as? String == "Status"{
            self.leadStatusPickListValues()
        }
    }
    
    @IBAction func leadStatusPickListValues() {
        
        let reqq = SFRestAPI.sharedInstance().requestForQuery("SELECT ApiName FROM LeadStatus")
        SFRestAPI.sharedInstance().sendRESTRequest(reqq, failBlock: {_ in
            print("Error")
            }, completeBlock: {response in
                print(response)
//                self.leadStatusValues = response!["records"]
//                dispatch_async(dispatch_get_main_queue(), {
//                    let storyboard = UIStoryboard.init(name: "SubContentsViewController", bundle: nil)
//                    let presentVC = storyboard.instantiateViewControllerWithIdentifier( "AccountListViewController") as? AccountListViewController
//                    presentVC!.accountListArr = self.leadStatusValues
//                    presentVC?.flag = true
//                    presentVC?.delegate = self;
//                    let nvc: UINavigationController = UINavigationController(rootViewController: presentVC!)
//                    self.presentViewController(nvc, animated: true, completion:nil)
//                })
        })
    }

    
    
    
}




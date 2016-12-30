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

var exDelegate: ExecuteQuery = ExecuteQuery()

protocol UpdateInfoDelegate {
    func updateInfo(params:Bool)
    func updateOfflineData(offlineData: NSMutableArray)
}


class CreateObjectViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SFRestDelegate, AccountListDelegate, UITextFieldDelegate {
    
    var offLineDataArr: AnyObject = NSMutableArray()
    var delegate:UpdateInfoDelegate?
    var objectInfoDic = [:]

    var isEditable = false

    var isOffLine = false
    var textFieldIndexPath : NSIndexPath?
    @IBOutlet weak var tableView: UITableView!
    var objDataArr = NSMutableArray()
    var objectType = String()
    
    var status = String()
    var presentTextField = UITextField()
    
    func nullToNil(value : AnyObject?) -> AnyObject? {
        if value is NSNull {
            return nil
        } else {
            return value
        }
    }
    
    
    
    func getSelectedAccountInfo(accointDetail:NSDictionary) {
        let accountName = accointDetail["Id"] as? String
        presentTextField.text = accountName
        
        let objectDic = objDataArr.objectAtIndex((textFieldIndexPath?.row)!).mutableCopy() as? NSMutableDictionary
        objectDic?.setObject(accountName!, forKey: FieldValueKey)
        objDataArr.replaceObjectAtIndex((textFieldIndexPath?.row)!, withObject: objectDic!)
        
        print(accointDetail)
    }
    
    @IBAction func chosseAccountPicker() {
        
        let reqq = SFRestAPI.sharedInstance().requestForQuery(AccountPIckerQuery)
        SFRestAPI.sharedInstance().sendRESTRequest(reqq, failBlock: {_ in
            print("Error")
            }, completeBlock: {response in
                print(response)
                dispatch_async(dispatch_get_main_queue(), {
                    let storyboard = UIStoryboard.init(name: "SubContentsViewController", bundle: nil)
                    let presentVC = storyboard.instantiateViewControllerWithIdentifier( "AccountListViewController") as? AccountListViewController
                    presentVC!.accountListArr = response!["records"]
                    presentVC?.delegate = self;
                    let nvc: UINavigationController = UINavigationController(rootViewController: presentVC!)
                    self.presentViewController(nvc, animated: true, completion:nil)
                })
        })
    }
    
    func setUpEditableValue()  {
        if isEditable {
            
            print(objectInfoDic)
            print(objDataArr)
            var k = 0
            for loopObjc in objDataArr {
                let objKey = loopObjc["Name"] as? String
                let  objValue = objectInfoDic[objKey!]
                let objectDic = loopObjc.mutableCopy() as? NSMutableDictionary
                if let _ = objValue {
                    objectDic?.setObject(objValue!, forKey: FieldValueKey)
                    objDataArr.replaceObjectAtIndex(k, withObject: objectDic!)
                }else {
                    objectDic?.setObject("", forKey: FieldValueKey)
                    objDataArr.replaceObjectAtIndex(k, withObject: objectDic!)
                }
                k += 1;
            }
            
            
            self.tableView.reloadData()
            //isOfflineData
        }
    }
    
    func downloadSchemaForPage() {
        
        let schemaKey = "\(objectType)_\(SchemaKeySuffix)"
        
        if exDelegate.isConnectedToNetwork() {
        let request = SFRestAPI.sharedInstance().requestForQuery("Select Name, (Select Name, Display_Name__c,Display_order__c, Input_Type__c, Picker_Value__c from FieldInfos__r Order by Display_order__c ASC ) from Master_Object__c Where name = '\(objectType)'" )
        SFRestAPI.sharedInstance().sendRESTRequest(request, failBlock: { error in
            print(error)
            }, completeBlock: { response in
                print(response)
                let arr = ((response!["records"]) as? NSArray)!
                if  arr.count > 0 {
                    if (response!["records"]!.valueForKey("FieldInfos__r")?.objectAtIndex(0).valueForKey("records")?.count > 0 ) {
                        let midarr = arr.valueForKey("FieldInfos__r") as! NSArray
                        self.objDataArr = (midarr.objectAtIndex(0).valueForKey("records") as! NSArray).mutableCopy() as! NSMutableArray
                        let arrOfLeadData = NSKeyedArchiver.archivedDataWithRootObject( self.objDataArr)
                        defaults.setObject(arrOfLeadData, forKey: schemaKey)
                    }
                    dispatch_async(dispatch_get_main_queue(), {
                        self.setUpEditableValue()
                        self.tableView.reloadData()
                    })
                }
        })
        } else {
            if let arrayOfObjectsData = defaults.objectForKey(schemaKey) as? NSData {
                 self.objDataArr = NSKeyedUnarchiver.unarchiveObjectWithData(arrayOfObjectsData)!.mutableCopy() as! NSMutableArray
                self.setUpEditableValue()

            }
        
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPickerView()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        setupDatePicker()
        self.tableView.separatorColor = UIColor.clearColor()
        // Do any additional setup after loading the view.
        downloadSchemaForPage()
        if let arrayOfObjectsData = defaults.objectForKey(getDataKey()) as? NSData {
            offLineDataArr = NSKeyedUnarchiver.unarchiveObjectWithData(arrayOfObjectsData)!
        }
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
            cell!.objectTextField.text =  String(valueToShow)
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
    
    
    
    func updateInfo(fields:[String: AnyObject]) {
    if exDelegate.isConnectedToNetwork() {
        let loading = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        loading.mode = MBProgressHUDMode.Indeterminate
        loading.detailsLabelText = "Updating!"
        loading.hide(true, afterDelay: 2)
        loading.removeFromSuperViewOnHide = true
   
    SFRestAPI.sharedInstance().performUpdateWithObjectType(objectType, objectId: (objectInfoDic["Id"] as? String)!, fields: fields , failBlock: { err in
    dispatch_async(dispatch_get_main_queue(), {
        loading.hide(true, afterDelay: 1)

    let alert = UIAlertView.init(title: "Error", message: err?.localizedDescription , delegate: self, cancelButtonTitle: "OK")
    alert.show()
    })
    }){ succes in
        self.delegate!.updateInfo(true)
    dispatch_async(dispatch_get_main_queue(), {
        loading.hide(true, afterDelay: 1)
        
    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0 * Double(NSEC_PER_SEC)))
    dispatch_after(delayTime, dispatch_get_main_queue()) {
    self.navigationController?.popViewControllerAnimated(true)
    }
    })
    }
    } else {
        if offLineDataArr.count > globalIndex {
            offLineDataArr.setObject(fields, atIndex: globalIndex )
            let offlineUpdatedArr = NSMutableArray()
            for (key, value) in fields {
                let objectDic = NSMutableDictionary()
                objectDic.setObject(key, forKey: KeyName)
                objectDic.setObject(value, forKey: KeyValue)
                offlineUpdatedArr.addObject(objectDic)
            }
            delegate?.updateOfflineData(offlineUpdatedArr)
            let arrOfLeadData = NSKeyedArchiver.archivedDataWithRootObject(offLineDataArr)
            defaults.setObject(arrOfLeadData, forKey: getDataKey())
            delegate?.updateInfo(true)
            dispatch_async(dispatch_get_main_queue(), {
                let loading = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                loading.mode = MBProgressHUDMode.Indeterminate
                loading.detailsLabelText = "\(self.objectType) is creating!"
                loading.removeFromSuperViewOnHide = true
                loading.hide(true, afterDelay:1)
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0 * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue()) {
                    self.navigationController?.popViewControllerAnimated(true)
                }
            })

        }
}
}
   
    func getDataKey() -> String {
        var keyForOffLine = ""
        switch objectType {
        case "Lead":
            keyForOffLine = "\(ObjectDataType.leadValue.rawValue)\(OffLineKeySuffix)"
            break
        case "Contact":
            keyForOffLine = "\(ObjectDataType.leadValue.rawValue)\(OffLineKeySuffix)"
            break
        case "Account":
            keyForOffLine = "\(ObjectDataType.leadValue.rawValue)\(OffLineKeySuffix)"
            break
        case "Opportunity":
            keyForOffLine = "\(ObjectDataType.leadValue.rawValue)\(OffLineKeySuffix)"
            break
        default:
            keyForOffLine = ""
        }

        return keyForOffLine
    }
    
    @IBAction func saveAction(sender: AnyObject) {
        
       
        self.view.endEditing(true)
        var  fields = [String: AnyObject]()
        for   data in self.objDataArr {
            if let val = data[FieldValueKey] {
                if let x = val {
                    print(x)
                    fields[ (data["Name"] as? String)!] = data[FieldValueKey]
                } else {
                    print("value is nil")
                }
            } else {
                print("key is not present in dict")
            }
        }
        
        if isEditable {
        
        updateInfo(fields)
        
        } else {
        
        
        if exDelegate.isConnectedToNetwork() {
            let loading = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            loading.mode = MBProgressHUDMode.Indeterminate
            loading.detailsLabelText = "\(objectType) is creating!"
            loading.removeFromSuperViewOnHide = true
            
            
            SFRestAPI.sharedInstance().performCreateWithObjectType(objectType, fields: fields, failBlock: {error in
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0 * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue()) {
                    loading.hide(true, afterDelay: 1)
                    let alert = UIAlertView.init(title: "Error", message: error!.localizedDescription , delegate: self, cancelButtonTitle: "OK")
                    alert.show()
                }
                
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
        } else {
            
            offLineDataArr.addObject(fields)
            let arrOfLeadData = NSKeyedArchiver.archivedDataWithRootObject(offLineDataArr)
            defaults.setObject(arrOfLeadData, forKey: getDataKey())
            dispatch_async(dispatch_get_main_queue(), {
                let loading = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                loading.mode = MBProgressHUDMode.Indeterminate
                loading.detailsLabelText = "Lead is creating!"
                loading.removeFromSuperViewOnHide = true
                loading.hide(true, afterDelay:2)
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue()) {
                    self.navigationController?.popViewControllerAnimated(true)
                }
            })
        }
        }
       
    }
    
   /* func saveDataOnAccountObject(){
        self.view.endEditing(true)
        var  fields = [String: AnyObject]()
        for data in self.objDataArr {
            fields[ (data["Name"] as? String)!] = data[FieldValueKey]
        }
        let loading = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        loading.mode = MBProgressHUDMode.Indeterminate
        loading.detailsLabelText = "Account is creating!"
        loading.removeFromSuperViewOnHide = true
        
        SFRestAPI.sharedInstance().performCreateWithObjectType(objectType, fields: fields, failBlock: {error in
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                loading.hide(true, afterDelay: 1)
                let alert = UIAlertView.init(title: "Error", message: error!.localizedDescription , delegate: self, cancelButtonTitle: "OK")
                alert.show()
            }
            
            }, completeBlock: { succes in
                dispatch_async(dispatch_get_main_queue(), {
                    loading.hide(true, afterDelay: 1)

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
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                loading.hide(true, afterDelay: 1)
                let alert = UIAlertView.init(title: "Error", message: error!.localizedDescription , delegate: self, cancelButtonTitle: "OK")
                alert.show()
            }
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
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                loading.hide(true, afterDelay: 1)
                let alert = UIAlertView.init(title: "Error", message: error!.localizedDescription , delegate: self, cancelButtonTitle: "OK")
                alert.show()
            }
            }, completeBlock: { succes in
                dispatch_async(dispatch_get_main_queue(), {
                    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0 * Double(NSEC_PER_SEC)))
                    dispatch_after(delayTime, dispatch_get_main_queue()) {
                        self.navigationController?.popViewControllerAnimated(true)
                    }
                })
        })
        
    }
    
    
    */
    func textFieldDidBeginEditing(textField: UITextField) {
        let pointInTable = textField.convertPoint(textField.bounds.origin, toView: self.tableView)
        textFieldIndexPath = self.tableView.indexPathForRowAtPoint(pointInTable)
        presentTextField = textField
        
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        presentTextField = textField
        let pointInTable = textField.convertPoint(textField.bounds.origin, toView: self.tableView)
        textFieldIndexPath = self.tableView.indexPathForRowAtPoint(pointInTable)
        
        if objDataArr.objectAtIndex((textFieldIndexPath?.row)!)["Input_Type__c"] as? String == TextFieldType {
            
            let pickerValue = self.objDataArr[(textFieldIndexPath?.row)!]["Picker_Value__c"] as! String
            print(pickerValue)
            let textPickerValueArr = pickerValue.componentsSeparatedByString(",")
            self.picker.showTextPicker(textPickerValueArr)
            self.picker.show(inVC: self)
            return false
        }  else if (objDataArr.objectAtIndex((textFieldIndexPath?.row)!)["Input_Type__c"] as? String == DatePicker) {
            presentTextField.resignFirstResponder()
            chooseDOB()
            return false
        }  else if objDataArr.objectAtIndex((textFieldIndexPath?.row)!)["Input_Type__c"] as? String == AccountPIcker {
            presentTextField.resignFirstResponder()
            chosseAccountPicker()
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
               let leadStatusValues = response!["records"]
                dispatch_async(dispatch_get_main_queue(), {
                    self.picker.showTextPicker(leadStatusValues as! NSArray )
                    self.picker.show(inVC: self)
                })
        })
    }
    
    var picker = GMPicker()
    
    var datePicker = GMDatePicker()
    var dateFormatter = NSDateFormatter()
    
    
    
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
        
        
        let objectDic = objDataArr.objectAtIndex((textFieldIndexPath?.row)!).mutableCopy() as? NSMutableDictionary
        objectDic?.setObject(presentTextField.text!, forKey: FieldValueKey)
        objDataArr.replaceObjectAtIndex((textFieldIndexPath?.row)!, withObject: objectDic!)
        

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
        let objectDic = objDataArr.objectAtIndex((textFieldIndexPath?.row)!).mutableCopy() as? NSMutableDictionary
        objectDic?.setObject(presentTextField.text!, forKey: FieldValueKey)
        objDataArr.replaceObjectAtIndex((textFieldIndexPath?.row)!, withObject: objectDic!)
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

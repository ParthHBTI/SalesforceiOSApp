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

protocol CreateNewLeadDelegate {
    func getValFromLeadVC(params:Bool)
    func getOfflineUpdatedLeadData(sendOfflineLeadArr: NSMutableArray)
    
    }


class CreateNewLeadVC: TextFieldViewController, ExecuteQueryDelegate, SFRestDelegate, AccountListDelegate {
    
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var companyName: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var cancleBtn: UIButton!
    @IBOutlet weak var leadStatus: UITextField!
    var flag: Bool = false
    var leadDataDict:AnyObject = []
    var leadStatusValues: AnyObject = []
    var exDelegate: ExecuteQuery = ExecuteQuery()
    var delegate: CreateNewLeadDelegate?
    var leadOfLineArr: AnyObject = NSMutableArray()
    var updateOfflineLeadAtIndex: Int = 0

    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let arrayOfObjectsData = defaults.objectForKey("\(ObjectDataType.leadValue.rawValue)\(OffLineKeySuffix)") as? NSData {
            leadOfLineArr = NSKeyedUnarchiver.unarchiveObjectWithData(arrayOfObjectsData)!
        }
        
        print(leadDataDict)
        lastName.delegate = self
        companyName.delegate = self
        cancleBtn.hidden = true
        setNavigationBarItem()
       leadStatus.delegate = self
        self.scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: view.frame.size.height );
        scrollView.setNeedsDisplay()
        //        let backBarButtonItem:UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "back"), style: .Plain, target: self, varion: #selector(CreateNewLeadVC.backAction))
        //        self.navigationItem.setLeftBarButtonItem(backBarButtonItem, animated: true)
        let navBarUpdateBtn: UIBarButtonItem = UIBarButtonItem(title: "Update", style: .Plain, target: self, action: #selector(updateLeadAction))
        
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
            //cancleBtn.hidden = true
            title = "Edit Lead"
            self.navigationItem.setRightBarButtonItem(navBarUpdateBtn, animated: true)
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
        //let storyboard = UIStoryboard(name: "Main" , bundle: nil)
        //let nav = storyboard.instantiateViewControllerWithIdentifier("LeadViewController") as! LeadViewController
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
                    //self.delegate!.getValFromLeadVC(true)
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
        } else {
           let leadDataArr = [
            "LastName" : lastName.text!,
            "Company" : companyName.text!,
            "Status" : leadStatus.text!
           ]
            leadOfLineArr.addObject(leadDataArr)
            let arrOfLeadData = NSKeyedArchiver.archivedDataWithRootObject(leadOfLineArr)
            defaults.setObject(arrOfLeadData, forKey: "\(ObjectDataType.leadValue.rawValue)\(OffLineKeySuffix)")
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
                    self.delegate!.getValFromLeadVC(true)
                    dispatch_async(dispatch_get_main_queue(), {
                        let loading = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                        loading.mode = MBProgressHUDMode.Indeterminate
                        loading.detailsLabelText = "Updating!"
                        loading.hide(true, afterDelay: 2)
                        loading.removeFromSuperViewOnHide = true
                        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
                        dispatch_after(delayTime, dispatch_get_main_queue()) {
                            self.navigationController?.popViewControllerAnimated(true)
                        }
                    })
                }
            }
        } else {
            
            if leadOfLineArr.count > updateOfflineLeadAtIndex {
                /*let leadData : NSMutableDictionary = [:]
                leadData.setObject(lastName.text!, forKey: "LastName")
                leadData.setObject(companyName.text!, forKey: "Company")
                leadData.setObject(leadStatus.text!, forKey: "Status")*/
                let leadDataArr = [
                    "LastName" : lastName.text!,
                    "Company" : companyName.text!,
                    "Status" : leadStatus.text!
                ]
                let leadOfflineArray = NSMutableArray()
                for (key,val) in leadDataArr {
                    let objectDic = NSMutableDictionary()
                    objectDic.setObject(key, forKey: KeyName)
                    objectDic.setObject(val, forKey: KeyValue)
                    leadOfflineArray.addObject(objectDic)
                }
                leadOfLineArr.setObject(leadDataArr, atIndex: updateOfflineLeadAtIndex )
                let arrOfLeadData = NSKeyedArchiver.archivedDataWithRootObject(leadOfLineArr)
                defaults.setObject(arrOfLeadData, forKey: "\(ObjectDataType.leadValue.rawValue)\(OffLineKeySuffix)")
                
                self.delegate!.getValFromLeadVC(true)
                self.delegate!.getOfflineUpdatedLeadData(leadOfflineArray as NSMutableArray)
                dispatch_async(dispatch_get_main_queue(), {
                    let loading = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                    loading.mode = MBProgressHUDMode.Indeterminate
                    loading.detailsLabelText = "Updating!"
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
    
    
    override func textFieldDidBeginEditing(textField: UITextField) {
        if textField.isEqual(leadStatus){
        leadStatusPickListValues()
        }
    }
    
    @IBAction func leadStatusPickListValues() {
        
            let reqq = SFRestAPI.sharedInstance().requestForQuery("SELECT ApiName FROM LeadStatus")
            SFRestAPI.sharedInstance().sendRESTRequest(reqq, failBlock: {_ in
                print("Error")
                }, completeBlock: {response in
                    print(response)
                    self.leadStatusValues = response!["records"]
                    dispatch_async(dispatch_get_main_queue(), {
                    let storyboard = UIStoryboard.init(name: "SubContentsViewController", bundle: nil)
                    let presentVC = storyboard.instantiateViewControllerWithIdentifier( "AccountListViewController") as? AccountListViewController
                    presentVC!.accountListArr = self.leadStatusValues
                    presentVC?.flag = true
                    presentVC?.delegate = self;
                    let nvc: UINavigationController = UINavigationController(rootViewController: presentVC!)
                    self.presentViewController(nvc, animated: true, completion:nil)
            })
        })
    }
    
    func isSubmittedCorrectVal() -> Bool {
        let charSet = NSCharacterSet.whitespaceCharacterSet()
        let lastNameWhiteSpaceSet = self.lastName.text!.stringByTrimmingCharactersInSet(charSet)
        let companyNameWhiteSpaceSet = self.companyName.text!.stringByTrimmingCharactersInSet(charSet)
        let leadStatusWhiteSpaceSet = leadStatus.text!.stringByTrimmingCharactersInSet(charSet)
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
    
    func getSelectedAccountInfo(accointDetail:NSDictionary) {
        leadStatus.text = accointDetail["ApiName"] as? String
        leadStatusValues = accointDetail;
        print(accointDetail)
    }
    
    
    func request(request: SFRestRequest, didLoadResponse dataResponse: AnyObject) {
        //let attachmentID = dataResponse["id"] as! String
            }
    
    func request(request: SFRestRequest, didFailLoadWithError error: NSError)
    {
        self.log(.Debug, msg: "didFailLoadWithError: \(error)")
        // Add your failed error handling here
    }
    
    func requestDidCancelLoad(request: SFRestRequest)
    {
        self.log(.Debug, msg: "requestDidCancelLoad: \(request)")
        // Add your failed error handling here
    }
    
    func requestDidTimeout(request: SFRestRequest)
    {
        self.log(.Debug, msg: "requestDidTimeout: \(request)")
        // Add your failed error handling here
    }
    

}
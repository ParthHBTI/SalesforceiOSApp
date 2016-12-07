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

protocol CreateNewAccDelegate {
    func getValFromAccVC(params:Bool)
}

class CreateNewAccountVC: TextFieldViewController, UIScrollViewDelegate, ExecuteQueryDelegate {
    
    @IBOutlet weak var accountName: UITextField!
    @IBOutlet weak var billingStreet: UITextField!
    @IBOutlet weak var billingCity: UITextField!
    @IBOutlet weak var billingState: UITextField!
    @IBOutlet weak var billingCountry: UITextField!
    @IBOutlet weak var postalCode: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var cancleBtn: UIButton!
    @IBOutlet weak var postalWarningLbl: UILabel!
    var accDataArr:NSMutableArray? = NSMutableArray()
    var accOfflineArr: AnyObject = NSMutableArray()
    var flag: Bool = false
    var accountDataDic:AnyObject = []
    
    var exDelegate: ExecuteQuery = ExecuteQuery()
    var delegate: CreateNewAccDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let arrayOfObjectsData = defaults.objectForKey(AccOfflineDataKey) as? NSData {
            accOfflineArr = NSKeyedUnarchiver.unarchiveObjectWithData(arrayOfObjectsData)!
        }
        accountName.delegate = self
        billingStreet.delegate = self
        billingCity.delegate = self
        billingState.delegate = self
        billingCountry.delegate = self
        postalCode.delegate = self
        postalWarningLbl.hidden = true
        self.cancleBtn.hidden = true
        setNavigationBarItem()
        self.scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: view.frame.size.height);
        scrollView.setNeedsDisplay()
        /*let backBarButtonItem:UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "back"), style: .Plain, target: self, action: #selector(CreateNewAccountVC.backAction))
         self.navigationItem.setLeftBarButtonItem(backBarButtonItem, animated: true)*/
        let navBarUpdateBtn: UIBarButtonItem = UIBarButtonItem(title: "Update", style: .Plain, target: self, action: #selector(updateAccountAction))
        let navColor = navigationController?.navigationBar.barTintColor
        saveBtn.backgroundColor = navColor
        saveBtn.layer.cornerRadius = 5.0
        cancleBtn.backgroundColor = navColor
        cancleBtn.layer.cornerRadius = 5.0
        title = "New Account"
        if flag == true {
            self.accountName.text = accountDataDic["Name"] as? String
            self.billingStreet.text = accountDataDic["BillingStreet"] as? String
            self.billingCity.text = accountDataDic["BillingCity"] as? String
            self.billingState.text = accountDataDic["BillingState"] as? String
            self.billingCountry.text = accountDataDic["BillingCountry"] as? String
            self.postalCode.text = accountDataDic["BillingPostalCode"] as? String
            self.saveBtn.hidden = true
            //self.cancleBtn.hidden = true
            title = "Edit Account"
            self.navigationItem.setRightBarButtonItem(navBarUpdateBtn, animated: true)
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
        self.scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height + 100);
        //self.scrollView.backgroundColor = UIColor.greenColor()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveAction(sender: AnyObject) {
        if exDelegate.isConnectedToNetwork() {
            if self.isSubmitCorrectVal() {
                let fields = [
                    "Name" : accountName.text!,
                    "BillingStreet" : billingStreet.text!,
                    "BillingCity" : billingCity.text!,
                    "BillingState" : billingState.text!,
                    "BillingCountry" : billingCountry.text!,
                    "BillingPostalCode" : postalCode.text!
                ]
                SFRestAPI.sharedInstance().performCreateWithObjectType("Account", fields: fields, failBlock: { err in
                    dispatch_async(dispatch_get_main_queue(), {
                        let alert = UIAlertView.init(title: "Error", message: err?.localizedDescription , delegate: self, cancelButtonTitle: "OK")
                        alert.show()
                    })
                    print( (err))
                }) { succes in
                    self.delegate!.getValFromAccVC(true)
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
                        /*self.accountName.text = nil
                         self.billingStreet.text = nil
                         self.billingCity.text = nil
                         self.billingState.text = nil
                         self.billingCountry.text = nil
                         self.billingCountry.text = nil*/
                    })
                }
            }
        }
        else {
            let accDataDic = [
                "AccName" : accountName.text!,
                "BillingStreet" : billingStreet.text!,
                "BillingCity" : billingCity.text!,
                "BillingState" : billingState.text!,
                "BillingCountry" : billingCountry.text!,
                "BillingPostalCode" : postalCode.text!
            ]
            accOfflineArr.addObject(accDataDic)
            let arrOfAccData = NSKeyedArchiver.archivedDataWithRootObject(accOfflineArr)
            defaults.setObject(arrOfAccData, forKey: AccOfflineDataKey)
            let loading = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            loading.mode = MBProgressHUDMode.Indeterminate
            loading.detailsLabelText = "Please check your Internet connection!"
            loading.hide(true, afterDelay: 2)
            loading.removeFromSuperViewOnHide = true
        }
    }
    
    
    @IBAction func cancelAction(sender: AnyObject) {
        
        
    }
    
    //update account record
    func updateAccountAction() {
        if exDelegate.isConnectedToNetwork() {
            if self.isSubmitCorrectVal() {
                let params = [
                    "Name" : accountName.text!,
                    "BillingStreet" : billingStreet.text!,
                    "BillingCity" : billingCity.text!,
                    "BillingState" : billingState.text!,
                    "BillingCountry" : billingCountry.text!,
                    "BillingPostalCode" : postalCode.text!
                ]
                SFRestAPI.sharedInstance().performUpdateWithObjectType("Account", objectId: (accountDataDic["Id"] as? String)!, fields: params , failBlock: { err in
                    dispatch_async(dispatch_get_main_queue(), {
                        let alert = UIAlertView.init(title: "Error", message: err?.localizedDescription , delegate: self, cancelButtonTitle: "OK")
                        alert.show()
                    })
                    print( (err))
                }){ succes in
                    self.delegate!.getValFromAccVC(true)
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
            let loading = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            loading.mode = MBProgressHUDMode.Indeterminate
            loading.detailsLabelText = "Please check your Internet connection!"
            loading.hide(true, afterDelay: 2)
            loading.removeFromSuperViewOnHide = true
        }
    }
    
    
    func isSubmitCorrectVal() -> Bool {
        let charSet = NSCharacterSet.whitespaceCharacterSet()
        let accNameWhiteSpaceSet = self.accountName.text!.stringByTrimmingCharactersInSet(charSet)
        let billStreetWhiteSpaceSet = self.billingStreet.text!.stringByTrimmingCharactersInSet(charSet)
        let billCityWhiteSpaceSet = self.billingCity.text!.stringByTrimmingCharactersInSet(charSet)
        let billStateWhiteSpaceSet = self.billingState.text!.stringByTrimmingCharactersInSet(charSet)
        let billCntryWhiteSpaceSet = self.billingCountry.text!.stringByTrimmingCharactersInSet(charSet)
        let billPostalCodeWhiteSpaceSet = self.postalCode.text!.stringByTrimmingCharactersInSet(charSet)
        if accountName.text!.isEmpty == true || billingStreet.text!.isEmpty == true || billingCity.text!.isEmpty == true || billingState.text!.isEmpty == true ||  postalCode.text!.isEmpty == true || billingCountry.text!.isEmpty == true {
            let loading = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            loading.mode = MBProgressHUDMode.Text
            loading.hide(true, afterDelay: 2)
            loading.removeFromSuperViewOnHide = true
            loading.detailsLabelText = "please give all values"
            self.animateSubmitBtnOnWrongSubmit()
            return false
        } else if billPostalCodeWhiteSpaceSet == "" || accNameWhiteSpaceSet == "" || billStreetWhiteSpaceSet == ""  || billCntryWhiteSpaceSet == ""  || billCityWhiteSpaceSet == ""  || billStateWhiteSpaceSet == ""  {
            let loading = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            loading.mode = MBProgressHUDMode.Text
            loading.hide(true, afterDelay: 2)
            loading.removeFromSuperViewOnHide = true
            loading.detailsLabelText = "You entered white spaces only"
            self.animateSubmitBtnOnWrongSubmit()
            return false
        } else if postalCode.text!.characters.count != 6 {
            let loading = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            loading.mode = MBProgressHUDMode.Text
            loading.hide(true, afterDelay: 2)
            loading.removeFromSuperViewOnHide = true
            loading.detailsLabelText = "Please enter a valid postal code"
            self.animateSubmitBtnOnWrongSubmit()
            return false
        }
        return true
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
    
    
    func textField(textField: UITextField,
                   shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let prospectiveText = (currentText as NSString).stringByReplacingCharactersInRange(range, withString: string)
        if string.characters.count == 0 {
            if prospectiveText.characters.count <= 6 {
                postalWarningLbl.hidden = true
            }
            return true
        }
        switch textField {
        case  postalCode:
            if prospectiveText.characters.count > 6 {
                postalWarningLbl.hidden = false
                postalWarningLbl.text = "*Please enter a valid postal code"
                postalWarningLbl.textColor = UIColor.redColor()
            }
            return true
            
        default:
            return true
        }
    }
    
}

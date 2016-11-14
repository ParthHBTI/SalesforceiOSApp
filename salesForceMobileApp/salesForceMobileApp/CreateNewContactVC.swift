//
//  RightViewController.swift
//  SlideMenuControllerSwift
//
//  Created by Yuji Hato on 12/3/14.
//

import UIKit
import SalesforceNetwork
import SalesforceRestAPI
import SalesforceSDKCore
import SmartStore.SalesforceSDKManagerWithSmartStore
import SmartSync
import SmartStore
import MBProgressHUD

class CreateNewContactVC : TextFieldViewController, SFRestDelegate,ExecuteQueryDelegate {
    
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var fax: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var cancleBtn: UIButton!
    @IBOutlet weak var phoneWarnigLbl: UILabel!
    
    var exDelegate: ExecuteQuery = ExecuteQuery()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstName.delegate = self
        lastName.delegate = self
        email.delegate = self
        phone.delegate = self
        fax.delegate = self
        phoneWarnigLbl.hidden = true
        self.setNavigationBarItem()
        self.scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: view.frame.size.height );
        scrollView.setNeedsDisplay()
        /*let backBarButtonItem:UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "back"), style: .Plain, target: self, action: #selector(CreateNewContactVC.backAction))
         self.navigationItem.setLeftBarButtonItem(backBarButtonItem, animated: true)*/
        let navColor = navigationController?.navigationBar.barTintColor
        saveBtn.backgroundColor = navColor
        saveBtn.layer.cornerRadius = 5.0
        cancleBtn.backgroundColor = navColor
        cancleBtn.layer.cornerRadius = 5.0
        // Do any additional setup after loading the view.
    }
    
    /*func backAction() {
     for controller: UIViewController in self.navigationController!.viewControllers {
     if (controller is ContactViewController) {
     self.navigationController!.popToViewController(controller, animated: true)
     }
     }
     }*/
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLayoutSubviews()  {
        super.viewDidLayoutSubviews()
        self.scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: view.frame.size.height + 100);
    }
    
    @IBAction func saveAction(sender: AnyObject) {
        let firstNameStr = self.firstName.text!
        let lastNameStr = self.lastName.text!
        let emailStr = self.email.text!
        let phoneStr = self.phone.text!
        let faxStr = self.fax.text!
        let charSet = NSCharacterSet.whitespaceCharacterSet()
        let firstNameWhiteSpaceSet = firstNameStr.stringByTrimmingCharactersInSet(charSet)
        let lastNameWhiteSpaceSet = lastNameStr.stringByTrimmingCharactersInSet(charSet)
        let emailWhiteSpaceSet = emailStr.stringByTrimmingCharactersInSet(charSet)
        let phoneWhiteSpaceSet = phoneStr.stringByTrimmingCharactersInSet(charSet)
        let faxWhiteSpaceSet = faxStr.stringByTrimmingCharactersInSet(charSet)
        
        if exDelegate.isConnectedToNetwork() {
            if firstName.text!.isEmpty == true || lastName.text!.isEmpty == true || email.text!.isEmpty == true || phone.text!.isEmpty == true || fax.text!.isEmpty == true {
                let loading = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                loading.mode = MBProgressHUDMode.Text
                loading.hide(true, afterDelay: 2)
                loading.removeFromSuperViewOnHide = true
                loading.detailsLabelText = "please give all values"
                self.animateSubmitBtnOnWrongSubmit()
            } else if firstNameWhiteSpaceSet == "" || lastNameWhiteSpaceSet == "" || emailWhiteSpaceSet == "" || phoneWhiteSpaceSet == "" || faxWhiteSpaceSet == "" {
                let loading = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                loading.mode = MBProgressHUDMode.Text
                loading.hide(true, afterDelay: 2)
                loading.removeFromSuperViewOnHide = true
                loading.detailsLabelText = "You entered white spaces only"
                self.animateSubmitBtnOnWrongSubmit()
            }else if phone.text?.characters.count != 10 {
                let loading = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                loading.mode = MBProgressHUDMode.Text
                loading.hide(true, afterDelay: 2)
                loading.removeFromSuperViewOnHide = true
                loading.detailsLabelText = "Please enter a valid phone number"
                self.animateSubmitBtnOnWrongSubmit()
            } else {
                let fields = [
                    "FirstName" : firstName.text!,
                    "LastName" : lastName.text!,
                    "Email" : email.text!,
                    "Phone" : phone.text!,
                    "Fax" : fax.text!
                ]
                SFRestAPI.sharedInstance().performCreateWithObjectType("Contact", fields: fields, failBlock: { err in
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
            if prospectiveText.characters.count <= 10 {
                phoneWarnigLbl.hidden = true
            }
            return true
        }
        switch textField {
        case  phone:
            if prospectiveText.characters.count > 10 {
                // phone.layer.borderWidth = 2.0
                //phone.layer.borderColor = UIColor.redColor().CGColor
                phoneWarnigLbl.hidden = false
                phoneWarnigLbl.text = "*Please enter a valid phone number"
                phoneWarnigLbl.textColor = UIColor.redColor()
            }
            return true
        /*case email:
            let flag = prospectiveText.isValidEmail()
            print(flag)
            if prospectiveText.isValidEmail() {
                phoneWarnigLbl.hidden = false
                phoneWarnigLbl.text = "*Please enter a valid email"
                phoneWarnigLbl.textColor = UIColor.redColor()
             }
                return true*/
            
        default:
            return true
        }
    }
    
}
extension String {
    func isValidEmail() -> Bool {
        let regex = try? NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .CaseInsensitive)
       // let regex = try? NSRegularExpression(pattern: "^[A-Z0-9._%+]+@(?:[A-Z0-9]+\\.)+[A-Z]{3}$", options: .CaseInsensitive)
        return regex?.firstMatchInString(self, options: [], range: NSMakeRange(0, self.characters.count)) != nil
    }
}

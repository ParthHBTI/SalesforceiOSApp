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

class CreateNewContactVC : UIViewController, SFRestDelegate,ExecuteQueryDelegate {
    
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var fax: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var cancleBtn: UIButton!
    
    var exDelegate: ExecuteQuery = ExecuteQuery()
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        if exDelegate.isConnectedToNetwork() {
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
    
}

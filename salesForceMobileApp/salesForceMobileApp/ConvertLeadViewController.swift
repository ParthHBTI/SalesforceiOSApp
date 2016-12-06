//
//  ConvertLeadViewController.swift
//  salesForceMobileApp
//
//  Created by mac on 22/11/16.
//  Copyright © 2016 Salesforce. All rights reserved.
//

import UIKit
import MBProgressHUD
import ZKSforce
import SalesforceRestAPI




class ConvertLeadViewController: UIViewController, SFRestDelegate, AccountListDelegate, UIAlertViewDelegate {

    @IBOutlet weak var checkAction: UIButton!
    @IBOutlet weak var accountNameText: UITextField!
    @IBOutlet weak var opporchunityText: UITextField!
    var checkButton = false
    var convertLeadDataArr: AnyObject = []
    var leadID = String()
    var leadStatus = String()
    var  client:ZKSforceClient?
    var  results:ZKQueryResult?
    var accountNameArr: AnyObject = []
    let cellReuseIdentifier = "cell"
    var selectAccountText = String()
    var accointInfo:NSDictionary?
    
       
    @IBAction func convertLeadAction(sender: AnyObject) {
        let req = SFRestAPI.sharedInstance().requestForQuery("SELECT Status FROM Lead Where Id = '\(leadID)'")
        SFRestAPI.sharedInstance().sendRESTRequest(req, failBlock: {_ in
            
            }, completeBlock: {response in
                let leadStatusArr: AnyObject = response!["records"]
                self.leadStatus = (leadStatusArr.objectAtIndex(0)["Status"] as? String)!
                NSOperationQueue.mainQueue().addOperationWithBlock({
                    let loading = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                    loading.mode = MBProgressHUDMode.Indeterminate
                    loading.detailsLabelText = "Lead is Converting..."
                    loading.hide(true, afterDelay: 2)
                    loading.removeFromSuperViewOnHide = true
                    self.convertLeadWithLeadId(self.convertLeadDataArr["Id"] as! String)
                })
        })
    }
 

    override func viewDidLoad() {
        super.viewDidLoad()
        accountNameText.enabled = false
        self.title = "Convert Lead"
        self.leftBarButtonWithImage(UIImage(named: "back_NavIcon")!)
        let query = "SELECT Id, Name FROM RecentlyViewed WHERE Type IN ('Account')  "
        let request = SFRestAPI.sharedInstance().requestForQuery(query)
        SFRestAPI.sharedInstance().send(request, delegate: self)
        
        checkAction.layer.cornerRadius = 5
        checkAction.layer.borderWidth = 1
        checkAction.layer.borderColor = UIColor.blackColor().CGColor
        accountNameText.rightViewMode = .Always

        accountNameText.text = convertLeadDataArr.valueForKey("Company") as? String
        opporchunityText.text = convertLeadDataArr.valueForKey("Company") as? String
        
        client = ZKSforceClient()
        
        
        let authoCordinater =    SFAuthenticationManager.sharedManager().coordinator.credentials
        client?.loginWithRefreshToken(authoCordinater.refreshToken, authUrl:  authoCordinater.identityUrl, oAuthConsumerKey: RemoteAccessConsumerKey)
    }
    
    func getSelectedAccountInfo(accointDetail:NSDictionary) {
        self.accountNameText.text = accointDetail["Name"] as? String
        
        accointInfo = accointDetail;
        print(accointDetail)
    }
    
    func leftBarButtonWithImage(buttonImage: UIImage) {
        let leftButton: UIBarButtonItem = UIBarButtonItem(image: buttonImage, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.toggleLeft))
        navigationItem.leftBarButtonItem = leftButton;
    }
    
    override func toggleLeft() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func doNotCreateOpportunity(sender: AnyObject) {
        if !checkButton {
        checkButton = true
        checkAction.setImage(UIImage(named: "checkUncheck"), forState: UIControlState.Normal)
            opporchunityText.enabled = false

        } else {
            checkButton = false
            checkAction.setImage(nil, forState: UIControlState.Normal)
            opporchunityText.enabled = true
        }
    }
    
     func convertLeadWithLeadId(leadId:String)  {
        //  client?.loginFromOAuthCallbackUrl(OAuthRedirectURI, oAuthConsumerKey: RemoteAccessConsumerKey)
        let authoCordinater =    SFAuthenticationManager.sharedManager().coordinator.credentials
       // print("accessToken",authoCordinater.accessToken ,"activationCode", authoCordinater.activationCode ,"=additionalOAuthFields=", authoCordinater.additionalOAuthFields ,"=apiUrl=",authoCordinater.apiUrl,"=apiUrl=" , authoCordinater.clientId,"=apiUrl=" , authoCordinater.communityId,"=communityUrl=" ,authoCordinater.communityUrl,"=domain=",authoCordinater.domain,"=identifier=",authoCordinater.identifier,"=identityUrl=",authoCordinater.identityUrl,"=instanceUrl=",authoCordinater.instanceUrl,"=refreshToken=",authoCordinater.refreshToken,"=redirectUri=",authoCordinater.redirectUri)
        print("\n\n\n=description=", authoCordinater.description)
        
        let leadConvertObj = ZKLeadConvert()
        leadConvertObj.leadId = leadId;
        leadConvertObj.convertedStatus = leadStatus;
        leadConvertObj.doNotCreateOpportunity = checkButton
        if !checkButton {
            leadConvertObj.opportunityName = self.opporchunityText.text
        }
        if let _ = accointInfo {
            leadConvertObj.accountId = accointInfo!["Id"] as? String
        }
        
        
        client?.performConvertLead([leadConvertObj], failBlock: { exp in
            let button2Alert: UIAlertView = UIAlertView(title: "Error", message: "Lead Status Picklist Values is not Converted",
                delegate: self, cancelButtonTitle: "Ok")
            button2Alert.show()
                        }, completeBlock: { success in
                print(success)
                
                let result = success.last as? ZKLeadConvertResult
                print(result?.accountId )
                print(result?.contactId )
                print(result?.opportunityId )
                print(result?.leadId )
                print(result?.success)
                
                
                let loading = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                loading.detailsLabelText = "Successfully Converted Lead"
                loading.hide(true, afterDelay: 2)
                loading.removeFromSuperViewOnHide = true
                
                self.navigationController?.popViewControllerAnimated(true)

        })
        
        
        
    }

    func request(request: SFRestRequest, didLoadResponse dataResponse: AnyObject) {
        self.accountNameArr = dataResponse["records"]
        print(dataResponse)
    }
    
    @IBAction func searchAccount(sender: AnyObject) {
        let storyboard = UIStoryboard.init(name: "SubContentsViewController", bundle: nil)
        let presentVC = storyboard.instantiateViewControllerWithIdentifier( "AccountListViewController") as? AccountListViewController
        presentVC!.accountListArr = self.accountNameArr
        presentVC?.delegate = self;
        let nvc: UINavigationController = UINavigationController(rootViewController: presentVC!)

        self.presentViewController(nvc, animated: true, completion:nil)
        
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

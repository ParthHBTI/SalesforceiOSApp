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

class ConvertLeadViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var checkAction: UIButton!
    @IBOutlet weak var height: NSLayoutConstraint!
     @IBOutlet weak var heighConstraints: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var accountNameText: NoCopyPasteUITextField!
    @IBOutlet weak var opporchunityText: UITextField!
    var checkButton = false
    var convertLeadDataArr: AnyObject = []
    var  client:ZKSforceClient?
    var  results:ZKQueryResult?
    var values = ["123 Main Street", "789 King Street", "456 Queen Street", "99 Apple Street", "21 Apple Street" ,"22 Apple Street"]
    let cellReuseIdentifier = "cell"
    
    
   
    @IBAction func textFieldChanged(sender: AnyObject) {
        tableView.hidden = true
    }
    
    @IBAction func convertLeadAction(sender: AnyObject) {
        let loading = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        loading.mode = MBProgressHUDMode.Indeterminate
            loading.detailsLabelText = "Lead is Converting..."
            loading.hide(true, afterDelay: 2)
            loading.removeFromSuperViewOnHide = true
        convertLeadWithLeadId(self.convertLeadDataArr["Id"] as! String)
        }
 

    override func viewDidLoad() {
        super.viewDidLoad()
        checkAction.layer.cornerRadius = 5
        checkAction.layer.borderWidth = 1
        checkAction.layer.borderColor = UIColor.blackColor().CGColor
        accountNameText.rightViewMode = .Always
//        let rightImageView = UIImageView(image: UIImage(named: "downArrow")!)
//        accountNameText.rightView! = rightImageView
       // accountNameText.text = convertLeadDataArr.valueForKey("Company") as? String
        opporchunityText.text = convertLeadDataArr.valueForKey("Company") as? String
        
        client = ZKSforceClient()
        
        
        let authoCordinater =    SFAuthenticationManager.sharedManager().coordinator.credentials
        client?.loginWithRefreshToken(authoCordinater.refreshToken, authUrl:  authoCordinater.identityUrl, oAuthConsumerKey: RemoteAccessConsumerKey)
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
        tableView.delegate = self
        tableView.dataSource = self
        accountNameText.delegate = self
        
        tableView.hidden = true
        
        // Manage tableView visibility via TouchDown in textField
        accountNameText.addTarget(self, action: #selector(textFieldActive), forControlEvents: UIControlEvents.TouchDown)


        // Do any additional setup after loading the view.
    }
    
    func textFieldActive() {
        tableView.hidden = !tableView.hidden
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        guard let touch:UITouch = touches.first else
        {
            return;
        }
        if touch.view != tableView
        {
            accountNameText.endEditing(true)
            tableView.hidden = true
        }
    }
    
    // Toggle the tableView visibility when click on textField
    
    // MARK: UITextFieldDelegate
    func textFieldDidEndEditing(textField: UITextField) {
        // TODO: Your app can do something when textField finishes editing
        print("The textField ended editing. Do something based on app requirements.")
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func doNotCreateOpportunity(sender: AnyObject) {
        if !checkButton {
        checkButton = true
        checkAction.setImage(UIImage(named: "checkUncheck"), forState: UIControlState.Normal)
        } else {
           
            checkButton = false
            checkAction.setImage(nil, forState: UIControlState.Normal)
        }
    }
    
    override func viewDidLayoutSubviews()
    {
        // Assumption is we're supporting a small maximum number of entries
        // so will set height constraint to content size
        // Alternatively can set to another size, such as using row heights and setting frame
        //height.constant = tableView.contentSize.height
        heighConstraints.constant = tableView.contentSize.height
    }
    
    // MARK: UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return values.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell!
        // Set text from the data model
        cell.textLabel?.text = values[indexPath.row]
        cell.textLabel?.font = accountNameText.font
        return cell
    }
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Row selected, so set textField to relevant value, hide tableView
        // endEditing can trigger some other action according to requirements
        accountNameText.text = values[indexPath.row]
        tableView.hidden = true
        accountNameText.endEditing(true)
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }
    

    func convertLeadWithLeadId(leadId:String)  {
        //  client?.loginFromOAuthCallbackUrl(OAuthRedirectURI, oAuthConsumerKey: RemoteAccessConsumerKey)
        
        let authoCordinater =    SFAuthenticationManager.sharedManager().coordinator.credentials
        print("accessToken",authoCordinater.accessToken ,"activationCode", authoCordinater.activationCode ,"=additionalOAuthFields=", authoCordinater.additionalOAuthFields ,"=apiUrl=",authoCordinater.apiUrl,"=apiUrl=" , authoCordinater.clientId,"=apiUrl=" , authoCordinater.communityId,"=communityUrl=" ,authoCordinater.communityUrl,"=domain=",authoCordinater.domain,"=identifier=",authoCordinater.identifier,"=identityUrl=",authoCordinater.identityUrl,"=instanceUrl=",authoCordinater.instanceUrl,"=refreshToken=",authoCordinater.refreshToken,"=redirectUri=",authoCordinater.redirectUri)
        print("\n\n\n=description=", authoCordinater.description)
        
        let leadConvertObj = ZKLeadConvert()
        leadConvertObj.leadId = leadId;
        leadConvertObj.convertedStatus = "Closed - Converted";
        leadConvertObj.doNotCreateOpportunity = checkButton
        
        client?.performConvertLead([leadConvertObj], failBlock: { exp in
            print(exp)
            
            }, completeBlock: { success in
                print(success)
                let loading = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                loading.detailsLabelText = "Successfully Converted Lead"
                loading.hide(true, afterDelay: 2)
                loading.removeFromSuperViewOnHide = true

        })
        
        
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

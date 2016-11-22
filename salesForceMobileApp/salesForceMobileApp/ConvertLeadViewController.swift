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

class ConvertLeadViewController: UIViewController {

    @IBOutlet weak var accountNameText: UITextField!
    @IBOutlet weak var opporchunityText: UITextField!
    var convertDataArr: AnyObject = []
    var convertLeadDataArr: AnyObject = []
    var  client:ZKSforceClient?
    var  results:ZKQueryResult?
    
    @IBAction func checkAction(sender: AnyObject) {
        
    }
    
    
    @IBAction func convertLeadAction(sender: AnyObject) {
        let loading = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        loading.mode = MBProgressHUDMode.Indeterminate
            loading.detailsLabelText = "Uploading Data from Server"
            loading.hide(true, afterDelay: 2)
            loading.removeFromSuperViewOnHide = true
            loading.detailsLabelText = "Uploading Data from Local"
            loading.hide(true, afterDelay: 2)
        convertLeadWithLeadId(self.convertLeadDataArr["Id"] as! String)
        }
 

    override func viewDidLoad() {
        super.viewDidLoad()
        accountNameText.text = convertDataArr.valueForKey("Company") as? String
        opporchunityText.text = convertDataArr.valueForKey("Company") as? String
        
        client = ZKSforceClient()
        
        
        let authoCordinater =    SFAuthenticationManager.sharedManager().coordinator.credentials
        client?.loginWithRefreshToken(authoCordinater.refreshToken, authUrl:  authoCordinater.identityUrl, oAuthConsumerKey: RemoteAccessConsumerKey)
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func convertLeadWithLeadId(leadId:String)  {
        //  client?.loginFromOAuthCallbackUrl(OAuthRedirectURI, oAuthConsumerKey: RemoteAccessConsumerKey)
        
        let authoCordinater =    SFAuthenticationManager.sharedManager().coordinator.credentials
        print("accessToken",authoCordinater.accessToken ,"activationCode", authoCordinater.activationCode ,"=additionalOAuthFields=", authoCordinater.additionalOAuthFields ,"=apiUrl=",authoCordinater.apiUrl,"=apiUrl=" , authoCordinater.clientId,"=apiUrl=" , authoCordinater.communityId,"=communityUrl=" ,authoCordinater.communityUrl,"=domain=",authoCordinater.domain,"=identifier=",authoCordinater.identifier,"=identityUrl=",authoCordinater.identityUrl,"=instanceUrl=",authoCordinater.instanceUrl,"=refreshToken=",authoCordinater.refreshToken,"=redirectUri=",authoCordinater.redirectUri)
        
        print("\n\n\n=description=", authoCordinater.description)
        
        
        let leadConvertObj = ZKLeadConvert()
        leadConvertObj.leadId = leadId;
        leadConvertObj.convertedStatus = "Closed - Converted";
        
        client?.performConvertLead([leadConvertObj], failBlock: { exp in
            print(exp)
            
            }, completeBlock: { success in
                print(success)
                
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

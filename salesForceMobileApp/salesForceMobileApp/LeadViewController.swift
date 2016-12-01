//
//  ViewController.swift
//  SlideMenuControllerSwift
//
//  Created by Yuji Hato on 12/3/14.
//

import UIKit
import SalesforceRestAPI
import SystemConfiguration
import MBProgressHUD
import ZKSforce

// class for Lead's data
class LeadViewController: UIViewController, ExecuteQueryDelegate, CreateNewLeadDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var resArr1:AnyObject = []
    var exDelegate: ExecuteQuery = ExecuteQuery()
    var isCreatedSuccessfully: Bool = false
    var createLeadDelegate: CreateNewLeadDelegate?
    
    
    var  client:ZKSforceClient?
    var  results:ZKQueryResult?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        exDelegate.delegate = self
        self.title = "Leads View"
        self.setNavigationBarItem()
        //self.addRightBarButtonWithImage1(UIImage(named: "plus")!)
        self.addRightBarButtonWithImage1()
        self.tableView.registerCellNib(DataTableViewCell.self)
        loadLead()
        client = ZKSforceClient()
        
        
        let authoCordinater =    SFAuthenticationManager.sharedManager().coordinator.credentials
        client?.loginWithRefreshToken(authoCordinater.refreshToken, authUrl:  authoCordinater.identityUrl, oAuthConsumerKey: RemoteAccessConsumerKey)
        
        
        //ZKOAuthInfo.oauthInfoWithRefreshToken(authoCordinater.refreshToken, authHost: authoCordinater.identityUrl, sessionId: authoCordinater.accessToken, instanceUrl: authoCordinater.instanceUrl, clientId: RemoteAccessConsumerKey)
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
    
    func executeQuery()  {
        resArr1 = exDelegate.resArr
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
        })
    }
    
    func addRightBarButtonWithImage1() {
        //let navBarAddBtn: UIBarButtonItem = UIBarButtonItem(title: "Add", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.toggleRight1))
        //let navBarAddBtn: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "addImg"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.toggleRight1))
        let navBarAddBtn = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(self.toggleRight1))
        navigationItem.rightBarButtonItem = navBarAddBtn;
    }
    
    func toggleRight1() {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let nv = storyboard.instantiateViewControllerWithIdentifier("CreateNewLeadVC") as! CreateNewLeadVC
        navigationController?.pushViewController(nv, animated: true)
        nv.delegate = self
    }
    
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        exDelegate.leadQueryDe("lead")
        self.setNavigationBarItem()
        if isCreatedSuccessfully {
            let loading = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            loading.mode = MBProgressHUDMode.Text
            loading.detailsLabelText = "Created Successfully!"
            loading.removeFromSuperViewOnHide = true
            loading.hide(true, afterDelay:2)
        }
        isCreatedSuccessfully = false
    }
    
    
    func getValFromLeadVC(params: Bool ) {
        self.isCreatedSuccessfully = params
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadLead() {
        let defaults = NSUserDefaults.standardUserDefaults()
        let arrayOfObjectsKey = "leadListData"
        let loading = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        loading.mode = MBProgressHUDMode.Indeterminate
        if exDelegate.isConnectedToNetwork() {
            loading.detailsLabelText = "Uploading Data from Server"
            loading.hide(true, afterDelay: 2)
            loading.removeFromSuperViewOnHide = true
            exDelegate.leadQueryDe("lead")
        } else if let arrayOfObjectsData = defaults.objectForKey(arrayOfObjectsKey) as? NSData {
            loading.detailsLabelText = "Uploading Data from Local"
            loading.hide(true, afterDelay: 2)
            loading.removeFromSuperViewOnHide = true
            resArr1 = NSKeyedUnarchiver.unarchiveObjectWithData(arrayOfObjectsData)!
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
        }
        
    }
}



extension LeadViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return DataTableViewCell.height()
    }
}

extension LeadViewController : UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resArr1.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier(DataTableViewCell.identifier) as! DataTableViewCell
        cell.dataText.text = resArr1.objectAtIndex(indexPath.row)["Name"] as? String
        cell.dataImage.layer.cornerRadius = 2.0
        cell.dataImage.image = UIImage.init(named: "leadImg")
        cell.dataImage.image = UIImage.init(named: "lead")
        cell.convertButton.addTarget(self, action: #selector(self.btnClicked), forControlEvents: .TouchUpInside)
        
        /*let img = UIImage(named: "lead")
         let tintedImage = img?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
         cell.dataImage.image = tintedImage
         cell.dataImage.tintColor = UIColor.redColor()*/
        return cell
    }
    
    func btnClicked(sender: UIButton) {
        print(sender.tag)
        let storyboard = UIStoryboard(name: "SubContentsViewController", bundle: nil)
        let subContentsVC = storyboard.instantiateViewControllerWithIdentifier("ConvertLeadViewController") as! ConvertLeadViewController
        subContentsVC.convertLeadDataArr = self.resArr1.objectAtIndex(sender.tag)
        self.navigationController?.pushViewController(subContentsVC, animated: true)
        //convertLeadWithLeadId(self.resArr1.objectAtIndex(sender.tag)["Id"] as! String)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //convertLeadWithLeadId(self.resArr1.objectAtIndex(indexPath.row)["Id"] as! String)
        let storyboard = UIStoryboard(name: "SubContentsViewController", bundle: nil)
        let subContentsVC = storyboard.instantiateViewControllerWithIdentifier("LeadContentVC") as! LeadContentVC
        subContentsVC.getResponseArr = self.resArr1.objectAtIndex(indexPath.row)
        subContentsVC.leadID = self.resArr1.objectAtIndex(indexPath.row)["Id"] as! String
        subContentsVC.parentIndex = (indexPath.row)
        self.navigationController?.pushViewController(subContentsVC, animated: true)
    }
    
}

extension LeadViewController : SlideMenuControllerDelegate {
    
    func leftWillOpen() {
        print("SlideMenuControllerDelegate: leftWillOpen")
    }
    
    func leftDidOpen() {
        print("SlideMenuControllerDelegate: leftDidOpen")
    }
    
    func leftWillClose() {
        print("SlideMenuControllerDelegate: leftWillClose")
    }
    
    func leftDidClose() {
        print("SlideMenuControllerDelegate: leftDidClose")
    }
    
    func rightWillOpen() {
        print("SlideMenuControllerDelegate: rightWillOpen")
    }
    
    func rightDidOpen() {
        print("SlideMenuControllerDelegate: rightDidOpen")
    }
    
    func rightWillClose() {
        print("SlideMenuControllerDelegate: rightWillClose")
    }
    
    func rightDidClose() {
        print("SlideMenuControllerDelegate: rightDidClose")
    }
}


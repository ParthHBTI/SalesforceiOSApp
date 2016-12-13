//
//  ViewController.swift
//  SlideMenuControllerSwift
//
//  Created by Yuji Hato on 12/3/14.
//

let LeadOnLineDataKey = "LeadOnLineDataKey"
let LeadOfLineDataKey = "LeadOfLineDataKey"


import UIKit
import SalesforceRestAPI
import SystemConfiguration
import MBProgressHUD
import ZKSforce

// class for Lead's data
class LeadViewController: UIViewController, ExecuteQueryDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    //var resArr1:AnyObject = []
    var leadOnLineArr: AnyObject = NSMutableArray()
    var leadOfLineArr: AnyObject = NSMutableArray()
    
    var exDelegate: ExecuteQuery = ExecuteQuery()
    var isCreatedSuccessfully: Bool = false
    var createLeadDelegate: CreateNewLeadDelegate?
    var deleteLeadAtIndexPath: NSIndexPath? = nil
    var delObjAtId: String = " "
    var isFirstLoaded:Bool = false
    
    var  client:ZKSforceClient?
    var  results:ZKQueryResult?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        exDelegate.delegate = self
        self.title = "Leads View"
        isFirstLoaded = true
        self.setNavigationBarItem()
        self.addRightBarButtonWithImage1()
        self.tableView.registerCellNib(DataTableViewCell.self)
        loadLead()
        client = ZKSforceClient()
        let authoCordinater =    SFAuthenticationManager.sharedManager().coordinator.credentials
        client?.loginWithRefreshToken(authoCordinater.refreshToken, authUrl:  authoCordinater.identityUrl, oAuthConsumerKey: RemoteAccessConsumerKey)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        /*if !isFirstLoaded {
            if exDelegate.isConnectedToNetwork() {
            exDelegate.leadQueryDe("lead")
            }
        }*/
        if let arrayOfObjectsData = defaults.objectForKey(LeadOfLineDataKey) as? NSData {
            leadOfLineArr = NSKeyedUnarchiver.unarchiveObjectWithData(arrayOfObjectsData)!
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
        }
        loadLead()
        self.setNavigationBarItem()
        if isCreatedSuccessfully {
            let loading = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            loading.mode = MBProgressHUDMode.Text
            loading.detailsLabelText = "Created Successfully!"
            loading.hide(true, afterDelay:2)
            loading.removeFromSuperViewOnHide = true
        }
        isFirstLoaded = false
        isCreatedSuccessfully = false
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
        leadOnLineArr = exDelegate.resArr.mutableCopy() as! NSMutableArray
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
        self.navigationController?.pushViewController(nv, animated: true)
        //nv.delegate = self
    }
    
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }
    
    
    func getValFromLeadVC(params: Bool ) {
        self.isCreatedSuccessfully = params
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadLead() {
        let defaults = NSUserDefaults.standardUserDefaults()
        let loading = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        loading.mode = MBProgressHUDMode.Indeterminate
        if exDelegate.isConnectedToNetwork() {
            if leadOfLineArr.count > 1 {
                offlineData.leadOfflineShrinkData(leadOfLineArr as! NSMutableArray)
            }
            loading.detailsLabelText = "Loading Data from Server"
            loading.hide(true, afterDelay: 2)
            loading.removeFromSuperViewOnHide = true
            exDelegate.leadQueryDe("lead")
        } else if let arrayOfObjectsData = defaults.objectForKey(LeadOnLineDataKey) as? NSData {
            loading.detailsLabelText = "Loading Data from Local"
            loading.hide(true, afterDelay: 2)
            loading.removeFromSuperViewOnHide = true
            leadOnLineArr = NSKeyedUnarchiver.unarchiveObjectWithData(arrayOfObjectsData)!.mutableCopy() as! NSMutableArray
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
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int // Default is 1 if not implemented
    {
        return 2;
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == 0) ? leadOfLineArr.count : leadOnLineArr.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier(DataTableViewCell.identifier) as! DataTableViewCell
        cell.dataImage.layer.cornerRadius = 2.0
        cell.dataImage.image = UIImage.init(named: "leadImg")
        cell.dataImage.image = UIImage.init(named: "lead")
        cell.convertButton.titleLabel?.textColor = self.navigationController?.navigationBar.barTintColor
        cell.convertButton.layer.borderColor = self.navigationController?.navigationBar.barTintColor?.CGColor
        cell.convertButton.tag = indexPath.row
        cell.convertButton.addTarget(self, action: #selector(LeadViewController.btnClicked(_:)), forControlEvents: .TouchUpInside)
        
        if indexPath.section == 0 {
            cell.dataText.text = leadOfLineArr.objectAtIndex(indexPath.row)["LastName"] as? String
            cell.notConnectedImage.hidden = false
        } else {
            cell.dataText.text = leadOnLineArr.objectAtIndex(indexPath.row)["Name"] as? String
            cell.notConnectedImage.hidden = true
        }
        
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            if indexPath.section == 0 {
                //print(leadOfLineArr)
                deleteLeadAtIndexPath = indexPath
                let leadToDelete = self.leadOfLineArr.objectAtIndex(indexPath.row)["LastName"] as! String
                confirmDelete(leadToDelete)
            } else {
                deleteLeadAtIndexPath = indexPath
                delObjAtId = self.leadOnLineArr.objectAtIndex(indexPath.row)["Id"] as! String
                let leadToDelete = self.leadOnLineArr.objectAtIndex(indexPath.row)["Name"] as! String
                confirmDelete(leadToDelete)
            }
        }
    }
    
    
    func confirmDelete(leadName: String) {
        let alert = UIAlertController(title: "Delete file", message: "Are you sure to permanently delete \(leadName)?", preferredStyle: .Alert )
        let DeleteAction = UIAlertAction(title: "Delete", style: .Destructive, handler: leadDelAction)
        let CancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler:cancle)
        alert.addAction(DeleteAction)
        alert.addAction(CancelAction)
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = CGRectMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0, 1.0, 1.0)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    func cancle(alertAction: UIAlertAction!) -> Void {
        
    }
    
    ///
    func leadDelAction(alertAction: UIAlertAction) -> Void {
        if exDelegate.isConnectedToNetwork() {
            SFRestAPI.sharedInstance().performDeleteWithObjectType("Lead", objectId: delObjAtId,failBlock: { err in
                dispatch_async(dispatch_get_main_queue(), {
                    let alert = UIAlertView.init(title: "Error", message: err?.localizedDescription , delegate: self, cancelButtonTitle: "OK")
                    alert.show()
                })
                print( (err))
            }){ succes in
                dispatch_async(dispatch_get_main_queue(), {
                    if let indexPath = self.deleteLeadAtIndexPath {
                        self.leadOnLineArr.removeObjectAtIndex(indexPath.row)
                        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                        ///self.tableView.reloadData()
                        self.deleteLeadAtIndexPath = nil
                    }
                })
            }
        }
        else {
            if let indexPath = self.deleteLeadAtIndexPath {
                self.leadOfLineArr.removeObjectAtIndex(indexPath.row)
                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                let offlineLeadArr = NSKeyedArchiver.archivedDataWithRootObject(leadOfLineArr)
                defaults.setObject(offlineLeadArr, forKey: LeadOfLineDataKey)
                self.deleteLeadAtIndexPath = nil
            }
            let loading = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            loading.mode = MBProgressHUDMode.Indeterminate
            loading.detailsLabelText = "Please check your Internet connection!"
            loading.hide(true, afterDelay: 2)
            loading.removeFromSuperViewOnHide = true
        }
    }
    
    ///
    
    func btnClicked(sender: UIButton) {
        let storyboard = UIStoryboard(name: "SubContentsViewController", bundle: nil)
        let subContentsVC = storyboard.instantiateViewControllerWithIdentifier("ConvertLeadViewController") as! ConvertLeadViewController
        subContentsVC.convertLeadDataArr = self.leadOnLineArr.objectAtIndex(sender.tag)
        subContentsVC.leadID = self.leadOnLineArr.objectAtIndex(sender.tag)["Id"] as! String
        self.navigationController?.pushViewController(subContentsVC, animated: true)
        //convertLeadWithLeadId(self.resArr1.objectAtIndex(sender.tag)["Id"] as! String)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //convertLeadWithLeadId(self.resArr1.objectAtIndex(indexPath.row)["Id"] as! String)
        let storyboard = UIStoryboard(name: "SubContentsViewController", bundle: nil)
        let subContentsVC = storyboard.instantiateViewControllerWithIdentifier("LeadContentVC") as! LeadContentVC
        if indexPath.section == 0 {
            subContentsVC.isOfflineData  = true
            //subContentsVC.getResponseArr = self.leadOfLineArr.objectAtIndex(indexPath.row)
            subContentsVC.getResponseArr = self.leadOfLineArr.objectAtIndex(indexPath.row) as! NSDictionary
        } else {
            subContentsVC.getResponseArr = self.leadOnLineArr.objectAtIndex(indexPath.row) as! NSDictionary
            subContentsVC.leadID = self.leadOnLineArr.objectAtIndex(indexPath.row)["Id"] as! String
            
        }
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


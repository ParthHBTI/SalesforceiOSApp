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

var leadOnLineArr: AnyObject = NSMutableArray()
var deletedKeysArr: AnyObject = NSMutableArray()
// class for Lead's data
class LeadViewController: UIViewController, ExecuteQueryDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    //var resArr1:AnyObject = []
    
    var leadOfLineArr: AnyObject = NSMutableArray()
    
    var exDelegate: ExecuteQuery = ExecuteQuery()
    var isCreatedSuccessfully: Bool = false
    var createLeadDelegate: CreateNewLeadDelegate?
    var deleteLeadAtIndexPath: NSIndexPath? = nil
    var onlineDataFlag = false
    var delObjAtId: String = " "
    var isFirstLoaded:Bool = false
    
    var  client:ZKSforceClient?
    var  results:ZKQueryResult?
    
    
    
    func dataUpdateToServer()  {
        print("interNetChanges")
        leadOfLineArr.removeAllObjects()
        
        if let arrayOfObjectsData = defaults.objectForKey("\(ObjectDataType.leadValue.rawValue)\(OffLineKeySuffix)") as? NSData {
            leadOfLineArr = NSKeyedUnarchiver.unarchiveObjectWithData(arrayOfObjectsData)!
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
        }
        loadLead()
    }
    
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
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector:#selector(LeadViewController.dataUpdateToServer),
            name: "\(ObjectDataType.leadValue.rawValue)\(NotificationSuffix)",
            object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if let arrayOfObjectsData = defaults.objectForKey("\(ObjectDataType.leadValue.rawValue)\(OffLineKeySuffix)") as? NSData {
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
    
    func updateOnlineData(leadOnLineUpdateArr: NSMutableArray) {
      leadOnLineArr = leadOnLineUpdateArr
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
        let storyboard = UIStoryboard.init(name: "SubContentsViewController", bundle: nil)
        let nv = storyboard.instantiateViewControllerWithIdentifier("CreateObjectViewController") as! CreateObjectViewController
        nv.objectType = ObjectDataType.leadValue.rawValue
        navigationController?.pushViewController(nv, animated: true)    }
    
    
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
        if exDelegate.isConnectedToNetwork() {
            if leadOfLineArr.count > 0 {
              //  obj.OfflineShrinkData(leadOfLineArr as! NSMutableArray, objType: ObjectDataType.leadValue.rawValue)
            }
            let loading = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            loading.mode = MBProgressHUDMode.Indeterminate
            loading.detailsLabelText = "Loading Data from Server"
            loading.hide(true, afterDelay: 0.5)
            loading.removeFromSuperViewOnHide = true
            exDelegate.leadQueryDe(ObjectDataType.leadValue.rawValue)
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
        } else if let arrayOfObjectsData = defaults.objectForKey("\(ObjectDataType.leadValue.rawValue)\(OnLineKeySuffix)") as? NSData {
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
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
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
            cell.dataText.text = leadOnLineArr.objectAtIndex(indexPath.row)["LastName"] as? String
             cell.detailText.text = leadOnLineArr.objectAtIndex(indexPath.row)["Title"] as? String
            cell.notConnectedImage.hidden = true
        }
        
       
        
        
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            if indexPath.section == 0 {
                deleteLeadAtIndexPath = indexPath
                let leadToDelete = self.leadOfLineArr.objectAtIndex(indexPath.row)["LastName"] as! String
                confirmDelete(leadToDelete)
            } else if exDelegate.isConnectedToNetwork() {
                deleteLeadAtIndexPath = indexPath
                delObjAtId = leadOnLineArr.objectAtIndex(indexPath.row)["Id"] as! String
                let leadToDelete = leadOnLineArr.objectAtIndex(indexPath.row)["Name"] as! String
                confirmDelete(leadToDelete)
            } else {
                onlineDataFlag = true
                deleteLeadAtIndexPath = indexPath
                delObjAtId = leadOnLineArr.objectAtIndex(indexPath.row)["Id"] as! String
                let leadToDelete = leadOnLineArr.objectAtIndex(indexPath.row)["Name"] as! String
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
                        leadOnLineArr.removeObjectAtIndex(indexPath.row)
                        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                        self.deleteLeadAtIndexPath = nil
                    }
                })
            }
        } else if onlineDataFlag {
            dispatch_async(dispatch_get_main_queue(), {
                if let indexPath = self.deleteLeadAtIndexPath {
                    leadOnLineArr.removeObjectAtIndex(indexPath.row)
                    self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                    deletedKeysArr.addObject(self.delObjAtId)
                    print(self.delObjAtId)
                    let onlineDeletsKeys = NSKeyedArchiver.archivedDataWithRootObject(deletedKeysArr)
                    defaults.setObject(onlineDeletsKeys, forKey:onlineDeletsObjectsKey)
                    let offlineLeadArr = NSKeyedArchiver.archivedDataWithRootObject(leadOnLineArr)
                    defaults.setObject(offlineLeadArr, forKey:"\(ObjectDataType.leadValue.rawValue)\(OnLineKeySuffix)")
                    self.deleteLeadAtIndexPath = nil
                }
            })
        } else {
            if let indexPath = self.deleteLeadAtIndexPath {
                self.leadOfLineArr.removeObjectAtIndex(indexPath.row)
                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                let offlineLeadArr = NSKeyedArchiver.archivedDataWithRootObject(leadOfLineArr)
                defaults.setObject(offlineLeadArr, forKey:"\(ObjectDataType.leadValue.rawValue)\(OffLineKeySuffix)")
                self.deleteLeadAtIndexPath = nil
            }
        }
    }
    
    ///
    
    func btnClicked(sender: UIButton) {
        let storyboard = UIStoryboard(name: "SubContentsViewController", bundle: nil)
        let subContentsVC = storyboard.instantiateViewControllerWithIdentifier("ConvertLeadViewController") as! ConvertLeadViewController
        subContentsVC.convertLeadDataArr = leadOnLineArr.objectAtIndex(sender.tag)
        subContentsVC.leadID = leadOnLineArr.objectAtIndex(sender.tag)["Id"] as! String
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
            //
            subContentsVC.leadID = self.leadOfLineArr.objectAtIndex(indexPath.row)["Id"] as! String
            //subContentsVC.selectedSectionVal = indexPath.section
        } else {
            subContentsVC.getResponseArr = leadOnLineArr.objectAtIndex(indexPath.row) as! NSDictionary
            subContentsVC.leadID = leadOnLineArr.objectAtIndex(indexPath.row)["Id"] as! String
            //subContentsVC.selectedSectionVal = indexPath.section
            
        }
        subContentsVC.parentIndex = (indexPath.row)
        globalIndex = (indexPath.row)
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


//
//  OpportunityViewController.swift
//  SlideMenuControllerSwift
//
//  Created by Yuji Hato on 1/19/15.
//  Copyright (c) 2015 Yuji Hato. All rights reserved.
//
let OppOnlineDataKey = "OpportunityOnlineDataKey"
let OppOfflineDataKey = "OpportunityOfflineDataKey"

import UIKit
import SalesforceRestAPI
import MBProgressHUD
import SalesforceRestAPI
class OpportunityViewController: UIViewController, ExecuteQueryDelegate,CreateNewOppDelegate, SFRestDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var resArr1 = NSMutableArray()
    var exDelegate: ExecuteQuery = ExecuteQuery()
    var isFirstLoad : Bool = false
    var delObjAtId:String = " "
    var delOppAtIndexPath:NSIndexPath? = nil
    var isCreatedSuccessfully:Bool = false
    var OppOfflineArr:AnyObject = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isFirstLoad = true
        exDelegate.delegate = self
        self.title = "Opportunity View"
        self.setNavigationBarItem()
        //self.addRightBarButtonWithImage1(UIImage(named: "plus")!)
        self.addRightBarButtonWithImage1()
        self.tableView.registerCellNib(DataTableViewCell.self)
           }
    
    func executeQuery()  {
        resArr1 = exDelegate.resArr.mutableCopy() as! NSMutableArray
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
        })
    }
    
    //func addRightBarButtonWithImage1(buttonImage: UIImage) {
    //let rightButton: UIBarButtonItem = UIBarButtonItem(image: buttonImage, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.toggleRight1))
    func addRightBarButtonWithImage1() {
        //let navBarAddBtn: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "addImg"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.toggleRight1))
        let navBarAddBtn: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(self.toggleRight1))
        navigationItem.rightBarButtonItem = navBarAddBtn;
    }
    
    func toggleRight1() {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let nv = storyboard.instantiateViewControllerWithIdentifier("CreateNewOpportunityVC") as! CreateNewOpportunityVC
        navigationController?.pushViewController(nv, animated: true)
        nv.delegate = self
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let arrayOfObjectsData = defaults.objectForKey(OppOfflineDataKey) as? NSData {
            OppOfflineArr = NSKeyedUnarchiver.unarchiveObjectWithData(arrayOfObjectsData)!
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
        }
        loadOpporchunity()
        if isCreatedSuccessfully {
            let loading = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            loading.mode = MBProgressHUDMode.Text
            loading.detailsLabelText = "Created Successfully!"
            loading.hide(true, afterDelay:2)
            loading.removeFromSuperViewOnHide = true
        }
        isCreatedSuccessfully = false
        isFirstLoad = false
        self.setNavigationBarItem()
    }
    
    func getValFromOppVC(params:Bool) {
        isCreatedSuccessfully = params
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadOpporchunity() {
        let defaults = NSUserDefaults.standardUserDefaults()
        //let opportunityDataKey = "opportunityDataKey"
        let loading = MBProgressHUD.showHUDAddedTo(self.navigationController!.view, animated: true)
        loading.mode = MBProgressHUDMode.Indeterminate
        if exDelegate.isConnectedToNetwork() {
//            if OppOfflineArr.count > 1 {
//            for  index in 0..<OppOfflineArr.count  {
//                let fields = [
//                    "Name" : OppOfflineArr.objectAtIndex(index)["Name"]  ,
//                    "CloseDate" : OppOfflineArr.objectAtIndex(index)["CloseDate"] as? String,
//                    "Amount" : OppOfflineArr.objectAtIndex(index)["Amount"] as? String,
//                    "StageName" :OppOfflineArr.objectAtIndex(index)["StageName"] as? String,
//                    ]
//                SFRestAPI.sharedInstance().performCreateWithObjectType("Opportunity", fields: fields, failBlock: { err in
//                    dispatch_async(dispatch_get_main_queue(), {
//                        let alert = UIAlertView.init(title: "Error", message: err?.localizedDescription , delegate: self, cancelButtonTitle: "OK")
//                        alert.show()
//                        print(err?.localizedDescription)
//                    })
//                    print( (err))
//                }) { succes in
//                    //self.delegate!.getValFromOppVC(true)
//                    dispatch_async(dispatch_get_main_queue(), {
//                        let loading = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
//                        loading.mode = MBProgressHUDMode.Indeterminate
//                        loading.detailsLabelText = "Offline Opportunity is Uploading!"
//                        loading.removeFromSuperViewOnHide = true
//                        loading.hide(true, afterDelay: 2)
//                        //self.OppOfflineArr.removeObjectAtIndex(index)
//                    })
//                }
//               print("\(index) and arrValue is \(OppOfflineArr[index])")
//            }
//            } else {}
            
            loading.detailsLabelText = "Loading Data from Server"
            loading.hide(true, afterDelay: 2)
            loading.removeFromSuperViewOnHide = true
            exDelegate.leadQueryDe("opporchunity")
           
        } else if let arrayOfObjectsData = defaults.objectForKey(OppOnlineDataKey) as? NSData {
            loading.detailsLabelText = "Loading Data from Local"
            loading.hide(true, afterDelay: 2)
            loading.removeFromSuperViewOnHide = true
            resArr1 = NSKeyedUnarchiver.unarchiveObjectWithData(arrayOfObjectsData)!.mutableCopy() as! NSMutableArray
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
        }
    }
}

extension OpportunityViewController : UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return DataTableViewCell.height()
    }
}

extension OpportunityViewController : UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 2;
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == 0) ? OppOfflineArr.count : resArr1.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier(DataTableViewCell.identifier) as! DataTableViewCell
        cell.convertButton.hidden = true
        if indexPath.section == 0 {
            cell.dataText?.text = OppOfflineArr.objectAtIndex(indexPath.row)["Name"] as? String
        } else {
            cell.dataText?.text = resArr1.objectAtIndex(indexPath.row)["Name"] as? String
        }
        cell.dataImage.backgroundColor = UIColor.init(hex: "FFB642")
        cell.dataImage.layer.cornerRadius = 2.0
        cell.dataImage.image = UIImage.init(named: "opportunity")
        print(cell.textLabel?.text)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let storyboard = UIStoryboard(name: "SubContentsViewController", bundle: nil)
        let subContentsVC = storyboard.instantiateViewControllerWithIdentifier("OpportunityDataVC") as! OpportunityDataVC
        if indexPath.section == 0 {
            subContentsVC.isOfflineData = true
            subContentsVC.getResponseArr = self.OppOfflineArr.objectAtIndex(indexPath.row)
        } else {
             subContentsVC.getResponseArr = self.resArr1.objectAtIndex(indexPath.row)
            subContentsVC.leadID = self.resArr1.objectAtIndex(indexPath.row)["Id"] as! String
        }
        
        subContentsVC.parentIndex = (indexPath.row)
        self.navigationController?.pushViewController(subContentsVC, animated: true)
    }
    
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            delOppAtIndexPath = indexPath
            delObjAtId = self.resArr1.objectAtIndex(indexPath.row)["Id"] as! String
            let oppToDelete = self.resArr1.objectAtIndex(indexPath.row)["Name"] as! String
            confirmDelete(oppToDelete)
        }
    }
    
    func confirmDelete(oppName: String) {
        let alert = UIAlertController(title: "Delete file", message: "Are you sure to permanently delete \(oppName)?", preferredStyle: .Alert )
        let DeleteAction = UIAlertAction(title: "Delete", style: .Destructive, handler: oppDelAction)
        let CancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler:cancle)
        
        alert.addAction(DeleteAction)
        alert.addAction(CancelAction)
        
        // Support display in iPad
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = CGRectMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0, 1.0, 1.0)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    func cancle(alertAction: UIAlertAction!) -> Void {
        
    }
    
    
    func oppDelAction(alertAction: UIAlertAction) -> Void {
        if exDelegate.isConnectedToNetwork() {
            SFRestAPI.sharedInstance().performDeleteWithObjectType("Opportunity", objectId: delObjAtId,failBlock: { err in
                dispatch_async(dispatch_get_main_queue(), {
                    let alert = UIAlertView.init(title: "Error", message: err?.localizedDescription , delegate: self, cancelButtonTitle: "OK")
                    alert.show()
                })
                print( (err))
            }){ succes in
                dispatch_async(dispatch_get_main_queue(), {
                    if let indexPath = self.delOppAtIndexPath {
                        self.resArr1.removeObjectAtIndex(indexPath.row)
                        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                        self.delOppAtIndexPath = nil
                    }
                })
            }
        }
        else {
            let loading = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            loading.mode = MBProgressHUDMode.Indeterminate
            loading.detailsLabelText = "Please check your Internet connection!"
            loading.hide(true, afterDelay: 2)
            loading.removeFromSuperViewOnHide = true
        }
    }
}
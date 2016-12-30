//
//  OpportunityViewController.swift
//  SlideMenuControllerSwift
//
//  Created by Yuji Hato on 1/19/15.
//  Copyright (c) 2015 Yuji Hato. All rights reserved.
//

//let offlineData = OfflineShrinkData()

import UIKit
import SalesforceRestAPI
import MBProgressHUD
import SalesforceRestAPI

class OpportunityViewController: UIViewController, ExecuteQueryDelegate,SFRestDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var oppOnlineArr = NSMutableArray()
    var exDelegate: ExecuteQuery = ExecuteQuery()
    var isFirstLoad : Bool = false
    
    var delObjAtId:String = " "
    var delOppAtIndexPath:NSIndexPath? = nil
    var isCreatedSuccessfully:Bool = false
    var oppOfflineArr:AnyObject = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isFirstLoad = true
        exDelegate.delegate = self
        self.title = "Opportunity View"
        self.setNavigationBarItem()
        self.addRightBarButtonWithImage1()
        self.tableView.registerCellNib(DataTableViewCell.self)
           }
    
    func executeQuery()  {
        oppOnlineArr = exDelegate.resArr.mutableCopy() as! NSMutableArray
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
        })
    }
    
        func addRightBarButtonWithImage1() {
        //let navBarAddBtn: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "addImg"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.toggleRight1))
        let navBarAddBtn: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(self.toggleRight1))
        navigationItem.rightBarButtonItem = navBarAddBtn;
    }
    
    func toggleRight1() {
        let storyboard = UIStoryboard.init(name: "SubContentsViewController", bundle: nil)
        let nv = storyboard.instantiateViewControllerWithIdentifier("CreateObjectViewController") as! CreateObjectViewController
        nv.objectType = ObjectDataType.opportunityValue.rawValue
        navigationController?.pushViewController(nv, animated: true)
        //nv.delegate = self
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let arrayOfObjectsData = defaults.objectForKey("\(ObjectDataType.opportunityValue.rawValue)\(OffLineKeySuffix)") as? NSData {
            oppOfflineArr = NSKeyedUnarchiver.unarchiveObjectWithData(arrayOfObjectsData)!
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
        }
        loadOpporchunity()
        if isCreatedSuccessfully {
            let defaults = NSUserDefaults.standardUserDefaults()
            let loading = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            if exDelegate.isConnectedToNetwork() {
//                if oppOfflineArr.count > 0 {
//                    offlineData.oppOfflineShrinkData(oppOfflineArr as! NSMutableArray)
//                }
                exDelegate.leadQueryDe(ObjectDataType.opportunityValue.rawValue)
            } else if let arrayOfObjectsData = defaults.objectForKey("\(ObjectDataType.opportunityValue.rawValue)\(OnLineKeySuffix)") as? NSData {
                oppOnlineArr = NSKeyedUnarchiver.unarchiveObjectWithData(arrayOfObjectsData)! as! NSMutableArray
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                })
            }
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
        
        if exDelegate.isConnectedToNetwork() {
//            if oppOfflineArr.count > 0 {
//                offlineData.oppOflineShrinkData(oppOfflineArr as! NSMutableArray)
//            }
            let loading = MBProgressHUD.showHUDAddedTo(self.navigationController!.view, animated: true)
            loading.mode = MBProgressHUDMode.Indeterminate
            loading.detailsLabelText = "Loading Data from Server"
            loading.hide(true, afterDelay: 2)
            loading.removeFromSuperViewOnHide = true
            exDelegate.leadQueryDe(ObjectDataType.opportunityValue.rawValue)
           
        } else if let arrayOfObjectsData = defaults.objectForKey("\(ObjectDataType.opportunityValue.rawValue)\(OnLineKeySuffix)") as? NSData {
            oppOnlineArr = NSKeyedUnarchiver.unarchiveObjectWithData(arrayOfObjectsData)!.mutableCopy() as! NSMutableArray
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
        return (section == 0) ? oppOfflineArr.count : oppOnlineArr.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier(DataTableViewCell.identifier) as! DataTableViewCell
        cell.convertButton.hidden = true
        if indexPath.section == 0 {
            cell.dataText?.text = oppOfflineArr.objectAtIndex(indexPath.row)["Name"] as? String
            cell.notConnectedImage.hidden = false
        } else {
            cell.dataText?.text = oppOnlineArr.objectAtIndex(indexPath.row)["Name"] as? String
            cell.detailText?.text = oppOnlineArr.objectAtIndex(indexPath.row)["Account"]?["Name"] as? String
            cell.notConnectedImage.hidden = true
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
            subContentsVC.section = indexPath.section
            subContentsVC.getResponseArr = self.oppOfflineArr.objectAtIndex(indexPath.row).mutableCopy() as! NSMutableDictionary
            subContentsVC.parentIndex = (indexPath.row)
            self.navigationController?.pushViewController(subContentsVC, animated: true)
        } else {
            if self.exDelegate.isConnectedToNetwork() {
                subContentsVC.getResponseArr = self.oppOnlineArr.objectAtIndex(indexPath.row).mutableCopy() as! NSMutableDictionary
                subContentsVC.leadID = self.oppOnlineArr.objectAtIndex(indexPath.row)["Id"] as! String
                subContentsVC.parentIndex = (indexPath.row)
                self.navigationController?.pushViewController(subContentsVC, animated: true)
            }
        }
        globalIndex = (indexPath.row)
      
    }
    
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            delOppAtIndexPath = indexPath
            if indexPath.section != 0 {
                delObjAtId = self.oppOnlineArr.objectAtIndex(indexPath.row)["Id"] as! String
                let oppToDelete = self.oppOnlineArr.objectAtIndex(indexPath.row)["Name"] as! String
                confirmDelete(oppToDelete)
            } else {
                let oppToDelete = self.oppOfflineArr.objectAtIndex(indexPath.row)["Name"] as! String
                confirmDelete(oppToDelete)
            }
            
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
         if delOppAtIndexPath!.section == 0  {
            dispatch_async(dispatch_get_main_queue(), {
                if let indexPath = self.delOppAtIndexPath {
                    self.oppOfflineArr.removeObjectAtIndex(indexPath.row)
                    self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                    let arrOfOppData = NSKeyedArchiver.archivedDataWithRootObject(self.oppOfflineArr)
                    defaults.setObject(arrOfOppData, forKey: "\(ObjectDataType.opportunityValue.rawValue)\(OffLineKeySuffix)")
                    self.delOppAtIndexPath = nil
                }
            })
            let loading = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            loading.mode = MBProgressHUDMode.Indeterminate
            loading.detailsLabelText = "Please check your Internet connection!"
            loading.hide(true, afterDelay: 2)
            loading.removeFromSuperViewOnHide = true
         } else {
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
                        self.oppOnlineArr.removeObjectAtIndex(indexPath.row)
                        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                        self.delOppAtIndexPath = nil
                    }
                })
            }
        }
        }
    }
}

//
//  AccountViewController.swift
//  SlideMenuControllerSwift
//
//  Created by Yuji Hato on 1/19/15.
//  Copyright (c) 2015 Yuji Hato. All rights reserved.
//




import UIKit
import SalesforceRestAPI
import MBProgressHUD

class AccountViewController:UIViewController, ExecuteQueryDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var delAccAtIndexPath:NSIndexPath? = nil
    var delObjAtId: String = " "
    var exDelegate: ExecuteQuery = ExecuteQuery()
    var accOnlineArr: AnyObject = NSMutableArray()
    var accOfflineArr: AnyObject = NSMutableArray()
    var isCreatedSuccessfully: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        exDelegate.delegate = self
        self.title = "Account View"
        self.setNavigationBarItem()
        self.addRightBarButtonWithImage1()
        self.tableView.registerCellNib(DataTableViewCell.self)
    }
    
    func executeQuery()  {
        accOnlineArr = exDelegate.resArr.mutableCopy() as! NSMutableArray
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
        })
    }
    
    func addRightBarButtonWithImage1() {
        //let navBarAddBtn: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "addImg"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.toggleRight1))
        let navBarAddBtn: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(self.toggleRight1))
        navigationItem.rightBarButtonItem = navBarAddBtn
    }
    
    func toggleRight1() {
        let storyboard = UIStoryboard.init(name: "SubContentsViewController", bundle: nil)
        let nv = storyboard.instantiateViewControllerWithIdentifier("CreateObjectViewController") as! CreateObjectViewController
        nv.objectType = ObjectDataType.accountValue.rawValue
        navigationController?.pushViewController(nv, animated: true)
        //nv.delegate = self
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let arrayOfObjectsData = defaults.objectForKey("\(ObjectDataType.accountValue.rawValue)\(OffLineKeySuffix)") as? NSData {
            accOfflineArr = NSKeyedUnarchiver.unarchiveObjectWithData(arrayOfObjectsData)!
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
        }
        loadAccount()
        if isCreatedSuccessfully {
            let loading = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        if exDelegate.isConnectedToNetwork() {
            exDelegate.leadQueryDe(ObjectDataType.accountValue.rawValue)
        } else if let arrayOfObjectsData = defaults.objectForKey("\(ObjectDataType.accountValue.rawValue)\(OnLineKeySuffix)") as? NSData {
            accOnlineArr = NSKeyedUnarchiver.unarchiveObjectWithData(arrayOfObjectsData)!
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
        }
        loading.mode = MBProgressHUDMode.Text
        loading.detailsLabelText = "Created Successfully!"
        loading.removeFromSuperViewOnHide = true
        loading.hide(true, afterDelay:2)
        }
        isCreatedSuccessfully = false
        self.setNavigationBarItem()
    }
    
    
    func getValFromAccVC(params:Bool) {
        isCreatedSuccessfully = params
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadAccount() {
        
        if exDelegate.isConnectedToNetwork() {
       if accOfflineArr.count > 0 {
        obj.OfflineShrinkData(accOfflineArr as! NSMutableArray, objType: ObjectDataType.accountValue.rawValue)
            }
            let loading = MBProgressHUD.showHUDAddedTo(self.navigationController?.view, animated: true)
            loading.detailsLabelText = "Loading Data from Server"
            loading.hide(true, afterDelay: 2)
            loading.removeFromSuperViewOnHide = true
            exDelegate.leadQueryDe(ObjectDataType.accountValue.rawValue)
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
        } else if let arrayOfObjectsData = defaults.objectForKey("\(ObjectDataType.accountValue.rawValue)\(OnLineKeySuffix)") as? NSData {
            dispatch_async(dispatch_get_main_queue(), {
            self.accOnlineArr = NSKeyedUnarchiver.unarchiveObjectWithData(arrayOfObjectsData)!.mutableCopy() as! NSMutableArray
                self.tableView.reloadData()
            })
        }
    }
}

extension AccountViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return DataTableViewCell.height()
    }
}

extension AccountViewController : UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int // Default is 1 if not implemented
    {
        return 2;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == 0) ? accOfflineArr.count : accOnlineArr.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier(DataTableViewCell.identifier) as! DataTableViewCell
        cell.convertButton.hidden = true
        //Name
        
        //cell.dataText?.text = resArr1.objectAtIndex(indexPath.row)["Website"] as? String
        if indexPath.section == 0 {
            cell.dataText?.text = accOfflineArr.objectAtIndex(indexPath.row)["Name"] as? String
            cell.notConnectedImage.hidden = false
        } else {
            cell.dataText?.text = accOnlineArr.objectAtIndex(indexPath.row)["Name"] as? String
            cell.notConnectedImage.hidden = true
        }
        cell.dataImage.backgroundColor = UIColor.init(hex: "FFD434")
        cell.dataImage.layer.cornerRadius = 1.0
        cell.dataImage.image = UIImage.init(named: "accImg")
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let storyboard = UIStoryboard(name: "SubContentsViewController", bundle: nil)
        let subContentsVC = storyboard.instantiateViewControllerWithIdentifier("AccountDataVC") as! AccountDataVC
        if indexPath.section == 0 {
            subContentsVC.isOfflineData = true
            subContentsVC.getResponseArr = self.accOfflineArr.objectAtIndex(indexPath.row).mutableCopy() as! NSMutableDictionary
            subContentsVC.parentIndex = (indexPath.row)
            self.navigationController?.pushViewController(subContentsVC, animated: true)
            
        } else {
            if self.exDelegate.isConnectedToNetwork() {
                subContentsVC.getResponseArr = self.accOnlineArr.objectAtIndex(indexPath.row).mutableCopy() as! NSMutableDictionary
                subContentsVC.leadID = self.accOnlineArr.objectAtIndex(indexPath.row)["Id"] as! String
                subContentsVC.parentIndex = (indexPath.row)
                self.navigationController?.pushViewController(subContentsVC, animated: true)
            }
        }
        globalIndex = (indexPath.row)
    }
    
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            delAccAtIndexPath = indexPath
            delObjAtId = self.accOnlineArr.objectAtIndex(indexPath.row)["Id"] as! String
            let accToDelete = self.accOnlineArr.objectAtIndex(indexPath.row)["Name"] as! String
            confirmDelete(accToDelete)
        }
    }
    
    
    func confirmDelete(accName: String) {
        let alert = UIAlertController(title: "Delete file", message: "Are you sure to permanently delete \(accName)?", preferredStyle: .Alert )
        let DeleteAction = UIAlertAction(title: "Delete", style: .Destructive, handler: accDelAction)
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
    
    func accDelAction(alertAction: UIAlertAction) -> Void {
        if delAccAtIndexPath!.section == 0  {
            dispatch_async(dispatch_get_main_queue(), {
                if let indexPath = self.delAccAtIndexPath {
                    self.accOfflineArr.removeObjectAtIndex(indexPath.row)
                    self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                    let arrOfOppData = NSKeyedArchiver.archivedDataWithRootObject(self.accOfflineArr)
                    defaults.setObject(arrOfOppData, forKey: "\(ObjectDataType.accountValue.rawValue)\(OffLineKeySuffix)")
                    self.delAccAtIndexPath = nil
                }
            })
        } else {
            if exDelegate.isConnectedToNetwork() {
                SFRestAPI.sharedInstance().performDeleteWithObjectType("Account", objectId: delObjAtId,failBlock: { err in
                    dispatch_async(dispatch_get_main_queue(), {
                        let alert = UIAlertView.init(title: "Error", message: err?.localizedDescription , delegate: self, cancelButtonTitle: "OK")
                        alert.show()
                    })
                    print( (err))
                }){ succes in
                    dispatch_async(dispatch_get_main_queue(), {
                        if let indexPath = self.delAccAtIndexPath {
                            self.accOnlineArr.removeObjectAtIndex(indexPath.row)
                            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                            ///self.tableView.reloadData()
                            self.delAccAtIndexPath = nil
                        }
                    })
                }
            }
        }    }
}
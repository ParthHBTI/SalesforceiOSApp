//
//  ContactViewController.swift
//  SlideMenuControllerSwift
//
//  Created by Yuji Hato on 1/19/15.
//  Copyright (c) 2015 Yuji Hato. All rights reserved.
//

let ContactOnLineDataKey = "ContactOnLineDataKey"
let ContactOfLineDataKey = "ContactOfLineDataKey"

import UIKit
import SalesforceRestAPI
import MBProgressHUD

var contactOnLineArr: AnyObject = NSMutableArray()

class ContactViewController: UIViewController , ExecuteQueryDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    var exDelegate: ExecuteQuery = ExecuteQuery()
    var delContactAtIndexPath:NSIndexPath? = nil
    var delObjAtId:String = " "
    var isCreatedSuccessfully:Bool = false
    var onlineDataFlag = false
    var contactOfLineArr: AnyObject = NSMutableArray()
    
    
    
    func dataUpdateToServer()  {
        print("interNetChanges")
        contactOfLineArr.removeAllObjects()
        
        if let arrayOfObjectsData = defaults.objectForKey("\(ObjectDataType.contactValue.rawValue)\(OffLineKeySuffix)") as? NSData {
            contactOfLineArr = NSKeyedUnarchiver.unarchiveObjectWithData(arrayOfObjectsData)!
           
        }
        loadContact()
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
        })
    }
    
 
    
       override func viewDidLoad() {
        super.viewDidLoad()
        exDelegate.delegate = self
         self.title = "Contacts View"
        self.setNavigationBarItem()
        //self.addRightBarButtonWithImage1(UIImage(named: "plus")!)
        self.addRightBarButtonWithImage1()
        self.tableView.registerCellNib(DataTableViewCell.self)
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector:#selector(ContactViewController.dataUpdateToServer),
            name: "\(ObjectDataType.contactValue.rawValue)\(NotificationSuffix)",
            object: nil)
    }
    
    func executeQuery()  {
        contactOnLineArr = exDelegate.resArr.mutableCopy() as!NSMutableArray
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
        nv.objectType = ObjectDataType.contactValue.rawValue
        navigationController?.pushViewController(nv, animated: true)
        //nv.delegate = self
    }

    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let arrayOfObjectsData = defaults.objectForKey("\(ObjectDataType.contactValue.rawValue)\(OffLineKeySuffix)") as? NSData {
            contactOfLineArr = NSKeyedUnarchiver.unarchiveObjectWithData(arrayOfObjectsData)!
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
        }
        loadContact()
        if isCreatedSuccessfully {
            let loading = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            if exDelegate.isConnectedToNetwork() {
                exDelegate.leadQueryDe(ObjectDataType.contactValue.rawValue)
            } else if let arrayOfObjectsData = defaults.objectForKey("\(ObjectDataType.contactValue.rawValue)\(OnLineKeySuffix)") as? NSData {
                contactOnLineArr = NSKeyedUnarchiver.unarchiveObjectWithData(arrayOfObjectsData)!
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
    
    
    func getValFromContactVC(params:Bool) {
        isCreatedSuccessfully = params
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadContact() {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if exDelegate.isConnectedToNetwork() {
            if contactOfLineArr.count > 0 {
               // obj.OfflineShrinkData(contactOfLineArr as! NSMutableArray, objType: ObjectDataType.contactValue.rawValue)
            }
             let loading = MBProgressHUD.showHUDAddedTo(self.navigationController!.view, animated: true)
            loading.detailsLabelText = "Loading Data from Server"
            loading.hide(true, afterDelay: 0.5)
            loading.removeFromSuperViewOnHide = true
            exDelegate.leadQueryDe(ObjectDataType.contactValue.rawValue)
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
        } else if let arrayOfObjectsData = defaults.objectForKey("\(ObjectDataType.contactValue.rawValue)\(OnLineKeySuffix)") as? NSData {
            contactOnLineArr = NSKeyedUnarchiver.unarchiveObjectWithData(arrayOfObjectsData)!.mutableCopy() as! NSMutableArray
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
        }
        
    }
}

extension ContactViewController : UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return DataTableViewCell.height()
    }
}

extension ContactViewController : UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int // Default is 1 if not implemented
    {
        return 2;
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == 0) ? contactOfLineArr.count : contactOnLineArr.count
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier(DataTableViewCell.identifier) as! DataTableViewCell
         cell.convertButton.hidden = true
//        cell.textLabel?.text = resArr1.objectAtIndex(indexPath.row)["Name"] as? String
//        cell.detailTextLabel?.text = resArr1.objectAtIndex(indexPath.row)["Name"] as? String
        if indexPath.section == 0 {
            cell.dataText.text = contactOfLineArr.objectAtIndex(indexPath.row)["LastName"] as? String
            cell.notConnectedImage.hidden = false
        } else {
            cell.dataText.text = contactOnLineArr.objectAtIndex(indexPath.row)["Name"] as? String
            cell.detailText.text = contactOnLineArr.objectAtIndex(indexPath.row)["Account"]!["Name"] as? String
            cell.notConnectedImage.hidden = true
        }
        cell.dataImage.backgroundColor = UIColor.init(hex: "9996D2")
        cell.dataImage.layer.cornerRadius = 2.0
        cell.dataImage.image = UIImage.init(named: "add_contact")
        //print(cell.textLabel?.text)
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let storyboard = UIStoryboard(name: "SubContentsViewController", bundle: nil)
        let subContentsVC = storyboard.instantiateViewControllerWithIdentifier("ContactDataVC") as! ContactDataVC
        if indexPath.section == 0 {
            subContentsVC.isOfflineData = true
            subContentsVC.getResponseArr = self.contactOfLineArr.objectAtIndex(indexPath.row).mutableCopy() as! NSMutableDictionary
            subContentsVC.parentIndex = (indexPath.row)
            self.navigationController?.pushViewController(subContentsVC, animated: true)
        } else {
            if self.exDelegate.isConnectedToNetwork() {
                subContentsVC.getResponseArr = contactOnLineArr.objectAtIndex(indexPath.row).mutableCopy() as! NSMutableDictionary
                subContentsVC.leadID = contactOnLineArr.objectAtIndex(indexPath.row)["Id"] as! String
                subContentsVC.parentIndex = (indexPath.row)
                self.navigationController?.pushViewController(subContentsVC, animated: true)
            } else {
                subContentsVC.getResponseArr = contactOnLineArr.objectAtIndex(indexPath.row).mutableCopy() as! NSMutableDictionary
                subContentsVC.leadID = contactOnLineArr.objectAtIndex(indexPath.row)["Id"] as! String
                subContentsVC.parentIndex = (indexPath.row)
                self.navigationController?.pushViewController(subContentsVC, animated: true)
            }
        }
        globalIndex = (indexPath.row)
    }
    
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            if indexPath.section == 0 {
                delContactAtIndexPath = indexPath
                let leadToDelete = self.contactOfLineArr.objectAtIndex(indexPath.row)["LastName"] as! String
                confirmDelete(leadToDelete)
            } else if exDelegate.isConnectedToNetwork() {
                delContactAtIndexPath = indexPath
                delObjAtId = contactOnLineArr.objectAtIndex(indexPath.row)["Id"] as! String
                let leadToDelete = contactOnLineArr.objectAtIndex(indexPath.row)["Name"] as! String
                confirmDelete(leadToDelete)
            } else {
                onlineDataFlag = true
                delContactAtIndexPath = indexPath
                delObjAtId = contactOnLineArr.objectAtIndex(indexPath.row)["Id"] as! String
                let leadToDelete = contactOnLineArr.objectAtIndex(indexPath.row)["Name"] as! String
                confirmDelete(leadToDelete)
            }
        }
    }
    
    func confirmDelete(contactName: String) {
        let alert = UIAlertController(title: "Delete file", message: "Are you sure to permanently delete \(contactName)?", preferredStyle: .Alert )
        let DeleteAction = UIAlertAction(title: "Delete", style: .Destructive, handler: conDelAction)
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
    
    
    func conDelAction(alertAction: UIAlertAction) -> Void {
        if exDelegate.isConnectedToNetwork() {
            SFRestAPI.sharedInstance().performDeleteWithObjectType("Contact", objectId: delObjAtId,failBlock: { err in
                dispatch_async(dispatch_get_main_queue(), {
                    let alert = UIAlertView.init(title: "Error", message: err?.localizedDescription , delegate: self, cancelButtonTitle: "OK")
                    alert.show()
                })
                print( (err))
            }){ succes in
                dispatch_async(dispatch_get_main_queue(), {
                    if let indexPath = self.delContactAtIndexPath {
                        contactOnLineArr.removeObjectAtIndex(indexPath.row)
                        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                        self.delContactAtIndexPath = nil
                    }
                })
            }
        }   else if onlineDataFlag {
            dispatch_async(dispatch_get_main_queue(), {
                if let indexPath = self.delContactAtIndexPath {
                    contactOnLineArr.removeObjectAtIndex(indexPath.row)
                    self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                    deletedKeysArr.addObject(self.delObjAtId)
                    print(self.delObjAtId)
                    let onlineDeletsKeys = NSKeyedArchiver.archivedDataWithRootObject(deletedKeysArr)
                    defaults.setObject(onlineDeletsKeys, forKey:onlineDeletsObjectsKey)
                    self.delContactAtIndexPath = nil
                }
            })
        } else {
            if let indexPath = self.delContactAtIndexPath {
                self.contactOfLineArr.removeObjectAtIndex(indexPath.row)
                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                let offlineLeadArr = NSKeyedArchiver.archivedDataWithRootObject(contactOfLineArr)
                defaults.setObject(offlineLeadArr, forKey:"\(ObjectDataType.leadValue.rawValue)\(OffLineKeySuffix)")
                self.delContactAtIndexPath = nil
            }
            }
        }
}

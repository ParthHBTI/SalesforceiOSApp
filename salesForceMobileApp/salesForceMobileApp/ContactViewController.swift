//
//  ContactViewController.swift
//  SlideMenuControllerSwift
//
//  Created by Yuji Hato on 1/19/15.
//  Copyright (c) 2015 Yuji Hato. All rights reserved.
//

import UIKit
import SalesforceRestAPI
import MBProgressHUD

class ContactViewController: UIViewController , ExecuteQueryDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var resArr1:AnyObject = []
    var exDelegate: ExecuteQuery = ExecuteQuery()
    var isFirstLoad: Bool = false
  
    override func viewDidLoad() {
        super.viewDidLoad()
        isFirstLoad = true
        exDelegate.delegate = self
         self.title = "Contacts View"
        self.setNavigationBarItem()
        //self.addRightBarButtonWithImage1(UIImage(named: "plus")!)
        self.addRightBarButtonWithImage1()
        self.tableView.registerCellNib(DataTableViewCell.self)
        loadContact()
    }
    
    func executeQuery()  {
        resArr1 = exDelegate.resArr
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
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let nv = storyboard.instantiateViewControllerWithIdentifier("CreateNewContactVC") as! CreateNewContactVC
        navigationController?.pushViewController(nv, animated: true)
    }

    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if !isFirstLoad {
            exDelegate.leadQueryDe("contact")
        }
        isFirstLoad = false
        self.setNavigationBarItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadContact() {
        let defaults = NSUserDefaults.standardUserDefaults()
        let contacttDataKey = "contactListData"
        let loading = MBProgressHUD.showHUDAddedTo(self.navigationController!.view, animated: true)
        loading.mode = MBProgressHUDMode.Indeterminate
        if exDelegate.isConnectedToNetwork() {
            loading.detailsLabelText = "Uploading Data from Server"
            loading.hide(true, afterDelay: 2)
            loading.removeFromSuperViewOnHide = true
            exDelegate.leadQueryDe("contact")
        } else if let arrayOfObjectsData = defaults.objectForKey(contacttDataKey) as? NSData {
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

extension ContactViewController : UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return DataTableViewCell.height()
    }
}

extension ContactViewController : UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.resArr1.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier(DataTableViewCell.identifier) as! DataTableViewCell
         cell.convertButton.hidden = true
//        cell.textLabel?.text = resArr1.objectAtIndex(indexPath.row)["Name"] as? String
//        cell.detailTextLabel?.text = resArr1.objectAtIndex(indexPath.row)["Name"] as? String
        cell.dataText?.text = resArr1.objectAtIndex(indexPath.row)["Name"] as? String
        cell.dataImage.image = UIImage.init(named: "contact")
        print(cell.textLabel?.text)
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let storyboard = UIStoryboard(name: "SubContentsViewController", bundle: nil)
        let subContentsVC = storyboard.instantiateViewControllerWithIdentifier("ContactDataVC") as! ContactDataVC
        subContentsVC.getResponseArr = self.resArr1.objectAtIndex(indexPath.row)
        subContentsVC.leadID = self.resArr1.objectAtIndex(indexPath.row)["Id"] as! String
        subContentsVC.parentIndex = (indexPath.row)
        self.navigationController?.pushViewController(subContentsVC, animated: true)
    }
}
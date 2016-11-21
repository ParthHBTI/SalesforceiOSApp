//
//  OpportunityViewController.swift
//  SlideMenuControllerSwift
//
//  Created by Yuji Hato on 1/19/15.
//  Copyright (c) 2015 Yuji Hato. All rights reserved.
//

import UIKit
import SalesforceRestAPI
import MBProgressHUD
class OpportunityViewController: UIViewController, ExecuteQueryDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    var resArr1:AnyObject = []
    var exDelegate: ExecuteQuery = ExecuteQuery()
    var isFirstLoad : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isFirstLoad = true
        exDelegate.delegate = self
        self.title = "Opportunity View"
        self.setNavigationBarItem()
        //self.addRightBarButtonWithImage1(UIImage(named: "plus")!)
        self.addRightBarButtonWithImage1()
        self.tableView.registerCellNib(DataTableViewCell.self)
        loadOpporchunity()
    }
    
    func executeQuery()  {
        resArr1 = exDelegate.resArr
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
        })
    }
    
    //func addRightBarButtonWithImage1(buttonImage: UIImage) {
    //let rightButton: UIBarButtonItem = UIBarButtonItem(image: buttonImage, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.toggleRight1))
    func addRightBarButtonWithImage1() {
        let navBarAddBtn: UIBarButtonItem = UIBarButtonItem(title: "Add", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.toggleRight1))
        navigationItem.rightBarButtonItem = navBarAddBtn;
    }
    
    func toggleRight1() {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let nv = storyboard.instantiateViewControllerWithIdentifier("CreateNewOpportunityVC") as! CreateNewOpportunityVC
        navigationController?.pushViewController(nv, animated: true)
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if !isFirstLoad {
            exDelegate.leadQueryDe("opporchunity")
        }
        isFirstLoad = false
        self.setNavigationBarItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadOpporchunity() {
        let defaults = NSUserDefaults.standardUserDefaults()
        let opportunityDataKey = "opportunityDataKey"
        let loading = MBProgressHUD.showHUDAddedTo(self.navigationController!.view, animated: true)
        loading.mode = MBProgressHUDMode.Indeterminate
        if exDelegate.isConnectedToNetwork() {
            loading.detailsLabelText = "Uploading Data from Server"
            loading.hide(true, afterDelay: 2)
            loading.removeFromSuperViewOnHide = true
            exDelegate.leadQueryDe("opporchunity")
        } else if let arrayOfObjectsData = defaults.objectForKey(opportunityDataKey) as? NSData {
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

extension OpportunityViewController : UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return DataTableViewCell.height()
    }
}

extension OpportunityViewController : UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.resArr1.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier(DataTableViewCell.identifier) as! DataTableViewCell
        cell.dataText?.text = resArr1.objectAtIndex(indexPath.row)["Name"] as? String
        cell.dataImage.image = UIImage.init(named: "oppo")
        print(cell.textLabel?.text)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let storyboard = UIStoryboard(name: "SubContentsViewController", bundle: nil)
        let subContentsVC = storyboard.instantiateViewControllerWithIdentifier("OpportunityDataVC") as! OpportunityDataVC
        subContentsVC.getResponseArr = self.resArr1.objectAtIndex(indexPath.row)
        subContentsVC.leadID = self.resArr1.objectAtIndex(indexPath.row)["Id"] as! String
        subContentsVC.parentIndex = (indexPath.row)
        self.navigationController?.pushViewController(subContentsVC, animated: true)
    }
}
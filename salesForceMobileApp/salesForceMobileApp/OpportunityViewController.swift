//
//  OpportunityViewController.swift
//  SlideMenuControllerSwift
//
//  Created by Yuji Hato on 1/19/15.
//  Copyright (c) 2015 Yuji Hato. All rights reserved.
//

import UIKit
import SalesforceRestAPI

class OpportunityViewController: UIViewController, ExecuteQueryDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    var resArr1:AnyObject = []
    var exDelegate: ExecuteQuery = ExecuteQuery()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        exDelegate.delegate = self
        self.title = "Opportunity View"
        self.setNavigationBarItem()
        self.addRightBarButtonWithImage1(UIImage(named: "plus")!)
        self.tableView.registerCellNib(DataTableViewCell.self)
        let defaults = NSUserDefaults.standardUserDefaults()
        let opportunityDataKey = "opportunityDataKey"
        if let arrayOfObjectsData = defaults.objectForKey(opportunityDataKey) as? NSData {
            resArr1 = NSKeyedUnarchiver.unarchiveObjectWithData(arrayOfObjectsData)!
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
        } else {
            exDelegate.leadQueryDe("opporchunity")
        }
    }
    
    func leadQuery()  {
        resArr1 = exDelegate.resArr
        tableView.reloadData()
    }

    
    func addRightBarButtonWithImage1(buttonImage: UIImage) {
        let rightButton: UIBarButtonItem = UIBarButtonItem(image: buttonImage, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.toggleRight1))
        navigationItem.rightBarButtonItem = rightButton;
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
        self.setNavigationBarItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        print(cell.textLabel?.text)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let storyboard = UIStoryboard(name: "SubContentsViewController", bundle: nil)
        let subContentsVC = storyboard.instantiateViewControllerWithIdentifier("OpportunityDataVC") as! OpportunityDataVC
        subContentsVC.getResponseArr = self.resArr1.objectAtIndex(indexPath.row)
        self.navigationController?.pushViewController(subContentsVC, animated: true)
    }
}
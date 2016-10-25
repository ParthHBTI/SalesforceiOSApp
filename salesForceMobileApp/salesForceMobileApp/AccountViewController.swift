//
//  AccountViewController.swift
//  SlideMenuControllerSwift
//
//  Created by Yuji Hato on 1/19/15.
//  Copyright (c) 2015 Yuji Hato. All rights reserved.
//



import UIKit
import SalesforceRestAPI

class AccountViewController:UIViewController, SFRestDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var resArr:AnyObject = []
    // MARK: - View lifecycle
    
    // MARK: - SFRestAPIDelegate
    func request(request: SFRestRequest, didLoadResponse jsonResponse: AnyObject) {
        let dataRows = jsonResponse["records"] as! [NSDictionary]
        self.log(.Debug, msg: "request:didLoadResponse: #records: \(dataRows.count)")
        dispatch_async(dispatch_get_main_queue(), {
            self.resArr = dataRows
            self.tableView.reloadData()
            let defaults = NSUserDefaults.standardUserDefaults()
            let accountDataKey = "accountListData"
            let arrOfAccountData = NSKeyedArchiver.archivedDataWithRootObject(self.resArr)
            defaults.setObject(arrOfAccountData, forKey: accountDataKey)
        })
    }
    
    func request(request: SFRestRequest, didFailLoadWithError error: NSError)
    {
        self.log(.Debug, msg: "didFailLoadWithError: \(error)")
        // Add your failed error handling here
    }
    
    func requestDidCancelLoad(request: SFRestRequest)
    {
        self.log(.Debug, msg: "requestDidCancelLoad: \(request)")
        // Add your failed error handling here
    }
    
    func requestDidTimeout(request: SFRestRequest)
    {
        self.log(.Debug, msg: "requestDidTimeout: \(request)")
        // Add your failed error handling here
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Account View"
        self.addRightBarButtonWithImage1(UIImage(named: "plus")!)
        self.tableView.registerCellNib(DataTableViewCell.self)
        let defaults = NSUserDefaults.standardUserDefaults()
        let accountDataKey = "accountListData"
        if let arrayOfObjectsData = defaults.valueForKey(accountDataKey) as? NSData {
            self.resArr = NSKeyedUnarchiver.unarchiveObjectWithData(arrayOfObjectsData)!
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
        }
        else{
            let request = SFRestAPI.sharedInstance().requestForQuery("SELECT AccountNumber,Fax,LastModifiedDate,Name,Ownership,Phone,Type,Website FROM Account Limit 10");
            SFRestAPI.sharedInstance().send(request, delegate: self);
         }
     }
    
    func addRightBarButtonWithImage1(buttonImage: UIImage) {
        let rightButton: UIBarButtonItem = UIBarButtonItem(image: buttonImage, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.toggleRight1))
        navigationItem.rightBarButtonItem = rightButton;
    }
    
    func toggleRight1() {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let nv = storyboard.instantiateViewControllerWithIdentifier("CreateNewAccountVC") as! CreateNewAccountVC
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

extension AccountViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return DataTableViewCell.height()
    }
}

extension AccountViewController : UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.resArr.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier(DataTableViewCell.identifier) as! DataTableViewCell
        cell.dataText?.text = resArr.objectAtIndex(indexPath.row)["Website"] as? String
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let storyboard = UIStoryboard(name: "SubContentsViewController", bundle: nil)
        let subContentsVC = storyboard.instantiateViewControllerWithIdentifier("AccountDataVC") as! AccountDataVC
        subContentsVC.getResponseArr = self.resArr.objectAtIndex(indexPath.row)
        self.navigationController?.pushViewController(subContentsVC, animated: true)
        
    }
}
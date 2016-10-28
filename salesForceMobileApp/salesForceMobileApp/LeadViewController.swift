//
//  ViewController.swift
//  SlideMenuControllerSwift
//
//  Created by Yuji Hato on 12/3/14.
//

import UIKit
import SalesforceRestAPI

// class for Lead's data
class LeadViewController: UIViewController, ExecuteQueryDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var resArr1:AnyObject = []
    var exDelegate: ExecuteQuery = ExecuteQuery()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        exDelegate.delegate = self
        self.title = "Leads View"
        self.setNavigationBarItem()
        self.addRightBarButtonWithImage1(UIImage(named: "plus")!)
        self.tableView.registerCellNib(DataTableViewCell.self)
        let defaults = NSUserDefaults.standardUserDefaults()
        let arrayOfObjectsKey = "leadListData"
        defaults.removeObjectForKey(arrayOfObjectsKey)
        if let arrayOfObjectsData = defaults.objectForKey(arrayOfObjectsKey) as? NSData {
            resArr1 = NSKeyedUnarchiver.unarchiveObjectWithData(arrayOfObjectsData)!
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
        } else {
           exDelegate.leadQueryDe("lead")
        }
    }
    
    func executeQuery()  {
        resArr1 = exDelegate.resArr
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
        })
    }
    
    func addRightBarButtonWithImage1(buttonImage: UIImage) {
        let rightButton: UIBarButtonItem = UIBarButtonItem(image: buttonImage, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.toggleRight1))
        navigationItem.rightBarButtonItem = rightButton;
    }
    
    func toggleRight1() {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let nv = storyboard.instantiateViewControllerWithIdentifier("CreateNewLeadVC") as! CreateNewLeadVC
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



extension LeadViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return DataTableViewCell.height()
    }
}

extension LeadViewController : UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resArr1.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier(DataTableViewCell.identifier) as! DataTableViewCell
        cell.dataText.text = resArr1.objectAtIndex(indexPath.row)["Company"] as? String
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let storyboard = UIStoryboard(name: "SubContentsViewController", bundle: nil)
        let subContentsVC = storyboard.instantiateViewControllerWithIdentifier("LeadContentVC") as! LeadContentVC
        subContentsVC.getResponseArr = self.resArr1.objectAtIndex(indexPath.row)
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


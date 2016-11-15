//
//  ContactDataVC.swift
//  salesForceMobileApp
//
//  Created by HemendraSingh on 20/10/16.
//  Copyright © 2016 Salesforce. All rights reserved.
//

import UIKit

class ContactDataVC: UITableViewController {
    
    var getResponseArr:AnyObject = []
    var cellTitleArr: NSArray = ["Contact Owner:","Name:","Email:","Birthdate:","Phone:","Fax:","Title:"]
    var contactDataArr = []
    
    func nullToNil(value : AnyObject?) -> AnyObject? {
        if value is NSNull {
            return nil
        } else {
            return value
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationBarItem()
        tableView.rowHeight = 70
        let crossBtnItem: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "plus"), style: .Plain, target: self, action: #selector(ContactDataVC.shareAction))
        let navBarEditBtn = UIBarButtonItem(title: "Edit", style: .Plain, target: self, action:#selector(self.editAction))
        self.navigationItem.setRightBarButtonItems([crossBtnItem,navBarEditBtn], animated: true)
        
        var birthdate = ""
        if  let _  = nullToNil( getResponseArr["Birthdate"]) {
            birthdate =  (getResponseArr["Birthdate"] as? String)!
        }
        
        var email = ""
        if  let _  = nullToNil( getResponseArr["Email"]) {
            email =  (getResponseArr["Email"] as? String)!
        }
        
        var phone = ""
        if  let _  = nullToNil( getResponseArr["Phone"]) {
            phone =  (getResponseArr["Phone"] as? String)!
        }
        
        var fax = ""
        if  let _  = nullToNil( getResponseArr["Fax"]) {
            fax =  (getResponseArr["Fax"] as? String)!
        }
        
        var salutation = ""
        if let _ = nullToNil(getResponseArr["Salutation"]) {
            salutation = (getResponseArr["Salutation"] as? String)!
        }
        
        var contactName = getResponseArr["Name"] as! String
        if salutation != "" {
            contactName = salutation + " " + (getResponseArr["Name"] as! String)
        }
        
        contactDataArr = [getResponseArr["Owner"]!!["Name"] as! String,
                          contactName,
                          email,
                          birthdate ,
                          phone,
                          fax
        ]
    }
    
    func shareAction() {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let nv = storyboard.instantiateViewControllerWithIdentifier("AttachViewController") as! AttachViewController
        navigationController?.pushViewController(nv, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactDataArr.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ContactDataCellID", forIndexPath: indexPath) as! ContactDataCell
        cell.TitleLbl.text = cellTitleArr.objectAtIndex(indexPath.row) as? String
        cell.TitleNameLbl.text = contactDataArr.objectAtIndex(indexPath.row) as? String
        if indexPath.row == 0 {
            cell.TitleNameLbl.textColor = self.navigationController?.navigationBar.barTintColor
        }
        if cell.TitleNameLbl.text == "" {
            tableView.rowHeight = 40
        }
        else {
            tableView.rowHeight = 70
        }
        return cell
    }
    
    
    func editAction() {
        let storyboard = UIStoryboard(name: "Main" , bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("CreateNewContactVC") as! CreateNewContactVC
        vc.contactDataDic = self.getResponseArr
        vc.flag = true
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
     if editingStyle == .Delete {
     // Delete the row from the data source
     tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
     } else if editingStyle == .Insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

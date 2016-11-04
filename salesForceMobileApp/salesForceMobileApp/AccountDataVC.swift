//
//  AccountDataVC.swift
//  salesForceMobileApp
//
//  Created by HemendraSingh on 20/10/16.
//  Copyright © 2016 Salesforce. All rights reserved.
//

import UIKit

class AccountDataVC: UITableViewController {
    
    var getResponseArr:AnyObject = []
    var accountCellTitleArr: NSArray = ["Account Name:","Account Number:","Type:","Ownership:","Website:","Phone:","Fax:","Last Modified Date:"]
    var accountDataArr = []
    
    func nullToNil(value : AnyObject?) -> AnyObject? {
        if value is NSNull {
            return nil
        } else {
            return value
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 70
        //print(getResponseArr)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        var lastModifiedDate = ""
        if  let _  = nullToNil( getResponseArr["LastModifiedDate"]) {
            lastModifiedDate =  (getResponseArr["LastModifiedDate"] as? String)!
        }
        
        var accountNumber = ""
        if  let _  = nullToNil( getResponseArr["AccountNumber"]) {
            accountNumber =   getResponseArr["AccountNumber"] as! String
        }

        
        var type = ""
        if  let _  = nullToNil( getResponseArr["Type"]) {
            type =   getResponseArr["Type"] as! String
        }
        
        var ownership = ""
        if  let _  = nullToNil( getResponseArr["Ownership"]) {
            ownership =   getResponseArr["Ownership"] as! String
        }
        
        var website = ""
        if  let _  = nullToNil( getResponseArr["Website"]) {
            website =   getResponseArr["Website"] as! String
        }
        
        var phone = ""
        if  let _  = nullToNil( getResponseArr["Phone"]) {
            phone =   getResponseArr["Phone"] as! String
        }
        
        var fax = ""
        if  let _  = nullToNil( getResponseArr["Fax"]) {
            fax =   getResponseArr["Fax"] as! String
        }
        
        accountDataArr = [
            getResponseArr["Name"] as! String,
            accountNumber,
            type,
            ownership,
            website,
            phone,
            fax,
            lastModifiedDate
        ]
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
        return accountDataArr.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AccountDataCellID", forIndexPath: indexPath) as! AccountDataCell
        cell.TitleLbl.text = self.accountCellTitleArr.objectAtIndex(indexPath.row) as? String
        cell.TitleNameLbl.text = self.accountDataArr.objectAtIndex(indexPath.row) as? String
        return cell
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

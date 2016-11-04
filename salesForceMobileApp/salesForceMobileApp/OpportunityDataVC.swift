//
//  OpportunityDataVC.swift
//  salesForceMobileApp
//
//  Created by HemendraSingh on 20/10/16.
//  Copyright © 2016 Salesforce. All rights reserved.
//

import UIKit

class OpportunityDataVC: UITableViewController {
    
    var getResponseArr:AnyObject = []
    var opportunityDataArr = []
    var cellTitleArr: NSArray = ["Name:","Lead Source:","Stage Name:","Type:","Ammount:","Probability:","Is Private:","Created Date:","Close Date:","Is Closed:","Is Deleted:","Last Modified Date:"]
    
    /*func isObjectNil(object:AnyObject!) -> Bool
    {
        if let _:AnyObject = object
        {
            return false
        }
        
        return true
    }*/
    
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
        print(getResponseArr)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        var leadSource = "Not available"
        if  let _  = nullToNil( getResponseArr["LeadSource"]) {
            leadSource =  (getResponseArr["LeadSource"] as? String)!
        }
        
        var type = ""
        if  let _  = nullToNil( getResponseArr["Type"]) {
            type =  (getResponseArr["Type"] as? String)!
        }
        
        var amount = 0
        if  let _  = nullToNil( getResponseArr["Amount"]) {
            amount =   getResponseArr["Amount"] as! Int
        }
        
        opportunityDataArr = [
            getResponseArr["Name"] as! String,
            leadSource,
            getResponseArr["StageName"] as! String,
            type,
            amount,
            getResponseArr["Probability"] as! Int,
            getResponseArr["IsPrivate"] as! Bool,
            getResponseArr["CreatedDate"] as! String,
            getResponseArr["CloseDate"] as! String,
            getResponseArr["IsClosed"] as! Bool,
            getResponseArr["IsDeleted"] as! Bool,
            getResponseArr["LastModifiedDate"] as! String
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
        return opportunityDataArr.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("OpportunityDataCellID", forIndexPath: indexPath) as! OpportunityDataCell
        cell.TitltLbl.text = self.cellTitleArr.objectAtIndex(indexPath.row) as? String
        cell.TitleNameLbl.text = self.opportunityDataArr.objectAtIndex(indexPath.row) as? String
        
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

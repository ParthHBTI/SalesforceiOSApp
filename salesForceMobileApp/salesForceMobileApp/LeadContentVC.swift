//
//  LeadContentVC.swift
//  salesForceMobileApp
//
//  Created by HemendraSingh on 20/10/16.
//  Copyright © 2016 Salesforce. All rights reserved.
//

import UIKit
import SalesforceRestAPI

class LeadContentVC: UITableViewController {
    
    var getResponseArr:AnyObject = []
    var cellTitleArr: NSArray = ["Name:","Company:","Email:","Phone:","Title:","Fax:"]
    var leadDataArr = []
    
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
        //
        print(getResponseArr)
        let nav = self.navigationController?.navigationBar
        nav!.barTintColor = UIColor.init(colorLiteralRed: 78.0/255, green: 158.0/255, blue: 255.0/255, alpha: 1.0)
        nav!.tintColor = UIColor.whiteColor()
        nav!.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        let viewRecordingList: UIBarButtonItem = UIBarButtonItem(title: "Convert",style: .Plain, target: self, action: #selector(self.convertLead))
        self.navigationItem.setRightBarButtonItem(viewRecordingList, animated: true)
        
        //
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        var email = ""
        if  let _  = nullToNil( getResponseArr["Email"]) {
            email =  (getResponseArr["Email"] as? String)!
        }
        
        var phone = ""
        if  let _  = nullToNil( getResponseArr["Phone"]) {
            phone =  (getResponseArr["Phone"] as? String)!
        }
        
        var title = ""
        if  let _  = nullToNil( getResponseArr["Title"]) {
            title =  (getResponseArr["Title"] as? String)!
        }
        
        leadDataArr = [
            getResponseArr["Name"] as! String,
            getResponseArr["Company"] as! String,
            email,
            phone,
            title
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
        return leadDataArr.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("leadContentCellID", forIndexPath: indexPath) as! LeadContentCell
        cell.titleLbl.text = self.cellTitleArr.objectAtIndex(indexPath.row) as? String
        cell.titleNameLbl.text = self.leadDataArr.objectAtIndex(indexPath.row) as? String
        
        return cell
    }
    
    
    func convertLead() {
//        var request = SFRestRequest(method: post, path: "", queryParams: nil)
//        request.endpoint = "/services/apexrest/{your endpoint}/{a lead Id}"
//        SFRestAPI.sharedInstance().sendRESTRequest(request, failBlock: {(err: NSError) -> Void in
//            print("error: \(err)")
//            }, completeBlock: {(success: AnyObject) -> Void in
//                print("success: \(success)")
//        })
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

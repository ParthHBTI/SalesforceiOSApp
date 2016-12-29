//
//  ManageObjectViewController.swift
//  salesForceMobileApp
//
//  Created by HemendraSingh on 15/12/16.
//  Copyright © 2016 Salesforce. All rights reserved.
//


import UIKit
import SalesforceRestAPI
import MBProgressHUD
let fieldValueKey = "FieldValue"

class AddNewObjectVC: UITableViewController,SFRestDelegate {
    
    var ObjectsArr = NSMutableArray()
    var getObjDataDic = NSDictionary()
    var ObjectsNameArr = NSArray()
    var ObjType:String = " "
    var exDelegate: ExecuteQuery = ExecuteQuery()
    
    /*func executeQuery()  {
        let accountRequest = "Select Name, (Select Name from FieldInfos__r) from Master_Object__c WHERE Name = 'Account'"
        let request = SFRestAPI.sharedInstance().requestForQuery(accountRequest)
        SFRestAPI.sharedInstance().sendRESTRequest(request, failBlock: {err in
            print( err)
            })
        { response in
            self.getObjDataDic = response as! NSDictionary
            print(self.getObjDataDic)
            self.ObjectsNameArr = ((self.getObjDataDic["records"]) as? NSArray)!
            self.ObjectsNameArr  = self.ObjectsNameArr.valueForKey("FieldInfos__r") as! NSArray
            self.ObjectsNameArr = self.ObjectsNameArr.objectAtIndex(0).valueForKey("records") as! NSArray
            self.ObjectsNameArr = self.ObjectsNameArr.valueForKey("Name") as! NSArray
            print(self.ObjectsNameArr)
        }
        tableView.reloadData()
    }
    */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navBarSaveBtn: UIBarButtonItem = UIBarButtonItem(title: "Save", style: .Plain, target: self, action: #selector(saveObjAction))
        self.navigationItem.setRightBarButtonItem(navBarSaveBtn, animated: true)
        let accountRequest = "Select Name, (Select Name,Display_Name__c,Display_order__c from FieldInfos__r) from Master_Object__c WHERE Name = 'Account'"
        let request = SFRestAPI.sharedInstance().requestForQuery(accountRequest)
        SFRestAPI.sharedInstance().sendRESTRequest(request, failBlock: {err in
            print( err)
            
            },completeBlock: { response in
                let Arr = ((response!["records"]) as? NSArray)!
                let newArr = Arr.valueForKey("FieldInfos__r") as! NSArray
                self.ObjectsArr = (newArr.objectAtIndex(0).valueForKey("records") as! NSArray).mutableCopy() as! NSMutableArray
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                })
                
                print(self.ObjectsArr)
                /*self.getObjDataDic = response as! NSDictionary
                 print(self.getObjDataDic)
                 self.ObjectsNameArr = ((self.getObjDataDic["records"]) as? NSArray)!
                 self.ObjectsNameArr  = self.ObjectsNameArr.valueForKey("FieldInfos__r") as! NSArray
                 self.ObjectsNameArr = self.ObjectsNameArr.objectAtIndex(0).valueForKey("records") as! NSArray
                 self.ObjectsNameArr = self.ObjectsNameArr.valueForKey("Name") as! NSArray
                 print(self.ObjectsNameArr)
                 self.tableView.reloadData()*/
                
        })
        // self.clearsSelectionOnViewWillAppear = false
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        //tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ObjectsArr.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ObjectsCellIdentifier", forIndexPath: indexPath) as! ManageObjectTableCell
        cell.ObjectName.text = self.ObjectsArr[indexPath.row].valueForKey("Display_Name__c") as? String
        if let valueToShow =  self.ObjectsArr[indexPath.row].valueForKey(fieldValueKey){
            cell.ObjectValueTxtField.text = valueToShow as? String
        } else {
            cell.ObjectValueTxtField.text = ""
        }
        return cell
    }
 
    
    func saveObjAction() {
        /* var arrayOfValues = NSMutableArray()
         for i in 0 ..< self.ObjectsNameArr.count {
         let indexPath = NSIndexPath(forRow:i, inSection:0)
         let cell : ManageObjectTableCell? = self.tableView.cellForRowAtIndexPath(indexPath) as! ManageObjectTableCell?
         if let val = cell?.ObjectValueTxtField.text {
         arrayOfValues.addObject(val)
         }
         }
         print(arrayOfValues)*/
        self.view.endEditing(true)
        var  fields = [String: AnyObject]()
        print(ObjectsArr)
        for data in self.ObjectsArr {
            fields[ (data["Name"] as? String)!] = data[fieldValueKey]
        }
        print(fields)
        SFRestAPI.sharedInstance().performCreateWithObjectType("Account", fields: fields, failBlock: {error in
            print(error)
            }, completeBlock: { response in
                print(response)
        })
    }
    
    
    func textFieldDidEndEditing(textField: UITextField)  {
        
        let pointInTable = textField.convertPoint(textField.bounds.origin, toView: self.tableView)
        let textFieldIndexPath = self.tableView.indexPathForRowAtPoint(pointInTable)
        let objectDic = ObjectsArr.objectAtIndex((textFieldIndexPath?.row)!).mutableCopy() as? NSMutableDictionary
        objectDic?.setObject(textField.text!, forKey: fieldValueKey)
        ObjectsArr.replaceObjectAtIndex((textFieldIndexPath?.row)!, withObject: objectDic!)
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

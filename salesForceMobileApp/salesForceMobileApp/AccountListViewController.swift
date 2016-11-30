//
//  AccountListViewController.swift
//  salesForceMobileApp
//
//  Created by mac on 28/11/16.
//  Copyright © 2016 Salesforce. All rights reserved.
//

import UIKit
import SystemConfiguration

@objc public protocol AccountListDelegate {
    optional func getAccountDel(accointDetail:String)
}

class AccountListViewController: UIViewController {
    internal weak var delegate : AccountListDelegate?
    @IBOutlet weak var tableView: UITableView!
    
    var accountListArr: AnyObject = []
    var acName = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.leftBarButtonWithImage(UIImage(named: "back_NavIcon")!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    
    func leftBarButtonWithImage(buttonImage: UIImage) {
        let leftButton: UIBarButtonItem = UIBarButtonItem(image: buttonImage, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.toggleLeft))
        navigationItem.leftBarButtonItem = leftButton;
    }
    
    override func toggleLeft() {
        self.navigationController?.popViewControllerAnimated(true)
    }

    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accountListArr.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("Identifire") as UITableViewCell!
        cell.textLabel?.text = accountListArr.objectAtIndex(indexPath.row)["Name"] as? String
               return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.acName = (self.accountListArr.objectAtIndex(indexPath.row)["Name"] as? String)!
        self.delegate?.getAccountDel!(self.acName )
        self.dismissViewControllerAnimated(true, completion: {
            
        })
        }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

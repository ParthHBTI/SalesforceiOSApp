//
//  ContactDataVC.swift
//  salesForceMobileApp
//
//  Created by HemendraSingh on 20/10/16.
//  Copyright © 2016 Salesforce. All rights reserved.
//

import UIKit
import SalesforceRestAPI

class ContactDataVC: UITableViewController, SFRestDelegate {
    var feedData: AnyObject = []
    var getResponseArr:AnyObject = []
    var cellTitleArr: NSArray = ["Contact Owner:","Name:","Email:","Birthdate:","Phone:","Fax:","Title:"]
    var contactDataArr = []
    var leadID = String()
    @IBOutlet weak var feedSegment: UISegmentedControl!
    
    func nullToNil(value : AnyObject?) -> AnyObject? {
        if value is NSNull {
            return nil
        } else {
            return value
        }
    }
    
    @IBAction func contactSegAction(sender: AnyObject) {
        if feedSegment.selectedSegmentIndex == 0 {
            dispatch_async(dispatch_get_main_queue(), {
                let path: String =  "/services/data/v36.0/sobjects/Contact/\(self.leadID)/feeds"
                let request = SFRestRequest(method: SFRestMethod.GET , path: path, queryParams: nil)
                SFRestAPI.sharedInstance().send(request, delegate: self)
                self.tableView.reloadData()
            })
        } else {
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
        }

        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationBarItem()
        tableView.rowHeight = 70
        feedSegment.selectedSegmentIndex = 1
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
        if feedSegment.selectedSegmentIndex == 1 {
            return contactDataArr.count
        } else {
            return feedData.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if feedSegment.selectedSegmentIndex == 1 {
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

            
        } else {
            let feedCell = tableView.dequeueReusableCellWithIdentifier("feedCellID", forIndexPath: indexPath) as! LeadContentCell
            self.tableView.rowHeight = 400
            feedCell.feedDateStatus.text = self.feedData.objectAtIndex(indexPath.row)["CreatedDate"] as?
            String
            feedCell.totalLike.text = String(self.feedData.valueForKey("LikeCount")![indexPath.row])
            feedCell.totalComment.text = String(self.feedData.objectAtIndex(indexPath.row)["CommentCount"])// as?
            feedCell.shareText.text = self.feedData.objectAtIndex(indexPath.row)["Body"] as?
            String
            let recordID = self.feedData.objectAtIndex(indexPath.row)["RelatedRecordId"]
            let query = "SELECT Id FROM ContentDocument where LatestPublishedVersionId = '\(recordID)'"
            let requ = SFRestAPI.sharedInstance().requestForQuery(query)
            //  SFRestAPI.sharedInstance().send(requ, delegate: self);
            
            SFRestAPI.sharedInstance().sendRESTRequest(requ, failBlock: {
                erro in
                print(erro)
                }, completeBlock: { response in
                    print(response)
                    
                    let imageData = response!["records"] as? NSArray
                    let id = imageData!.objectAtIndex(0)["Id"] as! String
                    
                    let downloadImgReq: SFRestRequest = SFRestAPI.sharedInstance().requestForFileContents(id , version: nil)
                    SFRestAPI.sharedInstance().sendRESTRequest(downloadImgReq, failBlock: {
                        erro in
                        print(erro)
                        }, completeBlock: { response in
                            let image: UIImage = UIImage.sd_imageWithData(response as! NSData)
                            feedCell.sharePhoto.image = image
                    })
            })
            return feedCell
        }
    }
    
    func request(request: SFRestRequest, didLoadResponse dataResponse: AnyObject) {
        //let attachmentID = dataResponse["id"] as! String
        self.feedData = dataResponse["records"]
        print(feedData)
        self.tableView.reloadData()
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

}

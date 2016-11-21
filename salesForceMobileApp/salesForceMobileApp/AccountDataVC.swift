//
//  AccountDataVC.swift
//  salesForceMobileApp
//
//  Created by HemendraSingh on 20/10/16.
//  Copyright © 2016 Salesforce. All rights reserved.
//

import UIKit
import SalesforceRestAPI

class AccountDataVC: UITableViewController, SFRestDelegate {
    
    var feedData: AnyObject = []
    var getResponseArr:AnyObject = []
    var leadID = String()
    var accountCellTitleArr: NSArray = ["Account Owner:","Account Name:","Account Number:","Type:","Ownership:","Website:","Phone:","Fax:","Last Modified Date:"]
    var accountDataArr = []
    var attachmentArr: AnyObject = []
    var noteArr: AnyObject = []
    @IBOutlet weak var feedSegment: UISegmentedControl!
    
    func nullToNil(value : AnyObject?) -> AnyObject? {
        if value is NSNull {
            return nil
        } else {
            return value
        }
    }
    
    @IBAction func accountSegAction(sender: AnyObject) {
        if feedSegment.selectedSegmentIndex == 0 {
            dispatch_async(dispatch_get_main_queue(), {
                let path: String =  "/services/data/v36.0/sobjects/Account/\(self.leadID)/feeds"
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
        let crossBtnItem: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "plus"), style: .Plain, target: self, action: #selector(AccountDataVC.shareAction))
        let navBarEditBtn = UIBarButtonItem(title: "Edit", style: .Plain, target: self, action:#selector(self.editAction))
        self.navigationItem.setRightBarButtonItems([crossBtnItem,navBarEditBtn], animated: true)
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
        
        accountDataArr = [getResponseArr["Owner"]!!["Name"] as! String,
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
    override func viewWillAppear(animated: Bool) {
         super.viewWillAppear(animated)
        dowloadAttachment()
    }
    
    func dowloadAttachment() {
        let query = "SELECT Body,CreatedDate,Id,Title FROM Note Where ParentId = '\(leadID)'"
        let reqs = SFRestAPI.sharedInstance().requestForQuery(query)
        SFRestAPI.sharedInstance().sendRESTRequest(reqs, failBlock: {
            erro in
            print(erro)
            }, completeBlock: { response in
                print(response)
                self.attachmentArr = response!["records"]
                self.tableView.reloadData()
                
                
        })
        let attachQuery = "SELECT ContentType,IsDeleted,IsPrivate,LastModifiedDate,Name FROM Attachment Where ParentId = '\(leadID)'"
        let attachReq = SFRestAPI.sharedInstance().requestForQuery(attachQuery)
        SFRestAPI.sharedInstance().sendRESTRequest(attachReq, failBlock: {
            erro in
            print(erro)
            }, completeBlock: { response in
                print(response)
                self.noteArr = response!["records"]
                self.tableView.reloadData()
                
                
        })
        
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
        if feedSegment.selectedSegmentIndex == 1 {
            return 3
        } else {
            return 1
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if feedSegment.selectedSegmentIndex == 1 {
            
            switch (section) {
            case 0:
                return accountDataArr.count
                
            case 1:
                return attachmentArr.count
                
            case 2:
                return noteArr.count
                
            default:
                return 1
            }
            //            return (section==0) ? leadDataArr.count : attachmentArr.count
        } else {
            return feedData.count
        }
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if feedSegment.selectedSegmentIndex == 1 {
            if indexPath.section == 0 {
                let detailCell = tableView.dequeueReusableCellWithIdentifier("leadContentCellID", forIndexPath: indexPath) as! LeadContentCell
                detailCell.titleLbl.text = self.accountCellTitleArr.objectAtIndex(indexPath.row) as? String
                detailCell.titleNameLbl.text = self.accountDataArr.objectAtIndex(indexPath.row) as? String
                if indexPath.row == 0 {
                    detailCell.titleNameLbl.textColor = self.navigationController?.navigationBar.barTintColor
                }
                if detailCell.titleNameLbl.text == "" {
                    tableView.rowHeight = 40
                } else {
                    tableView.rowHeight = 70
                }
                return detailCell
            } else if indexPath.section == 1 {
                let textFeedCell = tableView.dequeueReusableCellWithIdentifier("AttachCellID", forIndexPath: indexPath) as! NoteAndAttachFileCell
                textFeedCell.fileType.text = self.attachmentArr.objectAtIndex(indexPath.row)["Title"] as? String
                textFeedCell.fileModifyDate.text = self.attachmentArr.objectAtIndex(indexPath.row)["CreatedDate"] as? String
                return textFeedCell
            } else {
                let textFeedCell = tableView.dequeueReusableCellWithIdentifier("NoteCellID", forIndexPath: indexPath) as! NoteAndAttachFileCell
                //textFeedCell.fileType.text = self.noteArr.objectAtIndex(indexPath.row)["Title"] as? String
                textFeedCell.fileModifyDate.text = self.noteArr.objectAtIndex(indexPath.row)["LastModifiedDate"] as? String
                return textFeedCell
            }
        } else { 
            let fileContentName  = nullToNil(self.feedData.objectAtIndex(indexPath.row)["ContentFileName"])
            if fileContentName == nil {
                let textFeedCell = tableView.dequeueReusableCellWithIdentifier("textFeedCellID", forIndexPath: indexPath) as! AccountDataCell
                textFeedCell.feedDateStatus.text = self.feedData.objectAtIndex(indexPath.row)["CreatedDate"] as?
                String
                textFeedCell.totalLike.text = String(self.feedData.valueForKey("LikeCount")![indexPath.row])
                textFeedCell.totalComment.text = String(self.feedData.objectAtIndex(indexPath.row)["CommentCount"])// as?
                textFeedCell.shareText.text = self.feedData.objectAtIndex(indexPath.row)["Body"] as?
                String
                
                self.tableView.rowHeight = 200
                textFeedCell.shareText.text = self.feedData.objectAtIndex(indexPath.row)["Body"] as?
                String
                return textFeedCell
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
        
    }
    
    func request(request: SFRestRequest, didLoadResponse dataResponse: AnyObject) {
        //let attachmentID = dataResponse["id"] as! String
        self.feedData = dataResponse["records"]
        print(feedData)
        self.tableView.reloadData()
    }
    
    func request(request: SFRestRequest, didFailLoadWithError error: NSError)
    {
        self.log(.Debug, msg: "didFailLoadWithError: \(error)")
        // Add your failed error handling here
    }
    func editAction() {
        let storyboard = UIStoryboard(name: "Main" , bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("CreateNewAccountVC") as! CreateNewAccountVC
        vc.accountDataDic = self.getResponseArr
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

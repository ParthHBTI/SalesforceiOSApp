//
//  OpportunityDataVC.swift
//  salesForceMobileApp
//
//  Created by HemendraSingh on 20/10/16.
//  Copyright © 2016 Salesforce. All rights reserved.
//

import UIKit
import SalesforceRestAPI
class OpportunityDataVC: UITableViewController, SFRestDelegate,ExecuteQueryDelegate, UIActionSheetDelegate {
    var feedData: AnyObject = []
    var getResponseArr:AnyObject = []
    var opportunityDataArr = []
    var exDelegate: ExecuteQuery = ExecuteQuery()
    var attachmentArr: AnyObject = []
    var noteArr: AnyObject = []
    var cellTitleArr: NSArray = ["Opportunity Owner:","Opportunity Name:","Account Name:","Lead Source:","Stage Name:","Type:","Ammount:","Probability:","Is Private:","Created Date:","Close Date:","Is Closed:","Is Deleted:","Last Modified Date:"]
    var leadID = String()
    var isFirstLoad: Bool = false
    var parentIndex:Int = 0
    @IBOutlet weak var feedSegment: UISegmentedControl!
    func nullToNil(value : AnyObject?) -> AnyObject? {
        if value is NSNull {
            return nil
        } else {
            return value
        }
    }
    
    @IBAction func opporchunitySegAction(sender: AnyObject) {
        if feedSegment.selectedSegmentIndex == 0 {
            dispatch_async(dispatch_get_main_queue(), {
                let path: String =  "/services/data/v36.0/sobjects/Opportunity/\(self.leadID)/feeds"
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
        isFirstLoad = true
        exDelegate.delegate = self
        tableView.rowHeight = 70
        feedSegment.selectedSegmentIndex = 1
        //let crossBtnItem: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "plus"), style: .Plain, target: self, action: #selector(OpportunityDataVC.shareAction))
        let navBarActionBtn: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: #selector(LeadContentVC.shareAction))
        let navBarEditBtn = UIBarButtonItem(image: UIImage(named: "editImg-1"), style: .Plain, target: self, action: #selector(OpportunityDataVC.editAction))
        self.navigationItem.setRightBarButtonItems([navBarActionBtn,navBarEditBtn], animated: true)
        print(getResponseArr)
        self.isOpportunityDataNil()
        
    }
    
    func executeQuery()  {
        getResponseArr = exDelegate.resArr.objectAtIndex(parentIndex)
        self.isOpportunityDataNil()
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        if !isFirstLoad {
            exDelegate.leadQueryDe("opporchunity")
        }
        self.isFirstLoad = false
        dowloadAttachment()

    }
    
    
    func editAction() {
        let storyboard = UIStoryboard(name: "Main" , bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("CreateNewOpportunityVC") as! CreateNewOpportunityVC
        vc.opportunityDataDic = self.getResponseArr
        vc.flag = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func isOpportunityDataNil() {
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
        
        opportunityDataArr = [getResponseArr["Owner"]!!["Name"] as! String,
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
    
    
    func shareAction() {
        let actionSheet = UIActionSheet(title: "Choose Option", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Add Attachment", "Add Note")
        
        actionSheet.showInView(self.view)
        
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int)
    {
        print("\(buttonIndex)")
        switch (buttonIndex){
            
        case 0:
            print("Cancel")
        case 1:
            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            let nv = storyboard.instantiateViewControllerWithIdentifier("AttachViewController") as! AttachViewController
            nv.leadDetailInfo = getResponseArr;
            navigationController?.pushViewController(nv, animated: true)
            print("Save")
        case 2:
            let storyboard = UIStoryboard.init(name: "SubContentsViewController", bundle: nil)
            let nv = storyboard.instantiateViewControllerWithIdentifier("NoteViewController") as! NoteViewController
            //nv.leadDetailInfo = getResponseArr;
            nv.leadId = leadID
            navigationController?.pushViewController(nv, animated: true)
            
            print("Delete")
        default:
            print("Default")
            //Some code here..
            
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                return opportunityDataArr.count
                
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
                detailCell.titleLbl.text = self.cellTitleArr.objectAtIndex(indexPath.row) as? String
                detailCell.titleNameLbl.text = self.opportunityDataArr.objectAtIndex(indexPath.row) as? String
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
                tableView.rowHeight = 70
                let textFeedCell = tableView.dequeueReusableCellWithIdentifier("AttachCellID", forIndexPath: indexPath) as! NoteAndAttachFileCell
                textFeedCell.attachAndNoteFileName.text = attachmentArr.objectAtIndex(indexPath.row)["Title"] as? String
                let typeArr: AnyObject = attachmentArr.objectAtIndex(indexPath.row)["attributes"]
                textFeedCell.attachNoteFileSize.text = typeArr["type"] as? String
                return textFeedCell
            } else {
                tableView.rowHeight = 70
                let textFeedCell = tableView.dequeueReusableCellWithIdentifier("NoteCellID", forIndexPath: indexPath) as! NoteAndAttachFileCell
                textFeedCell.attachAndNoteFileName.text = noteArr.objectAtIndex(indexPath.row)["Name"] as? String
                let typeArr: AnyObject = noteArr.objectAtIndex(indexPath.row)["attributes"]
                textFeedCell.attachNoteFileSize.text = typeArr["type"] as? String
                return textFeedCell
            }
        } else {
            let fileContentName  = nullToNil(self.feedData.objectAtIndex(indexPath.row)["ContentFileName"])
            if fileContentName == nil {
                let textFeedCell = tableView.dequeueReusableCellWithIdentifier("textFeedCellID", forIndexPath: indexPath) as! AccountDataCell
                textFeedCell.feedDateStatus.text = self.feedData.objectAtIndex(indexPath.row)["CreatedDate"] as?
                String
                textFeedCell.totalLike.text = String(self.feedData.objectAtIndex(indexPath.row)["LikeCount"])
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
                feedCell.totalLike.text = String(self.feedData.objectAtIndex(indexPath.row)["LikeCount"])
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
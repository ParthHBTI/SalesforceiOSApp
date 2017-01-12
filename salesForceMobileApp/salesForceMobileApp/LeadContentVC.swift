import UIKit
import SalesforceRestAPI
import SalesforceNetwork
import SystemConfiguration
import MBProgressHUD


class LeadContentVC: UITableViewController, SFRestDelegate, ExecuteQueryDelegate, UIActionSheetDelegate,UpdateInfoDelegate {

    @IBOutlet weak var leadSegment: UISegmentedControl!
    //var getResponseArr:AnyObject = []
    var getResponseArr = [:]
    var leadID = String()
    var leadArr = NSMutableArray()
    var feedData: AnyObject = []
    var attachmentArr: AnyObject = []
    var noteArr: AnyObject = []
    var checkResponseType = false
    var coutFile = Int()
    var tempCell = LeadContentCell()
    var exDelegate: ExecuteQuery = ExecuteQuery()
    var delegate:UpdateInfoDelegate?
    var parentIndex:Int = 0
    var isOfflineData:Bool = false
    var isUpdatedSuccessfully:Bool = false
    var selectedSectionVal = Int()
    
    func nullToNil(value : AnyObject?) -> AnyObject? {
        if value is NSNull {
            return nil
        } else {
            return value
        }
    }
    
    @IBAction func leadAction(sender: AnyObject) {
        if leadSegment.selectedSegmentIndex == 0 {
            dispatch_async(dispatch_get_main_queue(), {
                let path: String =  "/services/data/v36.0/sobjects/Lead/\(self.leadID)/feeds"
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        configureTableView()
        dowloadAttachment()
        if isUpdatedSuccessfully {
            if exDelegate.isConnectedToNetwork() {
                exDelegate.leadQueryDe("lead")
            }
            let loading = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            loading.mode = MBProgressHUDMode.Text
            loading.detailsLabelText = "Updated Successfully!"
            loading.hide(true, afterDelay:2)
            loading.removeFromSuperViewOnHide = true
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
            /*exDelegate.leadQueryDe("lead")
            let loading = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            loading.mode = MBProgressHUDMode.Text
            loading.detailsLabelText = "Updated Successfully!"
            loading.removeFromSuperViewOnHide = true
            loading.hide(true, afterDelay:2)*/
        } else {
        }
        isUpdatedSuccessfully = false
    }
    
    
    func updateOfflineData(offlineData: NSMutableArray) {
        leadArr = offlineData
    }
    
    func updateOnlineData(offlineData: NSMutableArray) {
        leadArr = offlineData
    }
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.registerNib(UINib(nibName: "LeadContentCell", bundle: nil), forCellReuseIdentifier: "leadContentCellID")
        tableView.registerNib(UINib(nibName: "AccountDataCell", bundle: nil), forCellReuseIdentifier: "textFeedCellID")
        tableView.registerNib(UINib(nibName: "AccountDataImageCell", bundle: nil), forCellReuseIdentifier: "feedCellID")
        tableView.registerNib(UINib(nibName: "NoteFileCell", bundle: nil), forCellReuseIdentifier: "AttachCellID")
        tableView.registerNib(UINib(nibName: "AttachFileCell", bundle: nil), forCellReuseIdentifier: "NoteCellID")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Lead Detail"
        self.tableView.separatorColor = UIColor.clearColor()
        self.setNavigationBarItem()
        exDelegate.delegate = self
        leadSegment.selectedSegmentIndex = 1
        tableView.rowHeight = 70
        let nav = self.navigationController?.navigationBar
        nav!.barTintColor = UIColor.init(colorLiteralRed: 78.0/255, green: 158.0/255, blue: 255.0/255, alpha: 1.0)
        nav!.tintColor = UIColor.whiteColor()
        nav!.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        let navEditBtn = UIBarButtonItem(image: UIImage(named: "editImg-1"), style: .Plain, target: self, action:#selector(self.editAction))
        //let navEditBtn = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action:#selector(self.editAction))
        let navBarActionBtn: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: #selector(LeadContentVC.shareAction))
        self.navigationItem.setRightBarButtonItems([navBarActionBtn,navEditBtn], animated: true)
        isLeadDataNil()
    }
    
    
    func executeQuery() {
        getResponseArr = exDelegate.resArr.objectAtIndex(parentIndex) as! NSDictionary
        leadArr.removeAllObjects()
        self.isLeadDataNil()
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
        })
    }
    
    
    func updateInfo(flag: Bool ) {
        self.isUpdatedSuccessfully = flag
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
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                })
                
        })
        let attachQuery = "SELECT ContentType,CreatedDate, IsDeleted,IsPrivate,LastModifiedDate,Name FROM Attachment Where ParentId = '\(leadID)'"
        let attachReq = SFRestAPI.sharedInstance().requestForQuery(attachQuery)
        SFRestAPI.sharedInstance().sendRESTRequest(attachReq, failBlock: {
            erro in
            print(erro)
            }, completeBlock: { response in
                print(response)
                self.noteArr = response!["records"]
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                })
                
        })
        
    }
    
    func isLeadDataNil() {
        if isOfflineData {
            for (key, value) in getResponseArr{
                let objectDic = NSMutableDictionary()
                objectDic.setObject(key, forKey: KeyName)
                objectDic.setObject(value, forKey: KeyValue)
                leadArr.addObject(objectDic)
            }
        } else {
            for (key,val) in getResponseArr {
                if let _ = nullToNil(val) {
                    let objectDic = NSMutableDictionary()
                    if val is String {
                        objectDic.setObject(key, forKey: KeyName)
                        objectDic.setObject(val, forKey: KeyValue)
                    } else if key as! String == "Owner" {
                        objectDic.setObject(key, forKey: KeyName)
                        objectDic.setObject(val["Name"], forKey: KeyValue)
                    } else if key as! String == "attributes" {
                        objectDic.setObject(key, forKey: KeyName)
                        objectDic.setObject(val["type"], forKey: KeyValue)
                    }
                    leadArr.addObject(objectDic)
                }
            }
        }
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
            let attachmentVC = storyboard.instantiateViewControllerWithIdentifier("AttachViewController") as! AttachViewController
            attachmentVC.leadDetailInfo = getResponseArr;
            attachmentVC.offlineMode = !isOfflineData
            self.navigationController?.pushViewController(attachmentVC, animated: true)
        case 2:
            let storyboard = UIStoryboard.init(name: "SubContentsViewController", bundle: nil)
            let notesVC = storyboard.instantiateViewControllerWithIdentifier("NoteViewController") as! NoteViewController
            notesVC.leadId = leadID
            notesVC.noteDetailArr = leadArr //leadDataArr
            notesVC.noteDetailInfo = getResponseArr
            notesVC.SectionVal = selectedSectionVal
            self.navigationController?.pushViewController(notesVC, animated: true)
        default:
            print("Default")
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if leadSegment.selectedSegmentIndex == 1 {
            return 3
        } else {
            return 1
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if leadSegment.selectedSegmentIndex == 1 {
            
            switch (section) {
                
            case 0:
                return  leadArr.count //leadDataArr.count
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
    
    func getTimeFromString(index: Int, array: NSArray) -> String {
        if array.count != 0 {
            let str = array.objectAtIndex(index)["CreatedDate"] as? String
            let arrayWithTwoStrings = str!.componentsSeparatedByString("T")
            let StringsAfter = arrayWithTwoStrings[1]
            let timeStr = StringsAfter.componentsSeparatedByString(".")
            let timeSt = timeStr[0]
            return timeSt
        }
        return ""
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if leadSegment.selectedSegmentIndex == 1 {
            if indexPath.section == 0 {
                let detailCell = tableView.dequeueReusableCellWithIdentifier("leadContentCellID", forIndexPath: indexPath) as! LeadContentCell
                
                let objectDic = leadArr.objectAtIndex(indexPath.row)
                detailCell.titleLbl.text = objectDic[KeyName] as? String
                detailCell.titleNameLbl.text = objectDic[KeyValue] as? String
                if indexPath.row == 0 {
                    detailCell.titleNameLbl.textColor = self.navigationController?.navigationBar.barTintColor
                }
                if detailCell.titleNameLbl.text == "" {
                    tableView.rowHeight = 70
                } else {
                    tableView.rowHeight = 70
                }
                return detailCell
            } else if indexPath.section == 1 {
                tableView.rowHeight = 70
                let textFeedCell = tableView.dequeueReusableCellWithIdentifier("AttachCellID", forIndexPath: indexPath) as! NoteAndAttachFileCell
                
               textFeedCell.attachNoteTime.text = getTimeFromString(indexPath.row, array: attachmentArr as! NSArray)
                textFeedCell.attachAndNoteFileName.text = attachmentArr.objectAtIndex(indexPath.row)["Title"] as? String
                let typeArr: AnyObject = attachmentArr.objectAtIndex(indexPath.row)["attributes"]
                    textFeedCell.attachNoteFileSize.text = typeArr["type"] as? String
                textFeedCell.attachPhoto.backgroundColor = UIColor(hex: "FFD434" )
                textFeedCell.attachPhoto.layer.cornerRadius = 1.0
                return textFeedCell
            } else {
                tableView.rowHeight = 70
                
                let textFeedCell = tableView.dequeueReusableCellWithIdentifier("NoteCellID", forIndexPath: indexPath) as! NoteAndAttachFileCell
               textFeedCell.attachNoteTime.text = getTimeFromString(indexPath.row, array: noteArr as! NSArray)
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
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(LeadContentVC.tapOnImage(_:)))
                textFeedCell.likeImage.addGestureRecognizer(tapGesture)
                textFeedCell.commentImage.addGestureRecognizer(tapGesture)
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
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(LeadContentVC.tapOnImage(_:)))
                feedCell.likeImage.addGestureRecognizer(tapGesture)
                feedCell.commentImage.addGestureRecognizer(tapGesture)
                return feedCell
            }
        }
    }
    
    func tapOnImage(tap : UITapGestureRecognizer) {
        let tempcell = tap.view?.superview?.superview?.superview
        let indexPath : NSIndexPath?
        if tempcell is LeadContentCell {
            indexPath = self.tableView.indexPathForCell(tempcell as! LeadContentCell)
            checkResponseType = true
            UIView.animateWithDuration(10.0, animations: {
                let path =  "/services/data/v23.0/chatter/feed-items/\(self.feedData.objectAtIndex((indexPath?.row)!)["Id"])/likes"
                let request = SFRestRequest(method: SFRestMethod.POST, path: path, queryParams: nil)
                SFRestAPI.sharedInstance().sendRESTRequest(request, failBlock: { error in
                    print(error)
                    }, completeBlock: {response in
                        print(response)
                })
                self.checkResponseType = false
                
            })
            
        } else {
            indexPath = self.tableView.indexPathForCell(tempcell as! AccountDataCell)
            checkResponseType = true
            UIView.animateWithDuration(10.0, animations: {
                let path =  "/services/data/v23.0/chatter/feed-items/\(self.feedData.objectAtIndex((indexPath?.row)!)["Id"])/comments?text=Congragulation Dost"
                let request = SFRestRequest(method: SFRestMethod.POST, path: path, queryParams: nil)
                SFRestAPI.sharedInstance().sendRESTRequest(request, failBlock: { error in
                    print(error)
                    }, completeBlock: {response in
                        print(response)
                })
                self.checkResponseType = false
            })
        }
    }
    
    func editAction() {
        let storyboard = UIStoryboard.init(name: "SubContentsViewController", bundle: nil)
        let nv = storyboard.instantiateViewControllerWithIdentifier("CreateObjectViewController") as! CreateObjectViewController
        nv.objectType = "Lead"
        nv.objectInfoDic = self.getResponseArr.mutableCopy() as! NSMutableDictionary
        nv.isOffLine = isOfflineData
        nv.isEditable = true
        nv.delegate = self
        navigationController?.pushViewController(nv, animated: true)
    }
    
    /*func makeLeadDataArr(getLeadArr: NSDictionary) {
        
        var email = ""
        if  let _  = nullToNil( getLeadArr["Email"]) {
            email =  (getLeadArr["Email"] as? String)!
        }
        
        var phone = ""
        if  let _  = nullToNil( getLeadArr["Phone"]) {
            phone =  (getLeadArr["Phone"] as? String)!
        }
        
        var title = ""
        if  let _  = nullToNil( getLeadArr["Title"]) {
            title =  (getLeadArr["Title"] as? String)!
        }
        
        /*var salutation = ""
         if let _ = nullToNil(getResponseArr["Salutation"]) {
         salutation = (getResponseArr["Salutation"] as? String)!
         }*/
        
        /* var leadName = getResponseArr["Name"] as! String
         if salutation != "" {
         leadName = salutation + " " + (getResponseArr["Name"] as! String)
         }*/
        var leadName = ""
        if let _ = nullToNil(getLeadArr["Name"]) {
            leadName = (getLeadArr["Name"] as! String)
        }
        
        self.leadDataArr = [getLeadArr["Owner"]!["Name"] as! String,
                            leadName,
                            getLeadArr["Company"] as! String,
                            email,
                            phone,
                            title
        ]
    }*/
    
    
    func convertLead() {
        //        var request = SFRestRequest(method: post, path: "", queryParams: nil)
        //        request.endpoint = "/services/apexrest/{your endpoint}/{a lead Id}"
        //        SFRestAPI.sharedInstance().sendRESTRequest(request, failBlock: {(err: NSError) -> Void in
        //            print("error: \(err)")
        //            }, completeBlock: {(success: AnyObject) -> Void in
        //                print("success: \(success)")
        //        })
    }
    
    func request(request: SFRestRequest, didLoadResponse dataResponse: AnyObject) {
        //let attachmentID = dataResponse["id"] as! String
        if !checkResponseType {
            self.feedData = dataResponse["records"]
        }
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

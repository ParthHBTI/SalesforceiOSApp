import UIKit
import SalesforceRestAPI

class LeadContentVC: UITableViewController, SFRestDelegate {
    
    @IBOutlet weak var leadSegment: UISegmentedControl!
    var getResponseArr:AnyObject = []
    var leadID = String()
    var cellTitleArr: NSArray = ["Lead Owner:","Name:","Company:","Email:","Phone:","Title:","Fax:"]
    var leadDataArr = []
    var feedData: AnyObject = []
    
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
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationBarItem()
        leadSegment.selectedSegmentIndex = 1
        tableView.rowHeight = 70
        print(getResponseArr)
        let nav = self.navigationController?.navigationBar
        nav!.barTintColor = UIColor.init(colorLiteralRed: 78.0/255, green: 158.0/255, blue: 255.0/255, alpha: 1.0)
        nav!.tintColor = UIColor.whiteColor()
        nav!.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        //        let viewRecordingList: UIBarButtonItem = UIBarButtonItem(title: "Convert",style: .Plain, target: self, action: #selector(self.convertLead))
        //        self.navigationItem.setRightBarButtonItem(viewRecordingList, animated: true)
        let navEditBtn = UIBarButtonItem(title: "Edit", style: .Plain, target: self, action:#selector(self.editAction))
        let crossBtnItem: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "plus"), style: .Plain, target: self, action: #selector(LeadContentVC.shareAction))
        self.navigationItem.setRightBarButtonItems([crossBtnItem,navEditBtn], animated: true)
        
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
        
        /*var salutation = ""
         if let _ = nullToNil(getResponseArr["Salutation"]) {
         salutation = (getResponseArr["Salutation"] as? String)!
         }*/
        
        /* var leadName = getResponseArr["Name"] as! String
         if salutation != "" {
         leadName = salutation + " " + (getResponseArr["Name"] as! String)
         }*/
        var leadName = ""
        if let _ = nullToNil(getResponseArr["Name"]) {
            leadName = (getResponseArr["Name"] as! String)
        }
        
        leadDataArr = [getResponseArr["Owner"]!["Name"] as! String,
                       leadName,
                       getResponseArr["Company"] as! String,
                       email,
                       phone,
                       title
        ]
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func shareAction() {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let nv = storyboard.instantiateViewControllerWithIdentifier("AttachViewController") as! AttachViewController
        nv.leadDetailInfo = getResponseArr;
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
        if leadSegment.selectedSegmentIndex == 1 {
            return leadDataArr.count
        } else {
            return feedData.count
        }
        
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if leadSegment.selectedSegmentIndex == 1 {
            let detailCell = tableView.dequeueReusableCellWithIdentifier("leadContentCellID", forIndexPath: indexPath) as! LeadContentCell
            detailCell.titleLbl.text = self.cellTitleArr.objectAtIndex(indexPath.row) as? String
            detailCell.titleNameLbl.text = self.leadDataArr.objectAtIndex(indexPath.row) as? String
            if indexPath.row == 0 {
                detailCell.titleNameLbl.textColor = self.navigationController?.navigationBar.barTintColor
            }
            
            if detailCell.titleNameLbl.text == "" {
                tableView.rowHeight = 40
            } else {
                tableView.rowHeight = 70
            }
            return detailCell
            
        } else {
            let fileContentName  = nullToNil(self.feedData.objectAtIndex(indexPath.row)["ContentFileName"])
            if fileContentName == nil {
                 let textFeedCell = tableView.dequeueReusableCellWithIdentifier("textFeedCellID", forIndexPath: indexPath) as! LeadContentCell
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
    
    func editAction() {
        let storyboard = UIStoryboard(name: "Main" , bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("CreateNewLeadVC") as! CreateNewLeadVC
        vc.leadDataDict = self.getResponseArr 
        vc.flag = true
        self.navigationController?.pushViewController(vc, animated: true)
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

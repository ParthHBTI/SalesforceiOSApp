//
//  AttachViewController.swift
//  salesForceMobileApp
//
//  Created by mac on 07/11/16.
//  Copyright © 2016 Salesforce. All rights reserved.
//

import UIKit
import SalesforceRestAPI
class AttachViewController: UIViewController, UIPopoverPresentationControllerDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate, SFRestDelegate  {
    var leadDetailInfo:AnyObject = []
    var leadId = ""
    
@IBOutlet weak var imageView: UIImageView!
let imagePicker = UIImagePickerController()
    
    
    func nullToNil(value : AnyObject?) -> AnyObject? {
        if value is NSNull {
            return nil
        } else {
            return value
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "New Post"
        imagePicker.delegate = self
        let shareBarButton:UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "share"), style: .Plain, target: self, action: #selector(AttachViewController.shareAction))
        self.navigationItem.setRightBarButtonItem(shareBarButton, animated: true)
        

        if let _ = nullToNil(leadDetailInfo["Id"]) {
            leadId = (leadDetailInfo["Id"] as? String)!
        }
        
        
    }

       override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func shareAction() {
        let paramDict:AnyObject = []
        let method: SFRestMethod = SFRestMethod.POST
        let reqs = SFRestRequest.init(method: method, path: "", queryParams: paramDict as? [String : String])
        reqs.endpoint = "/services/data/v36.0/sobjects/Lead/06928000002vMyw/feeds"
        let fileStr = NSBundle.mainBundle().pathForResource("swift_iOS_app_developers", ofType: "jpg")
        reqs.addPostFileData(NSData(contentsOfFile: fileStr!)! , paramName: "feedElemntsFileUpload", fileName: "Feed File", mimeType: "image/jpg")
        reqs.customHeaders =  [ "Content-Type" : "multipart/form-data" ]
        SFRestAPI.sharedInstance().send(reqs, delegate: self)
        let entID = SFUserAccountManager.sharedInstance().currentUser?.idData.orgId
        let req = SFRestAPI.sharedInstance().requestForAddFileShare(entID!, entityId: entID!, shareType: "V")
         SFRestAPI.sharedInstance().send(req, delegate: self)
    }
    
    
    func createFeedForAttachment(field: String) {
    let entID = SFUserAccountManager.sharedInstance().currentUser?.idData.userId
        let req = SFRestAPI.sharedInstance().requestForAddFileShare(field, entityId: entID!, shareType: "V")
//        let res = SFRestAPI.sharedInstance().requestForFileShares(entID!, page: 1)
//          SFRestAPI.sharedInstance().send(res, delegate: self)
        SFRestAPI.sharedInstance().send(req, delegate: self)
        
    }
    
    func createFeedForAttachmentId(attachmentId: String) {
        let filePath = NSBundle.mainBundle().pathForResource("feedTemplate", ofType: "json")!
        let url = NSURL.fileURLWithPath(filePath)
        let feedJSONTemplateData = try! NSData(contentsOfURL: url, options: NSDataReadingOptions.DataReadingMappedIfSafe)
        var feedJSONTemplateStr = String(data: feedJSONTemplateData, encoding: NSUTF8StringEncoding)
        feedJSONTemplateStr = feedJSONTemplateStr!.stringByReplacingOccurrencesOfString("__BODY_TEXT__", withString: "__kloudrac_softwares__")
        feedJSONTemplateStr = feedJSONTemplateStr!.stringByReplacingOccurrencesOfString("__ATTACHMENT_ID__", withString: attachmentId)
//        feedJSONTemplateStr = feedJSONTemplateStr!.stringByReplacingOccurrencesOfString("__Parent_Id__", withString: leadId)
        let data = feedJSONTemplateStr!.dataUsingEncoding(NSUTF8StringEncoding)
        let jsonObj: AnyObject = try! NSJSONSerialization.JSONObjectWithData(data!, options: []) as! [String:AnyObject]
        //var path: String =  "/%@/chatter/feeds/record/%@/feed-items/"
      let api = SFRestAPI.sharedInstance()
        let path: String = "/services/data/v23.0/chatter/feeds/to/me/feed-items"

     let request = SFRestRequest(method: SFRestMethod.POST , path: path, queryParams: jsonObj as? [String : String])
       // let method = SFRestMethod.POST
        //let req = SFRestRequest.init(method: method, path: path, queryParams: jsonObj as? [String : String]
        
        SFRestAPI.sharedInstance().send(request, delegate: self)
    }
    
    @IBAction func attachPopOver(sender: AnyObject) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            imageView.image = pickedImage
            let imageData: NSData = UIImageJPEGRepresentation(pickedImage, 0.1)!
            let req = SFRestAPI.sharedInstance().requestForUploadFile(imageData, name: "swift_iOS_app_developers.jpg", description: "Share Image", mimeType: "image/jpeg")
//            req.setHeaderValue(leadId, forHeaderName: "ParentId")
//           req.setCustomRequestBodyData( leadId.dataUsingEncoding(NSUTF8StringEncoding)!, contentType: "ParentId")
//            req.addPostFileData(imageData, paramName: "fileData", fileName: "swift_iOS_app_developers.jpg", mimeType: "image/jpg/png")
            SFRestAPI.sharedInstance().send(req, delegate: self)
      
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func request(request: SFRestRequest, didLoadResponse dataResponse: AnyObject) {
        if request.method == SFRestMethod.POST {
            let range = (request.path as NSString).rangeOfString("/feed-items")
            if range.location == NSNotFound {
                createFeedForAttachmentId(dataResponse.objectForKey("id") as! String)
            } else {
                dispatch_async(dispatch_get_main_queue(), {() -> Void in
                    self.presentingViewController!.presentingViewController!.dismissViewControllerAnimated(true, completion: { _ in })
                })

            }
        }
//        let attachmentId = (dataResponse["id"] as! String)
//        createFeedForAttachmentId(attachmentId)
    }
    
//    func request(request: SFRestRequest, didLoadResponse dataResponse: AnyObject) {
//        let attachmentId = dataResponse.valueForKey("id") as! String
//        let range = (request.path as NSString).rangeOfString("/feed-items")
//        //Note: this request:didLoadResponse is called for both Attachment upload and create feedItem.
//        //So we need to distinguish b/w the two and take appropriate action
//        if range.location == NSNotFound {
//            //Just uploaded image but not associated it to a feed item, so create feedItem w/ attachment.
//            self.createFeedForAttachmentId(attachmentId)
//        }
//        else {
//            dispatch_async(dispatch_get_main_queue(), {() -> Void in
//                self.presentingViewController!.presentingViewController!.dismissViewControllerAnimated(true, completion: { _ in })
//            })
//        }
//    }
    
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

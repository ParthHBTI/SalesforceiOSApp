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
    
@IBOutlet weak var imageView: UIImageView!
let imagePicker = UIImagePickerController()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "New Post"
        imagePicker.delegate = self
        let shareBarButton:UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "share"), style: .Plain, target: self, action: #selector(AttachViewController.shareAction))
        self.navigationItem.setRightBarButtonItem(shareBarButton, animated: true)
    
    }

       override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func shareAction() {
        let paramDict:AnyObject = []
        let method: SFRestMethod = SFRestMethod.POST
        let reqs = SFRestRequest.init(method: method, path: "", queryParams: paramDict as? [String : String])
        reqs.endpoint = "/services/data/v36.0/sobjects/Lead/00Q2800000SSZY6EAP/feed-items/"
        let fileStr = NSBundle.mainBundle().pathForResource("swift_iOS_app_developers", ofType: "jpg")
        reqs.addPostFileData(NSData(contentsOfFile: fileStr!)! , paramName: "feedElemntsFileUpload", fileName: "Feed File", mimeType: "image/jpg")
        reqs.customHeaders =  [ "Content-Type" : "multipart/form-data" ]
        SFRestAPI.sharedInstance().send(reqs, delegate: self)
        let entID = SFUserAccountManager.sharedInstance().currentUser?.idData.orgId
        let req = SFRestAPI.sharedInstance().requestForAddFileShare(entID!, entityId: entID!, shareType: "V")
         SFRestAPI.sharedInstance().send(req, delegate: self)
    }
    
     func request(request: SFRestRequest, didLoadResponse dataResponse: AnyObject) {
        if request.method == SFRestMethod.POST {
        createFeedForAttachment(dataResponse.objectForKey("id") as! String)
        }
        let attachmentId = (dataResponse["id"] as! String)
         createFeedForAttachmentId(attachmentId)
    }
    
    func createFeedForAttachment(field: String) {
    let entID = SFUserAccountManager.sharedInstance().currentUser?.idData.orgId
        let req = SFRestAPI.sharedInstance().requestForAddFileShare(field, entityId: entID!, shareType: "V")
        SFRestAPI.sharedInstance().send(req, delegate: self)
        
    }
    
    func createFeedForAttachmentId(attachmentId: String) {
        let filePath = NSBundle.mainBundle().pathForResource("feedTemplate", ofType: "json")!
        let url = NSURL.fileURLWithPath(filePath)
        let feedJSONTemplateData = try! NSData(contentsOfURL: url, options: NSDataReadingOptions.DataReadingMappedIfSafe)
        var feedJSONTemplateStr = String(data: feedJSONTemplateData, encoding: NSUTF8StringEncoding)
        feedJSONTemplateStr = feedJSONTemplateStr!.stringByReplacingOccurrencesOfString("__BODY_TEXT__", withString: "kloudrac")
        feedJSONTemplateStr = feedJSONTemplateStr!.stringByReplacingOccurrencesOfString("__ATTACHMENT_ID__", withString: attachmentId)
        let data = feedJSONTemplateStr!.dataUsingEncoding(NSUTF8StringEncoding)
        let jsonObj: AnyObject = try! NSJSONSerialization.JSONObjectWithData(data!, options: []) as! [String:AnyObject]
        let method = SFRestMethod.POST
        let path: String = "/services/data/v36.0/sobjects/Lead/00Q2800000SSZY6EAP/feed-items/"
        let request = SFRestRequest.init(method: method, path: path, queryParams: jsonObj as? [String : String])
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
            let imageData: NSData = UIImageJPEGRepresentation(pickedImage, 0.0)!
            let req = SFRestAPI.sharedInstance().requestForUploadFile(imageData, name: "swift_iOS_app_developers.jpg", description: "Share Image", mimeType: "image/jpg")
            SFRestAPI.sharedInstance().send(req, delegate: self)
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    }

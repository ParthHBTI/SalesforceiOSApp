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
        var image = UIImage()
        image = imageView.image!
        //let imageData = UIImageJPEGRepresentation(image, 1.0)
        
//        let request = SFRestAPI.sharedInstance().requestForUploadFile(imageData!, name: "plus.png", description: "Test Img", mimeType: "image/png")
//        SFRestAPI.sharedInstance().send(request, delegate: self)
//        print(request)

//       let entID = SFUserAccountManager.sharedInstance().currentUser?.idData.orgId
//        let req = SFRestAPI.sharedInstance().requestForAddFileShare(entID!, entityId: entID!, shareType: "V")
//         SFRestAPI.sharedInstance().send(req, delegate: self)
    }
    
     func request(request: SFRestRequest, didLoadResponse dataResponse: AnyObject) {
        if request.method == SFRestMethod.POST {
            shareFile(dataResponse.objectForKey("id") as! String)
        } else {
            print("")
        }
        let attachmentId = (dataResponse["id"] as! String)
        let range = (request.path as NSString).rangeOfString("/feed-items")
         createFeedForAttachmentId(attachmentId)
    }
    
    func shareFile(field: String) {
    let entID = SFUserAccountManager.sharedInstance().currentUser?.idData.orgId
        let req = SFRestAPI.sharedInstance().requestForAddFileShare(field, entityId: entID!, shareType: "V")
        SFRestAPI.sharedInstance().send(req, delegate: self)
    }
    
    
    func createFeedForAttachmentId(attachmentId: String) {
//        let filePath = NSBundle.mainBundle().pathForResource("feedTemplate", ofType: "json")!
//        let url = NSURL.fileURLWithPath(filePath)
//        let error: NSError? = nil
//        let feedJSONTemplateData = try! NSData(contentsOfURL: url, options: NSDataReadingOptions.DataReadingMappedIfSafe)
//        var feedJSONTemplateStr = String(data: feedJSONTemplateData, encoding: NSUTF8StringEncoding)
//        feedJSONTemplateStr = feedJSONTemplateStr!.stringByReplacingOccurrencesOfString("__BODY_TEXT__", withString: "kloudrac")
//        feedJSONTemplateStr = feedJSONTemplateStr!.stringByReplacingOccurrencesOfString("__ATTACHMENT_ID__", withString: attachmentId)
//        let data = feedJSONTemplateStr!.dataUsingEncoding(NSUTF8StringEncoding)
//        if let jsonObj: AnyObject = try! NSJSONSerialization.JSONObjectWithData(data!, options: []) as? [String:AnyObject] {
//            if let dict = jsonObj as? NSDictionary {
//                print(dict)
//            } else {
//                print("not a dictionary")
//            }
//        } else {
//            print("Could not parse JSON: \(error!)")
//        }
//        let api = SFRestAPI.sharedInstance()
//        _ = "/\(api.apiVersion)/chatter/feeds/record//feed-items/"
//        
//        
 
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
            let req = SFRestAPI.sharedInstance().requestForUploadFile(imageData, name: "TestImage.png", description: "Share Image", mimeType: "image/png")
            SFRestAPI.sharedInstance().send(req, delegate: self)
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    }

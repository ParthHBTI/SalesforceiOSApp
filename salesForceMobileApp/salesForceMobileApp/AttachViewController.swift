//
//  AttachViewController.swift
//  salesForceMobileApp
//
//  Created by mac on 07/11/16.
//  Copyright © 2016 Salesforce. All rights reserved.
//

import UIKit
import SalesforceRestAPI
import MBProgressHUD
var attachOfflineDic =  NSMutableDictionary()
var attachOnlineDic =  NSMutableDictionary()

class AttachViewController: UIViewController, UIPopoverPresentationControllerDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate, SFRestDelegate, UITextViewDelegate, ExecuteQueryDelegate  {
    var leadDetailInfo:AnyObject = []
    var leadId = ""
    var imagesDirectoryPath:String!
    var imagesDirectoryPathOfflineObj: String!
    var checkButton = false
    var offlineMode = false
    @IBOutlet weak var attachTextView: UITextView!
    var exDelegate: ExecuteQuery = ExecuteQuery()
    @IBOutlet weak var checkUncheckBtn: UIButton!
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
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentDirectorPath:String = paths[0]
        var objcBool:ObjCBool = true
//        if Section == 0 {
//            if let arrayOfObjectsData = defaults.objectForKey(offAttachmentForOffObjKey) as? NSData {
//                attachmentForOfflinObjDic = NSKeyedUnarchiver.unarchiveObjectWithData(arrayOfObjectsData)! as! NSMutableDictionary
//            }
//            imagesDirectoryPathOfflineObj = documentDirectorPath.stringByAppendingString("/AttachmentForOfflineObj")
//            let isExists = NSFileManager.defaultManager().fileExistsAtPath(imagesDirectoryPathOfflineObj, isDirectory: &objcBool)
//            if isExists == false{
//                do{
//                    try NSFileManager.defaultManager().createDirectoryAtPath(imagesDirectoryPathOfflineObj, withIntermediateDirectories: true, attributes: nil)
//                }catch{
//                    print("Something went wrong while creating a new folder")
//                }
//            }
//        } else {
            if let arrayOfObjectsData = defaults.objectForKey(offlineAttachKey) as? NSData {
                attachOfflineDic = NSKeyedUnarchiver.unarchiveObjectWithData(arrayOfObjectsData)! as! NSMutableDictionary
            }
        if let arrayOfObjectsData = defaults.objectForKey(onlineAttachKey) as? NSData {
            attachOnlineDic = NSKeyedUnarchiver.unarchiveObjectWithData(arrayOfObjectsData)! as! NSMutableDictionary
        }
            imagesDirectoryPath = documentDirectorPath.stringByAppendingString("/Attachment")
            let isExists = NSFileManager.defaultManager().fileExistsAtPath(imagesDirectoryPath, isDirectory: &objcBool)
            if isExists == false{
                do{
                    try NSFileManager.defaultManager().createDirectoryAtPath(imagesDirectoryPath, withIntermediateDirectories: true, attributes: nil)
                }catch{
                    print("Something went wrong while creating a new folder")
                }
            }
        //}
        checkUncheckBtn.layer.cornerRadius = 5
        checkUncheckBtn.layer.borderWidth = 1
        attachTextView.delegate = self
        checkUncheckBtn.layer.borderColor = UIColor.blackColor().CGColor
        imagePicker.delegate = self
        
        /* let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
         let documentDirectorPath:String = paths[0]
         imagesDirectoryPath = documentDirectorPath.stringByAppendingString("/Attachment")
         var objcBool:ObjCBool = true
         let isExist = NSFileManager.defaultManager().fileExistsAtPath(imagesDirectoryPath, isDirectory: &objcBool)
         if isExist == false{
         do{
         try NSFileManager.defaultManager().createDirectoryAtPath(imagesDirectoryPath, withIntermediateDirectories: true, attributes: nil)
         }catch{
         print("Something went wrong while creating a new folder")
         }
         }*/
        
        let borderColor = UIColor(red: 204.0 / 255.0, green: 204.0 / 255.0, blue: 204.0 / 255.0, alpha: 1.0)
        attachTextView.layer.borderColor = borderColor.CGColor
        attachTextView.layer.borderWidth = 1.0
        attachTextView.layer.cornerRadius = 5.0
        let shareBarButton = UIBarButtonItem(title: "Share", style: .Plain, target: self, action: #selector(AttachViewController.shareAction))
        self.navigationItem.setRightBarButtonItem(shareBarButton, animated: true)
        if let _ = nullToNil(leadDetailInfo["Id"]) {
            leadId = (leadDetailInfo["Id"] as? String)!
        }
    }
    
    @IBAction func checkPrivateAction(sender: AnyObject) {
        if !checkButton {
            checkButton = true
            checkUncheckBtn.setImage(UIImage(named: "checkUncheck"), forState: UIControlState.Normal)
        } else {
            checkButton = false
            checkUncheckBtn.setImage(nil, forState: UIControlState.Normal)
        }
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        self.attachTextView.text = nil
        return true
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func textFieldDoneClicked(sender: AnyObject) {
        self.view.endEditing(true)
    }
    
    
    func shareAction() {
        self.view.endEditing(true)
        if imageView.image == nil {
            let alert = UIAlertView.init(title: "Error", message: "Please attach image first." , delegate: self, cancelButtonTitle: "OK")
            alert.show()
            return;
        }
        let imageData: NSData = UIImageJPEGRepresentation(imageView.image!, 0.1)!
        let b64 = imageData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.EncodingEndLineWithLineFeed)
        print(b64)
        let fields = [
            "Name": "k4",
            "Body": b64,
            "ParentId":leadId
        ]
        if !exDelegate.isConnectedToNetwork() {
            if offlineMode {
                var attachedArr = attachOnlineDic[leadId]
                if let _ = attachedArr {
                    attachedArr = attachedArr?.mutableCopy() as? NSMutableArray
                } else {
                    attachedArr = NSMutableArray()
                }
                attachedArr?.addObject(fields)
                print(fields.indexForKey("Body"))
                attachOnlineDic.setObject(attachedArr!, forKey: leadId)
                defaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(attachOnlineDic), forKey: onlineAttachKey)
            } else  {
                var attachedArr = attachOfflineDic[leadId]
                if let _ = attachedArr {
                    attachedArr = attachedArr?.mutableCopy() as? NSMutableArray
                } else {
                    attachedArr = NSMutableArray()
                }
                attachedArr?.addObject(fields)
                attachOfflineDic.setObject(attachedArr!, forKey: leadId)
                defaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(attachOfflineDic), forKey: offlineAttachKey)
            }
                var imagePath = NSDate().description
                imagePath = imagePath.stringByReplacingOccurrencesOfString(" ", withString: "")
                imagePath = imagesDirectoryPath.stringByAppendingString("/\(imagePath).png")
                let success =  NSFileManager.defaultManager().createFileAtPath(imagePath as String, contents: imageData, attributes: nil)
                if success {
                    self.navigationController?.popViewControllerAnimated(true)
                }else {
                    print("Something went wrong")
                }
            } else {
            let loading = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            loading.mode = MBProgressHUDMode.Indeterminate
            SFRestAPI.sharedInstance().performCreateWithObjectType("Attachment", fields: fields, failBlock: { err in
                dispatch_async(dispatch_get_main_queue(), {
                    let alert = UIAlertView.init(title: "Error", message: err?.localizedDescription , delegate: self, cancelButtonTitle: "OK")
                    alert.show()
                })
                print( (err))
            }) { succes in
                dispatch_async(dispatch_get_main_queue(), {
                    let loading = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                    loading.hide(true, afterDelay: 2)
                    loading.removeFromSuperViewOnHide = true
                    self.navigationController?.popViewControllerAnimated(true)
                })
            }
        }
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
        let path: String = "/services/data/v36.0/chatter/groups/00D28000001acWmEAI/photos"
        //let getSessionId = SFUserAccountManager.sharedInstance().currentUser?.idData.userId
        let request = SFRestRequest(method: SFRestMethod.POST , path: path, queryParams: jsonObj as? [String : String])
        request.setHeaderValue("Authorization", forHeaderName: "OAuth " )
        request.setHeaderValue("Content-Type:", forHeaderName: "application/json");
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
            
            
            //          let imageData: NSData = UIImageJPEGRepresentation(pickedImage, 0.1)!
            //            let req = SFRestAPI.sharedInstance().requestForUploadFile(imageData, name: "swift_iOS_app_developers.jpg", description: "Share Image", mimeType: "image/jpeg")
            //
            //            SFRestAPI.sharedInstance().send(req, delegate: self)
            
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func request(request: SFRestRequest, didLoadResponse dataResponse: AnyObject) {
        
        print(dataResponse);
        /*
         if request.method == SFRestMethod.POST {
         let range = (request.path as NSString).rangeOfString("/feed-items")
         if range.location == NSNotFound {
         createFeedForAttachmentId(dataResponse.objectForKey("id") as! String)
         } else {
         dispatch_async(dispatch_get_main_queue(), {() -> Void in
         self.presentingViewController!.presentingViewController!.dismissViewControllerAnimated(true, completion: { _ in })
         })
         
         }
         }*/
        //        let attachmentId = (dataResponse["id"] as! String)
        //        createFeedForAttachmentId(attachmentId)
    }
    
    
    
    
    func oauthCoordinator(coordinator: SFOAuthCoordinator, didFailWithError error: NSError?) {
        print("oauthCoordinator:didFailWithError: \(error)")
        coordinator.view.removeFromSuperview()
        if error!.code == kSFOAuthErrorInvalidGrant {
            print("Logging out because oauth failed with error code: \(error!.code)")
        }
        else if error!.code == kSFOAuthErrorAccessDenied {
            print("Logging out because AccessDenied error code: \(error!.code)")
            self.performSelector(#selector(SFUserAccountManager.log(_:msg:) ), withObject: nil, afterDelay: 0)
        }
        else {
            let alert = UIAlertView(title: "Salesforce Error", message: "Can't connect to salesforce: \(error)", delegate: self, cancelButtonTitle: "Retry")
            alert.show()
        }
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
    
    func request(request: SFRestRequest, didFailLoadWithError error: NSError){
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
/*
 
 
 func saherAction2()  {
 let imageData = UIImagePNGRepresentation(imageView.image!)
 
 if imageData != nil{
 let request = NSMutableURLRequest(URL: NSURL(string:"https://ap1.salesforce.com/services/data/v35.0/chatter/feeds/news/me/feed-items")!)
 
 var messgeDic = ["body":["messageSegments":[["text":"Mesaage","type":"Text"]],"feedElementType":"FeedItem","subjectId":"00Q2800000Q751L"]]
 
 //  {"body":{"messageSegments":[{"text":"this is the body ","type":"text"},{"type":"mention","id":"005U0000000GIQkIAO"}]},"attachment":{"title":"this is the file name","desc":"this is the file description","fileName":"Screen shot 2012-05-19 at 4.11.12 PM.png"}}
 
 
 
 request.HTTPMethod = "POST"
 
 let boundary = NSString(format: "---------------------------14737809831466499882746641449")
 let contentType = NSString(format: "multipart/form-data; boundary=%@",boundary)
 //  println("Content Type \(contentType)")
 request.addValue(contentType as String, forHTTPHeaderField: "Content-Type")
 
 var body = NSMutableData()
 
 // Title
 body.appendData(NSString(format: "\r\n--%@\r\n",boundary).dataUsingEncoding(NSUTF8StringEncoding)!)
 body.appendData(NSString(format:"Content-Disposition: form-data; name=\"title\"\r\n\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
 body.appendData("Hello World".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
 
 // Image
 body.appendData(NSString(format: "\r\n--%@\r\n", boundary).dataUsingEncoding(NSUTF8StringEncoding)!)
 body.appendData(NSString(format:"Content-Disposition: form-data; name=\"feedItemFileUpload\"; filename=\"img.jpg\"\\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
 body.appendData(NSString(format: "Content-Type: application/octet-stream\r\n\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
 body.appendData(imageData!)
 body.appendData(NSString(format: "\r\n--%@\r\n", boundary).dataUsingEncoding(NSUTF8StringEncoding)!)
 request.HTTPBody = body
 
 var response: NSURLResponse?
 let urlData = try? NSURLConnection.sendSynchronousRequest(request, returningResponse: &response)
 
 //            [formData appendPartWithFileData:attachData name:@"feedItemFileUpload" fileName:@"photo.jpg" mimeType:@"image/jpeg"];
 
 
 
 let results = NSString(data:urlData!, encoding:NSUTF8StringEncoding)
 print("API Response: \(results)")
 
 
 }
 
 
 }
 
 
 func saherAction1()  {
 
 
 /*
 AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer new];
 
 NSMutableURLRequest *req = [serializer multipartFormRequestWithMethod:@"POST" URLString:@"フルURL" parameters:nil constructingBodyWithBlock:^(AFMultipartFormData *data) {
 // このブロック内でmultipart/form-dataに追加したいpartを必要数分追加する
 
 
 // NSData *attachData = // 添付するファイルのバイナリデータ
 [formData appendPartWithFileData:attachData name:@"feedItemFileUpload" fileName:@"photo.jpg" mimeType:@"image/jpeg"];
 
 // 投稿の情報はJSONで別のpartとして追加
 NSMutableDictionary *segments = @{}.mutableCopy;
 NSMutableDictionary *body = @{@"body":@{@"messageSegments":segments}}.mutableCopy;
 [segments addObject:@{
 @"type":@"Text",
 @"text":@"投稿したいテキスト"
 }];
 
 body[@"attachment"] = @{
 @"attachmentType":@"NewFile",
 @"title":@"Photo"
 };
 
 NSData *json = [NSJSONSerialization dataWithJSONObject:body options: NSJSONWritingPrettyPrinted error: nil];
 [data appendPartWithHeaders:@{@"Content-Disposition":@"form-data; name=\"json\"", @"Content-Type":@"application/json; charset=UTF-8"} body:json];
 } error:nil];
 
 // 実際の呼び出し部分
 AFHTTPRequestOperationManager *http = [AFHTTPRequestOperationManager new];
 http.requestSerializer = serializer;
 [serializer setValue:[NSString stringWithFormat:@"Bearer %@", accessToken] forHTTPHeaderField:@"Authorization"]; // 自前でAccessTokenを指定してやる
 http.responseSerializer = [AFJSONResponseSerializer new];
 
 AFHTTPRequestOperation *ope = [http HTTPRequestOperationWithRequest:req success:^(AFHTTPRequestOperation *operation, id responseObject) {
 // 成功時の処理
 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
 // 失敗時の処理
 }];
 
 // 忘れがち。別スレッドで実行開始！
 [ope start];*/
 }
 
 */
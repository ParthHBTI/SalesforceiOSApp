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
        
        let shareBarButton = UIBarButtonItem(title: "Share", style: .Plain, target: self, action: #selector(AttachViewController.shareAction))
        
        self.navigationItem.setRightBarButtonItem(shareBarButton, animated: true)
        

        if let _ = nullToNil(leadDetailInfo["Id"]) {
            leadId = (leadDetailInfo["Id"] as? String)!
        }
        
        
    }

       override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func saherAction2()  {
        let imageData = UIImagePNGRepresentation(imageView.image!)
        
        if imageData != nil{
            let request = NSMutableURLRequest(URL: NSURL(string:"Enter Your URL")!)
            var session = NSURLSession.sharedSession()
            
            request.HTTPMethod = "POST"
            
            var boundary = NSString(format: "---------------------------14737809831466499882746641449")
            var contentType = NSString(format: "multipart/form-data; boundary=%@",boundary)
            //  println("Content Type \(contentType)")
            request.addValue(contentType as String, forHTTPHeaderField: "Content-Type")
            
            var body = NSMutableData()
            
            // Title
            body.appendData(NSString(format: "\r\n--%@\r\n",boundary).dataUsingEncoding(NSUTF8StringEncoding)!)
            body.appendData(NSString(format:"Content-Disposition: form-data; name=\"title\"\r\n\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
            body.appendData("Hello World".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
            
            // Image
            body.appendData(NSString(format: "\r\n--%@\r\n", boundary).dataUsingEncoding(NSUTF8StringEncoding)!)
            body.appendData(NSString(format:"Content-Disposition: form-data; name=\"profile_img\"; filename=\"img.jpg\"\\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
            body.appendData(NSString(format: "Content-Type: application/octet-stream\r\n\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
            body.appendData(imageData!)
            body.appendData(NSString(format: "\r\n--%@\r\n", boundary).dataUsingEncoding(NSUTF8StringEncoding)!)
            request.HTTPBody = body
            
            var response: NSURLResponse?
            let urlData = try? NSURLConnection.sendSynchronousRequest(request, returningResponse: &response)

            
            
            
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
    
    func shareAction() {
     /*
        SFRestMethod method = SFRestMethodPOST;
        SFRestRequest *request = [SFRestRequest requestWithMethod:method path:nil queryParams:paramDict];
        request.endpoint = @"/services/data/v33.0/connect/communities/0DB28000000Cafi/chatter/feed-elements";
        
        NSString *filestr= [[NSBundle mainBundle] pathForResource:@"Pic" ofType:@"png"];
        [request addPostFileData:[NSData dataWithContentsOfFile:filestr] paramName:@"feedElementFileUpload" fileName:@"test.png" mimeType:@"image/png"];
        [request setCustomHeaders:[NSDictionary dictionaryWithObject:@"multipart/form-data" forKey:@"Content-Type"]];
        [[SFRestAPI sharedInstance] send:request delegate:self];
         
         {
         body = {
         messageSegments = (
         {
         text = "test msg";
         type = Text;
         }
         );
         };
         capabilities = {
         content = {
         description = "Test image";
         title = "test.png";
         };
         };
         feedElementType = FeedItem;
         subjectId = 00Q2800000Q751L;
         }
*/
        let paramDict:AnyObject = ["feedElementType":"FeedItem","subjectId":"me","parentId":"00Q2800000Q751L"]

        
      //  let paramDict:AnyObject = ["body":"{\"feedElementType\" = \"FeedItem\",\"subjectId\" = \"00Q2800000Q751L\"}"]
            //["body":["messageSegments":[["text":"Mesaage","type":"Text"]],"feedElementType":"FeedItem","subjectId":"00Q2800000Q751L"]]
        let method: SFRestMethod = SFRestMethod.POST
        let reqs = SFRestRequest.init(method: method, path: "", queryParams: paramDict as? [String : String])
        reqs.endpoint = "/services/data/v35.0/chatter/feed-elements"
        
        let imageData: NSData = UIImageJPEGRepresentation(imageView.image!, 0.1)!
       // let fileStr = NSBundle.mainBundle().pathForResource("swift_iOS_app_developers", ofType: "jpg")
        reqs.addPostFileData(imageData , paramName: "feedElementFileUpload", fileName: "Feed File", mimeType: "image/jpg")
        reqs.customHeaders =  [ "Content-Type" : "multipart/form-data;" ]
       // reqs.customHeaders =  [ "Accept" : "application/json" ]
        

        SFRestAPI.sharedInstance().send(reqs, delegate: self)
        
       // [[SFRestAPI sharedInstance] sendRew]
//        let entID = SFUserAccountManager.sharedInstance().currentUser?.idData.orgId
//        let req = SFRestAPI.sharedInstance().requestForAddFileShare(entID!, entityId: entID!, shareType: "V")
//         SFRestAPI.sharedInstance().send(req, delegate: self)
    }
    
    
    func createFeedForAttachment(field: String) {
    let entID = SFUserAccountManager.sharedInstance().currentUser?.idData.userId
        let req = SFRestAPI.sharedInstance().requestForAddFileShare(field, entityId: entID!, shareType: "V")
//        let res = SFRestAPI.sharedInstance().requestForFileShares(entID!, page: 1)
//          SFRestAPI.sharedInstance().send(res, delegate: self)
        SFRestAPI.sharedInstance().send(req, delegate: self)
        
    }
    
    func createFeedForAttachmentId(attachmentId: String) {
        //Load json template from "feedTemplate.json" file as a string. Then replace __BODY_TEXT__ and __ATTACHMENT_ID__ w/
        // addPostTextField.text and attachmentId and pass that to post to chatter feed.
        //    {
        //        "body": {
        //            "messageSegments": [
        //                                {
        //                                    "type": "Text",
        //                                    "text": "__BODY_TEXT__"
        //                                }
        //                                ]
        //        },
        //        "attachment": {
        //            "attachmentType": "ExistingContent",
        //            "contentDocumentId": "__ATTACHMENT_ID__"
        //        }
        //    }
        
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

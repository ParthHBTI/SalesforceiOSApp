//
//  AttachViewController.swift
//  salesForceMobileApp
//
//  Created by mac on 07/11/16.
//  Copyright © 2016 Salesforce. All rights reserved.
//

import UIKit
import SalesforceRestAPI
class AttachViewController: UIViewController, UIPopoverPresentationControllerDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
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
        
        //SFRestAPI.sharedInstance().requestForUploadFile(imageData, name: <#T##String#>, description: <#T##String#>, mimeType: <#T##String#>)
    }
    @IBAction func attachPopOver(sender: AnyObject) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = pickedImage
            
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    }

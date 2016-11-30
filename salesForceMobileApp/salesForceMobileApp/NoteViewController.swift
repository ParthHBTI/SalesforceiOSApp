//
//  NoteViewController.swift
//  salesForceMobileApp
//
//  Created by mac on 21/11/16.
//  Copyright © 2016 Salesforce. All rights reserved.
//

import UIKit
import SalesforceRestAPI
import MBProgressHUD
class NoteViewController: UIViewController, SFRestDelegate {

    @IBOutlet weak var noteOwnerName: UILabel!
    @IBOutlet weak var ownerCompanyName: UILabel!
    @IBOutlet weak var checkNoteIsPrivate: UIButton!
    @IBOutlet weak var noteTitleText: UITextField!
    @IBOutlet weak var noteBodyTextView: UITextView!
    var leadId = String()
    var checkButton = false
    
    @IBAction func checkUncheckBtn(sender: AnyObject) {
        if !checkButton {
            checkButton = true
            checkNoteIsPrivate.setImage(UIImage(named: "checkUncheck"), forState: UIControlState.Normal)
        } else {
            checkButton = false
            checkNoteIsPrivate.setImage(nil, forState: UIControlState.Normal)
        }
    }
    
    func nullToNil(value : AnyObject?) -> AnyObject? {
        if value is NSNull {
            return nil
        } else {
            return value
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let borderColor = UIColor(red: 204.0 / 255.0, green: 204.0 / 255.0, blue: 204.0 / 255.0, alpha: 1.0)
        noteBodyTextView.layer.borderColor = borderColor.CGColor
        noteBodyTextView.layer.borderWidth = 1.0
        noteBodyTextView.layer.cornerRadius = 5.0
        checkNoteIsPrivate.layer.cornerRadius = 5
        checkNoteIsPrivate.layer.borderWidth = 1
        checkNoteIsPrivate.layer.borderColor = UIColor.blackColor().CGColor
        let shareBarButton = UIBarButtonItem(title: "Share", style: .Plain, target: self, action: #selector(NoteViewController.shareAction))
        self.navigationItem.setRightBarButtonItem(shareBarButton, animated: true)
        
        
//        if let _ = nullToNil(leadDetailInfo["Id"]) {
//            leadId = (leadDetailInfo["Id"] as? String)!
//        }
//

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   func  shareAction() {
    let noteFields = [
        
        "Title":noteTitleText.text,
        
        "Body": noteBodyTextView.text,
        
        "ParentId":leadId
        
    ]
    
    print(noteFields)
    
    let request1 = SFRestAPI.sharedInstance().requestForCreateWithObjectType("Note", fields: noteFields)
    SFRestAPI.sharedInstance().sendRESTRequest(request1, failBlock: { error in
    print(error)
    })
    { response in
    print(response)
    }
}
    @IBAction func saveNoteAction(sender: AnyObject) {
        let loading = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
       
        if noteTitleText.text!.isEmpty == true || noteBodyTextView.text!.isEmpty == true {
            loading.mode = MBProgressHUDMode.Text
            loading.detailsLabelText = "please give all values"
            loading.hide(true, afterDelay: 2)
            loading.removeFromSuperViewOnHide = true
        } else {
        let noteFields = [
            
            "Title":noteTitleText.text,
            
            "Body": noteBodyTextView.text,
            
            "ParentId":leadId
            
        ]
        
        print(noteFields)
        
        let request1 = SFRestAPI.sharedInstance().requestForCreateWithObjectType("Note", fields: noteFields)
        SFRestAPI.sharedInstance().sendRESTRequest(request1, failBlock: { error in
            print(error)
            })
        { response in
            dispatch_async(dispatch_get_main_queue(), {
                let loading1 = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                loading1.mode = MBProgressHUDMode.Indeterminate
                loading1.mode = MBProgressHUDMode.Text
                loading1.hide(true, afterDelay: 2)
                loading1.detailsLabelText = "Your Note Created Successfully"
                loading1.removeFromSuperViewOnHide = true
                self.navigationController!.popToViewController(self.navigationController!.viewControllers[1], animated: true)!
            })
                        print(response)
            
            }
        }
    }
}
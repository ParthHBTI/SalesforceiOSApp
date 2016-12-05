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
class NoteViewController: UIViewController, SFRestDelegate, UITextViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var noteOwnerName: UILabel!
    @IBOutlet weak var ownerCompanyName: UILabel!
    @IBOutlet weak var checkNoteIsPrivate: UIButton!
    @IBOutlet weak var noteTitleText: UITextField!
    @IBOutlet weak var noteBodyTextView: UITextView!
    var leadId = String()
    var checkButton = false
    var noteDetailArr: AnyObject = []
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
        noteBodyTextView.delegate = self
        noteTitleText.delegate = self
        noteBodyTextView.layer.borderColor = borderColor.CGColor
        noteBodyTextView.layer.borderWidth = 1.0
        noteBodyTextView.layer.cornerRadius = 5.0
        checkNoteIsPrivate.layer.cornerRadius = 5
        checkNoteIsPrivate.layer.borderWidth = 1
        checkNoteIsPrivate.layer.borderColor = UIColor.blackColor().CGColor
        let shareBarButton = UIBarButtonItem(title: "Share", style: .Plain, target: self, action: #selector(NoteViewController.shareAction))
        print(noteDetailArr)
        noteOwnerName.text = noteDetailArr.objectAtIndex(1) as? String
        //ownerCompanyName.text = noteDetailArr.objectAtIndex(2) as? String
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
    
    self.view.endEditing(true)
    
    print(noteFields)
    
    let loading = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
    loading.mode = MBProgressHUDMode.Indeterminate

    let request1 = SFRestAPI.sharedInstance().requestForCreateWithObjectType("Note", fields: noteFields)
    SFRestAPI.sharedInstance().sendRESTRequest(request1, failBlock: { error in
        print(error)
        loading.hide(true, afterDelay: 2)
        loading.removeFromSuperViewOnHide = true
        

        })
    { response in
        print(response)
        loading.hide(true, afterDelay: 2)
        loading.removeFromSuperViewOnHide = true
        

        self.navigationController?.popViewControllerAnimated(true)
    }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        noteTitleText.resignFirstResponder()
        return true
    }
    @IBAction func saveNoteAction(sender: AnyObject) {
        shareAction()
}
}
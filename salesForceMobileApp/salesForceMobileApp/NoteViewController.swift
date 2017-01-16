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
var offlineNotesDic = NSMutableDictionary()
var onlineNotesDic = NSMutableDictionary()

class NoteViewController: UIViewController, SFRestDelegate, UITextViewDelegate, UITextFieldDelegate {
    @IBOutlet weak var ObjTypeImageView: UIImageView!
    @IBOutlet weak var noteOwnerName: UILabel!
    @IBOutlet weak var ownerCompanyName: UILabel!
    @IBOutlet weak var checkNoteIsPrivate: UIButton!
    @IBOutlet weak var noteTitleText: UITextField!
    @IBOutlet weak var noteBodyTextView: UITextView!
    var leadId = String()
    var checkButton = false
    var noteDetailInfo:AnyObject = []
    var SectionVal = Int()
    var objectType:ObjectDataType?
   
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
        self.setNavigationBarItem()
        print(objectType)
        ObjTypeImageView.image = UIImage(named: "\(objectType?.rawValue)")
        if SectionVal == 0 {
            if let arrayOfObjectsData = defaults.objectForKey(offlineNotesKey) as? NSData {
                offlineNotesDic = NSKeyedUnarchiver.unarchiveObjectWithData(arrayOfObjectsData)! as! NSMutableDictionary
            }
        } else {
            if let arrayOfObjectsData = defaults.objectForKey(onlineNotesKey) as? NSData {
                onlineNotesDic = NSKeyedUnarchiver.unarchiveObjectWithData(arrayOfObjectsData)! as! NSMutableDictionary
            }
        }
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
        self.navigationItem.setRightBarButtonItem(shareBarButton, animated: true)
        
        
        if let _ = nullToNil(noteDetailInfo["Id"]) {
            leadId = (noteDetailInfo["Id"] as? String)!
        }


        // Do any additional setup after loading the view.
    }
    override func setNavigationBarItem() {
        self.leftBarButtonWithImage(UIImage(named: "back_NavIcon")!)
    }
    
    func leftBarButtonWithImage(buttonImage: UIImage) {
        let leftButton: UIBarButtonItem = UIBarButtonItem(image: buttonImage, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.backAction))
        navigationItem.leftBarButtonItem = leftButton;
    }
    
    func backAction() {
        navigationController?.popViewControllerAnimated(true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func  shareAction() {
        self.view.endEditing(true)
        let params = [
            "Title":noteTitleText.text,
            "Body": noteBodyTextView.text,
            "ParentId":leadId
        ]
        //print(params)
        if exDelegate.isConnectedToNetwork() {
            let loading = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            loading.mode = MBProgressHUDMode.Indeterminate
            let request1 = SFRestAPI.sharedInstance().requestForCreateWithObjectType("Note", fields: params)
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
        } else {
            if SectionVal == 0 {
                var NotesArr = offlineNotesDic[leadId]
                if let _ = NotesArr {
                    NotesArr = NotesArr?.mutableCopy() as? NSMutableArray
                } else {
                    NotesArr = NSMutableArray()
                }
                NotesArr?.addObject(params)
                offlineNotesDic.setObject(NotesArr!, forKey: leadId)
                defaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(offlineNotesDic), forKey: offlineNotesKey)
                print(offlineNotesDic)
                self.navigationController?.popViewControllerAnimated(true)
            } else {
                var NotesArr = onlineNotesDic[leadId]
                if let _ = NotesArr {
                    NotesArr = NotesArr?.mutableCopy() as? NSMutableArray
                } else {
                    NotesArr = NSMutableArray()
                }
                NotesArr?.addObject(params)
                onlineNotesDic.setObject(NotesArr!, forKey: leadId)
                defaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(onlineNotesDic), forKey: onlineNotesKey)
                print(onlineNotesDic)
                self.navigationController?.popViewControllerAnimated(true)
            }
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
  }
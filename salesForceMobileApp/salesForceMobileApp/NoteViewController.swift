//
//  NoteViewController.swift
//  salesForceMobileApp
//
//  Created by mac on 21/11/16.
//  Copyright © 2016 Salesforce. All rights reserved.
//

import UIKit
import SalesforceRestAPI
class NoteViewController: UIViewController, SFRestDelegate {

    @IBOutlet weak var noteOwnerName: UILabel!
    @IBOutlet weak var ownerCompanyName: UILabel!
    @IBOutlet weak var checkNoteIsPrivate: UIButton!
    @IBOutlet weak var noteTitleText: UITextField!
    @IBOutlet weak var noteBodyTextView: UITextView!
    var leadId = String()
    
    func nullToNil(value : AnyObject?) -> AnyObject? {
        if value is NSNull {
            return nil
        } else {
            return value
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
    }
    @IBAction func cancelNoteAction(sender: AnyObject) {
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

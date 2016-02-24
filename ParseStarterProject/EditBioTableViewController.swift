//
//  EditBioTableViewController.swift
//  Timeline
//
//  Created by Br@R on 24/02/16.
//  Copyright © 2016 Conclurer GbR. All rights reserved.
//

import Foundation
import UIKit
import Parse

class EditBioTableViewController: TintedHeaderTableViewController, UITextViewDelegate {
    
    @IBOutlet var bioField: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        bioField.text = "Bio"
        bioField.textColor = UIColor.lightGrayColor()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func save() {
        //        if websiteField.text != "" {
        //            let user = PFUser.currentUser()
        //            user?.email = websiteField.text
        //            user?.saveInBackgroundWithBlock { (success, error) -> Void in
        //                if success {
        //                    Storage.performRequest(.UserUpdate) { (json) -> Void in
        //                        main { self.navigationController?.popViewControllerAnimated(true) }
        //                    }
        //                }
        //            }
        //        } else {
        //            let alert = UIAlertController(title: local(.SettingsAlertEmailMissingTitle), message: local(.SettingsAlertEmailMissingMessage), preferredStyle: UIAlertControllerStyle.Alert)
        //            alert.addAction(UIAlertAction(title: local(.SettingsAlertEmailMissingActionDismiss), style: UIAlertActionStyle.Default, handler: nil))
        //            presentAlertController(alert)
        //        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            save()
            return false
        }
        return true
    }
    func textViewDidBeginEditing(textView: UITextView) {
        textView.text = ""
        textView.textColor = UIColor.blackColor()
    }
}

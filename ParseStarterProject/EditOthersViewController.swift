//
//  EditOthersViewController.swift
//  Timeline
//
//  Created by Br@R on 24/02/16.
//  Copyright © 2016 Conclurer GbR. All rights reserved.
//

import Foundation
import UIKit
import Parse

class EditOthersTableViewController: TintedHeaderTableViewController, UITextViewDelegate {
    
    @IBOutlet var othersField: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let other = PFUser.currentUser()!["other"] as? String {
            othersField.text = other
        }
        othersField.textColor = UIColor.lightGrayColor()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidDisappear(animated: Bool) {
        main{
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.hideActivityIndicator()
        }
    }
    @IBAction func save() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if othersField.text != "" {
            let user = PFUser.currentUser()
            appDelegate.showActivityIndicator()
            user!.setObject(othersField.text!, forKey: "other")
            user?.saveInBackgroundWithBlock { (success, error) -> Void in
                appDelegate.hideActivityIndicator()
                if success {
                    Storage.performRequest(.UserUpdate) { (json) -> Void in
                        main { self.navigationController?.popViewControllerAnimated(true) }
                    }
                }
            }
        } else {
            let alert = UIAlertController(title: local(.SettingsAlertEmailMissingTitle), message: local(.SettingsAlertEmailMissingMessage), preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: local(.SettingsAlertEmailMissingActionDismiss), style: UIAlertActionStyle.Default, handler: nil))
            presentAlertController(alert)
        }
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

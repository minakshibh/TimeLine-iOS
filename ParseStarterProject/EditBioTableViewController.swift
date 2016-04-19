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
        if let bio = PFUser.currentUser()!["bio"] as? String {
            bioField.text = bio
        }
        bioField.textColor = UIColor.lightGrayColor()
    }
    override func viewDidDisappear(animated: Bool) {
        main{
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.hideActivityIndicator()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func save() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if bioField.text != "" {
            let user = PFUser.currentUser()
            appDelegate.showActivityIndicator()
            user!.setObject(bioField.text!, forKey: "bio")
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
        
        let newLength = text.characters.count + textView.text.characters.count - range.length
        
        if(newLength > 120)
        {
            textView.resignFirstResponder()
            return false
        }
        if(text == "\n") {
            textView.resignFirstResponder()
            save()
            return false
        }
        return true
    }
    func textViewDidBeginEditing(textView: UITextView) {
        //textView.text = ""
        textView.textColor = UIColor.blackColor()
    }
}

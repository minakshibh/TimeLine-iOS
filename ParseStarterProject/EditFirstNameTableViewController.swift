//
//  EditNameTableViewController.swift
//  Timeline
//
//  Created by Br@R on 24/02/16.
//  Copyright © 2016 Conclurer GbR. All rights reserved.
//

import Foundation
import UIKit
import Parse

class EditFirstNameTableViewController: TintedHeaderTableViewController, UITextFieldDelegate {
    
    @IBOutlet var fNameField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let firstName = PFUser.currentUser()!["firstname"] as? String {
            fNameField.placeholder = firstName
        }
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

        if fNameField.text != "" {
            let user = PFUser.currentUser()
            user!.setObject(fNameField.text!, forKey: "firstname")
            appDelegate.showActivityIndicator()

            user?.saveInBackgroundWithBlock { (success, error) -> Void in
                appDelegate.hideActivityIndicator()

                if success {
                    Storage.performRequest(.UserUpdate) { (json) -> Void in
                        main { self.navigationController?.popViewControllerAnimated(true) }
                    }
                }
            }
        }else {
            let alert = UIAlertController(title: local(.SettingsAlertEmailMissingTitle), message: local(.SettingsAlertEmailMissingMessage), preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: local(.SettingsAlertEmailMissingActionDismiss), style: UIAlertActionStyle.Default, handler: nil))
            presentAlertController(alert)
        }
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField {
        case fNameField:
            fNameField.resignFirstResponder()
            save()
            return false
        default:
            return false
        }
    }
}

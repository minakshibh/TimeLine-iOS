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

class EditNameTableViewController: TintedHeaderTableViewController, UITextFieldDelegate {
    
    @IBOutlet var fNameField: UITextField!
    @IBOutlet var lNameField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        fNameField.placeholder = PFUser.currentUser()?.username
        lNameField.placeholder = PFUser.currentUser()?.username

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func save() {
//        if fNameField.text != "" {
//            let user = PFUser.currentUser()
//            user?.email = fNameField.text
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
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField {
        case fNameField:
            fNameField.resignFirstResponder()
            save()
            return false
        case lNameField:
            lNameField.resignFirstResponder()
            save()
            return false
        default:
            return false
        }
    }
}

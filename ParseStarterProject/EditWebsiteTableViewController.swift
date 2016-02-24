//
//  EditWebsiteTableViewController.swift
//  Timeline
//
//  Created by Br@R on 24/02/16.
//  Copyright © 2016 Conclurer GbR. All rights reserved.
//

import Foundation
import UIKit
import Parse

class EditWebsiteTableViewController: TintedHeaderTableViewController, UITextFieldDelegate {
    
    @IBOutlet var websiteField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        websiteField.placeholder = PFUser.currentUser()?.email ?? local(.SettingsPlaceholderEmailText)
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
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField {
        case websiteField:
            websiteField.resignFirstResponder()
            save()
            return false
        default:
            return false
        }
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
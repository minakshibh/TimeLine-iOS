//
//  EditPasswordTableViewController.swift
//  Timeline
//
//  Created by Valentin Knabel on 06.08.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import UIKit
import Parse

class EditPasswordTableViewController: TintedHeaderTableViewController, UITextFieldDelegate {

    @IBOutlet var newField: UITextField!
    @IBOutlet var repField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func save() {
        if newField.text != "" && repField.text != ""
            && newField.text == repField.text
        {
            let user = PFUser.currentUser()
            user?.password = newField.text
            user?.saveInBackground()
            
            navigationController?.popViewControllerAnimated(true)
        } else {
            let alert = UIAlertController(title: local(.SettingsAlertPasswordErrorTitle), message: local(.SettingsAlertPasswordErrorMessage), preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: local(.SettingsAlertPasswordErrorActionDismiss), style: UIAlertActionStyle.Default, handler: nil))
            presentAlertController(alert)
        }
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField {
        case newField:
            repField.becomeFirstResponder()
            return false
        case repField:
            repField.resignFirstResponder()
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


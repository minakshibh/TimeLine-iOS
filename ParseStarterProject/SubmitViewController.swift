//
//  SubmitViewController.swift
//  Timeline
//
//  Created by Valentin Knabel on 08.08.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import UIKit

class SubmitViewController: UIViewController {
    
    @IBOutlet var textFields: [UITextField]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func submitAction() { }
    
    @IBAction func dismissKeyboard() {
        for t in textFields {
            t.resignFirstResponder()
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

extension SubmitViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        for i in 0..<textFields.count {
            if textFields[i] == textField {
                if i == textFields.count - 1 {
                    textField.resignFirstResponder()
                    submitAction()
                } else {
                    textFields[i+1].becomeFirstResponder()
                }
                return false
            }
        }
        
        return true
    }
    
}

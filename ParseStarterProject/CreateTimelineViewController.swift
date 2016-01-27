//
//  CreateTimelineViewController.swift
//  Timeline
//
//  Created by Valentin Knabel on 08.08.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import UIKit

class CreateTimelineViewController: SubmitViewController {

    @IBOutlet var submitButton: UIButton!
    @IBOutlet var warningLabel: UILabel!
    
    var upgrading: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //tabBarController?.delegate = self
        //navigationController?.delegate = self

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        if upgrading {
            submitAction()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction override func submitAction() {
        main {
            self.submitButton.enabled = false
            self.textFields.first?.enabled = false
            self.navigationItem.setHidesBackButton(true, animated: true)
            self.upgrading = false
        
            guard let title = self.textFields.first!.text else { return }
            if title == "" {
                let alert = UIAlertController(title: local(.TimelineAlertCreateMissingTitle), message: local(.TimelineAlertCreateMissingMessage), preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: local(.TimelineAlertCreateMissingDismiss), style: .Default, handler: nil))
                self.presentAlertController(alert)
                return
            }
            
            Storage.performRequest(.CreateTimeline(title)) { (json) -> Void in
                switch json["status_code"] as? Int ?? 400 {
                case 400, 402: // payment required
                    let alert = UIAlertController(title: local(LocalizedString.TimelineAlertLimitRequiredTitle),
                        message: local(LocalizedString.TimelineAlertLimitRequiredMessage),
                        preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: local(LocalizedString.TimelineAlertLimitRequiredActionUpgrade),
                        style: UIAlertActionStyle.Default,
                        handler: { _ in
                            self.upgrading = true
                            self.performSegueWithIdentifier("BuyUpgrade", sender: self)
                    }))
                    alert.addAction(UIAlertAction(title: local(LocalizedString.TimelineAlertLimitRequiredActionCancel),
                    style: UIAlertActionStyle.Cancel,
                    handler: { _ in
                        self.navigationController?.popViewControllerAnimated(true)
                    }))
                    self.presentAlertController(alert)
                    
                default:
                    if let error = (json["error"] as? String) ?? (json["error"] as? [AnyObject])?.first as? String {
                        main {
                            let alert = UIAlertController(title: local(.TimelineAlertCreateErrorTitle), message: error, preferredStyle: .Alert)
                            alert.addAction(UIAlertAction(title: local(.TimelineAlertCreateErrorActionDismiss), style: .Default, handler: nil))
                            self.presentAlertController(alert)
                            
                            self.submitButton.enabled = true
                            self.textFields.first?.enabled = true
                            self.navigationItem.setHidesBackButton(false, animated: true)
                            self.upgrading = false
                        }
                    }
                }
                
                if let _ = json["id"] as? String,
                    let _ =  json["name"] as? String,
                    let _ = json["updated_at"] as? String,
                    let _ = json["created_at"] as? String,
                    let _ = json["likers_count"] as? Int,
                    let _ = json["followers_count"] as? Int
                {
                    let user = Storage.session.currentUser
                    let tl = Timeline(dict: json, parent: user)
                    tl.persistent = false
                    user?.timelines.append(tl)
                    Storage.save()
                    
                    main {
                        self.submitButton.enabled = true
                        self.upgrading = false
                        self.navigationController?.popViewControllerAnimated(true)
                        self.navigationController?.topViewController?.performSegueWithIdentifier("TimelineCreated", sender: tl)
                    }
                }
            }
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        switch segue.identifier ?? "" {
        case "BuyUpgrade":
            let dest = segue.destinationViewController as! UpgradeTableViewController
            dest.popOnAppear = true
        default:
            break
        }
    }

    // MARK: - TextFieldDelegate

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        // ALGORITHM HARDCODED - SEE TRENDING SEARCH
        let data = string.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: true)
        let temp = NSString(data: data!, encoding: NSASCIIStringEncoding) as! String
        let replacement = String(temp.characters.filter { (c: Character) -> Bool in
            return "abcdefghijklmnopqrstuvwxyz0123456789".rangeOfString(String(c).lowercaseString) != nil
        }).lowercaseString
        if warningLabel.hidden == true && string.characters.count != replacement.characters.count {
            warningLabel.alpha = 0.0
            warningLabel.hidden = false
            UIView.animateWithDuration(0.3) {
                self.warningLabel.alpha = 1.0
            }
        }
        
        if let stringRange = textField.text?.rangeFromNSRange(range)
        {
            textField.text?.replaceRange(stringRange, with: replacement)
        }
        // prefix with "#"
        if let pred = textField.text?.hasPrefix("#") where !pred {
            textField.text?.insert("#", atIndex: textField.text!.startIndex)
        }
        return false
    }
    
}

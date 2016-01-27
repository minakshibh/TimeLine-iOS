//
//  LicenseViewController.swift
//  Timeline
//
//  Created by Valentin Knabel on 07.09.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import UIKit

class LicenseViewController: UIViewController {

    @IBOutlet var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let projects = ["RMStore", "NSURL-Parameters", "CustomBadge", "MGSwipeTableCell", "Alamofire", "APParallaxHeader", "CSStickyHeaderFlowLayout", "SCRecorder", "BWWalkthrough"]
            .sort(<)
            .map { (name: String) -> String in
                let path = NSBundle.mainBundle().pathForResource(name, ofType: "license")!
                let license = try! String(contentsOfFile: path, encoding: NSUTF8StringEncoding)
                return lformat(LocalizedString.SettingsFormatLicenseContainer2s, args: name, license)
        }
        let result = projects.joinWithSeparator("\n\n----------\n\n")
        textView.text = result
        textView.scrollRangeToVisible(NSMakeRange(0, 1))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

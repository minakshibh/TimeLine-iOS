//
//  WalkthroughViewController.swift
//  Timeline
//
//  Created by Valentin Knabel on 04.09.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import UIKit

class WalkthroughViewController: BWWalkthroughPageViewController {

    var shouldHideDismissButton: Bool = false
    @IBOutlet var dismissButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        dismissButton!.hidden = shouldHideDismissButton
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    @IBAction override func dismissViewControllerWithAnimation(sender: AnyObject?) {
        self.dismissViewControllerAnimated(true, completion: nil)
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

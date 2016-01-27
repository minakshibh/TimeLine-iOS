 //
//  InitialViewController.swift
//  Timeline
//
//  Created by Valentin Knabel on 13.07.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import UIKit
import Parse

class InitialViewController: UIViewController, SegueHandlerType {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        println(PFUser.currentUser()?.sessionToken)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logoutUser(sender: AnyObject) {
        PFUser.logOutInBackgroundWithBlock { (error) -> Void in
            if let e = error {
                print(e)
            } else {
                let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
                appDelegate?.initializeRootViewController()
            }
        }
    }

    @IBAction func inviteAction(sender: AnyObject) {
        
    }
    
    // MARK: - Navigation

    enum SegueIdentifier: String {
        case CaptureSegue = "CaptureSegue"
    }
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        switch SegueIdentifier(rawValue: segue.identifier!)! {
        case .CaptureSegue:
            (segue.destinationViewController as! CaptureViewController).delegate = self
        }
    }

}

import MediaPlayer

extension InitialViewController: CaptureViewControllerDelegate {
    
    func captureViewControllerDidFinishWithURL(URL: NSURL?) {
        main {
            let mpvc = MPMoviePlayerViewController(contentURL: URL!)
            self.presentViewController(mpvc, animated: true) {
                // completion
            }
        }
    }
    
}

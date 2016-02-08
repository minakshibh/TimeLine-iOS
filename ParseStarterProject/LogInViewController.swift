//
//  LogInViewController.swift
//  Timeline
//
//  Created by Valentin Knabel on 13.07.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import UIKit
import Bolts
import Parse
import ParseUI

class LogInViewController: PFLogInViewController {
    
    var task: AnyObject?
    var alert: UIAlertController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        fields = [PFLogInFields.UsernameAndPassword, .LogInButton, .SignUpButton, .PasswordForgotten]
        
        // bug-fix: PFLogInViewController always displays dismissButton
        logInView?.dismissButton?.hidden = true
        
        signUpController = SignUpViewController()
        logInView?.passwordForgottenButton?.setAttributedTitle(NSAttributedString(string: logInView!.passwordForgottenButton!.titleLabel!.text!, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()]), forState: UIControlState.Normal)
        
        // set title
        self.logInView?.logo = UIImageView(image: UIImage(assetIdentifier: .Logo))
        (self.logInView?.logo as? UIImageView)?.contentMode = .ScaleAspectFill
        
        // set background
        let backgroundView = UIImageView(image: UIImage(assetIdentifier: .Background))
        backgroundView.contentMode = .ScaleAspectFill
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        self.logInView?.insertSubview(backgroundView, atIndex: 0)
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[back]-0-|", options: NSLayoutFormatOptions.AlignAllCenterY, metrics: nil, views: ["back": backgroundView]))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[back]-0-|", options: NSLayoutFormatOptions.AlignAllCenterX, metrics: nil, views: ["back": backgroundView]))

        
        // submit to notifications
        for (selector, name) in [
            ("logInSuccessful:", PFLogInSuccessNotification),
            ("logInFailure:", PFLogInFailureNotification),
            ("logInCancel:", PFLogInCancelNotification)] {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector(selector), name: name, object: self)
        }
        // sign up notifications
        for (selector, name) in [
            ("signUpSuccessful:", PFSignUpSuccessNotification),
            ("logInFailure:", PFSignUpFailureNotification),
            ("logInCancel:", PFSignUpCancelNotification)] {
                NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector(selector), name: name, object: signUpController)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func signUpSuccessful(not: NSNotification!) {
        signUpController?.dismissViewControllerAnimated(false, completion: nil)
        logInSuccessful(not)
    }
    
    func logInSuccessful(not: NSNotification!) {
        alert = UIAlertController(title: local(.LoginAlertWaitTitle), message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        presentAlertController(alert!)
        
        let tokenRequest = ApiRequest.GetToken(PFUser.currentUser()!.sessionToken!)
        Storage.performRequest(tokenRequest) { (json) -> Void in
            if let e = json["error"] as? String {
                self.alert?.dismissViewControllerWithAnimation(self)
                self.alert = UIAlertController(title: "Error", message: e, preferredStyle: .Alert)
                self.alert?.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                delay(0.5) { self.presentAlertController(self.alert!) }
                return
            }

            if let jwt = json["jwt"] as? String,
                let id = json["id"] as? String,
                let name = json["name"] as? String,
                let email = json["email"] as? String,
                let timelinesPublic = json["timelines_public"] as? Bool,
                let approveFollowers = json["approve_followers"] as? Bool,
                let followersCount = json["followers_count"] as? Int,
                let allowedTimelinesCount = json["allowed_timelines_count"] as? Int,
                let followingCount = json["followees_users_count"] as? Int,
                let likersCount = json["likers_count"] as? Int,
                let externalID = json["external_id"] as? String
            {
                
                let pendingFollowersCount = json["pending_followers"] as? Int
                
                Storage.session = Session(uuid: id, webToken: jwt, sessionToken: PFUser.currentUser()?.sessionToken, allowedTimelinesCount: allowedTimelinesCount, users: [User(name: name, email: email, externalID: externalID, timelinesPublic: timelinesPublic, approveFollowers: approveFollowers, pendingFollowersCount: pendingFollowersCount, followersCount: followersCount, followingCount: followingCount, likersCount: likersCount, liked:  json["liked"] as? Bool ?? false, blocked: json["blocked"] as? Bool ?? false, followed: .NotFollowing, timelines: [], state: SynchronizationState(dict: json))], drafts:Storage.session.drafts)
                Storage.save()
                
                do {
                    try NSFileManager.defaultManager().createDirectoryAtPath(Moment.basePath, withIntermediateDirectories: false, attributes: nil)
                } catch _ {
                }
                
                PFInstallation.currentInstallation().user = PFUser.currentUser()
                PFInstallation.currentInstallation().saveInBackground()
                
                self.alert?.dismissViewControllerAnimated(true, completion: { () -> Void in
                    print("first")
                        let delegate = UIApplication.sharedApplication().delegate as? AppDelegate
                        delegate?.initializeRootViewController()
                })
            } else {
                print("not called")
                self.alert?.dismissViewControllerWithAnimation(self)
            }
            
        }
    }
    
    func logInFailure(not: NSNotification!) {
        print(not.userInfo, terminator: "")
    }
    
    func logInCancel(not: NSNotification!) {
        print(not.userInfo, terminator: "")
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
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

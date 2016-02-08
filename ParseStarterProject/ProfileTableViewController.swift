//
//  ProfileTableViewController.swift
//  Timeline
//
//  Created by Valentin Knabel on 31.07.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import UIKit
import Parse

class ProfileTableViewController: TintedHeaderTableViewController {

    @IBOutlet var userSummaryView: UserSummaryTableViewCell!

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var followingLabel: UILabel!
    @IBOutlet var followersLabel: UILabel!
    @IBOutlet var lovedLabel: UILabel!
    @IBOutlet var pendingLabel: UILabel!
    
    @IBOutlet var timelinesPublicSwitch: UISwitch!
    @IBOutlet var approveFollowersSwitch: UISwitch!
    
    @IBOutlet var userImageView: ProfileImageView!
    
    var pendingBadge: CustomBadge?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerNib(UINib(nibName: "UserSummaryTableViewCell", bundle: nil), forCellReuseIdentifier: "UserCell")

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        navigationController?.delegate = self
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        cleanUpHooking()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setUpHooking()
        refresh()
        
        Storage.performRequest(ApiRequest.UserMe, completion: { (json) -> Void in
            if let user = Storage.session.currentUser {
                user.state = SynchronizationState(dict: json, parent: nil)
                
                if let timelinesPublic = json["timelines_public"] as? Bool {
                    user.timelinesPublic = timelinesPublic
                }
                if let approveFollowers = json["approve_followers"] as? Bool {
                    user.approveFollowers = approveFollowers
                }
                if let allowedTimelinesCount = json["allowed_timelines_count"] as? Int {
                    Storage.session.allowedTimelinesCount = allowedTimelinesCount
                }
                if let pendingFollowersCount = json["pending_followers"] as? Int {
                    user.pendingFollowersCount = pendingFollowersCount
                }
                if let likesCount = json["likers_count"] as? Int {
                    user.likesCount = likesCount
                }
                if let followersCount = json["followers_count"] as? Int {
                    user.followersCount = followersCount
                }
                if let followingCount = json["followees_users_count"] as? Int {
                    user.followingCount = followingCount
                }
                Storage.save()
                
                self.refresh()
            }
        })
    }
    
    private func refresh() {
        userSummaryView.user = Storage.session.currentUser

        // set title
        if PFUser.currentUser()?.authenticated ?? false {
            let user = PFUser.currentUser()!
            navigationItem.title = "@\(user.username!)"
            nameLabel.text = "\(user.username!)"
            emailLabel.text = "\(user.email!)"
            
            timelinesPublicSwitch.on = Storage.session.currentUser!.timelinesPublic!
            approveFollowersSwitch.on = Storage.session.currentUser!.approveFollowers!
            
//            user.badgePendingInBackground { pc -> Void in
//                main {
//                    if pc > 0 {
//                        let text = String(pc)
//                        if self.pendingBadge == nil {
//                            self.pendingBadge = CustomBadge(string: text, withStyle: BadgeStyle.defaultStyle())
//                            self.pendingLabel.superview?.addSubview(self.pendingBadge!)
//                            self.pendingBadge?.center = self.pendingLabel.center
//                        } else {
//                            self.pendingBadge?.badgeText = text
//                        }
//                    } else {
//                        self.pendingBadge?.removeFromSuperview()
//                    }
//                }
//            }
        } else {
            Storage.logout()
        }
        
        if let user = Storage.session.currentUser {
            pendingLabel.text = "\(user.pendingFollowersCount ?? 0)"
        }
        
        userImageView.user = Storage.session.currentUser
    }
    
    @IBAction func toggleTimelinesPublic() {
        let flag = timelinesPublicSwitch.on
        timelinesPublicSwitch.enabled = false
        Storage.performRequest(.UserSettings("timelines_public", flag)) { json in
            main {
                if let error = json["error"] as? String {
                    let alert = UIAlertController(title: local(.SettingsAlertTimelinesPublicErrorTitle), message: error, preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: local(.SettingsAlertTimelinesPublicErrorActionDismiss), style: .Default, handler: nil))
                    self.presentAlertController(alert)
                } else {
                    Storage.session.currentUser?.timelinesPublic = flag
                    Storage.save()
                    self.timelinesPublicSwitch.enabled = true
                }
            }
        }
    }
    
    @IBAction func toggleFollowersApprove() {
        let flag = approveFollowersSwitch.on
        approveFollowersSwitch.enabled = false
        Storage.performRequest(.UserSettings("approve_followers", flag)) { json in
            main {
                if let error = json["error"] as? String {
                    let alert = UIAlertController(title: local(.SettingsAlertFollowersApproveErrorTitle), message: error, preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: local(.SettingsAlertFollowersApproveErrorActionDismiss), style: .Default, handler: nil))
                    self.presentAlertController(alert)
                } else {
                    Storage.session.currentUser?.approveFollowers = flag
                    Storage.save()
                    self.approveFollowersSwitch.enabled = true
                }
            }
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let fl = sender as? Followable,
            let dest = segue.destinationViewController as? CallbackUserTableViewController
            where segue.identifier == "ShowUserList"
        {
            dest.callback = { fl.followers($0) }
            dest.navigationItem.title = local(.Followers)
        } else if let fl = sender as? Likeable,
            let dest = segue.destinationViewController as? CallbackUserTableViewController
            where segue.identifier == "ShowUserList"
        {
            dest.callback = { fl.likers($0) }
            dest.navigationItem.title = local(.Likes)
        }
    }

    @IBAction func shareApplication() {
        let activities = [local(.SettingsStringShareMessage), NSURL(string: local(.SettingsStringShareURL))!]
        let controller = UIActivityViewController(activityItems: activities, applicationActivities: nil)
        presentActivityViewController(controller)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source


    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    var hookingResponsibilities: [AnyObject?] = []
}

extension ProfileTableViewController: Hooking, UserMoreButtonBehavior, PushableBehavior, ShareableBehavior, BlockableBehavior {
    var hookingSetUps: [() -> AnyObject?] {
        return [setUpUserMoreButtonBehavior, setUpActiveControllerBehavior]
    }
}

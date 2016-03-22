//
//  PendingUserTableViewController.swift
//  Timeline
//
//  Created by Valentin Knabel on 06.09.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import UIKit
import Parse

class PendingUserTableViewController: FlatUserTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func refreshTableView() {
        var first = true
        
        User.getUsers(ApiRequest.CurrentUserPending) { usrs in
            if !first {
                main { self.refreshControl?.endRefreshing() }
                PFUser.currentUser()?.resetBadgePendingInBackground()
            } else {
                first = false
            }
            self.users = usrs
        }
        
//        delay(0.001) {
//            if !Storage.session.walkedThroughApprove {
//                Storage.session.walkedThroughApprove = true
//                self.performSegueWithIdentifier("WalkthroughApprove", sender: self)
//            }
//        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("UserCell", forIndexPath: indexPath) as! UserSummaryTableViewCell
        
        // Configure the cell...
        cell.hidesApproveButton = false
        cell.user = users[indexForIndexPath(indexPath)]
        cell.nameLabel.hidden = false
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowUser" {
            let dest = segue.destinationViewController as! UserSummaryTableViewController
            let user: User?
            if let pushable = sender as? User {
                user = pushable
            } else {
                let cell = tableView.cellForRowAtIndexPath(tableView.indexPathForSelectedRow!) as! UserSummaryTableViewCell
                user = cell.user
            }
            dest.user = user
        }
    }
}

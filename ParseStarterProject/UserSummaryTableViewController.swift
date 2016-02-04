//
//  UserSummaryTableViewController.swift
//  Timeline
//
//  Created by Valentin Knabel on 20.08.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import UIKit
import ConclurerHook

class UserSummaryTableViewController: FlatTimelineTableViewControllerWithoutUsername {
    
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerNib(UINib(nibName: "UserSummaryTableViewCell", bundle: nil), forCellReuseIdentifier: "UserCell")

        //tableView.rowHeight = UITableViewAutomaticDimension
        navigationItem.title = "@\(user.name ?? String())"
        if navigationController?.viewControllers[0] == self {
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(assetIdentifier: UIImage.AssetIdentifier.BackIndicator), style: UIBarButtonItemStyle.Plain, target: self, action: "dismissViewControllerWithAnimation:")
        }
    }
    
    override func refreshTableView() {
        timelines = user.timelines ?? []
        user.reloadUser {
            main {
                self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forItem: 0, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
            }
        }
        user.reloadTimelines {
            main { self.timelines = self.user.timelines ?? [] }
        }
    }
    
    override func indexPathForIndex(index: Int) -> NSIndexPath {
        return super.indexPathForIndex(index + 1)
    }
    
    override func indexForIndexPath(indexPath: NSIndexPath) -> Int {
        let path = NSIndexPath(forRow: indexPath.row - 1, inSection: indexPath.section)
        return super.indexForIndexPath(path)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return super.tableView(tableView, numberOfRowsInSection: section) + 1
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 143
        default:
            return 392
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("UserCell", forIndexPath: indexPath) as! UserSummaryTableViewCell
            
            // Configure the cell...
            cell.user = user
            return cell
            
        default:
            return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "AddTimeline" {
            
        } else {
            super.prepareForSegue(segue, sender: sender)
        }
    }
    
    func addTimeline() {
        performSegueWithIdentifier("AddTimeline", sender: nil)
    }
    
}
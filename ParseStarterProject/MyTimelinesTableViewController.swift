//
//  MyTimelinesTableViewController.swift
//  Timeline
//
//  Created by Valentin Knabel on 10.08.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import UIKit
import Parse

private func timelineOrder(l: Timeline, r: Timeline) -> Bool {
    return l.state.updatedAt > r.state.updatedAt
}

class MyTimelinesTableViewController: CommonTimelineTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.allowsMultipleSelectionDuringEditing = false
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        (leftBarButtonItems, rightBarButtonItems) = (navigationItem.leftBarButtonItems, navigationItem.rightBarButtonItems)
        
        delay(0.001) {
            if !Storage.session.walkedThroughMine {
                Storage.session.walkedThroughMine = true
                self.performSegueWithIdentifier("WalkthroughMy", sender: self)
            }
        }
    }
    
    private var leftBarButtonItems: [AnyObject]?
    private var rightBarButtonItems: [AnyObject]?
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        for any: AnyObject in leftBarButtonItems ?? [] {
            if let item = any as? UIBarButtonItem {
                item.tintColor = UIColor.whiteColor()
            }
        }
        for any: AnyObject in rightBarButtonItems ?? [] {
            if let item = any as? UIBarButtonItem {
                item.tintColor = UIColor.whiteColor()
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        for any: AnyObject in leftBarButtonItems ?? [] {
            if let item = any as? UIBarButtonItem {
                item.tintColor = UIColor.whiteColor()
            }
        }
        for any: AnyObject in rightBarButtonItems ?? [] {
            if let item = any as? UIBarButtonItem {
                item.tintColor = UIColor.whiteColor()
            }
        }
    }
    
    override func refreshTableView() {
        var first = true
        Timeline.getTimelines(ApiRequest.TimelineMe, completion: { (timelines) -> Void in
            Storage.session.currentUser?.timelines.sortInPlace(>)
            super.users = [Storage.session.currentUser!]
            
            if !first {
                PFUser.currentUser()?.resetBadgeMineInBackground()
                self.navigationController?.tabBarItem.badgeValue = nil
                self.refreshControl?.endRefreshing()
            } else {
                first = !first
            }
            
        })
    }
    
    override func deletionCallback() -> MGSwipeButtonCallback? {
        func result(sender: MGSwipeTableCell!) -> Bool {
            let indexPath = self.tableView.indexPathForCell(sender)!
            func performDelete(action: UIAlertAction!) {
                
                let alert = UIAlertController(title: LocalizedString.TimelineAlertDeleteWaitTitle.localized, message: local(.TimelineAlertDeleteWaitMessage), preferredStyle: .Alert)
                self.presentAlertController(alert)
                
                // Delete the row from the data source
                let del = users[indexPath.section].timelines[indexPath.row]
                Storage.performRequest(ApiRequest.DestroyTimeline(del.state.uuid!), completion: { (json) -> Void in
                    alert.dismissViewControllerAnimated(true) {
                        if let error = json["error"] as? String {
                            let alert = UIAlertController(title: local(.TimelineAlertDeleteErrorTitle), message: error, preferredStyle: .Alert)
                            alert.addAction(UIAlertAction(title: local(.TimelineAlertDeleteErrorActionDismiss), style: .Default, handler: nil))
                            self.presentAlertController(alert)
                            return
                        }
                        let moms = del.moments
                        async {
                            for m in moms {
                                if let url = m.localVideoURL {
                                    do {
                                        try NSFileManager.defaultManager().removeItemAtURL(url)
                                    } catch _ {
                                    }
                                }
                            }
                        }
                        
                        for i in 0..<(Storage.session.currentUser?.timelines.count ?? 0) {
                            let t = Storage.session.currentUser!.timelines[i]
                            if del.state.uuid == t.state.uuid {
                                Storage.session.currentUser!.timelines.removeAtIndex(i)
                                main { self.tableView.reloadData() }
                                break
                            }
                        }
                    }
                })
            }
            let confirmation = UIAlertController(title: local(.TimelineAlertDeleteConfirmTitle), message: local(.TimelineAlertDeleteConfirmMessage), preferredStyle: .Alert)
            confirmation.addAction(UIAlertAction(title: local(.TimelineAlertDeleteConfirmActionDelete), style: .Destructive, handler: performDelete))
            confirmation.addAction(UIAlertAction(title: local(.TimelineAlertDeleteConfirmActionCancel), style: .Cancel, handler: { [weak self] _ in
                self?.tableView.cellForRowAtIndexPath(indexPath)?.setEditing(false, animated: true)
            }))
            presentAlertController(confirmation)
            
            return true
        }
        return result
    }
    
    // MARK: - Table view data source
    
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
        
}

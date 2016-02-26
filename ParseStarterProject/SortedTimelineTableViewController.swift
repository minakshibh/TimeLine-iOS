//
//  SortedTimelineTableViewController.swift
//  Timeline
//
//  Created by Valentin Knabel on 07.09.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import UIKit

class SortedTimelineTableViewController: UITableViewController {

    var sections: [(User, [Timeline])] = [] {
        didSet {
            main { self.tableView.reloadData() }
        }
    }
    
    func setTimelines(timelines: [Timeline]) {
        var secs: [UUID: (User, [Timeline])] = [:]
//        for t in timelines {
//            print("\(t.parent)")
//            if let uid = t.parent?.uuid {
//                if secs[uid] == nil {
//                    secs[uid] = (t.parent!, [])
//                }
//                secs[uid]!.1.append(t)
//            }
//        }
        for t in timelines {
            print("\(t.parent)")
            if let uid = t.parent?.uuid {
                let indexUid = "\(secs.count)\(uid)"
                if secs[indexUid] == nil {
                    secs[indexUid] = (t.parent!, [])
                }
                secs[indexUid]!.1.append(t)
            }
        }
        let resultingSecs = secs.values.map { uts in
            (uts.0, uts.1.sort(<))
        }.sort { (luts, ruts) -> Bool in
            luts.0.name < ruts.0.name
        }
        sections = Array(resultingSecs)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.refreshControl?.addTarget(self, action: "refreshTableView", forControlEvents: UIControlEvents.ValueChanged)
        self.refreshTableView()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    func refreshTableView() { }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        print("\(sections.count)")
        return sections.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("\(sections[section].1.count)")
        return sections[section].1.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TimelineCell", forIndexPath: indexPath) as! ModernTimelineTableViewCell
        
        // Configure the cell...
        cell.timeline = sections[indexPath.section].1[indexPath.row]
        
        return cell
    }
    
    /*override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    println("height")
    return TimelineTableHeaderView.Height
    }*/
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView: TimelineTableHeaderView = NSBundle.mainBundle().loadNib(.TimelineTableHeaderView, owner: self)[0] as! TimelineTableHeaderView
        headerView.user = sections[section].0
        return headerView
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowTimeline" {
            let dest = segue.destinationViewController as! TimelineSummaryTableViewController
            let cell = tableView.cellForRowAtIndexPath(tableView.indexPathForSelectedRow!) as! ModernTimelineTableViewCell
            dest.timeline = cell.timeline
            cell.timeline?.hasNews = false
            if let sip = tableView.indexPathForSelectedRow {
                tableView.reloadRowsAtIndexPaths([sip], withRowAnimation: UITableViewRowAnimation.Automatic)
            }
        } else if let user = sender as? User where segue.identifier == "ShowUser" {
            let dest = segue.destinationViewController as! UserSummaryTableViewController
            dest.user = user
        } else if segue.identifier == "PresentTimelineModally" {
            let dest = segue.destinationViewController as! TimelinePlaybackViewController
            let timeline = sender as! Timeline
            dest.timeline = timeline
        } else if let _ = sender as? Timeline,
            let nav = segue.destinationViewController as? UINavigationController,
            let _ = nav.topViewController as? DraftCollectionViewController
            where segue.identifier == "TimelineCreated"
        {
                //dest.timeline = tl
        } else if let fl = sender as? Followable,
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
    
    func deletionCallback(sender: MGSwipeTableCell!) -> Bool {
        let indexPath = self.tableView.indexPathForCell(sender)!
        func performDelete(action: UIAlertAction!) {
            
            let alert = UIAlertController(title: LocalizedString.TimelineAlertDeleteWaitTitle.localized, message: local(.TimelineAlertDeleteWaitMessage), preferredStyle: .Alert)
            self.presentAlertController(alert)
            
            // Delete the row from the data source
            let del = sections[indexPath.section].1[indexPath.row]
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
                    
                    Storage.session.currentUser?.reloadTimelines {
                        main { self.tableView.reloadData() }
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
    // MARK: Hooking
    var hookingResponsibilities: [AnyObject?] = []

}

extension SortedTimelineTableViewController: Hooking, TimelineMoreButtonBehavior, UserMoreButtonBehavior, PushableBehavior, ShareableBehavior, DeleteableBehavior, BlockableBehavior {
    var hookingSetUps: [() -> AnyObject?] {
        return [setUpTimelineMoreButtonBehavior, setUpUserMoreButtonBehavior, setUpPushableBehavior, setUpActiveControllerBehavior]
    }


    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.setUpHooking() // required for Hooking protocol
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        cleanUpHooking() // breaks cycles on disappear
    }
}
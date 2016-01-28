//
//  FlatTimelineTableViewController.swift
//  Timeline
//
//  Created by Valentin Knabel on 18.08.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import UIKit

class FlatTimelineTableViewController: UITableViewController {
    
    var oldTabDelegate: UITabBarControllerDelegate?
    var oldNavDelegate: UINavigationControllerDelegate?
    
    var timelines: [Timeline] = [] {
        didSet {
            print("didset")

            for i in 0..<timelines.count {
                timelines[i].reloadMoments {
                    if let cell = self.tableView.cellForRowAtIndexPath(self.indexPathForIndex(i)) as? ModernTimelineTableViewCell {
                        cell.timeline = self.timelines[i]
                    }
                }
            }
            main { self.tableView.reloadData() }
        }
    }

    var callbacks: [AnyObject?] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        callbacks.append(setUpReloadable())
        
        oldTabDelegate = tabBarController?.delegate
        tabBarController?.delegate = self
        oldNavDelegate = navigationController?.delegate
        navigationController?.delegate = self
        
        self.refreshControl?.addTarget(self, action: "refreshTableView", forControlEvents: UIControlEvents.ValueChanged)
        self.refreshTableView()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func refreshTableView() { }

    override func viewWillAppear(animated: Bool) {
        self.setUpHooking() // required for Hooking protocol
    }
    override func viewWillDisappear(animated: Bool) {
        cleanUpHooking() // breaks cycles on disappear
        
        tabBarController?.delegate = oldTabDelegate
        navigationController?.delegate = oldNavDelegate
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timelines.count
    }
    
    func indexPathForIndex(index: Int) -> NSIndexPath {
        return NSIndexPath(forRow: index, inSection: 0)
    }
    
    func indexForIndexPath(indexPath: NSIndexPath) -> Int {
        return indexPath.row
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("TimelineCell", forIndexPath: indexPath) as! ModernTimelineTableViewCell
        
        // Configure the cell...
        cell.timeline = timelines[indexForIndexPath(indexPath)]
        
        return cell
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
    
    func removeTimelineFromCache(uuid: UUID) { }
    
    func deletionCallback() -> MGSwipeButtonCallback? {
        return nil
    }
    // MARK: Hooking
    var hookingResponsibilities: [AnyObject?] = []

}

extension FlatTimelineTableViewController: Hooking, UserMoreButtonBehavior, TimelineMoreButtonBehavior, PushableBehavior, ShareableBehavior, DeleteableBehavior, BlockableBehavior {
    var hookingSetUps: [() -> AnyObject?] {
        return [setUpTimelineMoreWithoutUserButtonButtonBehavior, setUpUserMoreButtonBehavior, setUpPushableBehavior, setUpActiveControllerBehavior]
    }

    override func reloadData() {
        main {
            self.refreshTableView()
            self.tableView.reloadData()
        }
    }
}

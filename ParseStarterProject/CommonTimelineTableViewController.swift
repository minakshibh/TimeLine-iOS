//
//  CommonTimelineTableViewController.swift
//  Timeline
//
//  Created by Valentin Knabel on 15.08.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import UIKit

class CommonTimelineTableViewController: UITableViewController {

    var users: [User] = [] {
        didSet {
            
            NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "update", userInfo: nil, repeats: false)
        }
    }
    func update(){
        main { self.tableView.reloadData() }
        
        for j in 0..<users.count {
            let ts = users[j].timelines
            for i in 0..<ts.count {
                users[j].timelines[i].reloadMoments {
                    if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forItem: j, inSection: i)) as? ModernTimelineTableViewCell {
                        cell.timeline = self.users[j].timelines[i]
                    }
                }
            }
        }

    }
    
    var lblFeed:UILabel!
    var callbacks: [AnyObject?] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "update1", userInfo: nil, repeats: false)

    }
    func update1(){
        callbacks.append(setUpReloadable())
        
        tabBarController?.delegate = self
        navigationController?.delegate = self
        
        self.refreshControl?.addTarget(self, action: "refreshTableView", forControlEvents: UIControlEvents.ValueChanged)
        self.refreshTableView()
        
        NSUserDefaults.standardUserDefaults().setObject("yes", forKey: "status")
    }
    func refreshTableView() { }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return users.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(users[section].timelines.count == 0 && NSUserDefaults.standardUserDefaults().valueForKey("status") as? String == "yes"){
            
            self.tableView.addSubview(lblFeed)
            NSUserDefaults.standardUserDefaults().setObject("no", forKey: "status")
        }
        if(users[section].timelines.count > 0)
        {
            lblFeed.removeFromSuperview()
        }
        
        
        return users[section].timelines.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("TimelineCell", forIndexPath: indexPath) as! ModernTimelineTableViewCell
        
        
        // Configure the cell...
        cell.timelineView.timeline = users[indexPath.section].timelines[indexPath.row]
        lblFeed.removeFromSuperview()
        //cell.deletionCallback = self.deletionCallback()
        
        return cell
        
    }
    
    /*override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        println("height")
        return TimelineTableHeaderView.Height
    }*/
    
    private lazy var headerView: TimelineTableHeaderView = NSBundle.mainBundle().loadNib(.TimelineTableHeaderView, owner: self)[0] as! TimelineTableHeaderView
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        headerView.user = users[section]
        return headerView
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
       // print(users[indexPath.section].timelines[indexPath.row].uuid)
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
            let dest = segue.destinationViewController as! updatedUserSummaryTableViewController
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
                // dest.timeline = tl
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
    
    func deletionCallback() -> MGSwipeButtonCallback? {
        return nil
    }

    // MARK: Hooking
    var hookingResponsibilities: [AnyObject?] = []
    
}

extension CommonTimelineTableViewController: Hooking, TimelineMoreButtonBehavior, PushableBehavior, ShareableBehavior, DeleteableBehavior, BlockableBehavior {
    var hookingSetUps: [() -> AnyObject?] {
        return [setUpTimelineMoreButtonBehavior, setUpPushableBehavior, setUpActiveControllerBehavior]
    }
    override func reloadData() {
        main {
            NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "update2", userInfo: nil, repeats: false)

        }
    }
    func update2(){
        self.refreshTableView()
        self.tableView.reloadData()
    }
    override func viewWillAppear(animated: Bool) {
        NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "update3", userInfo: nil, repeats: false)
    }
    func update3(){
        self.setUpHooking() // required for Hooking protocol
        
        lblFeed = UILabel(frame: CGRectMake(0, 0, self.tableView.frame.size.width,  self.tableView.frame.size.height))
        lblFeed.textAlignment = NSTextAlignment.Center
        lblFeed.text = "No Feedeos found"
    }
    override func viewWillDisappear(animated: Bool) {
        cleanUpHooking() // breaks cycles on disappear
    }
}

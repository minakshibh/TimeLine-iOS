//
//  CommonTimelineTableViewController.swift
//  Timeline
//
//  Created by Valentin Knabel on 15.08.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import UIKit

class CommonTimelineTableViewController: UITableViewController {
    var lblFeed:UILabel! = UILabel()
    var users: [User] = [] {
        didSet {
            
            main { self.tableView.reloadData() }
            
       main{     
            for j in 0..<self.users.count {
//                print("\(users.count)")
                let ts = self.users[j].timelines
                if(ts.count == 0){
                    self.lblFeed.frame = CGRectMake(0, 0, self.tableView.frame.size.width,  self.tableView.frame.size.height)
                   self.lblFeed.textAlignment = NSTextAlignment.Center
                    self.lblFeed.text = "No Feedeos found"
                    

                    self.tableView.addSubview(self.lblFeed)
                }
                for i in 0..<ts.count {
//                    print("\(ts.count)")
                    if(ts.count != 0){
                        self.lblFeed.removeFromSuperview()
                    }
                    self.users[j].timelines[i].reloadMoments {
                        main{
                        if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forItem: j, inSection: i)) as? ModernTimelineTableViewCell {
                            cell.timeline = self.users[j].timelines[i]
                            
                            }
                        }
                    }
                }
            }
          main { self.tableView.reloadData() }
        }

        }
    }
    func update(){
           }
    
   
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
        return users[section].timelines.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("TimelineCell", forIndexPath: indexPath) as! ModernTimelineTableViewCell
        
        
        // Configure the cell...
        cell.timelineView.timeline = users[indexPath.section].timelines[indexPath.row]
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
    
//    func deletionCallback() -> MGSwipeButtonCallback? {
//        return nil
//    }

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
        
            }
    override func viewWillDisappear(animated: Bool) {
        cleanUpHooking() // breaks cycles on disappear
    }
}

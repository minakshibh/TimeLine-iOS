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

        //2016-01-11T04:25:50.000Z
        do{
        let resultingSecs = secs.values.map { uts in
            (uts.0, uts.1.sort(<))
        }.sort { (luts, ruts) -> Bool in
            
            var date1:NSString = ""
            var date2:NSString = ""
            
             for t in luts.1 {
               date1 =  t.updated_at
                print("%%%%\(date1)")
            }
            for t in ruts.1 {
                date2 =  t.updated_at
                print("%%%%\(date1)")
            }
            
            
            
            if (date1 != "") {
            var arr = date1.componentsSeparatedByString("T")
            date1 = arr[0]
            arr = arr[1].componentsSeparatedByString(".")
            date1 = "\(date1) \(arr[0])"
                print("1111111---\(date1)")
            }
            if (date2 != "") {
            var arr1 = date2.componentsSeparatedByString("T")
            date2 = arr1[0]
            arr1 = arr1[1].componentsSeparatedByString(".")
            date2 = "\(date2) \(arr1[0])"
                print("2222222---\(date2)")
            }
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            var status:Bool = false
            if (date2 != "" && date1 != ""){
             status = dateFormatter.dateFromString(date1 as String)?.compare((dateFormatter.dateFromString(date2 as String))!) == NSComparisonResult.OrderedDescending
            }
            
        return status
        }
        }catch{
            var alert=UIAlertController(title: "CRASH", message: "App tried to crash while sorting values", preferredStyle: UIAlertControllerStyle.Alert);
            self.showViewController(alert, sender: self);
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
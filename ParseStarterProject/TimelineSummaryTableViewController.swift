//
//  TimelineSummaryTableViewController.swift
//  Timeline
//
//  Created by Valentin Knabel on 18.08.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import UIKit

class TimelineSummaryTableViewController: FlatTimelineTableViewController {

    var timeline: Timeline!
    
    weak var headerView: DraftPreview?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = true

        navigationItem.title = "#\(timeline.name)"
        if timeline.parent?.uuid == Storage.session.currentUser?.uuid {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(assetIdentifier: .New), style: .Plain, target: self, action: "addMoment")
        }
        
        headerView = NSBundle.mainBundle().loadNib(.DraftPreview, owner: self)[0] as? DraftPreview
        headerView?.setTimeline(timeline)
        tableView.addParallaxWithView(headerView, andHeight: tableView.bounds.size.width)
        
        timeline.hasNews = false
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        
        headerView?.stop()
    }
    
    override func refreshTableView() {
        timelines = timeline.parent?.timelines ?? []
        timeline.parent?.reloadTimelines { _ in }

        timeline.parent?.reloadUser { }
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
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 58
        default:
            return 147
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("UserCell", forIndexPath: indexPath) as! UserSummaryTableViewCell
            
            // Configure the cell...
            cell.user = timeline.parent
            return cell
            
        default:
            return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "AddMoment" {
            let dest = segue.destinationViewController as? DraftCollectionViewController
            dest?.timeline = timeline
        } else if segue.identifier == "ShowUser" {
            let dest = segue.destinationViewController as? UserSummaryTableViewController
            dest?.user = timeline.parent
        } else {
            super.prepareForSegue(segue, sender: sender)
        }
    }
    
    func addMoment() {
        performSegueWithIdentifier("AddMoment", sender: nil)
    }

}

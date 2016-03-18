//
//  FlatUserTableViewController.swift
//  Timeline
//
//  Created by Valentin Knabel on 06.09.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import UIKit

class FlatUserTableViewController: UITableViewController {
    
    var users: [User] = [] {
        didSet {
            main { self.tableView.reloadData() }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerNib(UINib(nibName: "UserSummaryTableViewCell", bundle: nil), forCellReuseIdentifier: "UserCell")
        
        self.refreshControl?.addTarget(self, action: "refreshTableView", forControlEvents: UIControlEvents.ValueChanged)
        self.refreshTableView()

        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = true
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    override func reloadData() {
        refreshTableView()
    }
    
    func refreshTableView() { }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func indexPathForIndex(index: Int) -> NSIndexPath {
        return NSIndexPath(forRow: index, inSection: 0)
    }
    
    func indexForIndexPath(indexPath: NSIndexPath) -> Int {
        return indexPath.row
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let cell = tableView.cellForRowAtIndexPath(indexPath) as? UserSummaryTableViewCell,
            let user = cell.user else { return }
        performSegueWithIdentifier("ShowUser", sender: user)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("UserCell", forIndexPath: indexPath) as! UserSummaryTableViewCell
        
        // Configure the cell...
        cell.user = users[indexForIndexPath(indexPath)]
        cell.nameLabel.hidden = false
        
        return cell
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

    var hookingResponsibilities: [AnyObject?] = []
}

extension FlatUserTableViewController: Hooking, UserMoreButtonBehavior, BlockableBehavior, PushableBehavior, ShareableBehavior {
    var hookingSetUps: [() -> AnyObject?] {
        return [setUpActiveControllerBehavior, setUpActiveControllerBehavior, setUpUserMoreButtonBehavior]
    }

    override func viewWillAppear(animated: Bool) {
        setUpHooking()
    }

    override func viewWillDisappear(animated: Bool) {
        cleanUpHooking()
    }
}

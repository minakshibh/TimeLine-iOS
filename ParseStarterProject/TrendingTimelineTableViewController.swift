//
//  TrendingTimelineTableViewController.swift
//  Timeline
//
//  Created by Valentin Knabel on 18.08.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import UIKit


class TrendingTimelineTableViewController: FlatTimelineTableViewController {
    
    var searching: Bool = false
    var searchResults: [AnyObject] = [] {
        didSet {
            searching = false
            main {
                self.searchDisplayController?.searchResultsTableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerNib(UINib(nibName: "UserSummaryTableViewCell", bundle: nil), forCellReuseIdentifier: "UserCell")

        // Do any additional setup after loading the view.
        searchDisplayController?.searchBar.delegate = self
        searchDisplayController?.delegate = self
        
        delay(0.001) {
            if !Storage.session.walkedThroughTrends {
                Storage.session.walkedThroughTrends = true
                self.performSegueWithIdentifier("WalkthroughTrending", sender: self)
            }
        }
    }

    override func refreshTableView() {
        var first = true
        Timeline.getTimelines(.TimelineTrending) { tls in
            if !first {
                main { self.refreshControl?.endRefreshing() }
            }
            self.timelines = tls
            first = false
        }
    }
    
    override func removeTimelineFromCache(uuid: UUID) {
        Storage.session.trendingCache = Storage.session.trendingCache.filter { $0 != uuid }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            return super.tableView(tableView, numberOfRowsInSection: section)
        } else {
            return searching && searchResults.count == 0 ? 1 : searchResults.count
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if tableView == self.tableView {
            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        } else {
            if searching && searchResults.count == 0 {
                return 147
            } else if let _ = searchResults[indexPath.row] as? User {
                return 100
            } else {
                return 382
            }
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // MARK: Causing TableView Crash
        
        if tableView == self.tableView {
            //super.tableView(tableView, didSelectRowAtIndexPath: indexPath)
        } else if let user = searchResults[indexPath.row] as? User {
            performSegueWithIdentifier("ShowUser", sender: user)
        }
        
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView == self.tableView {
            return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        } else {
            if searching && searchResults.count == 0 {
                let cell = self.tableView.dequeueReusableCellWithIdentifier("ActivityCell", forIndexPath: indexPath) 
                return cell
            } else if let user = searchResults[indexPath.row] as? User {
                let cell = self.tableView.dequeueReusableCellWithIdentifier("UserCell", forIndexPath: indexPath) as! UserSummaryTableViewCell
                
                // Configure the cell...
                
                cell.user = user
                cell.nameLabel.hidden = false
                
                return cell
            } else {
                let timeline = searchResults[indexPath.row] as! Timeline
                let cell = self.tableView.dequeueReusableCellWithIdentifier("TimelineCell", forIndexPath: indexPath) as! ModernTimelineTableViewCell
                
                // Configure the cell...
                cell.timeline = timeline
                
                return cell
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowTimeline" {
            let dest = segue.destinationViewController as! TimelineSummaryTableViewController
            let cell: ModernTimelineTableViewCell
            if let selectedIndex = tableView.indexPathForSelectedRow {
                cell = tableView.cellForRowAtIndexPath(selectedIndex) as! ModernTimelineTableViewCell
            } else {
                let selectedIndex = searchDisplayController!.searchResultsTableView.indexPathForSelectedRow!
                cell = searchDisplayController!.searchResultsTableView.cellForRowAtIndexPath(selectedIndex) as! ModernTimelineTableViewCell
            }
            dest.timeline = cell.timeline
        } else if segue.identifier == "ShowUser" {
            let dest = segue.destinationViewController as? UserSummaryTableViewController
            let user: User?
            if let pushable = sender as? User {
                user = pushable
            } else {
                let selectedIndex = searchDisplayController!.searchResultsTableView.indexPathForSelectedRow!
                let cell = searchDisplayController!.searchResultsTableView.cellForRowAtIndexPath(selectedIndex) as! UserSummaryTableViewCell
                user = cell.user
            }
            dest?.user = user
        } else {
            super.prepareForSegue(segue, sender: sender)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension TrendingTimelineTableViewController: UISearchDisplayDelegate {
    
    func searchDisplayControllerDidEndSearch(controller: UISearchDisplayController) {
        if let searchBar = searchDisplayController?.searchBar {
            tableView.insertSubview(searchBar, aboveSubview: tableView)
        }
    }
    
}

extension TrendingTimelineTableViewController: UISearchBarDelegate {
    
    func searchBar(searchBar: UISearchBar, shouldChangeTextInRange range: NSRange, replacementText string: String) -> Bool {
        // ALGORITHM HARDCODED - SEE CREATE TIMELINE
        let data = string.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: true)
        let temp = NSString(data: data!, encoding: NSASCIIStringEncoding) as! String
        var replacement = String(temp.characters.filter { (c: Character) -> Bool in
            return "abcdefghijklmnopqrstuvwxyz0123456789".rangeOfString(String(c).lowercaseString) != nil
            })
        if range.location == 0 && string.hasPrefix("#") {
            replacement = "#" + replacement
        }
        if range.location == 0 && string.hasPrefix("@") {
            replacement = "@" + replacement
        }
        if let stringRange = searchBar.text?.rangeFromNSRange(range)
        {
            searchBar.text?.replaceRange(stringRange, with: replacement)
        }
        
        self.searchBar(searchBar, textDidChange: searchBar.text ?? "")
        return false
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        var text: String = String((searchBar.text ?? "").characters.filter { (c: Character) -> Bool in
            return "abcdefghijklmnopqrstuvwxyz0123456789".rangeOfString(String(c).lowercaseString) != nil
            })
        if text.characters.count < 2 { return }
        if searchText.hasPrefix("#") {
            text = "#" + text
        } else if searchText.hasPrefix("@") {
            text = "@" + text
        }
        if searchResults.count == 0 {
            searching = true
        }
        Storage.performRequest(ApiRequest.Search(text), completion: { (json) -> Void in
            var results = [AnyObject]()
            for r in json["result"] as? [[String: AnyObject]] ?? [] {
                if let _ = r["email"] as? String {
                    let user = User(dict: r, parent: nil)
                    if let uuid = user.state.uuid,
                        let existing = Storage.findUser(uuid)
                    {
                        results.append(existing)
                    } else {
                        results.append(user)
                    }
                }
                if let parentID = r["user_id"] as? UUID {
                    let timeline = Timeline(dict: r, parent: nil)
                    if let uuid = timeline.state.uuid,
                        let existing = Storage.findTimeline(uuid)
                    {
                        results.append(existing)
                    } else {
                        if let parentID = r["user_id"] as? UUID,
                            let parent = Storage.findUser(parentID)
                        {
                            parent.timelines.append(timeline)
                            results.append(timeline)
                        } else {
                            let _ = User(name: nil, email: nil, externalID: nil, timelinesPublic: nil, approveFollowers: nil, pendingFollowersCount: nil, followersCount: nil, followingCount: nil, likersCount: nil, liked: false, blocked: false, followed: .NotFollowing, timelines: [timeline], state: .Dummy(parentID), parent: nil)
                            results.append(timeline)
                            
                            Storage.performRequest(ApiRequest.UserProfile(parentID), completion: { (json) -> Void in
                                if let _ = json["error"] { return }
                                
                                let user = User(dict: json, parent: nil)
                                user.timelines.append(timeline)
                                Storage.session.users.append(user)
                            })
                        }
                    }
                }
            }
            main {
                self.searchResults = results
            }
        })
    }
    
}

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
    var dateArray: NSMutableArray! = []
    var sortedDateArray: NSMutableArray! = []
    var sortedtimelines: [Timeline] = []
    
    // Iphonecheck Classes
    enum UIUserInterfaceIdiom : Int
    {
        case Unspecified
        case Phone
        case Pad
    }
    
    struct ScreenSize
    {
        static let SCREEN_WIDTH         = UIScreen.mainScreen().bounds.size.width
        static let SCREEN_HEIGHT        = UIScreen.mainScreen().bounds.size.height
        static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
        static let SCREEN_MIN_LENGTH    = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    }
    
    struct DeviceType
    {
        static let IS_IPHONE_4_OR_LESS  = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
        static let IS_IPHONE_5          = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
        static let IS_IPHONE_6          = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
        static let IS_IPHONE_6P         = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
        static let IS_IPAD              = UIDevice.currentDevice().userInterfaceIdiom == .Pad && ScreenSize.SCREEN_MAX_LENGTH == 1024.0
    }
    let IPHONE4 : Int = DeviceType.IS_IPHONE_4_OR_LESS ? 1 : 0
    let IPHONE5 : Int = DeviceType.IS_IPHONE_5 ? 1 : 0
    let IPHONE6 : Int = DeviceType.IS_IPHONE_6 ? 1 : 0
    let IPHONE6P :Int = DeviceType.IS_IPHONE_6P ? 1 : 0
    
    
    var timelines: [Timeline] = [] {
        didSet {
            print("didset")
            //            print("\(timelines.count)")
            
            //get dates from timeline
            dateArray = []
            for f in 0..<timelines.count {
                //            print("\(timelines[f].updated_at)")
                
                if !(timelines[f].updated_at.isEmpty) {
                    var sampleArrayOne = "\(timelines[f].updated_at)".componentsSeparatedByString("T")
                    let dateStr = sampleArrayOne[0]
                    var sampleArrayTwo = sampleArrayOne[1].componentsSeparatedByString("Z")
                    var timeStr = sampleArrayTwo[0]
                    timeStr = timeStr.componentsSeparatedByString(".")[0]
                    
                    dateArray.addObject("\(dateStr) \(timeStr)")
                    //                    print ("\(dateArray)")
                }
            }
            
            // sort the date array
            
            
            //            print("\(dateArray)")
            if !(dateArray.count > 1) {
                return
            }
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            var sortedArray = dateArray.sort{(dateFormatter.dateFromString($0 as! String))!.compare(dateFormatter.dateFromString($1 as! String)!) == .OrderedAscending}
            
            //            print("----------*********---------")
            //            print("\(sortedArray)")
            
            // reverse an array
            var c = sortedArray.count - 1
            var i = 0
            while i < c {
                swap(&sortedArray[i++],&sortedArray[c--])
            }
            //print("\(sortedArray)")
            
            sortedtimelines = []
            for g in 0..<sortedArray.count{
                let sortedDateStr = "\(sortedArray[g])"
                for h in 0..<timelines.count{
                    if !(timelines[h].updated_at.isEmpty) {
                        var sampleArrayOne = "\(timelines[h].updated_at)".componentsSeparatedByString("T")
                        let dateStr = sampleArrayOne[0]
                        var sampleArrayTwo = sampleArrayOne[1].componentsSeparatedByString("Z")
                        var timeStr = sampleArrayTwo[0]
                        timeStr = timeStr.componentsSeparatedByString(".")[0]
                        let compareStr = "\(dateStr) \(timeStr)"
                        
                        if(sortedDateStr == compareStr){
                            sortedtimelines.append(timelines[h])
                            break
                        }
                    }
                    
                }
            }
            
            timelines = []
            timelines = sortedtimelines
            
            
            for i in 0..<timelines.count {
                timelines[i].reloadMoments {
                    if let cell = self.tableView.cellForRowAtIndexPath(self.indexPathForIndex(i)) as? ModernTimelineTableViewCell {
                        cell.timeline = self.timelines[i]
                    }
                }
            }
            //serialHook.perform(key: .ForceReloadData, argument: ())
            delay(0.01) {
                    //self.refreshTableView()
                self.tableView.reloadData()
            }
        }
    }

    var callbacks: [AnyObject?] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        //callbacks.append(setUpReloadable())
        
        oldTabDelegate = tabBarController?.delegate
        tabBarController?.delegate = self
        oldNavDelegate = navigationController?.delegate
        navigationController?.delegate = self
        
        //self.refreshControl?.addTarget(self, action: "refreshTableView", forControlEvents: UIControlEvents.ValueChanged)
        self.refreshTableView()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func refreshTableView() { }
    
    override func viewWillAppear(animated: Bool) {
        self.setUpHooking()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.setUpHooking()
    }
//    override func viewWillAppear(animated: Bool) {
//         // required for Hooking protocol
//    }
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
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        //print("is own Trending \(timelines[indexForIndexPath(indexPath)].isOwn)")
        if(timelines[indexForIndexPath(indexPath)].isOwn){
            
            if(timelines[indexForIndexPath(indexPath)].description.isEmpty){
                return CGFloat(380+30*IPHONE6P);
            }else{
                return CGFloat(402+30*IPHONE6P);
            }
        }else{
            
            if(timelines[indexForIndexPath(indexPath)].description.isEmpty){
                return CGFloat(435+30*IPHONE6P);
            }else{
                return CGFloat(455+30*IPHONE6P);
            }
            
        }
        
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
    
//    func deletionCallback() -> MGSwipeButtonCallback? {
//        return nil
//    }
    // MARK: Hooking
    var hookingResponsibilities: [AnyObject?] = []

}

extension FlatTimelineTableViewController: Hooking, UserMoreButtonBehavior, TimelineMoreButtonBehavior, PushableBehavior, ShareableBehavior, DeleteableBehavior, BlockableBehavior {
    var hookingSetUps: [() -> AnyObject?] {
        return [setUpTimelineMoreButtonBehavior, setUpUserMoreButtonBehavior, setUpPushableBehavior, setUpActiveControllerBehavior]
    }

//    override func reloadData() {
//        main {
//            //self.refreshTableView()
//            self.tableView.reloadData()
//        }
//    }
}

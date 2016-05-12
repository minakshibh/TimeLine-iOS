//
//  MyTimelinesTableViewController.swift
//  Timeline
//
//  Created by Valentin Knabel on 10.08.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//
import Foundation
import UIKit
import Parse
import Alamofire

private func timelineOrder(l: Timeline, r: Timeline) -> Bool {
    return l.state.updatedAt > r.state.updatedAt
}

class MyTimelinesTableViewController: CommonTimelineTableViewController {

    var status:Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.sharedApplication().statusBarHidden = false;
        NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "update6", userInfo: nil, repeats: false)
//        delay(0.001) {
//            self.callbacks.append(self.setUpReloadable())
//        }

        
    }
     func update6(){
        self.tableView.allowsMultipleSelectionDuringEditing = false

        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        (leftBarButtonItems, rightBarButtonItems) = (navigationItem.leftBarButtonItems, navigationItem.rightBarButtonItems)
        
//        delay(0.001) {
//            if !Storage.session.walkedThroughMine {
//                Storage.session.walkedThroughMine = true
//                self.performSegueWithIdentifier("WalkthroughMy", sender: self)
//            }
//        }
        
        let right: UIBarButtonItem = UIBarButtonItem(image: UIImage(named:"Back to previous screen"), style: .Plain, target: self, action:"goToRecordScreen")
        navigationItem.leftBarButtonItem = right
    }
    func goToRecordScreen(){
        
        UIView.animateWithDuration(1.0,animations: { () -> Void in
        let viewController = UIApplication.sharedApplication().windows[0].rootViewController?.childViewControllers[1] as? drawer
        viewController?.profileButtonClick()
           
        })
//        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        appDelegate.window = UIWindow(frame: UIScreen.mainScreen().bounds)
//        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc : drawer = storyboard.instantiateViewControllerWithIdentifier("drawerID") as! drawer
//        var nav = appDelegate.window?.rootViewController as? UINavigationController
//        
//        nav = UINavigationController.init(rootViewController:vc )
//        
//        hidesBottomBarWhenPushed = true
//        NSUserDefaults.standardUserDefaults().setObject("Capture", forKey: "transitionTo")
//        
//        let transition: CATransition = CATransition()
//        let timeFunc : CAMediaTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
//        transition.duration = 0.1
//        transition.timingFunction = timeFunc
//        transition.type = kCATransitionPush
//        transition.subtype = kCATransitionFromRight   //kCATransitionFromLeft
//        nav!.view.layer.addAnimation(transition, forKey: kCATransition)
//        appDelegate.window?.rootViewController = nav
//        appDelegate.window?.makeKeyAndVisible()
        
//        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        appDelegate.window = UIWindow(frame: UIScreen.mainScreen().bounds)
//        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc : drawer = storyboard.instantiateViewControllerWithIdentifier("drawerID") as! drawer
//        var nav = appDelegate.window?.rootViewController as? UINavigationController
//        
//        nav = UINavigationController.init(rootViewController:vc )
//        
//        hidesBottomBarWhenPushed = true
//        
//        let transition: CATransition = CATransition()
//        let timeFunc : CAMediaTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
//        transition.duration = 0.25
//        transition.timingFunction = timeFunc
//        transition.type = kCATransitionPush
//        transition.subtype = kCATransitionFromRight    //kCATransitionFromLeft
//        nav!.view.layer.addAnimation(transition, forKey: kCATransition)
//        appDelegate.window?.rootViewController = nav
//        appDelegate.window?.makeKeyAndVisible()
////        nav!.pushViewController(vc, animated: false)

}
    
    
    private var leftBarButtonItems: [AnyObject]?
    private var rightBarButtonItems: [AnyObject]?
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        serialHook.perform(key: .ForceReloadData, argument: ())
//        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "update", userInfo: nil, repeats: false)

        if(IPHONE6 == 1 || IPHONE5==1){
            if(self.navigationController!.navigationBar.frame.origin.y == 20.0){
                
            }else{
                self.navigationController!.navigationBar.frame = CGRectMake(0, 0, self.navigationController!.navigationBar.frame.size.width, self.navigationController!.navigationBar.frame.size.height+20)
                status = true
            }
        }

        
        if(IPHONE6P==1){
            if(self.navigationController!.navigationBar.frame.origin.y == 20.0){
                
            }else{
                self.navigationController!.navigationBar.frame = CGRectMake(0, 0, self.navigationController!.navigationBar.frame.size.width, self.navigationController!.navigationBar.frame.size.height+20)
                status = true
            }
        }
        main{
        NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(MyTimelinesTableViewController.update7), userInfo: nil, repeats: false)

        let valueStr = "\(NSUserDefaults.standardUserDefaults().valueForKey("moveToMomentsScreen"))"
        if valueStr.rangeOfString("yes") != nil{
        self.tabBarController?.selectedIndex = 1
            NSUserDefaults.standardUserDefaults().setObject("no", forKey:"moveToMomentsScreen")
        }
        }
    }
    
     func update7(){
        //refreshTableView()
        
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
        
        if (status) {
//            self.tableView.headerViewForSection(0)?.frame = CGRectMake((self.tableView.headerViewForSection(0)?.frame.origin.x)!,(self.tableView.headerViewForSection(0)?.frame.origin.y)!-20,(self.tableView.headerViewForSection(0)?.frame.size.width)!,(self.tableView.headerViewForSection(0)?.frame.size.height)!)
//            

            status = false
        }
        
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
           
            if Storage.session.currentUser?.name.isEmpty ?? true {
                print("str is nil or empty")
                return
            }
            
            super.users = [Storage.session.currentUser!]
            
            if !first {
                PFUser.currentUser()?.resetBadgeMineInBackground()
                self.navigationController?.tabBarItem.badgeValue = nil
                main{
                self.refreshControl?.endRefreshing()
                }
            } else {
                first = !first
            }
            
        })
    }
    
//    override func deletionCallback() -> MGSwipeButtonCallback? {
//        func result(sender: MGSwipeTableCell!) -> Bool {
//            let indexPath = self.tableView.indexPathForCell(sender)!
//            func performDelete(action: UIAlertAction!) {
//                
//                let alert = UIAlertController(title: LocalizedString.TimelineAlertDeleteWaitTitle.localized, message: local(.TimelineAlertDeleteWaitMessage), preferredStyle: .Alert)
//                self.presentAlertController(alert)
//                
//                // Delete the row from the data source
//                let del = users[indexPath.section].timelines[indexPath.row]
//                Storage.performRequest(ApiRequest.DestroyTimeline(del.state.uuid!), completion: { (json) -> Void in
//                    alert.dismissViewControllerAnimated(true) {
//                        if let error = json["error"] as? String {
//                            let alert = UIAlertController(title: local(.TimelineAlertDeleteErrorTitle), message: error, preferredStyle: .Alert)
//                            alert.addAction(UIAlertAction(title: local(.TimelineAlertDeleteErrorActionDismiss), style: .Default, handler: nil))
//                            self.presentAlertController(alert)
//                            return
//                        }
//                        let moms = del.moments
//                        async {
//                            for m in moms {
//                                if let url = m.localVideoURL {
//                                    do {
//                                        try NSFileManager.defaultManager().removeItemAtURL(url)
//                                    } catch _ {
//                                    }
//                                }
//                            }
//                        }
//                        
//                        for i in 0..<(Storage.session.currentUser?.timelines.count ?? 0) {
//                            let t = Storage.session.currentUser!.timelines[i]
//                            if del.state.uuid == t.state.uuid {
//                                Storage.session.currentUser!.timelines.removeAtIndex(i)
//                                main { self.tableView.reloadData() }
//                                break
//                            }
//                        }
//                    }
//                })
//            }
//            let confirmation = UIAlertController(title: local(.TimelineAlertDeleteConfirmTitle), message: local(.TimelineAlertDeleteConfirmMessage), preferredStyle: .Alert)
//            confirmation.addAction(UIAlertAction(title: local(.TimelineAlertDeleteConfirmActionDelete), style: .Destructive, handler: performDelete))
//            confirmation.addAction(UIAlertAction(title: local(.TimelineAlertDeleteConfirmActionCancel), style: .Cancel, handler: { [weak self] _ in
//                self?.tableView.cellForRowAtIndexPath(indexPath)?.setEditing(false, animated: true)
//            }))
//            presentAlertController(confirmation)
//            
//            return true
//        }
//        return result
//    }
    
    @IBAction func createTimelineActionButton(sender: AnyObject) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

        let controller = activeController()
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
               alert.addAction(title: local(.CreateSingleTimelineMessage), style: .Default) { _ in
            appDelegate.GroupTimeline = false
            appDelegate.headerLabelSTr = local(.CreateSingleTimelineMessage)
            main{
                self.performSegueWithIdentifier("ShowCreateTimeline", sender: self)
            }
        }
        alert.addAction(title: local(.CreateGroupTimelineMessage), style: .Default) { _ in
            appDelegate.GroupTimeline = true
            appDelegate.headerLabelSTr = local(.CreateGroupTimelineMessage)
            main{
                self.performSegueWithIdentifier("ShowCreateTimeline", sender: self)
            }
        }
        alert.addAction(title: local(.CreateGroupTimelineCancel), style: .Cancel, handler: nil)
        controller!.presentAlertController(alert)
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        if #available(iOS 9.0, *) {
            Manager.sharedInstance.session.getAllTasksWithCompletionHandler { (tasks) -> Void in
                tasks.forEach({ $0.cancel() })
            }
        } else {
            // Fallback on earlier versions
            Manager.sharedInstance.session.getTasksWithCompletionHandler({
                $0.0.forEach({ $0.cancel() })
                $0.1.forEach({ $0.cancel() })
                $0.2.forEach({ $0.cancel() })
            })
        }
        super.viewWillDisappear(animated)
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

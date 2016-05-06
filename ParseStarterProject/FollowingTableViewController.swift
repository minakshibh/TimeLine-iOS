//
//  FollowingTableViewController.swift
//  Timeline
//
//  Created by Valentin Knabel on 18.08.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import UIKit
import Parse

private func shouldShowRefreshControl() -> Bool {
    return followLoadingCount > 0
}

class FollowingTableViewController: SortedTimelineTableViewController {

    var active = false {
        didSet {
            followLoadingCountDidChange?(shouldShowRefreshControl())
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        self.hidesBottomBarWhenPushed = true
        self.refreshTableView()
        
        // Do any additional setup after loading the view.
        refreshControl!.tintColor = tableView.tintColor
        
        followLoadingCountDidChange = { [weak self] show in
//            print("Count: \(followLoadingCount)")
            main {
                if show || self?.active ?? false {
                    self?.refreshControl?.beginRefreshing()
                } else {
                    self?.refreshControl?.endRefreshing()
                }
            }
        }
        followLoadingCountDidChange?(shouldShowRefreshControl())
        
        let right: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "Back to Record"), style: .Plain, target: self, action: "goToRecordScreen")
        let left: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "Back to previous screen"), style: .Plain, target: self, action: "goToRecordScreen")
        navigationItem.rightBarButtonItem = right
        navigationItem.leftBarButtonItem = left
    }
    func goToRecordScreen(){
        
        let viewController = UIApplication.sharedApplication().windows[0].rootViewController?.childViewControllers[1] as? drawer
        viewController?.profileButtonClick()
//        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        appDelegate.window = UIWindow(frame: UIScreen.mainScreen().bounds)
//        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc : drawer = storyboard.instantiateViewControllerWithIdentifier("drawerID") as! drawer
//        var nav = appDelegate.window?.rootViewController as? UINavigationController
//        NSUserDefaults.standardUserDefaults().setObject("Capture", forKey: "transitionTo")
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
    }
    
    override func refreshTableView() {
        active = true
        var first = true
        do{
        Timeline.getTimelines(.TimelineFollowing) { tls in
            self.setTimelines(tls)
            //main{ removed 6may
                if !first {
                    PFUser.currentUser()?.resetBadgeFollowingInBackground()
                    
                    self.navigationController?.tabBarItem.badgeValue = nil
                    
                    
                    self.active = false
                } else {
                    first = !first
                }
            //}
        }
    }catch{
        var alert=UIAlertController(title: "CRASH", message: "App tried to crash at refreshing following screen", preferredStyle: UIAlertControllerStyle.Alert);
        self.showViewController(alert, sender: self);
            }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

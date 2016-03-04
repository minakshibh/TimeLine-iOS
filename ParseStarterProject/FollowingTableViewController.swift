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
        
        
        // Do any additional setup after loading the view.
        refreshControl!.tintColor = tableView.tintColor
        
        followLoadingCountDidChange = { [weak self] show in
            print("Count: \(followLoadingCount)")
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
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc : drawer = storyboard.instantiateViewControllerWithIdentifier("drawerID") as! drawer
        
        hidesBottomBarWhenPushed = true
        
        let transition: CATransition = CATransition()
        let timeFunc : CAMediaTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.duration = 0.25
        transition.timingFunction = timeFunc
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight    //kCATransitionFromLeft
        self.navigationController!.view.layer.addAnimation(transition, forKey: kCATransition)
        self.navigationController!.pushViewController(vc, animated: false)
    }
    
    override func refreshTableView() {
        active = true
        var first = true
        
        Timeline.getTimelines(.TimelineFollowing) { tls in
            self.setTimelines(tls)
            
            if !first {
                PFUser.currentUser()?.resetBadgeFollowingInBackground()
                self.navigationController?.tabBarItem.badgeValue = nil
                
                self.active = false
            } else {
                first = !first
            }
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

//
//  AllNotificationList.swift
//  Timeline
//
//  Created by Br@R on 15/02/16.
//  Copyright © 2016 Conclurer GbR. All rights reserved.
//

import Foundation
import UIKit
import Parse
import SDWebImage

class AllNotificationList: UITableViewController {
    
    var payloadArray :NSMutableArray = []
    let notificationListArray : NSMutableArray = []
    var page_id :String=""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delay (0.01) {
            self.allNotificationsAPi()
        }
           // Do any additional setup after loading the view.
    }
    override func viewDidDisappear(animated: Bool) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.hideActivityIndicator()
    }
     func allNotificationsAPi() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.showActivityIndicator()
        
        Storage.performRequest(ApiRequest.UserAllNotifications(page_id), completion: { (json) -> Void in
            print(json)
            if let pageId = json["page_id"] {
                self.page_id = String(pageId)
            }
            if let results = json["result"] as? [[String: AnyObject]]
            {
                for not in results {
                    if let raw = not["payload"] as? NSString,
                        let data = raw.dataUsingEncoding(NSUTF8StringEncoding),
                        let payload = (try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)) as? [String: AnyObject]
                    {
                        self.notificationListArray.addObject(not)
                        self.payloadArray.addObject(payload)
                    }
                }
            }
            appDelegate.notificationCount = 0
            appDelegate.hideActivityIndicator()
            self.reloadData()
            
        })
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notificationListArray.count;
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "NotificationTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! NotificationTableViewCell
        
    if let raw = self.notificationListArray[indexPath.row] as? NSDictionary
        {
            let dateStr = raw["created_at"] as! String
            
            let f = NSDateFormatter()
            f.locale = NSLocale(localeIdentifier: "en_US_POSIX")
            f.timeZone = NSTimeZone(name: "UTC")
            f.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'"
            
            let endDate:NSDate = f.dateFromString(dateStr)!
            let elapsedTime = NSDate().timeIntervalSinceDate(endDate)

            var timeStr = ""
            let duration = Int(elapsedTime)
            let minutes = duration / 60
            let hours = minutes / 60
            let days = hours / 24
            let months = days / 30
            let years = days / 365
            
            if (years != 0)
            {
                timeStr = String(years) + "y"
            }
            if (months != 0)
            {
                timeStr = String(months) + "m"
            }
            else if(days != 0)
            {
                timeStr = String(days) + "d"
            }
            else if(hours != 0)
            {
                timeStr = String(hours) + "h"
            }
            else if(minutes != 0)
            {
                timeStr = String(minutes) + "m"
            }
            else{
                timeStr = String(duration) + "s"
            }
            
            let notifyStr = raw["notification"] as! String
            let userNameStr = raw["username"] as? String ?? ""
            
            cell.userNameLabel?.text = "@" + userNameStr
            cell.notificationTxtLabel?.text = notifyStr
            cell.timeLabel?.text = timeStr

            
            let placeHolderimg = UIImage(named: "default-user-profile")
            let imageName = raw["user_image"] as? String ?? ""
            cell.photoImageView.sd_setImageWithURL(NSURL (string: imageName), placeholderImage:placeHolderimg)
            
            let showProfileBtn: UIButton = UIButton(frame: CGRectMake(0, 3, 60, 54))
            showProfileBtn.backgroundColor = UIColor.clearColor()
            showProfileBtn.addTarget(self, action: "showProfileBtn:", forControlEvents: UIControlEvents.TouchUpInside)
            showProfileBtn.tag = indexPath.row               // change tag property
            cell.contentView.addSubview(showProfileBtn) // add to view as subview

        }
        return cell
    }
   
  
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let isEqual = (page_id == "<null>")
        if isEqual || page_id.isEmpty
        {
            return 0.0
        }
        else
        {
            return 40.0
        }
    }

    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 40))
        footerView.backgroundColor = UIColor.blackColor()
        
        
        
        let btn: UIButton = UIButton(frame: CGRectMake(0, 0, tableView.frame.size.width, 40))
        btn.backgroundColor = UIColor.clearColor()
        btn.setTitle("Load More", forState: UIControlState.Normal)
        btn.addTarget(self, action: "loadMoreTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        btn.tag = 1               // change tag property
        footerView.addSubview(btn) // add to view as subview
        
        return footerView
    }
    
    func loadMoreTapped(sender: UIButton!) {
        let btnsendtag: UIButton = sender
        if btnsendtag.tag == 1 {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.hideActivityIndicator()
            allNotificationsAPi()
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let payload = self.payloadArray[indexPath.row] as! [String : AnyObject]
      
        processAsync(payload: payload) { link in
            if let link = link {
                    self.handle(deepLink: link)
                }
        }

        self.process(payload: payload)
        switch payload["action"] as? String ?? "" {
        case "follow_request":
            print("follow_request")
            break

        case "create":
            print("create")
            break
            
        case "like" :
            print("like")
            break
            
        case "follow":
            print("follow")
            break
            
            
        default:
            break
        }
    }
       // navigationItem.title = order
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func handle(deepLink link: DeepLink?) {
        main {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let push = storyboard.instantiateViewControllerWithIdentifier("PushFetchViewController") as! PushFetchViewController
            if PFUser.currentUser() != nil {
                push.link = link
                self.presentViewController(push, animated: true, completion: nil)
            }

        }
    }
    
    func process(payload payload: [String: AnyObject]) -> DeepLink? {
        let link = DeepLink.from(payload: payload)
        
        // increase counter
        if let link = link {
            switch link {
            case .MomentLink(_, let uuid, _):
                DeepLink.timeline(uuid: uuid, completion: { (tl) -> Void in
                    tl.hasNews = true
                    tl.parent?.hasNews = true
                    self.finish(payload: payload)
                })
            case .TimelineLink(_, let uuid):
                DeepLink.timeline(uuid: uuid, completion: { (tl) -> Void in
                    tl.hasNews = true
                    tl.parent?.hasNews = true
                    self.finish(payload: payload)
                })
            case .UserLink(_, _, let uuid):
                DeepLink.user(uuid: uuid, completion: { (u) -> Void in
                    u.hasNews = true
                    self.finish(payload: payload)
                })
            }
        }
        return link
    }
   
    func processAsync(payload payload: [String: AnyObject], completion: (DeepLink?) -> Void) {
        let link = DeepLink.from(payload: payload)
        
        // increase counter
        if let link = link {
            switch link {
            case .MomentLink(_, let uuid, _):
                DeepLink.timeline(uuid: uuid, completion: { (tl) -> Void in
                    tl.hasNews = true
                    tl.parent?.hasNews = true
                    self.finish(payload: payload)
                    completion(link)
                })
            case .TimelineLink(_, let uuid):
                DeepLink.timeline(uuid: uuid, completion: { (tl) -> Void in
                    tl.hasNews = true
                    tl.parent?.hasNews = true
                    self.finish(payload: payload)
                    completion(link)
                })
            case .UserLink(_, _, let uuid):
                DeepLink.user(uuid: uuid, completion: { (u) -> Void in
                    u.hasNews = true
                    self.finish(payload: payload)
                    completion(link)
                })
            }
        } else {
            completion(nil)
        }
    }
    private func finish(payload payload: [String: AnyObject]) {
        Storage.session.notificationDate = NSDate()
        Storage.save()
    }
    
    func showProfileBtn(sender: UIButton!) {
        let btnsendtag: UIButton = sender
        let payload = self.notificationListArray[btnsendtag.tag] as! [String : AnyObject]
        processAsyncForUser(payload: payload) { link in
            self.handle(deepLink: link)
        }
    }
    
    func processAsyncForUser(payload payload: [String: AnyObject], completion: (DeepLink?) -> Void) {
        let link = DeepLink.fromNotification(payload: payload)
        
        // increase counter
        if let link = link {
            switch link {
            case .MomentLink(_, let uuid, _):
                DeepLink.user(uuid: uuid, completion: { (u) -> Void in
                    u.hasNews = true
                    self.finish(payload: payload)
                    completion(link)
                })
            case .TimelineLink(_, let uuid):
                DeepLink.user(uuid: uuid, completion: { (u) -> Void in
                    u.hasNews = true
                    self.finish(payload: payload)
                    completion(link)
                })
            case .UserLink(_, _, let uuid):
                DeepLink.user(uuid: uuid, completion: { (u) -> Void in
                    u.hasNews = true
                    self.finish(payload: payload)
                    completion(link)
                })
            }
        }
        else {
            completion(nil)
        }
    }
}
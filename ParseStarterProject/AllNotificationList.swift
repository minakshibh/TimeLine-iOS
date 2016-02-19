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
    
     func allNotificationsAPi() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.showActivityIndicator()
        
        Storage.performRequest(ApiRequest.UserAllNotifications(page_id), completion: { (json) -> Void in
            print(json)
            if let results = json["result"] as? [[String: AnyObject]]
            {
                if let pageId = json["page_id"] {
                    self.page_id = String(pageId)
                }
                
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
            let notifyStr = raw["notification"] as! String
            cell.nameLabel?.text = notifyStr
        }
      
      //  cell.photoImageView.image = UIImage(named : self.itemsImages[indexPath.row])
        
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
}

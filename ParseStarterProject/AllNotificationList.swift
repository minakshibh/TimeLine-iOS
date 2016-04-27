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
    var timeline_id :String=""
    var timelineLikeOrComment :Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        delay (0.01) {
            self.allNotificationsAPI()
        }
        self.navigationController?.navigationBarHidden = false
           // Do any additional setup after loading the view.
    }
    override func viewDidDisappear(animated: Bool) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.hideActivityIndicator()
    }
 
    @IBAction func refreshTable(sender: AnyObject) {
        self.page_id = ""
        self.allNotificationsAPI()
        self.refreshControl!.endRefreshing()

    }
    
     func allNotificationsAPI() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.showActivityIndicator()
        
        Storage.performRequest(ApiRequest.UserAllNotifications(page_id), completion: { (json) -> Void in
            if let pageId = json["page_id"] {
               if (self.page_id.isEmpty)
               {
                Storage.session.notificationDate = NSDate()
                Storage.save()
                self.notificationListArray.removeAllObjects()
                self.payloadArray.removeAllObjects()
                }
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
                timeStr = String(years) + "year"
            }
            if (months != 0)
            {
                timeStr = String(months) + "mon"
            }
            else if(days != 0)
            {
                timeStr = String(days) + "day"
            }
            else if(hours != 0)
            {
                timeStr = String(hours) + "hrs"
            }
            else if(minutes != 0)
            {
                timeStr = String(minutes) + "min"
            }
            else{
                timeStr = String(duration) + "sec"
            }
            
            let notifyStr = raw["notification"] as! String
            let userNameStr = raw["username"] as? String ?? ""
            
            var notifyStrArr = notifyStr.componentsSeparatedByString(" ")
            let userName : String = notifyStrArr [0]
            cell.fullNameLabel?.text = ""

            var fullname : NSString = ""
            if let firstName = raw["first_name"] as? NSString
            {
                fullname = firstName
                if let lastName = raw["last_name"] as? NSString
                {
                    fullname = "\(firstName) \(lastName)"
                }
            }
           
          
           
            cell.timeLabel?.text = timeStr
            
            let attributedString = NSMutableAttributedString(string: notifyStr as String, attributes: [NSFontAttributeName:UIFont.systemFontOfSize(11.0)])
            
            let boldFontAttribute = [NSFontAttributeName: UIFont.boldSystemFontOfSize(11.0)]
            
            
            // Part of string to be bold
            attributedString.addAttributes(boldFontAttribute, range:  NSRange(location: 0,length: userName.characters.count))
//            cell.fullNameLabel.text = "FirstName"

            if (fullname == "")
            {
                cell.fullNameLabel.font = UIFont.boldSystemFontOfSize(10.0)
                cell.userNameLabel.font = UIFont.systemFontOfSize(11.0)
                cell.userNameLabel.textColor = UIColor.blackColor()
                cell.fullNameLabel.textColor = UIColor.grayColor()

                cell.fullNameLabel?.text = "@" + userNameStr
                cell.userNameLabel?.attributedText = attributedString
                cell.notificationTxtLabel?.text = ""
            }
            else
            {
                cell.fullNameLabel.font = UIFont.boldSystemFontOfSize(11.0)
                cell.userNameLabel.font = UIFont.systemFontOfSize(10.0)
                cell.userNameLabel.textColor = UIColor.grayColor()
                cell.fullNameLabel.textColor = UIColor.blackColor()
                
                cell.fullNameLabel?.text = fullname as String
                cell.userNameLabel?.text = "@" + userNameStr
                cell.notificationTxtLabel?.attributedText = attributedString
            }

            
            let placeHolderimg = UIImage(named: "default-user-profile")
            let imageName = raw["user_image"] as? String ?? ""
            cell.photoImageView.sd_setImageWithURL(NSURL (string: imageName), placeholderImage:placeHolderimg)
            
            let showProfileBtn: UIButton = UIButton(frame: CGRectMake(0, 3, 60, 54))
            showProfileBtn.backgroundColor = UIColor.clearColor()
            showProfileBtn.addTarget(self, action: "showProfileBtn:", forControlEvents: UIControlEvents.TouchUpInside)
            showProfileBtn.tag = indexPath.row               // change tag property
            cell.contentView.addSubview(showProfileBtn) // add to view as subview

            if (indexPath.row == self.notificationListArray.count - 1 && page_id != "<null>")
            {
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                appDelegate.hideActivityIndicator()
                allNotificationsAPI()
            }
            tableView.allowsSelection = true
            cell.selectionStyle = UITableViewCellSelectionStyle.Gray


        }
        return cell
    }
    
  
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let notificationPayload = self.notificationListArray[indexPath.row] as! [String : AnyObject]
        let payload = self.payloadArray[indexPath.row] as! [String : AnyObject]

        timelineLikeOrComment = false
        
         if let tid = payload["timeline_id"] as? String
        {
            self.timeline_id = tid
            switch payload["action"] as? String ?? "" {
            case "follow_request":
                print("follow_request")
                break
                
            case "create":
                print("create")
                break
                
            case "like" :
                timelineLikeOrComment = true
                print("like")
                break
                
            case "follow":
                timelineLikeOrComment = true
                print("follow")
                break
                
                
            default:
                break
            }
        }
        processAsyncForUser(payload: notificationPayload) { link in
            if let link = link {
                self.handle(deepLink: link)
                self.fetchData(link)
            }
        }
        
    }
       // navigationItem.title = order
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handle(deepLink link: DeepLink?) {
        main {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let push = storyboard.instantiateViewControllerWithIdentifier("PushFetchViewController") as! PushFetchViewController
            if PFUser.currentUser() != nil {
                push.link = link
                push.timeline_id = self.timeline_id
                //push.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
                
//                let transition: CATransition = CATransition()
//                let timeFunc : CAMediaTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
//                transition.duration = 0.1
//                transition.timingFunction = timeFunc
//                transition.type = kCATransitionPush
//                transition.subtype = kCATransitionFromLeft    //kCATransitionFromLeft
//                self.view.window!.layer.addAnimation(transition, forKey: kCATransition)

                //self.presentViewController(push, animated: true, completion: nil)
            }

        }
    }
    
    func fetchData(link: DeepLink?) {
        main {
            switch link! {
                
            case let .UserLink(_, _, uuid):
                DeepLink.user(uuid: uuid) { u in
                    self.performSegueWithIdentifier("ShowUser", sender: u)
                }
                
            case let .TimelineLink(_, uuid):
                DeepLink.timeline(uuid: uuid) { t in
                    self.performSegueWithIdentifier("ShowTimeline", sender: t)
                }
                
            case let .MomentLink(_, tid, vid):
                DeepLink.timeline(uuid: tid) { t in
                    t.reloadMoments {
                        let m = Storage.findMoment(vid)
                        self.performSegueWithIdentifier("ShowMoment", sender: m)
                    }
                }
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        finished = true
        
        switch segue.identifier ?? "" {
        case "ShowUser":
            let dest = (segue.destinationViewController as! UINavigationController).topViewController as! UserSummaryTableViewController
            dest.timeline_id = self.timeline_id
            dest.user = sender as! User
            
        case "ShowTimeline":
            let dest = (segue.destinationViewController as! UINavigationController).topViewController as! TimelinePlaybackViewController
            
            dest.timeline = sender as! Timeline
            
        case "ShowMoment":
            let dest = (segue.destinationViewController as! UINavigationController).topViewController as! TimelinePlaybackViewController
            dest.moment = sender as? Moment
            
        default:
            break
        }
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
                    completion(link)
                })
            case .TimelineLink(_, let uuid):
                DeepLink.timeline(uuid: uuid, completion: { (tl) -> Void in
                    tl.hasNews = true
                    tl.parent?.hasNews = true
                    completion(link)
                })
            case .UserLink(_, _, let uuid):
                DeepLink.user(uuid: uuid, completion: { (u) -> Void in
                    u.hasNews = true
                    completion(link)
                })
            }
        } else {
            completion(nil)
        }
    }
    
    func showProfileBtn(sender: UIButton!) {
        let btnsendtag: UIButton = sender
        let indexPath = NSIndexPath(forRow: sender.tag, inSection: 0)

        let cell = tableView.cellForRowAtIndexPath(indexPath) as! NotificationTableViewCell
        

        UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            cell.photoImageView.alpha = 0.3
            }, completion: nil)
        UIView.animateWithDuration(0.3, delay: 0.3, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            cell.photoImageView.alpha = 1.0
            }, completion: nil)
        
        delay(0.4) {
        let payload = self.notificationListArray[btnsendtag.tag] as! [String : AnyObject]
        self.processAsyncForUser(payload: payload) { link in
            self.handle(deepLink: link)
        }
        }
    }

    func processAsyncForUser(payload payload: [String: AnyObject], completion: (DeepLink?) -> Void) {
        let link = DeepLink.fromNotification(payload: payload , likeOrCreateTimeline: timelineLikeOrComment )
        
        // increase counter
        if let link = link {
            switch link {
            case .MomentLink(_, let uuid, _):
                DeepLink.user(uuid: uuid, completion: { (u) -> Void in
                    u.hasNews = true
                    completion(link)
                })
            case .TimelineLink(_, let uuid):
                DeepLink.user(uuid: uuid, completion: { (u) -> Void in
                    u.hasNews = true
                    completion(link)
                })
            case .UserLink(_, _, let uuid):
                DeepLink.user(uuid: uuid, completion: { (u) -> Void in
                    u.hasNews = true
                    completion(link)
                })
            }
        }
        else {
            completion(nil)
        }
    }
}

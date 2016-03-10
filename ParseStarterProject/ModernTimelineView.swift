//
//  ModernTimelineView.swift
//  Timeline
//
//  Created by Valentin Knabel on 17.11.15.
//  Copyright © 2015 Conclurer GbR. All rights reserved.
//

import UIKit
import Foundation
import SWFrameButton
import ConclurerHook
import KGModal
import Alamofire
import SDWebImage


class ModernTimelineView: UIView, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIScrollViewDelegate {
    let timelineCommentView = UIView()
    let commentTextField = UITextField()
    var payloadArray :NSMutableArray = []
    let notificationListArray : NSMutableArray = []
    let commentlist = UITableView()
    let commentTextfeildView = UIView()
    var scrollView = UIScrollView()
    var scrollMomentArray : NSArray = []
    var momentScroller = UIScrollView()
    var invitedFriendsArray : NSMutableArray = []
    var InvitedFriends_id : NSMutableArray = []
    var InvitedFriendsIdSTr : NSString = ""
    var selectedTimelineMomentArray : NSArray = []
    @IBOutlet var groupTimelineButton: UIButton!
    @IBOutlet var descriptionLabel: UILabel!


    lazy var behavior: ModernTimelineBehavior = {
        let behavior = ModernTimelineBehavior()
        behavior.modernTimelineView = self
        return behavior
    }()
    
    var timeline: Timeline? {
        get {
            return behavior.timeline
        }
        set {
            behavior.timeline = newValue
            main{
            self.scrollMomentArray = []
            self.scrollMomentArray = self.behavior.timeline?.dict["moments"]! as! NSArray
            var Yaxis :CGFloat = 0
            self.momentScroller.subviews.forEach {
                ( view) -> () in
                if (view is UIButton) {
                    
                    view.removeFromSuperview()
                
                }
            }
            self.momentScroller.frame = CGRectMake(CGFloat(self.frame.size.width - 80-CGFloat(5*isiphone6Plus())+CGFloat(10*isiPhone5())), self.firstMomentPreview.frame.origin.y, CGFloat(70+5*isiphone6Plus()-10*isiPhone5()), CGFloat(276 + 30*isiphone6Plus()-45*isiPhone5()))
            self.momentScroller.delegate = self
            self.momentScroller.showsVerticalScrollIndicator = false
            for var i = 0; i < self.scrollMomentArray.count; i++ {
                
                let villainButton = UIButton(frame: CGRect(x: 0, y: Yaxis, width: self.momentScroller.frame.size.width, height: self.momentScroller.frame.size.width))
                villainButton.titleLabel?.font =  UIFont.boldSystemFontOfSize(15)
                villainButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
                
                if let raw = self.scrollMomentArray[i] as? NSDictionary
                {
                    let notifyStr = raw["video_thumb"] as! String
                    
                    let momentNumbering = UILabel()
                    momentNumbering.frame = CGRectMake(CGFloat((villainButton.frame.size.width/2)-10), CGFloat((villainButton.frame.size.height/2)-10), 20, 20)
                    momentNumbering.layer.cornerRadius = 10
                    momentNumbering.layer.masksToBounds = true
                    momentNumbering.font = UIFont.boldSystemFontOfSize(15)
                    momentNumbering.textAlignment = .Center
                    momentNumbering.backgroundColor = UIColor(white: 1, alpha: 0.35)
                    momentNumbering.textColor = UIColor(white: 0, alpha: 0.7 )
                    momentNumbering.text = "\(i + 1)"
                    
                    villainButton.addSubview(momentNumbering)
                    
                    villainButton.sd_setBackgroundImageWithURL(NSURL(string: notifyStr), forState: .Normal)
                }
                villainButton.tag = i
                villainButton.addTarget(self, action: "momentButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
                
                    self.momentScroller.addSubview(villainButton)
                
                Yaxis = Yaxis + self.momentScroller.frame.size.width
            }
            self.momentScroller.contentSize = CGSizeMake(self.momentScroller.frame.size.width, Yaxis)
            self.momentScroller.backgroundColor = UIColor.from(hexString:"#e7e7e7")
            
            self.addSubview(self.momentScroller)
//                self.previewItems.append(self.momentScroller)
            }
            
            refresh()
            
            self.groupTimelineButton.hidden = !(behavior.timeline?.groupTimeline)!
            self.commentButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 3, bottom: 0, right: 0)

            if let timelineCount = behavior.timeline?.commentsCount {
                self.commentButton.setTitle("\(timelineCount)", forState: .Normal)
            }
            else{
                self.commentButton.setTitle("0", forState: .Normal)
            }
            if let description = behavior.timeline?.description {
                self.descriptionLabel.text = description
            }

            
        }
    }
    
    func momentButtonPressed(sender: UIButton){
        //print(sender.tag)
        self.momentScroller.hidden = true
        selectedTimelineMomentArray = behavior.timeline?.dict["moments"]! as! NSArray
        print(selectedTimelineMomentArray[sender.tag])

        behavior.playMoment(sender, moment: Moment.init(dict: selectedTimelineMomentArray[sender.tag] as! [String : AnyObject], parent: behavior.timeline))
        
    }
    
    var commentArray = NSMutableArray()
    var tagArray = NSMutableArray()
    var momentArray = NSMutableArray()
    

    @IBAction func groupTimelineButtonAction(sender: AnyObject) {
        
        let controller = activeController()
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        if !(self.timeline?.isOwn)!
        {
            return
        }
        if self.timeline?.parent?.uuid != Storage.session.uuid
        {
            alert.addAction(title: local(.ShowViewMembersGroupTimelineMessage), style: .Default) { _ in
            }
        }
        else if self.timeline?.adminId == self.timeline?.parent?.uuid
        {
            alert.addAction(title: local(.ShowViewMembersGroupTimelineMessage), style: .Default) { _ in
            }
            alert.addAction(title: local(.ShowExitGroupTimelineMessage), style: .Default) { _ in
                self.deleteGroupAPI()
            }
        }
        else
        {
            alert.addAction(title: local(.ShowViewMembersGroupTimelineMessage), style: .Default) { _ in
            }
            alert.addAction(title: local(.ShowLeaveGroupTimelineMessage), style: .Default) { _ in
                self.leaveGroupAPI()
            }
        }
        alert.addAction(title: local(.ShowGroupTimelineCancel), style: .Cancel, handler: nil)
        controller!.presentAlertController(alert)
    }
    
    
    func deleteGroupAPI()
    {
        let controller = activeController()
        
        self.timeline!.delete { (error) -> () in
            if let error = error {
                let alert = UIAlertController(title: local(.TimelineAlertDeleteErrorTitle), message: error, preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: local(.TimelineAlertDeleteErrorActionDismiss), style: .Default, handler: nil))
                controller!.presentAlertController(alert)
                return
            }
            
            for i in 0..<(Storage.session.currentUser?.timelines.count ?? 0) {
                let t = Storage.session.currentUser!.timelines[i]
                if self.timeline!.state.uuid == t.state.uuid {
                    Storage.session.currentUser!.timelines.removeAtIndex(i)
                    serialHook.perform(key: .ForceReloadData, argument: ())
                    break
                }
            }
        }
    }
    
    func leaveGroupAPI()
    {
        let controller = activeController()
        
        self.leaveGroup({ (error) -> () in
            if let error = error {
                let alert = UIAlertController(title: local(.TimelineAlertDeleteErrorTitle), message: error, preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: local(.TimelineAlertDeleteErrorActionDismiss), style: .Default, handler: nil))
                controller!.presentAlertController(alert)
                return
            }
            
            for i in 0..<(Storage.session.currentUser?.timelines.count ?? 0) {
                let t = Storage.session.currentUser!.timelines[i]
                if self.timeline!.state.uuid == t.state.uuid {
                    Storage.session.currentUser!.timelines.removeAtIndex(i)
                    serialHook.perform(key: .ForceReloadData, argument: ())
                    break
                }
            }
        })
    }
    func leaveGroup(completion: (error: String?) -> ()) {
        let user = Storage.session.uuid! as String
        let timelineID = self.timeline?.state.uuid
        Storage.performRequest(ApiRequest.LeaveGroupTimeline((self.timeline?.state.uuid!)!, Storage.session.uuid!), completion: { (json) -> Void in
            if let error = json["error"] as? String {
                defer { completion(error: error) }
            } else {
                completion(error: nil)
                let moms = self.timeline?.moments
                async {
                    for m in moms! {
                        if let url = m.localVideoURL {
                            do {
                                try NSFileManager.defaultManager().removeItemAtURL(url)
                            } catch {
                                print("Timeline.delete(completion:) could not remove \(url): \n\(error)")
                            }
                        }
                    }
                }
            }
        })
        
    }
    
    
    @IBAction func timelineCommentClick(sender: UIButton!){
        print("timeline id: \(timeline!.uuid!)")
        print(timeline!.dict["moments"]!)  //show all moments
        
        main{
            self.showCommentPopup()
        }
 
    }
    
    func showCommentPopup(){
        
        Storage.performRequest(ApiRequest.TimelineComments(timeline!.uuid!), completion: { (json) -> Void in
            print(json)
            if let raw = json["result"] as? NSMutableArray{
                self.commentArray = raw
            }
            self.commentlist.reloadData()
            main{
                let screenRect = UIScreen.mainScreen().bounds
                let screenWidth = screenRect.size.width;
                let screenHeight = screenRect.size.height;
                self.timelineCommentView.frame = CGRectMake(0, 0, screenWidth, screenHeight);
                self.timelineCommentView.backgroundColor = UIColor(white: 1 , alpha: 1)
                self.timelineCommentView.alpha = 1
                
                
                let Statusbarview = UIView()
                Statusbarview.frame = CGRectMake(0, 0, screenWidth, 20)
                Statusbarview.backgroundColor = UIColor.redNavbarColor()
                self.timelineCommentView.addSubview(Statusbarview)
                
                let commentScreenTitle = UILabel()
                commentScreenTitle.frame = CGRectMake(0, 20, screenWidth, 44)
                commentScreenTitle.font = UIFont.systemFontOfSize(18)
                commentScreenTitle.textAlignment = .Center
                commentScreenTitle.backgroundColor = UIColor.redNavbarColor()
                commentScreenTitle.textColor = UIColor.whiteColor()
                commentScreenTitle.text = "Comments"
                self.timelineCommentView.addSubview(commentScreenTitle)
                
                // close button comment section
                let closeButton  = UIButton()
                closeButton.frame = CGRectMake(0, 20, 50, 44);
                closeButton.setImage(UIImage(assetIdentifier: .BackIndicator) as UIImage?, forState: .Normal)
                closeButton.addTarget(self, action: "btnTouched", forControlEvents:.TouchUpInside)
                self.timelineCommentView.addSubview(closeButton)
                
                // table view declaration
                
                self.commentlist.frame         =   CGRectMake(10, 64, self.timelineCommentView.frame.width-20, self.timelineCommentView.frame.height-144);
                self.commentlist.delegate      =   self
                self.commentlist.dataSource    =   self
                self.commentlist.backgroundColor = UIColor.clearColor()
                self.commentlist.separatorStyle = .None
                self.commentlist.tableFooterView = UIView()
                self.commentlist.registerClass(UITableViewCell.self, forCellReuseIdentifier: "commentCell")
                self.timelineCommentView.addSubview(self.commentlist)
                
                
                self.commentTextfeildView.frame = CGRectMake(0, self.timelineCommentView.frame.size.height-80, self.timelineCommentView.frame.size.width, 80)
                self.commentTextfeildView.backgroundColor = UIColor.groupTableViewBackgroundColor()
                self.timelineCommentView.addSubview(self.commentTextfeildView)
                
                
                self.commentTextField.frame = CGRectMake(10, 15, CGFloat(295+40*isiphone6Plus()-55*isiPhone5()), 50)
                self.commentTextField.layer.cornerRadius = 4
                self.commentTextField.backgroundColor = UIColor.whiteColor()
                self.commentTextField.autocorrectionType = .No
                let leftPadding = UIImageView()
                leftPadding.frame = CGRectMake(0.0, 0.0, 10.0, 50);
                leftPadding.contentMode = UIViewContentMode.Center
                self.commentTextField.leftViewMode = UITextFieldViewMode.Always
                self.commentTextField.leftView = leftPadding
                self.commentTextField.delegate = self
                let attributes = [
                    NSForegroundColorAttributeName: UIColor.lightGrayColor(),
                    NSFontAttributeName : UIFont.boldSystemFontOfSize(20)
                ]
                self.commentTextField.attributedPlaceholder = NSAttributedString(string: "Share a comment", attributes:attributes)
                self.commentTextfeildView.addSubview(self.commentTextField)
                
                let button   = UIButton(type: UIButtonType.Custom) as UIButton
                button.frame = CGRectMake(self.commentTextField.frame.origin.x + self.commentTextField.frame.size.width+10, 15, 50, 50)
                button.layer.cornerRadius = 4
                button.backgroundColor = UIColor.redColor()
                button.setTitle("Send", forState: UIControlState.Normal)
                button.addTarget(self, action: "CommentSendButtonAction", forControlEvents: UIControlEvents.TouchUpInside)
                self.commentTextfeildView.addSubview(button)
                
                KGModal.sharedInstance().closeButtonType = KGModalCloseButtonType.None
                KGModal.sharedInstance().showWithContentView(self.timelineCommentView)
            }
        })
        
        
        
    }
    
    func CommentSendButtonAction(){
        
        // Trim all whitespace
        
        let TrimString = commentTextField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        print(TrimString)
        
        if(TrimString == ""){
        let alert = UIAlertView()
        alert.title = ""
        alert.message = "Please enter your comment first."
        alert.addButtonWithTitle(local(.MomentAlertUploadErrorActionDismiss))
        alert.show()
            return
        }
        
        let emoData = commentTextField.text!.dataUsingEncoding(NSNonLossyASCIIStringEncoding)
        let goodValue = NSString.init(data: emoData!, encoding: NSUTF8StringEncoding)
        
        Storage.performRequest(ApiRequest.TimelinePostComment(timeline!.uuid!, goodValue! as PARAMS , InvitedFriendsIdSTr as UserIdString), completion: { (json) -> Void in
            print(json)
            main{
                Storage.performRequest(ApiRequest.TimelineComments(self.timeline!.uuid!), completion: { (json) -> Void in
                    print(json)
                    if let raw = json["result"] as? NSMutableArray{
                        self.commentArray = raw
                        
                    }
                    main{
                        self.commentlist.reloadData()
                        let numberOfRows = self.commentlist.numberOfRowsInSection(0)
                        if numberOfRows > 0 {
                            let indexPath = NSIndexPath(forRow: numberOfRows-1, inSection: 0)
                            self.commentlist.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
                        }
                    }
                    
                })
                
                self.commentTextField.text = ""
                self.commentTextField.resignFirstResponder()
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    self.commentTextfeildView.frame = CGRectMake(0, self.timelineCommentView.frame.size.height-80, self.timelineCommentView.frame.size.width, 80)
                    
                })
            }
            
            
        })
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.commentTextfeildView.frame = CGRectMake(0, self.timelineCommentView.frame.size.height-290, self.timelineCommentView.frame.size.width, 80)
        })
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.commentTextfeildView.frame = CGRectMake(0, self.timelineCommentView.frame.size.height-80, self.timelineCommentView.frame.size.width, 80)
            textField.resignFirstResponder()
        })
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if(textField == self.commentTextField)
        {
            if(string == "@"){
                print("hello")
                Storage.performRequest(ApiRequest.GetTagUsers, completion: { (json) -> Void in
                     print(json)
                    if let raw = json["result"] as? NSMutableArray{
                        self.tagArray = raw
                        print(self.tagArray)
 
                    }
                    
                    main{
                        
                        var Yaxis :CGFloat = 0
                        self.scrollView.frame = CGRectMake(0, self.commentTextfeildView.frame.origin.y-250, self.timelineCommentView.frame.size.width, 250)
                        self.scrollView.delegate = self
                        
                        for var i = 0; i < self.tagArray.count; i++ {

                            
                            let villainButton = UIButton(frame: CGRect(x: 0, y: Yaxis, width: self.commentTextfeildView.frame.size.width, height: 50))
                            
                            villainButton.layer.cornerRadius = 0
                            villainButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
                            villainButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
                            villainButton.titleEdgeInsets = UIEdgeInsetsMake(
                                0, 60, 0.0, 0)
                            villainButton.backgroundColor = UIColor.whiteColor()
                            villainButton.tag = i
                            if let raw = self.tagArray[i] as? NSDictionary
                            {
                                villainButton.setTitle("@\(raw["name"]!)", forState: UIControlState.Normal)
                                let userimage = UIImageView()
                                userimage.frame = CGRectMake(10, 5, 40, 40)
                                userimage.layer.cornerRadius = 20
                                userimage.clipsToBounds = true
                                userimage.sd_setImageWithURL(NSURL(string: (raw["image"] as? String)!))
                                villainButton.addSubview(userimage)
//                                villainButton.sd_setBackgroundImageWithURL(NSURL(string: (raw["image"] as? String)!), forState: .Normal)
                            }
                            villainButton.addTarget(self, action: "villainButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
                            //villainButton.tag = Int(element.id)
                            self.scrollView.addSubview(villainButton)
                           Yaxis = Yaxis + 51
                        }
                        self.scrollView.contentSize = CGSizeMake(self.timelineCommentView.frame.size.width, Yaxis)
                        self.scrollView.backgroundColor = UIColor.groupTableViewBackgroundColor()
                        self.timelineCommentView.addSubview(self.scrollView)
                    }
                })
            }
        }
        return true
    }
    
    func villainButtonPressed(sender:UIButton!){
        print(sender.tag)
        var user_id : NSString = ""
        if let dataDict = self.tagArray[sender.tag] as? NSDictionary
        {
            user_id = (dataDict["id"] as? String!)!
        }

        if invitedFriendsArray .containsObject(sender.tag)
        {
            
            invitedFriendsArray .removeObject(sender.tag)
            InvitedFriends_id .removeObject(user_id)
        }
        else
        {

            invitedFriendsArray .addObject(sender.tag)
            InvitedFriends_id .addObject(user_id)
        }
        print(InvitedFriends_id)
        self.scrollView.removeFromSuperview()
        if let raw = self.tagArray[sender.tag] as? NSDictionary{
            print(raw["id"]!)
            
            InvitedFriendsIdSTr = ""
            for ids in InvitedFriends_id{
                if InvitedFriendsIdSTr == ""
                {
                    InvitedFriendsIdSTr = "\(ids)"
                }
                else
                {
                    InvitedFriendsIdSTr = "\(InvitedFriendsIdSTr),\(ids)"
                }
            }
            print(InvitedFriendsIdSTr)
            commentTextField.text = commentTextField.text!.stringByAppendingString("\(raw["name"] as! String)")
        }
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let commentMessage = UILabel()
        commentMessage.frame = CGRectMake(80, 40, CGFloat(250+40*isiphone6Plus()-55*isiPhone5()), 30)
        commentMessage.font = UIFont.systemFontOfSize(15)
        commentMessage.textColor = UIColor.blackColor()
        if let raw = self.commentArray[indexPath.row] as? NSDictionary
        {
            let notifyStr = raw["comment"] as! String
            
            let emoData1 = notifyStr.dataUsingEncoding(NSUTF8StringEncoding)
            let emoStringConverted = String.init(data: emoData1!, encoding: NSNonLossyASCIIStringEncoding)! as String
            
            
            commentMessage.text = emoStringConverted
        }
        commentMessage.autosizeForWidth()

        return CGFloat(60+commentMessage.frame.size.height)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.commentArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("commentCell", forIndexPath: indexPath)
        
        for object in cell.contentView.subviews
        {
            object.removeFromSuperview();
        }
        cell.selectionStyle = .None
        
        cell.backgroundColor = UIColor.clearColor()
        let cellView = UIView()
        cellView.frame = CGRectMake(0, 5, cell.contentView.frame.size.width, 75)
        cellView.backgroundColor = UIColor.whiteColor()
        cell.contentView.addSubview(cellView)
        
        let userImage = UIButton()
        userImage.frame = CGRectMake(5, 10, 60, 60)
        userImage.backgroundColor = UIColor.lightGrayColor()
        userImage.layer.cornerRadius = 30
        userImage.tag = indexPath.row
        if let raw = self.commentArray[indexPath.row] as? NSDictionary
        {
            
            let notifyStr = raw["user_image"] as! String
            //userImage.sd_setImageWithURL(NSURL(string: notifyStr))
            userImage.sd_setBackgroundImageWithURL(NSURL(string: notifyStr), forState: .Normal)
        }
        userImage.addTarget(self, action: "UserImageClick:", forControlEvents: .TouchUpInside)
        userImage.clipsToBounds = true
        cellView.addSubview(userImage)
        
        let username = UILabel()
        username.frame = CGRectMake(80, 5, 250, 30)
        username.font = UIFont.boldSystemFontOfSize(18)
        username.textColor = UIColor.blackColor()
        if let raw = self.commentArray[indexPath.row] as? NSDictionary
        {
            let notifyStr = raw["username"] as! String
            username.text = "@\(notifyStr)"
        }
        cellView.addSubview(username)
        
        let timeStamp = UILabel()
        timeStamp.frame = CGRectMake(cellView.frame.size.width-105, 5, 100, 30)
        timeStamp.font = UIFont.systemFontOfSize(14)
        //username.backgroundColor = UIColor(white: 0, alpha: 0.25)
        timeStamp.textColor = UIColor.blackColor()
        if let raw = self.commentArray[indexPath.row] as? NSDictionary
        {
            let notifyStr = raw["created_at"] as! String
            
            let f = NSDateFormatter()
            f.locale = NSLocale(localeIdentifier: "en_US_POSIX")
            f.timeZone = NSTimeZone(name: "UTC")
            f.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'"
            
            let endDate:NSDate = f.dateFromString(notifyStr)!
            let elapsedTime = NSDate().timeIntervalSinceDate(endDate)
            
            var timeStr = "1d"
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
            
            timeStamp.text = timeStr
            timeStamp.textAlignment = .Right
        }
        cellView.addSubview(timeStamp)
        
        let commentMessage = UILabel()
        commentMessage.frame = CGRectMake(80, 40, CGFloat(250+40*isiphone6Plus()-55*isiPhone5()), 30)
        commentMessage.font = UIFont.systemFontOfSize(15)
        commentMessage.textColor = UIColor.blackColor()
        if let raw = self.commentArray[indexPath.row] as? NSDictionary
        {
            let notifyStr = raw["comment"] as! String
            
            let emoData1 = notifyStr.dataUsingEncoding(NSUTF8StringEncoding)
            let emoStringConverted = String.init(data: emoData1!, encoding: NSNonLossyASCIIStringEncoding)! as String
            
            
            commentMessage.text = emoStringConverted
        }
        commentMessage.autosizeForWidth()
        cellView.addSubview(commentMessage)
        
        return cell
    }
    
    func UserImageClick(sender: UIButton){
        print(sender.tag)
        if let raw = self.commentArray[sender.tag] as? NSDictionary
        {
            print(raw)
            let payload = raw["payload"]
            
            let data = payload!.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: false)
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                
                if let dict = json as? [String: AnyObject] {
                    print(dict)
                    processAsync(payload: dict ) { link in
                        if let link = link {
                            
                            self.handle(deepLink: link)
                        }
                    }

                    }
  
            }
            catch {
                print(error)
            }
 
        }
    }
    
    func handle(deepLink link: DeepLink?) {
        main {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let push = storyboard.instantiateViewControllerWithIdentifier("PushFetchViewController") as! PushFetchViewController
            if PFUser.currentUser() != nil {
                push.link = link
                if let topController = UIApplication.sharedApplication().keyWindow?.rootViewController {

                    topController.presentViewController(push, animated: true, completion: nil)

                }
            }
            
        }
    }
    var notificationActivity: AllNotificationList?
    
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
    
    func btnTouched(){
        KGModal.sharedInstance().hideAnimated(true)
        self.commentArray = []
        self.tagArray = []
        self.timelineCommentView.removeFromSuperview()
        self.scrollView.removeFromSuperview()
        
    }
    
    @IBOutlet var firstMomentPreview: MomentImageView!
    @IBOutlet var lastMomentPreviews: [MomentImageView] = []
    @IBOutlet var previewItems: [UIView] = []
    @IBOutlet var playbackItems: [UIView] = []
    @IBOutlet var playerView: DraftPreviewView!
    var newsBadge: CustomBadge?
    
    @IBAction func tappedItem(sender: UITapGestureRecognizer) {
        self.momentScroller.hidden = true
        behavior.tappedItem(sender)
    }
    
    @IBAction func moreButtonTapped() {
        guard let tl: Timeline = timeline else { return }
        serialHook.perform(key: .TimelineMoreButtonTapped, argument: tl)
    }
    
    // MARK: -
    // MARK: NamedBehavior:
    @IBOutlet var nameLabel: UILabel!
    
    // MARK: LikeableBehavior:
    @IBOutlet var likeButton: SWFrameButton!
    
    // MARK: FollowableBehavior:
    @IBOutlet var followButton: SWFrameButton!
    
    // MARK: DurationalBehavior:
    @IBOutlet var durationLabel: UILabel!
    
    @IBOutlet var commentButton: UIButton!
    
    
}

extension ModernTimelineView: Refreshable {
    var refreshers: [() -> ()] {
        return [refreshDurationalBehavior, refreshNamedBehavior, refreshFollowableBehavior, refreshLikeableBehavior]
    }
}

extension ModernTimelineView: DurationalBehavior, NamedBehavior { }

extension ModernTimelineView: FollowableBehavior, LikeableBehavior {
    typealias TargetBehaviorType = Timeline
    
    var behaviorTarget: TargetBehaviorType? {
        return timeline
    }
    
    @IBAction func followButtonTapped() {
        toggleFollowState()
    }
    
    @IBAction func likeButtonTapped() {
        toggleLiked()
    }
}

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
import SlackTextViewController

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
    var removedFriends_id : NSMutableArray = []
    var participants_id : NSMutableArray = []
    
    var InvitedFriendsIdSTr : NSString = ""
    var sendbutton = UIButton()
    var Updatebutton = UIButton()
    var commentId : String = ""
    
    var selectedTimelineMomentArray : NSArray = []
    let friendsListView = UIView()
    let friendslistTableView = UITableView()
    var friendsListArray : NSMutableArray = []
    var isAdmin : Bool = false
    var followersArrayList: [User] = []
    var friendsInGroupTl : NSMutableArray = []
    let seperatorLineView = UIView()
    
    var activityIndicator = UIActivityIndicatorView()
    let activityIndicatorView = UIView()
    var timeline_id :String = ""
    
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
            User.getUsers(ApiRequest.CurrentUserFollowers) {
                usrs in  self.followersArrayList = usrs
            }
            behavior.timeline = newValue

            delay(0.001){
                self.scrollMomentArray = []
                
                // Seperator view for timeline
//                self.playerView.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + CGFloat(8*self.IPHONE5), self.frame.size.width, self.frame.size.height-CGFloat(8*self.IPHONE5))
                if let raw = self.behavior.timeline?.dict["moments"]!
                {
                    self.scrollMomentArray = raw as! NSArray
                    
                }
                // self.scrollMomentArray = self.behavior.timeline?.dict["moments"]! as! NSArray
                var Yaxis :CGFloat = 0
                self.momentScroller.subviews.forEach {
                    ( view) -> () in
                    if (view is UIButton) {
                        main{
                        view.removeFromSuperview()
                        }
                        
                    }
                }
                //self.momentScroller.frame = CGRectMake(CGFloat(self.frame.size.width - 80-CGFloat(5*isiphone6Plus())+CGFloat(10*isiPhone5())), self.firstMomentPreview.frame.origin.y, CGFloat(70+5*isiphone6Plus()-10*isiPhone5()), CGFloat(276 + 30*isiphone6Plus()-45*isiPhone5()))
                self.momentScroller.delegate = self
                self.momentScroller.showsVerticalScrollIndicator = false
                //print(self.timeline?.moments.)
                if !(self.timeline?.isOwn)!
                {
                    
                    self.seperatorLineView.removeFromSuperview()

                    self.seperatorLineView.frame = CGRectMake(25,self.likeTimelineButton.frame.origin.y + self.likeTimelineButton.frame.size.height + 5, self.frame.size.width-25,1)
                    self.seperatorLineView.hidden = false
                    self.seperatorLineView.backgroundColor = UIColor.groupTableViewBackgroundColor()
                    self.addSubview(self.seperatorLineView)
                    
                    self.likebuttonY.constant = 80
                    
                    main{
//                    self.momentScroller.frame = CGRectMake(CGFloat(self.frame.size.width - 80-CGFloat(5*isiphone6Plus())+CGFloat(10*isiPhone5())), self.firstMomentPreview.frame.origin.y, CGFloat(70+5*isiphone6Plus()-10*isiPhone5()), CGFloat(276 + 30*isiphone6Plus()-45*isiPhone5()))
                        self.momentScroller.frame = CGRectMake(CGFloat(self.frame.size.width - 80-CGFloat(5*self.IPHONE6P)+CGFloat(10*self.IPHONE5)), self.firstMomentPreview.frame.origin.y, CGFloat(70+5*self.IPHONE6P-10*self.IPHONE5), self.firstMomentPreview.frame.size.height)
                    }
                    
                }else{
                    if (self.timeline?.isOwn)!{
                        self.seperatorLineView.removeFromSuperview()
                        self.seperatorLineView.hidden = true
                        self.likebuttonY.constant = 35
                    main{
//                    self.momentScroller.frame = CGRectMake(CGFloat(self.frame.size.width - 80-CGFloat(5*isiphone6Plus())+CGFloat(10*isiPhone5())), self.firstMomentPreview.frame.origin.y, CGFloat(70+5*isiphone6Plus()-10*isiPhone5()), CGFloat(276 + 30*isiphone6Plus()-45*isiPhone5()))
                      self.momentScroller.frame = CGRectMake(CGFloat(self.frame.size.width - 80-CGFloat(5*self.IPHONE6P)+CGFloat(10*self.IPHONE5)), self.firstMomentPreview.frame.origin.y, CGFloat(70+5*self.IPHONE6P-10*self.IPHONE5), self.firstMomentPreview.frame.size.height)
                    }
                    }
                }
                
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
                    main{
                    self.momentScroller.addSubview(villainButton)
                    }
                    
                    Yaxis = Yaxis + self.momentScroller.frame.size.width
                }
                self.momentScroller.contentSize = CGSizeMake(self.momentScroller.frame.size.width, Yaxis)
                self.momentScroller.backgroundColor = UIColor.from(hexString:"#e7e7e7")
                
                self.addSubview(self.momentScroller)
                

            }
            
            refresh()
            
            self.friendsListArray.removeAllObjects()
            self.groupTimelineButton.hidden = !(behavior.timeline?.groupTimeline)!
            self.commentButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 3, bottom: 0, right: 0)
            
            if let timelineCount = behavior.timeline?.commentsCount {
                self.commentButton.setTitle("\(timelineCount)", forState: .Normal)
            }
            else{
                self.commentButton.setTitle("0", forState: .Normal)
            }
            if let description = behavior.timeline?.description {
                
                let emoData1 = description.dataUsingEncoding(NSUTF8StringEncoding)
                let emoStringConverted = String.init(data: emoData1!, encoding: NSNonLossyASCIIStringEncoding)! as String
                self.descriptionLabel.text = emoStringConverted
            }
            if let participants = behavior.timeline?.participants {
                self.friendsListArray = participants.mutableCopy() as! NSMutableArray
            }
            if let user_id = behavior.timeline?.parent?.state.uuid
            {
                commentOnTimelineButton.hidden = true
                
                //                if (user_id == Storage.session.currentUser?.uuid)
                //                {
                //                    commentOnTimelineButton.hidden = true
                //                    followTimelineButton.hidden = true
                //                    likeTimelineButton.hidden = true
                //                }
            }
            
        }
    }
    
    func momentButtonPressed(sender: UIButton){
        //print(sender.tag)
        self.momentScroller.hidden = true
        self.seperatorLineView.hidden = true
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
                main{
                    self.addFriendsListView()
                }
            }
        }
        else if self.timeline?.adminId == self.timeline?.parent?.uuid
        {
            isAdmin = true
            alert.addAction(title: local(.ShowViewMembersGroupTimelineMessage), style: .Default) { _ in
                main{
                    self.addFriendsListView()
                }
            }
            alert.addAction(title: local(.ShowExitGroupTimelineMessage), style: .Default) { _ in
                self.deleteGroupAPI()
            }
        }
        else
        {
            alert.addAction(title: local(.ShowViewMembersGroupTimelineMessage), style: .Default) { _ in
                main{
                    self.addFriendsListView()
                }
            }
            alert.addAction(title: local(.ShowLeaveGroupTimelineMessage), style: .Default) { _ in
                self.leaveGroupAPI()
            }
        }
        alert.addAction(title: local(.ShowGroupTimelineCancel), style: .Cancel, handler: nil)
        controller?.presentAlertController(alert)
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
        //        print("timeline id: \(timeline!.uuid!)")
        //        print(timeline!.dict["moments"]!)  //show all moments
        
        main{
            self.showCommentPopup()
            
        }
        
    }
    
    func addFriendsListView()
    {
        self.InvitedFriends_id.removeAllObjects()
        self.invitedFriendsArray.removeAllObjects()
        let screenRect = UIScreen.mainScreen().bounds
        let screenWidth = screenRect.size.width;
        let screenHeight = screenRect.size.height;
        self.friendsListView.frame = CGRectMake(0, 0, screenWidth, screenHeight);
        self.friendsListView.backgroundColor = UIColor.whiteColor()
        self.friendsListView.alpha = 1
        
        let headerBackView = UILabel()
        headerBackView.frame = CGRectMake(0, 0, screenWidth, 70)
        headerBackView.textAlignment = .Center
        headerBackView.backgroundColor = UIColor.redColor()
        headerBackView.text = ""
        self.friendsListView.addSubview(headerBackView)
        
        let viewTitle = UILabel()
        viewTitle.frame = CGRectMake(0, 30, screenWidth, 30)
        viewTitle.font = UIFont.boldSystemFontOfSize(17)
        viewTitle.textAlignment = .Center
        viewTitle.backgroundColor = UIColor.clearColor()
        viewTitle.textColor = UIColor.whiteColor()
        viewTitle.text = "View Members"
        self.friendsListView.addSubview(viewTitle)
        
        // close button comment section
        let closeButton  = UIButton()
        closeButton.frame = CGRectMake(5, 30, 30, 30);
        closeButton.setImage(UIImage(named: "Back to previous screen") as UIImage?, forState: .Normal)
        closeButton.addTarget(self, action: "closeViewButton", forControlEvents:.TouchUpInside)
        self.friendsListView.addSubview(closeButton)
        
        
        let friendslistY: CGFloat = 80
        let friendslistHeight: CGFloat = self.friendsListView.frame.height-150
        
        if isAdmin{
            // DONE button comment section
            let doneButton   = UIButton()
            doneButton.frame = CGRectMake(UIScreen.mainScreen().bounds.size.width - 70.0 , 30, 65, 30)
            doneButton.layer.cornerRadius = 4
            doneButton.setTitleColor (UIColor.whiteColor() ,forState: .Normal)
            doneButton.backgroundColor = UIColor.blackColor()
            doneButton.titleLabel!.font = UIFont.boldSystemFontOfSize(16)
            doneButton.setTitle("Done", forState: UIControlState.Normal)
            doneButton.addTarget(self, action: "doneButtonAction", forControlEvents:.TouchUpInside)
            self.friendsListView.addSubview(doneButton)
            self.participants_id.removeAllObjects()
            self.InvitedFriends_id.removeAllObjects()
            for i in 0..<(self.friendsListArray.count ?? 0) {
                if let dataDict = self.friendsListArray[i] as? NSDictionary
                {
                    let user_id = (dataDict["id"] as? String!)!
                    self.participants_id.addObject(user_id)
                    self.InvitedFriends_id.addObject(user_id)
                }
            }
        }
        
        // table view declaration
        friendslistTableView.frame         =   CGRectMake(10, friendslistY, self.friendsListView.frame.width-20, friendslistHeight);
        friendslistTableView.delegate      =   self
        friendslistTableView.dataSource    =   self
        friendslistTableView.backgroundColor = UIColor.clearColor()
        friendslistTableView.separatorStyle = .None
        friendslistTableView.tableFooterView = UIView()
        friendslistTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.friendsListView.addSubview(friendslistTableView)
        
        KGModal.sharedInstance().closeButtonType = KGModalCloseButtonType.None
        KGModal.sharedInstance().showWithContentView(self.friendsListView)
        
    }
    func closeViewButton(){
        
        KGModal.sharedInstance().hideAnimated(true)
        main {
            
            self.invitedFriendsArray.removeAllObjects()
            self.friendslistTableView.reloadData()
            self.friendsListView.removeFromSuperview()
            serialHook.perform(key: .ForceReloadData, argument: ())
            
        }
    }
    
    func doneButtonAction()
    {
        if self.InvitedFriends_id.count > 0
        {
            self.addNewParticipantsAPI()
        }
        if self.removedFriends_id.count > 0
        {
            self.removeParticipantsAPI()
        }
    }
    func addNewParticipantsAPI()
    {
        let addParticipantsList : NSMutableArray = []
        for i in 0..<self.InvitedFriends_id.count {
            if !self.participants_id .containsObject(self.InvitedFriends_id[i])
            {
                addParticipantsList.addObject(self.InvitedFriends_id[i])
            }
        }
        if addParticipantsList.count == 0
        {
            self.InvitedFriends_id.removeAllObjects()
            
            self.closeViewButton()
            return
        }
        
        var InvitedFriendsIdSTr : NSString = ""
        for ids in addParticipantsList{
            if InvitedFriendsIdSTr == ""
            {
                InvitedFriendsIdSTr = "\(ids)"
            }
            else
            {
                InvitedFriendsIdSTr = "\(InvitedFriendsIdSTr),\(ids)"
            }
        }
        
        Storage.performRequest(.AddParticipantInGroupTimeline((self.timeline?.uuid)! ,InvitedFriendsIdSTr  as members)) { (json) -> Void in
            
            let controller = activeController()
            
            switch json["status_code"] as? Int ?? 400 {
            default:
                if let error = (json["error"] as? String) ?? (json["error"] as? [AnyObject])?.first as? String {
                    main {
                        let alert = UIAlertController(title: local(.ShowViewMembersGroupTimelineMessage), message: error, preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: local(.TimelineAlertCreateErrorActionDismiss), style: .Default, handler: nil))
                        controller!.presentAlertController(alert)
                        self.closeViewButton()
                        return()
                        
                    }
                }
                else
                {
                    for i in 0..<addParticipantsList.count
                    {
                        self.participants_id.addObject(addParticipantsList[i])
                    }
                }
            }
            self.InvitedFriends_id.removeAllObjects()
            main {
                self.closeViewButton()
            }
        }
    }
    
    func removeParticipantsAPI()
    {
        let removeParticipantsList : NSMutableArray = []
        for i in 0..<self.removedFriends_id.count {
            if self.participants_id .containsObject(removedFriends_id[i])
            {
                removeParticipantsList.addObject(removedFriends_id[i])
            }
        }
        if removeParticipantsList.count == 0
        {
            self.closeViewButton()
            return
        }
        
        var removedFriendsIdSTr : NSString = ""
        for ids in removeParticipantsList{
            if removedFriendsIdSTr == ""
            {
                removedFriendsIdSTr = "\(ids)"
            }
            else
            {
                removedFriendsIdSTr = "\(removedFriendsIdSTr),\(ids)"
            }
        }
        
        Storage.performRequest(.RemoveParticipantFromGroupTimeline((self.timeline?.uuid)! ,removedFriendsIdSTr  as members)) { (json) -> Void in
            let controller = activeController()
            
            switch json["status_code"] as? Int ?? 400 {
            default:
                if let error = (json["error"] as? String) ?? (json["error"] as? [AnyObject])?.first as? String {
                    main {
                        let alert = UIAlertController(title: local(.ShowViewMembersGroupTimelineMessage), message: error, preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: local(.TimelineAlertCreateErrorActionDismiss), style: .Default, handler: nil))
                        controller!.presentAlertController(alert)
                        self.closeViewButton()
                        return
                        
                    }
                }
                else
                {
                    for i in 0..<removeParticipantsList.count
                    {
                        if self.participants_id.containsObject(removeParticipantsList[i])
                        {
                            self.participants_id.removeObject(removeParticipantsList[i])
                        }
                    }
                }
            }
            self.removedFriends_id.removeAllObjects()
            main {
                self.closeViewButton()
            }
            
        }
    }
    func followButton(sender: UIButton) {
        let indexPath = NSIndexPath(forRow: sender.tag, inSection: 0)
        let followButton = sender as UIButton
        
        var user_id : NSString = ""
        
        if let dataDict = self.friendsListArray[indexPath.row] as? NSDictionary
        {
            user_id = (dataDict["id"] as? String!)!
        }
        if user_id == Storage.session.currentUser?.uuid
        {
            followButton.setImage(UIImage(named: "dislikeImage") as UIImage?, forState: .Normal)
            return
        }
        let user = User(dict: (self.friendsListArray[indexPath.row] as? [String: AnyObject])!, parent: nil)
        
        if(followButton.imageView!.image == UIImage(named:"likeImage")){
            followButton.setImage(UIImage(named: "dislikeImage") as UIImage?, forState: .Normal)
            
            user.follow({ () -> () in
                self.friendslistTableView.reloadData()
            })
        }
        else
        {
            followButton.setImage(UIImage(named: "likeImage") as UIImage?, forState: .Normal)
            user.unfollow({ () -> () in
                self.friendslistTableView.reloadData()
            })
        }
        return
    }
    
    func inviteButton(sender: UIButton) {
        let indexPath = NSIndexPath(forRow: sender.tag, inSection: 0)
        let inviteButton = sender as UIButton
        
        var user_id : NSString = ""
        if let user : User?  = self.followersArrayList[indexPath.row]
            
        {
            user_id = (user?.uuid)!
        }
        
        if inviteButton.backgroundColor == UIColor.redColor()
        {
            inviteButton.backgroundColor = UIColor.whiteColor()
            self.InvitedFriends_id .removeObject(user_id)
            removedFriends_id .addObject(user_id)
        }
        else
        {
            inviteButton.backgroundColor = UIColor.redColor()
            self.InvitedFriends_id .addObject(user_id)
            removedFriends_id .removeObject(user_id)
        }
    }
    
    
    
    
    func showCommentPopup(){
        main{
            
            self.InvitedFriends_id.removeAllObjects()
            self.invitedFriendsArray.removeAllObjects()
            
            Storage.performRequest(ApiRequest.TimelineComments(self.timeline!.uuid!), completion: { (json) -> Void in
                if let raw = json["result"] as? NSMutableArray{
                    self.commentArray = raw
                }
                main{
                    self.activityIndicatorView.removeFromSuperview()
                    self.activityIndicator.stopAnimating()
                    self.commentlist.reloadData()
                }
            })
            
            let screenRect = UIScreen.mainScreen().bounds
            let screenWidth = screenRect.size.width;
            let screenHeight = screenRect.size.height;
            self.timelineCommentView.frame = CGRectMake(0, 0, screenWidth, screenHeight);
            self.timelineCommentView.backgroundColor = UIColor(white: 1 , alpha: 1)
            self.timelineCommentView.alpha = 1
            
            self.activityIndicatorView.frame = CGRectMake(0, 0, 70, 70);
            self.activityIndicatorView.backgroundColor = UIColor.grayColor()
            self.activityIndicatorView.alpha = 1
            self.activityIndicatorView.center = self.window!.center
            self.activityIndicatorView.layer.cornerRadius = 4
            self.timelineCommentView.addSubview(self.activityIndicatorView)
            
            self.activityIndicator.activityIndicatorViewStyle = .WhiteLarge
            self.activityIndicator.frame = CGRect(x: 0, y: 7, width: 70, height: 50)
            self.activityIndicatorView.addSubview(self.activityIndicator)
            self.activityIndicator.startAnimating()
            
            let indicatorTitle = UILabel()
            indicatorTitle.frame = CGRectMake(0, 50, 70, 20)
            indicatorTitle.font = UIFont.boldSystemFontOfSize(9)
            indicatorTitle.textAlignment = .Center
            indicatorTitle.textColor = UIColor.whiteColor()
            indicatorTitle.text = "Please wait.."
            self.activityIndicatorView.addSubview(indicatorTitle)
            
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
            
            self.commentlist.frame         =   CGRectMake(0, 64, self.timelineCommentView.frame.width, self.timelineCommentView.frame.height-144);
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
            
            
            self.commentTextField.frame = CGRectMake(10, 15, CGFloat(295+40*self.IPHONE6P-55*self.IPHONE5), 50)
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
            
            self.sendbutton = UIButton(type: UIButtonType.Custom) as UIButton
            self.sendbutton.frame = CGRectMake(self.commentTextField.frame.origin.x + self.commentTextField.frame.size.width+10, 15, 50, 50)
            self.sendbutton.layer.cornerRadius = 4
            self.sendbutton.hidden = false
            self.sendbutton.backgroundColor = UIColor.redColor()
            self.sendbutton.setTitle("Send", forState: UIControlState.Normal)
            self.sendbutton.addTarget(self, action: "CommentSendButtonAction", forControlEvents: UIControlEvents.TouchUpInside)
            self.commentTextfeildView.addSubview(self.sendbutton)
            
            self.Updatebutton = UIButton(type: UIButtonType.Custom) as UIButton
            self.Updatebutton.frame = CGRectMake(self.commentTextField.frame.origin.x + self.commentTextField.frame.size.width+10, 15, 50, 50)
            self.Updatebutton.layer.cornerRadius = 4
            self.Updatebutton.hidden = true
            self.Updatebutton.backgroundColor = UIColor.redColor()
            self.Updatebutton.setTitle("Done", forState: UIControlState.Normal)
            self.Updatebutton.addTarget(self, action: "CommentUpdateButtonAction", forControlEvents: UIControlEvents.TouchUpInside)
            self.commentTextfeildView.addSubview(self.Updatebutton)
            
            KGModal.sharedInstance().closeButtonType = KGModalCloseButtonType.None
            KGModal.sharedInstance().showWithContentView(self.timelineCommentView)
            
        }
        
    }
    
    func CommentUpdateButtonAction(){
        
        print("Update button Working")
        let TrimString = commentTextField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
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
        print(goodValue!)
//        Storage.performRequest(ApiRequest.EditComment(self.commentId as commentID, goodValue! as commentmessage), completion: { (json) -> Void in
//            main{
//                
//                Storage.performRequest(ApiRequest.TimelineComments(self.timeline!.uuid!), completion: { (json) -> Void in
//                    if let raw = json["result"] as? NSMutableArray{
//                        self.commentArray = raw
//                        
//                    }
//                    main{
//                        self.commentlist.reloadData()
//                        
//                    }
//                    
//                })
//                self.sendbutton.hidden = false
//                self.Updatebutton.hidden = true
//                self.commentTextField.text = ""
//                self.commentTextField.resignFirstResponder()
//                UIView.animateWithDuration(0.3, animations: { () -> Void in
//                    self.commentTextfeildView.frame = CGRectMake(0, self.timelineCommentView.frame.size.height-80, self.timelineCommentView.frame.size.width, 80)
//                    
//                })
//            }
//            
//            
//        })
        
        
    }
    
    func CommentSendButtonAction(){
        
        // Trim all whitespace
        
        let TrimString = commentTextField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
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
            main{
                Storage.performRequest(ApiRequest.TimelineComments(self.timeline!.uuid!), completion: { (json) -> Void in
                    if let raw = json["result"] as? NSMutableArray{
                        self.commentArray = raw
                        
                    }
                    main{
                        serialHook.perform(key: .ForceReloadData, argument: ())
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
                
                Storage.performRequest(ApiRequest.GetTagUsers, completion: { (json) -> Void in
                    print(json)
                    if let raw = json["result"] as? NSMutableArray{
                        
                        self.tagArray = raw
                    }
                    
                    main{
                        if(self.tagArray.count > 0){
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
                                    if let name = raw["name"] as? String{
                                        villainButton.setTitle("@\(name)", forState: UIControlState.Normal)
                                    }
                                    let userimage = UIImageView()
                                    userimage.frame = CGRectMake(10, 5, 40, 40)
                                    userimage.layer.cornerRadius = 20
                                    userimage.clipsToBounds = true
                                    if let image = raw["image"] as? String{
                                        userimage.sd_setImageWithURL(NSURL(string:image))
                                    }
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
                    }
                })
            }
            print(textField.text?.characters.count)
            
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
            
            self.invitedFriendsArray .removeObject(sender.tag)
            self.InvitedFriends_id .removeObject(user_id)
        }
        else
        {
            
            self.invitedFriendsArray .addObject(sender.tag)
            self.InvitedFriends_id .addObject(user_id)
        }
        self.scrollView.removeFromSuperview()
        if let raw = self.tagArray[sender.tag] as? NSDictionary{
            
            InvitedFriendsIdSTr = ""
            for ids in self.InvitedFriends_id{
                if InvitedFriendsIdSTr == ""
                {
                    InvitedFriendsIdSTr = "\(ids)"
                }
                else
                {
                    InvitedFriendsIdSTr = "\(InvitedFriendsIdSTr),\(ids)"
                }
            }
            commentTextField.text = commentTextField.text!.stringByAppendingString("\(raw["name"] as! String)")
        }
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if tableView == self.friendslistTableView
        {
            return 60
        }
        else
        {
            let commentMessage = UILabel()
            commentMessage.frame = CGRectMake(80, 40, CGFloat(250+40*self.IPHONE6P-55*self.IPHONE5), 30)
            commentMessage.font = UIFont.systemFontOfSize(15)
            commentMessage.textColor = UIColor.blackColor()
            if let raw = self.commentArray[indexPath.row] as? NSDictionary
            {
                if let notifyStr = raw["comment"] as? String{
                
                let emoData1 = notifyStr.dataUsingEncoding(NSUTF8StringEncoding)
                let emoStringConverted = String.init(data: emoData1!, encoding: NSNonLossyASCIIStringEncoding)! as String
                
                
                commentMessage.text = emoStringConverted
                }
            }
            commentMessage.autosizeForWidth()
            
            return CGFloat(35+commentMessage.frame.size.height)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.friendslistTableView
        {
            if self.timeline?.adminId == self.timeline?.parent?.uuid
                
            {
                return self.followersArrayList.count
            }
            else
            {
                return self.friendsListArray.count
            }
        }
        else
        {
            return self.commentArray.count
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView == friendslistTableView
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
            
            for object in cell.contentView.subviews
            {
                object.removeFromSuperview();
            }
            cell.selectionStyle = .None
            
            cell.backgroundColor = UIColor.clearColor()
            let cellView = UIView()
            cellView.frame = CGRectMake(0, 0, cell.contentView.frame.size.width, 60)
            cellView.backgroundColor = UIColor.whiteColor()
            cell.contentView.addSubview(cellView)
            
            let userImage = UIImageView()
            userImage.frame = CGRectMake(5, 5, 50, 50)
            userImage.backgroundColor = UIColor.lightGrayColor()
            userImage.layer.cornerRadius = 25
            userImage.layer.masksToBounds = true
            userImage.layer.cornerRadius = userImage.frame.size.width/2
            
            let fullName = UILabel()
            fullName.frame = CGRectMake(70, 3, 250, 23)
            fullName.font = UIFont.boldSystemFontOfSize(14)
            fullName.textColor = UIColor.blackColor()
            fullName.text = ""
            fullName.hidden = false
            
            let username = UILabel()
            username.frame = CGRectMake(70, 26, 250, 25)
            username.font = UIFont.boldSystemFontOfSize(16)
            username.textColor = UIColor.grayColor()
            
            
            cellView.addSubview(userImage)
            cellView.addSubview(username)
            cellView.addSubview(fullName)
            
            let gap : CGFloat = 15
            let buttonHeight: CGFloat = 30
            let buttonWidth: CGFloat = 30
            let inviteButton = UIButton()
            inviteButton .setTitleColor( UIColor.redColor(), forState: .Normal)
            inviteButton.frame = CGRectMake(cellView.frame.size.width - gap - buttonWidth, gap, buttonWidth, buttonHeight)
            inviteButton.backgroundColor = UIColor.whiteColor()
            inviteButton.tag = indexPath.row
            
            
            if isAdmin
            {
                if let user : User?  = self.followersArrayList[indexPath.row]
                {
                    if let fullNameStr = user?.userfullName
                    {
                        fullName.text = fullNameStr as String
                    }
                    if (fullName.text?.characters.count == 0)
                    {
                        username.frame = fullName.frame
                        fullName.hidden = true
                    }
                    
                    username.text = "@" + (user?.name)!
                    let placeHolderimg = UIImage(named: "default-user-profile")
                    let imageName = user!.imageUrl as? String ?? ""
                    userImage.sd_setImageWithURL(NSURL (string: imageName), placeholderImage:placeHolderimg)
                    
                    inviteButton.layer.cornerRadius = 0.5 * inviteButton.bounds.size.width
                    inviteButton.layer.borderColor = UIColor.blackColor().CGColor;
                    inviteButton.layer.borderWidth = 2.0
                    if self.InvitedFriends_id .containsObject(user!.uuid!)
                    {
                        inviteButton.backgroundColor = UIColor.redColor()
                    }
                    else
                    {
                        inviteButton.backgroundColor = UIColor.whiteColor()
                    }
                    inviteButton.addTarget(self, action: "inviteButton:", forControlEvents: UIControlEvents.TouchUpInside)
                    inviteButton.titleLabel!.font = UIFont.boldSystemFontOfSize(17)
                }
                
            }
            else
            {
                if let dataDict = self.friendsListArray[indexPath.row] as? NSMutableDictionary
                {
                    print(dataDict)
                    if let firstName = dataDict["firstname"] as? NSString
                    {
                        var fullname = firstName
                        if let lastName = dataDict["lastname"] as? NSString
                        {
                            if(dataDict["isAdmin"] as? Bool == true ){
                                fullname = "*\(firstName) \(lastName)"
                            }else{
                                fullname = "\(firstName) \(lastName)"
                            }
                            
                        }
                        fullName.text = fullname as String
                    }
                    if (fullName.text?.characters.count == 0)
                    {
                        username.frame = fullName.frame
                        fullName.hidden = true
                    }
                    //            fullName.text = "Firstname"+"LastName"
                    username.text = "@" + (dataDict["name"] as? String)!
                    let placeHolderimg = UIImage(named: "default-user-profile")
                    let imageName = dataDict["image"] as? String ?? ""
                    userImage.sd_setImageWithURL(NSURL (string: imageName), placeholderImage:placeHolderimg)
                }
                
                inviteButton.addTarget(self, action: "followButton:", forControlEvents: UIControlEvents.TouchUpInside)
                inviteButton.setImage(UIImage(named: "likeImage") as UIImage?, forState: .Normal)
                
                if let dataDict = self.friendsListArray[indexPath.row] as? NSDictionary
                {
                    let user_id = (dataDict["id"] as? String!)!
                    if user_id == Storage.session.currentUser?.uuid
                    {
                        inviteButton.setImage(UIImage(named: "dislikeImage") as UIImage?, forState: .Normal)
                    }
                    else
                    {
                        for var i = 0; i < self.followersArrayList.count; ++i
                        {
                            if let user : User?  = self.followersArrayList[i]
                            {
                                let follower_id = user?.uuid
                                if follower_id == user_id
                                {
                                    inviteButton.setImage(UIImage(named: "dislikeImage") as UIImage?, forState: .Normal)
                                }
                            }
                        }
                    }
                }
            }
            cellView.addSubview(inviteButton)
            
            return cell
        }
        else
        {
            
            let reuseIdentifier = "programmaticCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) as! MGSwipeTableCell!
            if cell == nil
            {
                cell = MGSwipeTableCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: reuseIdentifier)
            }
            
            
            
            for object in cell.contentView.subviews
            {
                object.removeFromSuperview();
            }
            cell.selectionStyle = .None
            
            cell.backgroundColor = UIColor.clearColor()
            let cellView = UIView()
            cellView.frame = CGRectMake(0, 0, self.frame.size.width, 65)
            cellView.backgroundColor = UIColor.whiteColor()
            cell.contentView.addSubview(cellView)
            
            let userImage = UIButton()
            userImage.frame = CGRectMake(15, 10, 50, 50)
            userImage.backgroundColor = UIColor.lightGrayColor()
            userImage.layer.cornerRadius = 25
            userImage.tag = indexPath.row
            if let raw = self.commentArray[indexPath.row] as? NSDictionary
            {
                var notifyStrs: String = ""
                
                if let notifyStr = raw["user_image"] as? NSString
                {
                    let notify = notifyStr
                    if(notify != "")
                    {
                    notifyStrs = notify as String
                    userImage.sd_setBackgroundImageWithURL(NSURL(string: notifyStrs), forState: .Normal)
                    }
                }
                //userImage.sd_setImageWithURL(NSURL(string: notifyStr))
                
                //userImage.sd_setBackgroundImageWithURL(NSURL(string: notifyStr), forState: .Normal, placeholderImage: UIImage(named:"default-user-profile", options: SDWebImageOptions.ProgressiveDownload)
            }
            userImage.addTarget(self, action: #selector(ModernTimelineView.UserImageClick(_:)), forControlEvents: .TouchUpInside)
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
            timeStamp.frame = CGRectMake(cellView.frame.size.width-110, 5, 100, 30)
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
                
                timeStamp.text = timeStr
                timeStamp.textAlignment = .Right
            }
            cellView.addSubview(timeStamp)
            
            let commentMessage = UILabel()
            commentMessage.frame = CGRectMake(80, 30, CGFloat(250+40*IPHONE6P-55*IPHONE5), 30)
            commentMessage.font = UIFont.systemFontOfSize(15)
            commentMessage.textColor = UIColor.blackColor()
            if let raw = self.commentArray[indexPath.row] as? NSDictionary
            {
                let notifyStr = raw["comment"] as! String
                
                let emoData1 = notifyStr.dataUsingEncoding(NSUTF8StringEncoding)
                let emoStringConverted = String.init(data: emoData1!, encoding: NSNonLossyASCIIStringEncoding)! as String
                
                
                commentMessage.text = emoStringConverted
            }
            cellView.addSubview(username)
            commentMessage.autosizeForWidth()
            cellView.addSubview(commentMessage)
            
            let notifyStr : String
            if let raw = self.commentArray[indexPath.row] as? NSDictionary
            {
                
                notifyStr = raw["user_id"] as! String
                if (notifyStr == Storage.session.uuid)
                {
                    //configure right buttons
                    cell.rightButtons = [MGSwipeButton(title: "", icon:UIImage(named: "CommentDelete.png"),backgroundColor: UIColor.redColor(), callback: {
                        (sender: MGSwipeTableCell!) -> Bool in
                        print("Delete: \(indexPath.row)")
                        
                        if let raw = self.commentArray[indexPath.row] as? NSDictionary
                        {
                            let notifyStr = raw["id"] as! String
                            print(notifyStr)
                            self.deleteCommentAPI(notifyStr)
                            
                        }
                        
                        return true
                    }),MGSwipeButton(title: "",icon:UIImage(named: "CommentEdit.png"),backgroundColor: UIColor.lightGrayColor(), callback: {
                        (sender: MGSwipeTableCell!) -> Bool in
                        self.sendbutton.hidden = true
                        self.Updatebutton.hidden = false
                        if let raw = self.commentArray[indexPath.row] as? NSDictionary
                        {
                            //print(raw)
                            self.commentTextField.text = raw["comment"] as? String
                            self.commentId = (raw["id"] as? String)!
                        }
                        return true
                    })]
                    cell.rightSwipeSettings.transition = MGSwipeTransition.ClipCenter
                }
                else if  (self.timeline?.isOwn)!
                {
                    cell.rightButtons = [MGSwipeButton(title: "",icon:UIImage(named: "CommentDelete.png") ,backgroundColor: UIColor.redColor(), callback: {
                        (sender: MGSwipeTableCell!) -> Bool in
                        print("Delete: \(indexPath.row)")
                        
                        if let raw = self.commentArray[indexPath.row] as? NSDictionary
                        {
                            let notifyStr = raw["id"] as! String
                            print(notifyStr)
                            self.deleteCommentAPI(notifyStr)
                        }
                        
                        return true
                    })]
                    cell.rightSwipeSettings.transition = MGSwipeTransition.ClipCenter
                }
            }
            
            
            return cell
        }
    }
    func deleteCommentAPI(commentid: String){
        
        Storage.performRequest(ApiRequest.DeleteComment(commentid as commentID), completion: { (json) -> Void in
            print(json)
            main{
                Storage.performRequest(ApiRequest.TimelineComments(self.timeline!.uuid!), completion: { (json) -> Void in
                    
                    if let raw = json["result"] as? NSMutableArray{
                        self.commentArray = raw
                        
                    }
                    main{
                        self.commentlist.reloadData()
                    }
                    
                })
            }
        })
    }
    
    func UserImageClick(sender: UIButton){
        print(sender.tag)
        if let raw = self.commentArray[sender.tag] as? NSDictionary
        {
            let payload = raw["payload"]
            
            let data = payload!.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: false)
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                
                if let dict = json as? [String: AnyObject] {
                    processAsync(payload: dict ) { link in
                        if let link = link {
                            
                            self.handle(deepLink: link)
//                            self.fetchData(link)
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
                switch link! {
                    
                case let .UserLink(_, _, uuid):
                    DeepLink.user(uuid: uuid) { u in
                        push.timeline_id = (self.behavior.timeline?.adminId)!
                        let dest = storyboard.instantiateViewControllerWithIdentifier("ShowUser") as! UserSummaryTableViewController
                        dest.user = u
                        let navigationController = UINavigationController(rootViewController: dest)
                        navigationController.navigationBar.barTintColor = UIColor.redNavbarColor()
                        navigationController.navigationBar.translucent = false
                        if let topController = UIApplication.sharedApplication().keyWindow?.rootViewController {
                            navigationController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
                            topController.presentViewController(navigationController, animated: true, completion: nil)
                            
                
                        }
                }
                default : break
                    
                    
                }
//                if let topController = UIApplication.sharedApplication().keyWindow?.rootViewController {
//                    
//                    topController.presentViewController(push, animated: true, completion: nil)
//                    
//                }
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
    @IBOutlet var groupTimelineButton: UIButton!
    @IBOutlet var descriptionLabel: UILabel!
    
    var newsBadge: CustomBadge?
    
    @IBAction func tappedItem(sender: UITapGestureRecognizer) {
        self.momentScroller.hidden = true
        self.seperatorLineView.hidden = true
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
    
    @IBOutlet var likebuttonY: NSLayoutConstraint!
    @IBOutlet var likeTimelineButton: UIButton!
    
    
    // MARK: FollowableBehavior:
    @IBOutlet var followButton: SWFrameButton!
    
    @IBOutlet var followTimelineButton: UIButton!
    // MARK: DurationalBehavior:
    @IBOutlet var durationLabel: UILabel!
    
    @IBOutlet var commentButton: UIButton!
    
    @IBOutlet var commentOnTimelineButton: UIButton!
    
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
        showFollowers()
    }
    
    @IBAction func likeButtonTapped() {
        showLikes()
    }
    
    @IBAction func likeTimelineButtonTapped(sender: UIButton) {
        toggledLiked()
    }
    @IBAction func followTimelineButtonTapped(sender: UIButton) {
        toggleFollowedState()
    }
    
    @IBAction func commentOnTimelineButtonTapped(sender: AnyObject) {
        
        let text = commentButton.titleLabel?.text!
        NSUserDefaults.standardUserDefaults().setObject("\(text!)", forKey: "CommentButtonCount")
        if let timelineID : String = (behaviorTarget?.uuid)! as String{
            showCommentScreen(timelineID, ownTimeline:(self.timeline?.isOwn)!)
        }
       
        
    }
}

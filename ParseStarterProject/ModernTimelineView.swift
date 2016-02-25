//
//  ModernTimelineView.swift
//  Timeline
//
//  Created by Valentin Knabel on 17.11.15.
//  Copyright © 2015 Conclurer GbR. All rights reserved.
//

import UIKit
import SWFrameButton
import ConclurerHook
import KGModal
import Alamofire
import SDWebImage

class ModernTimelineView: UIView , UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    let timelineCommentView = UIView()
    let commentTextField = UITextField()
    var payloadArray :NSMutableArray = []
    let notificationListArray : NSMutableArray = []
    let commentlist = UITableView()
    let commentTextfeildView = UIView()
    var scrollView = UIScrollView()
    
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
            refresh()
        }
    }
    
    var commentArray = NSMutableArray()
    var tagArray = NSMutableArray()
   
    @IBAction func timelineCommentClick(sender: UIButton!){
        print("timeline id: \(timeline!.uuid!)")
//        print(timeline!.dict["moments"]!.count)

        Storage.performRequest(ApiRequest.TimelineComments(timeline!.uuid!), completion: { (json) -> Void in
            print(json)
            if let raw = json["result"] as? NSMutableArray{
                self.commentArray = raw
                
            }
            self.commentlist.reloadData()
            main{
            self.showCommentPopup()
            }
        })
 
        
    }
    
    func showCommentPopup(){
        
        let screenRect = UIScreen.mainScreen().bounds
        let screenWidth = screenRect.size.width;
        let screenHeight = screenRect.size.height;
        self.timelineCommentView.frame = CGRectMake(0, 0, screenWidth, screenHeight);
        self.timelineCommentView.backgroundColor = UIColor(white: 1 , alpha: 1)
        self.timelineCommentView.alpha = 1
        
        let commentScreenTitle = UILabel()
        commentScreenTitle.frame = CGRectMake(0, 0, screenWidth, 64)
        commentScreenTitle.font = UIFont.systemFontOfSize(18)
        commentScreenTitle.textAlignment = .Center
        commentScreenTitle.backgroundColor = UIColor(red:235.0/255.0,green:129.0/255.0,blue:40.0/255.0,alpha:1.0)
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
        
        self.commentlist.frame         =   CGRectMake(10, 64, self.timelineCommentView.frame.width-20, self.timelineCommentView.frame.height-200);
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
        
        
        self.commentTextField.frame = CGRectMake(10, 15, 280, 50)
        self.commentTextField.layer.cornerRadius = 4
        self.commentTextField.backgroundColor = UIColor.whiteColor()
        
        let arrow = UIImageView()
        arrow.frame = CGRectMake(0.0, 0.0, 10.0, 50);
        arrow.contentMode = UIViewContentMode.Center
        self.commentTextField.leftViewMode = UITextFieldViewMode.Always
        self.commentTextField.leftView = arrow
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
    
    func CommentSendButtonAction(){
        let emoData = commentTextField.text!.dataUsingEncoding(NSNonLossyASCIIStringEncoding)
        let goodValue = NSString.init(data: emoData!, encoding: NSUTF8StringEncoding)

        Storage.performRequest(ApiRequest.TimelinePostComment(timeline!.uuid!, goodValue! as PARAMS), completion: { (json) -> Void in
            print(json)
            main{
                
                self.commentTextField.text = ""
                self.commentTextField.resignFirstResponder()
                self.commentlist.reloadData()
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    self.commentTextfeildView.frame = CGRectMake(0, self.timelineCommentView.frame.size.height-80, self.timelineCommentView.frame.size.width, 80)
                    
                })
            }
            
 
        })
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.commentTextfeildView.frame = CGRectMake(0, self.timelineCommentView.frame.size.height-325, self.timelineCommentView.frame.size.width, 80)
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
                   // print(json)
                    if let raw = json["result"] as? NSMutableArray{
                        self.tagArray = raw
                        print(self.tagArray)
                        
                        
                        //self.scrollView.contentSize = CGSizeMake(1000, 1000)
                        
                    }
                    
                    main{
                    self.scrollView.frame = CGRectMake(0, self.commentTextfeildView.frame.origin.y-250, self.timelineCommentView.frame.size.width, 250)
                    self.scrollView.delegate = self
                    
                    for villain in self.tagArray{
                        
                        let villainButton = UIButton(frame: CGRect(x: 0, y: 0, width: self.commentTextfeildView.frame.size.width, height: 30))
                        
                        villainButton.layer.cornerRadius = 0
                        villainButton.backgroundColor = UIColor.redColor()
                        if let raw = villain as? NSDictionary
                        {
                            villainButton.setTitle("@\(raw["name"]!)", forState: UIControlState.Normal)
                        }
                        villainButton.addTarget(self, action: "villainButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
                        //villainButton.tag = Int(element.id)
                        self.scrollView.addSubview(villainButton)
                    }
                    self.scrollView.backgroundColor = UIColor.lightGrayColor()
                    self.timelineCommentView.addSubview(self.scrollView)
                    }
                })
            }
        }
        return true
    }
    
    func villainButtonPressed(sender:UIButton!){
        print(sender.tag)
        self.scrollView.removeFromSuperview()
        if let raw = self.tagArray[sender.tag] as? NSDictionary{
            commentTextField.text = commentTextField.text!.stringByAppendingString("\(raw["name"] as! String)")
        }
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
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
        
        let userImage = UIImageView()
        userImage.frame = CGRectMake(5, 10, 60, 60)
        userImage.backgroundColor = UIColor.lightGrayColor()
        userImage.layer.cornerRadius = 30
        if let raw = self.commentArray[indexPath.row] as? NSDictionary
        {
            
            let notifyStr = raw["user_image"] as! String
            userImage.sd_setImageWithURL(NSURL(string: notifyStr))
        }
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
        
        
        //let strEmo = "Hello 🐶🐮 🇩🇪"
        //let strEmo = self.payloadArray.objectAtIndex(indexPath.row) as? String
        

        
//        let emoData = strEmo.dataUsingEncoding(NSNonLossyASCIIStringEncoding)
//        let goodValue = NSString.init(data: emoData!, encoding: NSUTF8StringEncoding)
//
//        let emoData1 = goodValue!.dataUsingEncoding(NSUTF8StringEncoding)
//        let emoStringConverted = NSString.init(data: emoData1!, encoding: NSNonLossyASCIIStringEncoding)! as NSString
        
        let commentMessage = UILabel()
        commentMessage.frame = CGRectMake(80, 40, 250, 30)
        commentMessage.font = UIFont.systemFontOfSize(15)
        commentMessage.textColor = UIColor.blackColor()
        if let raw = self.commentArray[indexPath.row] as? NSDictionary
        {
          let notifyStr = raw["comment"] as! String
            
            let emoData1 = notifyStr.dataUsingEncoding(NSUTF8StringEncoding)
            let emoStringConverted = String.init(data: emoData1!, encoding: NSNonLossyASCIIStringEncoding)! as String

            
            commentMessage.text = emoStringConverted
        }
        

        cellView.addSubview(commentMessage)
        
        return cell
    }

    
    func btnTouched(){
        KGModal.sharedInstance().hideAnimated(true)
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

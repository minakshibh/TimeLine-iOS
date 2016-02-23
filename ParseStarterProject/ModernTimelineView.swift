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

class ModernTimelineView: UIView , UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    let timelineCommentView = UIView()
    let commentTextField = UITextField()
    var payloadArray :NSMutableArray = []
    let notificationListArray : NSMutableArray = []
    let commentlist = UITableView()
    let commentTextfeildView = UIView()
    
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
    @IBAction func timelineCommentClick(sender: UIButton!){
        print("timeline id: \(timeline!.uuid!)")
        
        Storage.performRequest(ApiRequest.TimelineComments(timeline!.uuid!), completion: { (json) -> Void in
            print(json)
            
            self.commentArray = json["result"] as! NSMutableArray
            print(self.commentArray)
            self.commentlist.reloadData()
            
//            if let results = json["result"] as? [[String: AnyObject]]
//            {
//                for not in results {
//                    if let raw = not["comment"] as? NSString
//                    
//                    {
//                        //self.notificationListArray.addObject(raw)
//                        self.payloadArray.addObject(raw)
//                       // print(self.notificationListArray)
//                        print(self.payloadArray)
//                    }
//                }
//            }
            
        })

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
        
        commentlist.frame         =   CGRectMake(10, 64, self.timelineCommentView.frame.width-20, self.timelineCommentView.frame.height-200);
        commentlist.delegate      =   self
        commentlist.dataSource    =   self
        commentlist.backgroundColor = UIColor.clearColor()
        commentlist.separatorStyle = .None
        commentlist.tableFooterView = UIView()
        commentlist.registerClass(UITableViewCell.self, forCellReuseIdentifier: "commentCell")
        self.timelineCommentView.addSubview(commentlist)
        
        let commentTextfeildView = UIView()
        commentTextfeildView.frame = CGRectMake(0, self.timelineCommentView.frame.size.height-80, self.timelineCommentView.frame.size.width, 80)
        commentTextfeildView.backgroundColor = UIColor.groupTableViewBackgroundColor()
        self.timelineCommentView.addSubview(commentTextfeildView)
        
        
        commentTextField.frame = CGRectMake(10, 15, 280, 50)
        commentTextField.layer.cornerRadius = 4
        commentTextField.backgroundColor = UIColor.whiteColor()
        
        let arrow = UIImageView()
        arrow.frame = CGRectMake(0.0, 0.0, 10.0, 50);
        arrow.contentMode = UIViewContentMode.Center
        commentTextField.leftViewMode = UITextFieldViewMode.Always
        commentTextField.leftView = arrow
        commentTextField.delegate = self
        let attributes = [
            //NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName : UIFont.boldSystemFontOfSize(20)
        ]
        commentTextField.attributedPlaceholder = NSAttributedString(string: "Share a comment", attributes:attributes)
        commentTextfeildView.addSubview(commentTextField)
        
        let button   = UIButton(type: UIButtonType.Custom) as UIButton
        button.frame = CGRectMake(commentTextField.frame.origin.x + commentTextField.frame.size.width+10, 15, 50, 50)
        button.layer.cornerRadius = 4
        button.backgroundColor = UIColor.redColor()
        button.setTitle("Send", forState: UIControlState.Normal)
        button.addTarget(self, action: "CommentSendButtonAction", forControlEvents: UIControlEvents.TouchUpInside)
        
        commentTextfeildView.addSubview(button)
        KGModal.sharedInstance().closeButtonType = KGModalCloseButtonType.None
        KGModal.sharedInstance().showWithContentView(self.timelineCommentView)
  
    }
    
    func CommentSendButtonAction(){
        Storage.performRequest(ApiRequest.TimelinePostComment(timeline!.uuid!, commentTextField.text!), completion: { (json) -> Void in
            print(json)
 
        })
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        <#code#>
    }
    
//    var data = ["Apple", "Apricot", "Banana", "Blueberry", "Cantaloupe", "Cherry",
//        "Clementine", "Coconut", "Cranberry", "Fig", "Grape", "Grapefruit",
//        "Kiwi fruit", "Lemon", "Lime", "Lychee", "Mandarine", "Mango",
//        "Melon", "Nectarine", "Olive", "Orange", "Papaya", "Peach",
//        "Pear", "Pineapple", "Raspberry", "Strawberry"]
    
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
        cellView.addSubview(userImage)
        
        let username = UILabel()
        username.frame = CGRectMake(80, 5, 250, 30)
        username.font = UIFont.boldSystemFontOfSize(18)
        //username.backgroundColor = UIColor(white: 0, alpha: 0.25)
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
        commentMessage.frame = CGRectMake(80, 40, 150, 30)
        commentMessage.font = UIFont.systemFontOfSize(15)
        commentMessage.textColor = UIColor.blackColor()
        if let raw = self.commentArray[indexPath.row] as? NSDictionary
        {
          let notifyStr = raw["comment"] as! String
            commentMessage.text = notifyStr
        }
        

        cellView.addSubview(commentMessage)
        
        return cell
    }

    
    func btnTouched(){
        KGModal.sharedInstance().hideAnimated(true)
        //self.payloadArray.removeAllObjects()
        self.timelineCommentView.removeFromSuperview()
        
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

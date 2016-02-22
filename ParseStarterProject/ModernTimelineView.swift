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

class ModernTimelineView: UIView , UITableViewDataSource , UITableViewDelegate {
    let timelineCommentView = UIView()
    let commentTextField = UITextField()
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
    var commentArray: NSArray = []
//    var raw: NSString = ""
//    var commentData: NSData?
    @IBAction func timelineCommentClick(sender: UIButton!){
        print("timeline id: \(timeline!.uuid!)")
        
        Storage.performRequest(ApiRequest.TimelineComments(timeline!.uuid!), completion: { (json) -> Void in
            print(json["result"])
            self.commentArray = (json["result"] as? NSArray)!
            print(self.commentArray)
            

            
        })

        let screenRect = UIScreen.mainScreen().bounds
        let screenWidth = screenRect.size.width;
        let screenHeight = screenRect.size.height;
        self.timelineCommentView.frame = CGRectMake(0, 0, screenWidth, screenHeight);
        self.timelineCommentView.backgroundColor = UIColor(white: 0 , alpha: 0.5)
        self.timelineCommentView.alpha = 1
        
        let commentScreenTitle = UILabel()
        commentScreenTitle.frame = CGRectMake(0, 0, screenWidth, 64)
        commentScreenTitle.font = UIFont.boldSystemFontOfSize(20)
        commentScreenTitle.textAlignment = .Center
        commentScreenTitle.backgroundColor = UIColor(white: 0, alpha: 0.5)
        commentScreenTitle.textColor = UIColor.whiteColor()
        commentScreenTitle.text = "Moment 2 Comments"
        self.timelineCommentView.addSubview(commentScreenTitle)
        
        // close button comment section
        let closeButton  = UIButton()
        closeButton.frame = CGRectMake(5, 20, 30, 30);
        closeButton.setImage(UIImage(named: "close") as UIImage?, forState: .Normal)
        closeButton.addTarget(self, action: "btnTouched", forControlEvents:.TouchUpInside)
        self.timelineCommentView.addSubview(closeButton)
        
        // table view declaration
        let commentlist = UITableView()
        commentlist.frame         =   CGRectMake(10, 80, self.timelineCommentView.frame.width-20, self.timelineCommentView.frame.height-200);
        commentlist.delegate      =   self
        commentlist.dataSource    =   self
        commentlist.backgroundColor = UIColor.clearColor()
        commentlist.separatorStyle = .None
        commentlist.tableFooterView = UIView()
        commentlist.registerClass(UITableViewCell.self, forCellReuseIdentifier: "commentCell")
        self.timelineCommentView.addSubview(commentlist)
        
        let commentTextfeildView = UIView()
        commentTextfeildView.frame = CGRectMake(0, self.timelineCommentView.frame.size.height-80, self.timelineCommentView.frame.size.width, 80)
        commentTextfeildView.backgroundColor = UIColor(white: 1, alpha: 0.1)
        self.timelineCommentView.addSubview(commentTextfeildView)
        
        
        commentTextField.frame = CGRectMake(10, 15, 280, 50)
        commentTextField.layer.cornerRadius = 4
        commentTextField.backgroundColor = UIColor(white: 1, alpha: 0.3)
        let attributes = [
            NSForegroundColorAttributeName: UIColor.whiteColor(),
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
    
    var data = ["Apple", "Apricot", "Banana", "Blueberry", "Cantaloupe", "Cherry",
        "Clementine", "Coconut", "Cranberry", "Fig", "Grape", "Grapefruit",
        "Kiwi fruit", "Lemon", "Lime", "Lychee", "Mandarine", "Mango",
        "Melon", "Nectarine", "Olive", "Orange", "Papaya", "Peach",
        "Pear", "Pineapple", "Raspberry", "Strawberry"]
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.commentArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("commentCell", forIndexPath: indexPath)
        
        cell.prepareForReuse()
        
        for object in cell.contentView.subviews
        {
            object.removeFromSuperview();
        }
        cell.selectionStyle = .None
        
        cell.backgroundColor = UIColor.clearColor()
        let cellView = UIView()
        cellView.frame = CGRectMake(0, 5, cell.contentView.frame.size.width, 75)
        cellView.backgroundColor = UIColor(white: 0, alpha: 0.25)
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
        username.textColor = UIColor.whiteColor()
        username.text = "@\(data[indexPath.row])"
        cellView.addSubview(username)
        
        //let :[String:String]
        //let dict = [:] = self.commentArray.objectAtIndex(indexPath.row)
//        var emptyDic = [String: String]() = self.commentArray.objectAtIndex(indexPath.row) as! [String : String]
//        let strEmo =   emptyDic["comment"]                    //"Hello 🐶🐮 🇩🇪"
        
//        let emoData = strEmo.dataUsingEncoding(NSNonLossyASCIIStringEncoding)
//        let goodValue = NSString.init(data: emoData!, encoding: NSUTF8StringEncoding)
//        
//        let emoData1 = goodValue!.dataUsingEncoding(NSUTF8StringEncoding)
//        let emoStringConverted = NSString.init(data: emoData1!, encoding: NSNonLossyASCIIStringEncoding)! as NSString
        
        let commentMessage = UILabel()
        commentMessage.frame = CGRectMake(80, 40, 150, 30)
        commentMessage.font = UIFont.systemFontOfSize(15)
        commentMessage.textColor = UIColor.whiteColor()
       // commentMessage.text = strEmo! as String

        cellView.addSubview(commentMessage)
        
        return cell
    }

    
    func btnTouched(){
        KGModal.sharedInstance().hideAnimated(true)
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

//
//  DraftPreview.swift
//  Timeline
//
//  Created by Valentin Knabel on 15.08.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import UIKit
import MediaPlayer
import KGModal


class DraftPreview: UIView , UITableViewDelegate , UITableViewDataSource, UITextFieldDelegate{
    let timelineCommentView = UIView()
    var momentCommentView = UIViewController()
    let commentTextField = UITextField()
    enum RightError {
    case BlockedTimeline(String, String)
    case BlockedUser(String, String)
    case NotPublic(String)
    case Viewable
    }
    
    var rightError: RightError = .Viewable
    var moment: Moment? {
        get {
            return moments.first
        }
        set {
            if let m = newValue {
                moments = [m]
            } else {
                moments = []
            }
        }
    }
    private var moments: [Moment] = [] {
        didSet {
            if let moment = moments.sort(<).first {
                previewImageView.moment = moment
            } else {
                previewImageView.moment = nil
            }
            playButton.enabled = moments.count != 0
            momentPlayerController?.pause()
            momentPlayerController = nil
            playbackContainer.hidden = true
//            bufferIndicator.hidden = true
        }
    }
    func setTimeline(timeline: Timeline?) {
        if let timeline = timeline,
            let owner = timeline.parent,
            let user = Storage.session.currentUser
        {
            if user.uuid == owner.uuid {
                self.moments = timeline.moments
                rightError = .Viewable
            } else if owner.blocked {
                self.moments = []
                rightError = .BlockedUser(owner.name ?? "", timeline.name)
            } else if timeline.blocked {
                self.moments = []
                rightError = .BlockedTimeline(owner.name ?? "", timeline.name)
            } else if !(owner.timelinesPublic ?? true) && owner.followed != FollowState.Following {
                self.moments = []
                rightError = .NotPublic(owner.name ?? "")
            } else {
                self.moments = timeline.moments
                rightError = .Viewable
            }
        } else {
            self.moments = timeline?.moments ?? []
            rightError = .Viewable
        }
    }
    
    @IBOutlet var previewImageView: MomentImageView!
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet var playButton: UIButton!

    var momentPlayerController: MomentPlayerController?
    @IBOutlet var playbackContainer: PlayerView!
    @IBOutlet var bufferIndicator: UIActivityIndicatorView!
    @IBOutlet var pausePlayButton: UIButton!
    @IBOutlet var playPlayButton: UIButton!
    @IBOutlet var previousPlayButton: UIButton!
    @IBOutlet var nextPlayButton: UIButton!
    @IBOutlet var commentButton: UIButton!
    
    // MARK: - Overlay start
    //// The maximum to the top: >= 8
    @IBOutlet var topLayoutConstraint: NSLayoutConstraint!
    /// The minimum to the bottom: <= -8
    @IBOutlet var bottomLayoutConstraint: NSLayoutConstraint!
    /// MIN: topLayoutConstraint.constant
    /// MAX: momentImageView.frame.size.height + bottomLayoutConstraint.constant
    @IBOutlet var positioningLayoutConstraint: NSLayoutConstraint!
    
    @IBOutlet var textField: UILabel!
    @IBOutlet var textFieldContainer: UIView!
    
    // MARK: Overlay end
    // MARK: -
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.previewImageView?.frame = self.bounds
        self.playbackContainer?.frame = self.bounds
    }
    
    @IBAction func playMoment() {
        func error(title title: String, message: String, button: String) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: button, style: .Default, handler: nil))
            
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let rootViewController = appDelegate.window?.rootViewController
            (rootViewController?.presentedViewController ?? rootViewController)?.presentAlertController(alert)
        }
        
        switch rightError {
        case .Viewable:
            bufferIndicator .startAnimating()
            if momentPlayerController == nil {
                momentPlayerController = MomentPlayerController(moments: moments, inView: playbackContainer)
                momentPlayerController?.delegate = self
                pausePlayButton.hidden = false
                playPlayButton.hidden = true
            }
            momentPlayerController?.play()
            playbackContainer.hidden = false
            bufferIndicator.hidden = false
        case let .BlockedTimeline(u, t):
            error(
                title: lformat(LocalizedString.TimelineAlertBlockedTimelineTitle1s, t),
                message: lformat(LocalizedString.TimelineAlertBlockedTimelineMessage2s, args: u, t),
                button: local(LocalizedString.TimelineAlertBlockedTimelineActionDismiss)
            )
        case let .BlockedUser(u, t):
            error(
                title: lformat(LocalizedString.TimelineAlertBlockedUserTitle1s, u),
                message: lformat(LocalizedString.TimelineAlertBlockedUserMessage2s, args: u, t),
                button: local(LocalizedString.TimelineAlertBlockedUserActionDismiss)
            )
        case let .NotPublic(u):
            error(
                title: lformat(LocalizedString.TimelineAlertNotPublicTitle1s, u),
                message: lformat(LocalizedString.TimelineAlertNotPublicMessage1s, u),
                button: local(LocalizedString.TimelineAlertNotPublicActionDismiss)
            )
        }
    }
    
    @IBAction func play() {
        bufferIndicator.startAnimating()
        pausePlayButton.hidden = false
        playPlayButton.hidden = true
        momentPlayerController?.play()
    }
    
    @IBAction func pause() {
        bufferIndicator.stopAnimating()
        pausePlayButton.hidden = true
        playPlayButton.hidden = false
        momentPlayerController?.pause()
    }
    
    var commentArray = NSMutableArray()
    
    @IBAction func commentButtonClick(){
        print(moment?.state.uuid!)
        
        Storage.performRequest(ApiRequest.MomentComments((moment?.state.uuid)!), completion: { (json) -> Void in
            print(json)
            
                    if let raw = json["result"] as? NSString,
                        let data = raw.dataUsingEncoding(NSUTF8StringEncoding),
                        let payload = (try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)) as? [String: AnyObject]
                    {
                        print(payload)
                    }

        })
        
        let screenRect = UIScreen.mainScreen().bounds
        let screenWidth = screenRect.size.width;
        let screenHeight = screenRect.size.height;
        timelineCommentView.frame = CGRectMake(0, 0, screenWidth, screenHeight);
        timelineCommentView.backgroundColor = UIColor(white: 0 , alpha: 0.5)
        timelineCommentView.alpha = 1
        
        let commentScreenTitle = UILabel()
        commentScreenTitle.frame = CGRectMake(0, 0, screenWidth, 64)
        commentScreenTitle.font = UIFont.boldSystemFontOfSize(20)
        commentScreenTitle.textAlignment = .Center
        commentScreenTitle.backgroundColor = UIColor(white: 0, alpha: 0.5)
        commentScreenTitle.textColor = UIColor.whiteColor()
        commentScreenTitle.text = "Moment 2 Comments"
        timelineCommentView.addSubview(commentScreenTitle)
        
        // close button comment section
        let closeButton  = UIButton()
        closeButton.frame = CGRectMake(5, 20, 30, 30);
        closeButton.setImage(UIImage(named: "close") as UIImage?, forState: .Normal)
        closeButton.addTarget(self, action: "btnTouched", forControlEvents:.TouchUpInside)
        timelineCommentView.addSubview(closeButton)
        
        // table view declaration
        let commentlist = UITableView()
        commentlist.frame         =   CGRectMake(10, 80, timelineCommentView.frame.width-20, timelineCommentView.frame.height-200);
        commentlist.delegate      =   self
        commentlist.dataSource    =   self
        commentlist.backgroundColor = UIColor.clearColor()
        commentlist.separatorStyle = .None
        commentlist.tableFooterView = UIView()
        commentlist.registerClass(UITableViewCell.self, forCellReuseIdentifier: "commentCell")
        timelineCommentView.addSubview(commentlist)
        
        let commentTextfeildView = UIView()
        commentTextfeildView.frame = CGRectMake(0, timelineCommentView.frame.size.height-80, timelineCommentView.frame.size.width, 80)
        commentTextfeildView.backgroundColor = UIColor(white: 1, alpha: 0.1)
        timelineCommentView.addSubview(commentTextfeildView)
        
        
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
        button.addTarget(self, action: "MomentPostComment", forControlEvents: UIControlEvents.TouchUpInside)
        
        commentTextfeildView.addSubview(button)
        KGModal.sharedInstance().closeButtonType = KGModalCloseButtonType.None
        KGModal.sharedInstance().showWithContentView(timelineCommentView)
        
        
    }
    func MomentPostComment(){
    
        Storage.performRequest(ApiRequest.MomentPostComment((moment?.state.uuid)!, commentTextField.text!), completion: { (json) -> Void in
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
        return data.count
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
        
        let strEmo = "U+1F514"
        let emoData = strEmo.dataUsingEncoding(NSNonLossyASCIIStringEncoding)
        let goodValue = NSString.init(data: emoData!, encoding: NSUTF8StringEncoding)
        
        let emoData1 = goodValue!.dataUsingEncoding(NSUTF8StringEncoding)
        let emoStringConverted = NSString.init(data: emoData1!, encoding: NSNonLossyASCIIStringEncoding)! as NSString
        
        let commentMessage = UILabel()
        commentMessage.frame = CGRectMake(80, 40, 150, 30)
        commentMessage.font = UIFont.systemFontOfSize(15)
        commentMessage.textColor = UIColor.whiteColor()
        commentMessage.text = emoStringConverted as String
        
        cellView.addSubview(commentMessage)
        
        return cell
    }
    
    
    func btnTouched(){
        KGModal.sharedInstance().hideAnimated(true)
    }
    
    @IBAction func previous() {
        bufferIndicator.startAnimating()
        momentPlayerController?.previous()
    }
    
    @IBAction func next() {
        bufferIndicator.startAnimating()
        momentPlayerController?.next()
    }
    
    @IBAction func stop() {
        bufferIndicator.stopAnimating()
        momentPlayerController?.stop()
        momentPlayerController = nil
        playbackContainer.hidden = true
//        bufferIndicator.hidden = true

        serialHook.perform(key: .StopAllPlaybacks, argument: ())
    }
    
    func setCurrentMoment(moment: Moment) {
        if momentPlayerController == nil {
            momentPlayerController = MomentPlayerController(moments: moments, inView: playbackContainer)
            momentPlayerController?.delegate = self
            pausePlayButton.hidden = false
            playPlayButton.hidden = true
        }
        momentPlayerController?.setCurrentMoment(moment)
    }

    deinit {
        print("Draft deinited")
    }
}

extension DraftPreview: MomentPlayerControllerDelegate {

    func momentPlayerControllerDidFinishPlaying(momentPlayerController: MomentPlayerController?) {
        main {
            self.playbackContainer.hidden = true
//            self.bufferIndicator.hidden = true
            self.stop()
        }
    }
    
    func momentPlayerController(momentPlayerController: MomentPlayerController, isBuffering: Bool) {
        main {
            if isBuffering {
                self.bufferIndicator.startAnimating()
            } else {
                self.bufferIndicator.stopAnimating()
            }
        }
    }
    
    func momentPlayerControllerItemDidChange(momentPlayerController: MomentPlayerController, moment: Moment?) {
        
        main {
            self.previousPlayButton.userInteractionEnabled = momentPlayerController.isFirst ? false : true
            self.nextPlayButton.userInteractionEnabled = momentPlayerController.isLast ? false : true

        UIView.animateWithDuration(0.5, animations: {
            self.previousPlayButton.alpha = momentPlayerController.isFirst ? 0.0 : 0.5
            self.nextPlayButton.alpha = momentPlayerController.isLast ? 0.0 : 0.5
            
            (self.previousPlayButton.hidden, self.nextPlayButton.hidden) = (false, false)
            
            self.previousPlayButton.enabled = !momentPlayerController.isFirst
            self.nextPlayButton.enabled = !momentPlayerController.isLast
            
            if let moment = moment,
                let text = moment.overlayText,
                let color = moment.overlayColor,
                let position = moment.overlayPosition,
                let size = moment.overlaySize
            {
                self.textField.text = text
                self.textField.textColor = color
                self.textField.font = UIFont(descriptor: self.textField.font.fontDescriptor(), size: CGFloat(size))
                self.positioningLayoutConstraint.constant = self.validPosition(self.minPosition + CGFloat(position) * self.maxPosition)
                self.textFieldContainer.hidden = false
                //self.textFieldContainer.alpha = 1.0
            } else {
                //self.textFieldContainer.alpha = 0.0
                self.textFieldContainer.hidden = true
            }
            self.layoutIfNeeded()
            }) { _ in
                self.previousPlayButton.hidden = momentPlayerController.isFirst
                self.nextPlayButton.hidden = momentPlayerController.isLast
        }
    }
    }
}

// MARK: - UIGestureRecognizerDelegate
extension DraftPreview {
    
    private var minPosition: CGFloat {
        return topLayoutConstraint.constant
    }
    private var maxPosition: CGFloat {
        return previewImageView.frame.size.height - abs(bottomLayoutConstraint.constant) - textFieldContainer.frame.size.height
    }
    private var relativePosition: CGFloat {
        return (positioningLayoutConstraint.constant - minPosition) / maxPosition
    }
    private func validPosition(newPosition: CGFloat) -> CGFloat {
        return max(minPosition, min(newPosition, maxPosition))
    }
}

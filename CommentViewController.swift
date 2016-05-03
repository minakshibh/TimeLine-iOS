//
//  CommentViewController.swift
//  Timeline
//
//  Created by Krishna-Mac on 22/04/16.
//  Copyright © 2016 Conclurer GbR. All rights reserved.
//

import UIKit
import SlackTextViewController


class CommentViewController: SLKTextViewController {
    
    var timelineCommentID : String = ""
    var userArray : NSMutableArray = []
    var userImageArray : NSMutableArray = []
    var searchResult : NSArray = []
    var activityIndicator = UIActivityIndicatorView()
    let activityIndicatorView = UIView()
    var messages : NSMutableArray = []
    var ownTimeline : Bool = false
    var textMessage : String = ""
    let reuseIdentifier = "programmaticCell"
    var invitedFriendsArray : NSMutableArray = []
    var InvitedFriends_id : NSMutableArray = []
    var InvitedFriendsIdSTr : NSString = ""
    var editmessageid : String = ""
    var IsMoment : Bool = false
    var CurrentMoment: Int = 0
    
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
    
    override class func tableViewStyleForCoder(decoder: NSCoder) -> UITableViewStyle {
        return UITableViewStyle.Plain;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if IsMoment{
            if let raw : Int = CurrentMoment{
                navigationItem.title = "Moment \(raw + 1) Comments"
            }
        }else{
            navigationItem.title = "Comments"
        }
        
        navigationController?.navigationBar.tintColor = UIColor.redNavbarColor()
        navigationController?.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName : UIColor.whiteColor()
        ]
        
        self.inverted = false
        self.textInputbar.backgroundColor = UIColor.groupTableViewBackgroundColor()
        self.textInputbar.textView.placeholder = "Share a comment"
        self.textInputbar.autoHideRightButton = true
        
        self.tableView?.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.tableView?.separatorStyle = .None
        self.autoCompletionView.registerClass(MessageTableViewCell.self, forCellReuseIdentifier: AutoCompletionCellIdentifier)
        self.registerPrefixesForAutoCompletion(["@"])
        
        self.activityIndicatorView.frame = CGRectMake(0, 0, 70, 70);
        self.activityIndicatorView.backgroundColor = UIColor.grayColor()
        self.activityIndicatorView.alpha = 1
        self.activityIndicatorView.center = self.view.center
        self.activityIndicatorView.layer.cornerRadius = 4
        self.view.addSubview(self.activityIndicatorView)
        
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
        
        self.fetchingDataFromAPI()
//        print("isMoment: \(IsMoment) and current index:\(CurrentMoment)")
    }
    
    func fetchingDataFromAPI(){
        
        Storage.performRequest(ApiRequest.GetTagUsers, completion: { (json) -> Void in
            
            if let raw = json["result"] as? NSMutableArray{
                for (var i = 0; i < raw.count; i++ ){
                    if let username = raw[i] as? NSDictionary
                    {
                        //print("Username : \(username)")
                        //                        var userDict = NSMutableDictionary()
                        ////                        userDict = username
                        //                        userDict.setObject(username["name"]!, forKey: "name")
                        //                        userDict.setObject(username["image"]!, forKey: "image")
                        self.userArray.addObject(username)
                    }
                }
            }
        })
        if IsMoment{
            
            Storage.performRequest(ApiRequest.MomentComments(timelineCommentID), completion: { (json) -> Void in
                if let raw = json["result"] as? NSMutableArray{
                    self.messages = raw
                    
                }
                main{
//                    self.tableView!.reloadData()
//                    let numberOfRows = self.tableView!.numberOfRowsInSection(0)
//                    if numberOfRows > 0 {
//                        let indexPath = NSIndexPath(forRow: numberOfRows-1, inSection: 0)
//                        self.tableView!.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
                    
                        self.tableView?.reloadData()
                        self.activityIndicator.stopAnimating()
                        self.activityIndicatorView.removeFromSuperview()
                   
                }
                
            })
            
        }else{
            Storage.performRequest(ApiRequest.TimelineComments(timelineCommentID), completion: { (json) -> Void in
                if let raw = json["result"] as? NSMutableArray{
                    self.messages = raw
                    print("messages : \(raw)")
                    main{
                        self.tableView?.reloadData()
                        self.activityIndicator.stopAnimating()
                        self.activityIndicatorView.removeFromSuperview()
                    }
                }
            })
        }
        
    }
    
    
    override func didChangeAutoCompletionPrefix(prefix: String, andWord word: String) {
        
        var array : NSArray = []
        self.searchResult = []
        if (prefix == "@") {
            if (word.characters.count > 0) {
                array = self.userArray .filteredArrayUsingPredicate(NSPredicate(format:"name contains[c] %@", word))
            }
            else {
                array = self.userArray
            }
        }
        
        if (array.count > 0) {
            //array  = array.sortedArrayUsingSelector(#selector(NSString.localizedCaseInsensitiveCompare(_:)))
            array = array.sort({ $0.name > $1.name })
        }
        print("search array \(array)")
        self.searchResult = array
        let show : Bool = (self.searchResult.count > 0);
        self.showAutoCompletionView(show)
    }
    
    override func heightForAutoCompletionView() -> CGFloat {
        let cellHeight : CGFloat = (self.autoCompletionView.delegate?.tableView!(self.autoCompletionView, heightForRowAtIndexPath: NSIndexPath.init(forRow: 0, inSection: 0)))!
        return cellHeight*CGFloat(self.searchResult.count);
    }
    
    //MARK:UITableViewDataSoure Methods
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == self.tableView) {
            return self.messages.count;
        }else{
            return self.searchResult.count
        }
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        if (tableView == self.tableView) {
            
            return self.messageCellForRowAtIndexPath(indexPath)
            
        }else{
            return self.autoCompletionCellForRowAtIndexPath(indexPath)
        }
        
    }
    
    func messageCellForRowAtIndexPath(indexPath: NSIndexPath) -> MGSwipeTableCell{
        
        var cell = self.tableView!.dequeueReusableCellWithIdentifier(reuseIdentifier) as! MGSwipeTableCell!
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
        cellView.frame = CGRectMake(0, 0, self.view.frame.size.width, 65)
        cellView.backgroundColor = UIColor.whiteColor()
        cell.contentView.addSubview(cellView)
        
        let userImage = UIButton()
        userImage.frame = CGRectMake(15, 10, 50, 50)
        userImage.backgroundColor = UIColor.lightGrayColor()
        userImage.layer.cornerRadius = 25
        userImage.tag = indexPath.row
        
//        {
//            if let notifyStr = raw["user_image"] as? String {
//                userImage.sd_setBackgroundImageWithURL(NSURL(string: notifyStr), forState: .Normal)
//            }
//        }
        if let raw = self.messages[indexPath.row] as? NSDictionary
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
        userImage.addTarget(self, action: #selector(CommentViewController.UserImageClick(_:)), forControlEvents: .TouchUpInside)
        userImage.clipsToBounds = true
        cellView.addSubview(userImage)
        
        let username = UILabel()
        username.frame = CGRectMake(80, 5, 250, 30)
        username.font = UIFont.boldSystemFontOfSize(18)
        username.textColor = UIColor.blackColor()
        if let raw = self.messages[indexPath.row] as? NSDictionary
        {
            let notifyStr = raw["username"] as! String
            username.text = "@\(notifyStr)"
        }
        cellView.addSubview(username)
        
        let timeStamp = UILabel()
        timeStamp.frame = CGRectMake(cellView.frame.size.width-110, 5, 100, 30)
        timeStamp.font = UIFont.systemFontOfSize(12)
        
        timeStamp.textColor = UIColor.blackColor()
        if let raw = self.messages[indexPath.row] as? NSDictionary
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
                timeStr = String(months) + "mo"
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
                timeStr = String(minutes) + "min"
            }
            else{
                timeStr = String(duration) + "s"
            }
            
            timeStamp.text = timeStr
            timeStamp.textAlignment = .Right
        }
        cellView.addSubview(timeStamp)
        
        let commentMessage = UILabel()
        commentMessage.frame = CGRectMake(80, 30, CGFloat(250+40*IPHONE6P-55*IPHONE5), 30)
        commentMessage.font = UIFont.systemFontOfSize(15)
        commentMessage.textColor = UIColor.blackColor()
        if let raw = self.messages[indexPath.row] as? NSDictionary
        {
            if let notifyStr = raw["comment"] as? String
            {
                let emoData1 = notifyStr.dataUsingEncoding(NSUTF8StringEncoding)
                let emoStringConverted = String.init(data: emoData1!, encoding: NSNonLossyASCIIStringEncoding)! as String
                let newString = emoStringConverted.stringByReplacingOccurrencesOfString("%26", withString: "&")
                commentMessage.text = newString
            }
        }
        cellView.addSubview(username)
        commentMessage.autosizeForWidth()
        cellView.addSubview(commentMessage)
        
        let notifyStr : String
        if let raw = self.messages[indexPath.row] as? NSDictionary
        {
            
            notifyStr = raw["user_id"] as! String
            if (notifyStr == Storage.session.uuid)
            {
                //configure right buttons
                cell.rightButtons = [MGSwipeButton(title: "", icon:UIImage(named: "CommentDelete.png"),backgroundColor: UIColor.redColor(), callback: {
                    (sender: MGSwipeTableCell!) -> Bool in
                    print("Delete: \(indexPath.row)")
                    if let raw = self.messages[indexPath.row] as? NSDictionary
                    {
                        let notifyStr = raw["id"] as! String
                        print(notifyStr)
                        self.deleteCommentAPI(notifyStr)
                    }
                    
                    return true
                }),MGSwipeButton(title: "",icon:UIImage(named: "CommentEdit.png"),backgroundColor: UIColor.lightGrayColor(), callback: {
                    (sender: MGSwipeTableCell!) -> Bool in
                    
                    self.editCellMessage(indexPath)
                    return true
                })]
                cell.rightSwipeSettings.transition = MGSwipeTransition.ClipCenter
            }
                
            else if  (ownTimeline)
            {
                cell.rightButtons = [MGSwipeButton(title: "",icon:UIImage(named: "CommentDelete.png") ,backgroundColor: UIColor.redColor(), callback: {
                    (sender: MGSwipeTableCell!) -> Bool in
                    print("Delete: \(indexPath.row)")
                    
                    if let raw = self.messages[indexPath.row] as? NSDictionary
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
        return cell;
    }
    
    func autoCompletionCellForRowAtIndexPath(indexPath: NSIndexPath) -> MessageTableViewCell{
        let cell: MessageTableViewCell = MessageTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: AutoCompletionCellIdentifier)
        cell.indexPath = indexPath;
        if let user: NSMutableDictionary = self.searchResult[indexPath.row] as? NSMutableDictionary{
            cell.titleLabel.text = user["name"] as? String
            if let userimage : String = user["image"] as? String{
                cell.thumbnailView.sd_setImageWithURL(NSURL(string: userimage))
            }
        }
        //@cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        return cell;
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(tableView == self.tableView){
            let commentMessage = UILabel()
            commentMessage.frame = CGRectMake(80, 40, CGFloat(250+40*self.IPHONE6P-55*self.IPHONE5), 30)
            commentMessage.font = UIFont.systemFontOfSize(15)
            commentMessage.textColor = UIColor.blackColor()
            if let raw = self.messages[indexPath.row] as? NSDictionary
            {
                if let notifyStr = raw["comment"] as? String{
                    
                    let emoData1 = notifyStr.dataUsingEncoding(NSUTF8StringEncoding)
                    let emoStringConverted = String.init(data: emoData1!, encoding: NSNonLossyASCIIStringEncoding)! as String
                    
                    
                    commentMessage.text = emoStringConverted
                }
            }
            commentMessage.autosizeForWidth()
            
            return CGFloat(35+commentMessage.frame.size.height)
        }else{
            return kMessageTableViewCellMinimumHeight
        }
        
    }
    
    //MARK:UITableViewDelegate Methods
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (tableView == self.autoCompletionView) {
            var item : NSMutableString = ""
            if let userDetail : NSMutableDictionary = self.searchResult[indexPath.row] as? NSMutableDictionary{
                item  = NSMutableString(string: userDetail["name"] as! String)
            }
            //            if (self.foundPrefix == "@" && self.foundPrefixRange.location == 0) {
            //                item.appendString(":")
            //            }
            item.appendString(" ")
            self.villainButtonPressed(indexPath)
            self.acceptAutoCompletionWithString(item as String , keepPrefix: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func villainButtonPressed(indexPath:NSIndexPath){
        print(indexPath.row)
        var user_id : NSString = ""
        if let dataDict = self.userArray[indexPath.row] as? NSDictionary
        {
            user_id = (dataDict["id"] as? String!)!
        }
        
        if invitedFriendsArray .containsObject(indexPath.row)
        {
            
            self.invitedFriendsArray .removeObject(indexPath.row)
            self.InvitedFriends_id .removeObject(user_id)
        }
        else
        {
            
            self.invitedFriendsArray .addObject(indexPath.row)
            self.InvitedFriends_id .addObject(user_id)
        }
        
        if let raw = self.userArray[indexPath.row] as? NSDictionary{
            
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
            
        }
        
    }
    
    func editCellMessage(indexPath: NSIndexPath){
        delay(0.001) {
            if let raw = self.messages[indexPath.row] as? NSDictionary
            {
                if let notifyStr = raw["comment"] as? String{
                    let convertedString = notifyStr.stringByReplacingOccurrencesOfString("%26", withString: "&")
                    self.textMessage = convertedString
                }
                if let messageID = raw["id"] as? String{
                    self.editmessageid = messageID
                }
            }
            
            self.editText(self.textMessage)
            self.tableView?.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
        }
        
    }
    
    override func didPressRightButton(sender: AnyObject?) {
        
        self.textView.refreshFirstResponder()
        
        let TrimString = self.textView.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        if(TrimString == ""){
            let alert = UIAlertView()
            alert.title = ""
            alert.message = "Please enter your comment first."
            alert.addButtonWithTitle(local(.MomentAlertUploadErrorActionDismiss))
            alert.show()
            return
        }
        
        let emoData = self.textView.text.dataUsingEncoding(NSNonLossyASCIIStringEncoding)
        let goodValue = NSString.init(data: emoData!, encoding: NSUTF8StringEncoding)
        let newString = goodValue!.stringByReplacingOccurrencesOfString("&", withString: "%26")
        
        if IsMoment{
            Storage.performRequest(ApiRequest.MomentPostComment(timelineCommentID, newString as PARAMS, InvitedFriendsIdSTr as UserIdString), completion: { (json) -> Void in
                
                
                Storage.performRequest(ApiRequest.MomentComments(self.timelineCommentID), completion: { (json) -> Void in
                    if let raw = json["result"] as? NSMutableArray{
                        self.messages = raw
                        
                    }
                    main{
                        self.tableView!.reloadData()
                        let numberOfRows = self.tableView!.numberOfRowsInSection(0)
                        if numberOfRows > 0 {
                            let indexPath = NSIndexPath(forRow: numberOfRows-1, inSection: 0)
                            self.tableView!.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
                        }
                    }
                    
                })
                
            })
            
        }else{
            
            Storage.performRequest(ApiRequest.TimelinePostComment(timelineCommentID, newString as PARAMS , InvitedFriendsIdSTr as UserIdString), completion: { (json) -> Void in
                main{
                    Storage.performRequest(ApiRequest.TimelineComments(self.timelineCommentID), completion: { (json) -> Void in
                        if let raw = json["result"] as? NSMutableArray{
                            self.messages = raw
                        }
                        main{
                            serialHook.perform(key: .ForceReloadData, argument: ())
                            delay(0.001){
                                self.tableView?.reloadData()
                                let numberOfRows = self.tableView?.numberOfRowsInSection(0)
                                if numberOfRows > 0 {
                                    let indexPath = NSIndexPath(forRow: numberOfRows!-1, inSection: 0)
                                    self.tableView?.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
                            }
                            
                            }
                        }
                    })
                }
                
            })
        }
        
        super.didPressRightButton(sender)
    }
    
    func deleteCommentAPI(commentid: String){
        
        if IsMoment{
            Storage.performRequest(ApiRequest.DeleteComment(commentid as commentID), completion: { (json) -> Void in
                print(json)
                main{
                    Storage.performRequest(ApiRequest.MomentComments(self.timelineCommentID), completion: { (json) -> Void in
                        
                        if let raw = json["result"] as? NSMutableArray{
                            self.messages = raw
                            
                        }
                        main{
                            self.tableView!.reloadData()
                        }
                        
                    })
                }
            })
        }else{
            Storage.performRequest(ApiRequest.DeleteComment(commentid as commentID), completion: { (json) -> Void in
                print(json)
                main{
                    Storage.performRequest(ApiRequest.TimelineComments(self.timelineCommentID), completion: { (json) -> Void in
                        main{
                            if let raw = json["result"] as? NSMutableArray{
                                self.messages = raw
                                
                            }
                            main({
                                self.tableView!.reloadData()
                            })
                        }
                    })
                }
                
            })
        }
        
    }
    override func didCommitTextEditing(sender: AnyObject)
    {
        // Notifies the view controller when tapped on the right "Accept" button for commiting the edited text
        //    self.editingMessage.text = self.textView.text.copy
        //
        //    self.tableView!.reloadData()
        
        
        let TrimString = self.textView.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        if(TrimString == ""){
            let alert = UIAlertView()
            alert.title = ""
            alert.message = "Please enter your comment first."
            alert.addButtonWithTitle(local(.MomentAlertUploadErrorActionDismiss))
            alert.show()
            return
        }
        
        let emoData = self.textView.text!.dataUsingEncoding(NSNonLossyASCIIStringEncoding)
        let goodValue = NSString.init(data: emoData!, encoding: NSUTF8StringEncoding)
        let newString = goodValue!.stringByReplacingOccurrencesOfString("&", withString: "%26")
        
        if IsMoment{
            Storage.performRequest(ApiRequest.EditComment(self.editmessageid as commentID, newString as commentmessage , InvitedFriendsIdSTr as UserIdString), completion: { (json) -> Void in
                main{
                    print(json)
                    Storage.performRequest(ApiRequest.MomentComments(self.timelineCommentID), completion: { (json) -> Void in
                        if let raw = json["result"] as? NSMutableArray{
                            self.messages = raw
                            
                        }
                        main{
                            self.tableView!.reloadData()
                        }
                        
                    })
                    
                }
                
                
            })
        }else{
            Storage.performRequest(ApiRequest.EditComment(self.editmessageid as commentID, newString as commentmessage, InvitedFriendsIdSTr as UserIdString), completion: { (json) -> Void in
            main{
                
                Storage.performRequest(ApiRequest.TimelineComments(self.timelineCommentID), completion: { (json) -> Void in
                    if let raw = json["result"] as? NSMutableArray{
                        self.messages = raw
                        
                    }
                    main{
                        self.tableView!.reloadData()
                        
                    }
                    
                })
            }
            
        })
        }
        
        super.didCommitTextEditing(sender)
    }
    
    override func didCancelTextEditing(sender: AnyObject)
    {
        // Notifies the view controller when tapped on the left "Cancel" button
        
        super.didCancelTextEditing(sender)
    }
    
    func UserImageClick(sender: UIButton){
        print(sender.tag)
        if let raw = self.messages[sender.tag] as? NSDictionary
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
                        push.timeline_id = self.timelineCommentID
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
    
}


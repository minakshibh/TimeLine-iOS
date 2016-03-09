//
//  CreateTimelineViewController.swift
//  Timeline
//
//  Created by Valentin Knabel on 08.08.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import UIKit
import KGModal
import SDWebImage
import QuartzCore

class CreateTimelineViewController: SubmitViewController ,UITableViewDataSource , UITableViewDelegate {

    @IBOutlet var submitButton: UIButton!
    @IBOutlet var warningLabel: UILabel!
    let friendsListView = UIView()
    let friendslistTableView = UITableView()
    var dataArray = NSArray()
    var upgrading: Bool = false
    var invitedFriendsArray : NSMutableArray = []
    var InvitedFriends_id : NSMutableArray = []
    var GroupTimeline : Bool = false
    var headerLabelSTr : (NSString) = ""
    @IBOutlet var timelineDetailTxtView: UITextView!
    @IBOutlet var DescribeTimelineHeaderLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        headerLabelSTr = appDelegate.headerLabelSTr
        GroupTimeline = appDelegate.GroupTimeline

        navigationItem.title = headerLabelSTr as String
        if GroupTimeline{
            submitButton.setTitle("NEXT", forState: UIControlState.Normal)
            self.textFields.first!.placeholder = "#tagyourgroupfeedeo"
            DescribeTimelineHeaderLabel?.text = "Describe group feedeo.."

            self.getFriendsList()
            self.addFriendsListView()
        }
        else{
            submitButton.titleLabel?.text = "DONE"
            submitButton.setTitle("DONE", forState: UIControlState.Normal)
            self.textFields.first!.placeholder = "#tagyourfeedeo"
            DescribeTimelineHeaderLabel?.text = "Describe feedeo.."
        }
        timelineDetailTxtView.layer.cornerRadius = 4
        DescribeTimelineHeaderLabel.hidden = false
        self.friendsListView.hidden=true
        //tabBarController?.delegate = self
        //navigationController?.delegate = self

        // Do any additional setup after loading the view.
    }
    func getFriendsList()
    {
        Storage.performRequest(ApiRequest.GetTagUsers, completion: { (json) -> Void in
            // print(json)
//            if let results = json["result"] as? [[String: AnyObject]]
//            {
//                
//            }
            if let results = json["result"] as? NSMutableArray{
                self.dataArray = results
                print(self.dataArray)
            }
        })
    }
    override func viewWillAppear(animated: Bool) {
        if upgrading {
            submitAction()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction override func submitAction() {
        guard let title = self.textFields.first!.text else { return }
        if title == "" {
            let alert = UIAlertController(title: local(.TimelineAlertCreateMissingTitle), message: local(.TimelineAlertCreateMissingMessage), preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: local(.TimelineAlertCreateMissingDismiss), style: .Default, handler: nil))
            self.presentAlertController(alert)
            return
        }

        guard let detailTimeline = self.timelineDetailTxtView.text else { return }
        if detailTimeline == "" {
            let alert = UIAlertController(title: local(.TimelineAlertCreateMissingTitle), message: local(.TimelineAlertCreateMissingDetailMessage), preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: local(.TimelineAlertCreateMissingDismiss), style: .Default, handler: nil))
            self.presentAlertController(alert)
            return
        }
        
        self.submitButton.enabled = false
        self.textFields.first?.enabled = false
        self.navigationItem.setHidesBackButton(true, animated: true)
        self.upgrading = false
        
        if GroupTimeline{
            self.groupTimelineButtonAction()
        }
        else
        {
            self.CreateSingleTimelineButtonAction()
        }
    }
    func CreateSingleTimelineButtonAction() {
        main {
            guard let title = self.textFields.first!.text else { return }
            guard let description = self.timelineDetailTxtView.text else { return }
            Storage.performRequest(.CreateTimeline(title,description)) { (json) -> Void in
                print("timelime API response :\(json)")

                switch json["status_code"] as? Int ?? 400 {
                case 400, 402: // payment required
                    main {
                    let alert = UIAlertController(title: local(LocalizedString.TimelineAlertLimitRequiredTitle),
                        message: local(LocalizedString.TimelineAlertLimitRequiredMessage),
                        preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: local(LocalizedString.TimelineAlertLimitRequiredActionUpgrade),
                        style: UIAlertActionStyle.Default,
                        handler: { _ in
                            self.upgrading = true
                            self.performSegueWithIdentifier("BuyUpgrade", sender: self)
                    }))
                    alert.addAction(UIAlertAction(title: local(LocalizedString.TimelineAlertLimitRequiredActionCancel),
                        style: UIAlertActionStyle.Cancel,
                        handler: { _ in
                            self.navigationController?.popViewControllerAnimated(true)
                    }))
                    self.presentAlertController(alert)
                    }
                    
                default:
                    if let error = (json["error"] as? String) ?? (json["error"] as? [AnyObject])?.first as? String {
                        main {
                            let alert = UIAlertController(title: local(.TimelineAlertCreateErrorTitle), message: error, preferredStyle: .Alert)
                            alert.addAction(UIAlertAction(title: local(.TimelineAlertCreateErrorActionDismiss), style: .Default, handler: nil))
                            self.presentAlertController(alert)
                            
                            self.submitButton.enabled = true
                            self.textFields.first?.enabled = true
                            self.navigationItem.setHidesBackButton(false, animated: true)
                            self.upgrading = false
                        }
                    }
                }
                
                if  let _ = json["id"] as? String,
                    let _ = json["name"] as? String,
                    let _ = json["updated_at"] as? String,
                    let _ = json["created_at"] as? String,
                    let _ = json["likers_count"] as? Int,
                    let _ = json["followers_count"] as? Int
                {
                    let user = Storage.session.currentUser
                    let tl = Timeline(dict: json, parent: user)
                    tl.persistent = false
                    user?.timelines.append(tl)
                    Storage.save()
                    
                    main {
                        self.submitButton.enabled = true
                        self.upgrading = false
                        self.navigationController?.popViewControllerAnimated(true)
                        self.navigationController?.topViewController?.performSegueWithIdentifier("TimelineCreated", sender: tl)
                    }
                }
            }
        }
    }
    
    func groupTimelineButtonAction() {
        main {
            
            self.textFields.first?.enabled = false
            self.navigationItem.setHidesBackButton(true, animated: true)
            self.upgrading = false
            
            self.friendsListView.hidden=false
            self.friendslistTableView.reloadData()
            
            KGModal.sharedInstance().closeButtonType = KGModalCloseButtonType.None
            KGModal.sharedInstance().showWithContentView(self.friendsListView)
        }
        
    }
    
    func addFriendsListView()
    {
        let screenRect = UIScreen.mainScreen().bounds
        let screenWidth = screenRect.size.width;
        let screenHeight = screenRect.size.height;
        self.friendsListView.frame = CGRectMake(0, 0, screenWidth, screenHeight);
        self.friendsListView.backgroundColor = UIColor.whiteColor()
        self.friendsListView.alpha = 1
        
        let headerBackView = UILabel()
        headerBackView.frame = CGRectMake(0, 0, screenWidth, 70)
        headerBackView.textAlignment = .Center
        headerBackView.backgroundColor = UIColor(red:235.0/255.0,green:129.0/255.0,blue:40.0/255.0,alpha:1.0)
        headerBackView.text = ""
        self.friendsListView.addSubview(headerBackView)
        
        let viewTitle = UILabel()
        viewTitle.frame = CGRectMake(0, 30, screenWidth, 30)
        viewTitle.font = UIFont.boldSystemFontOfSize(17)
        viewTitle.textAlignment = .Center
        viewTitle.backgroundColor = UIColor.clearColor()
        viewTitle.textColor = UIColor.whiteColor()
        viewTitle.text = "Select Members"
        self.friendsListView.addSubview(viewTitle)
        
        // close button comment section
        let closeButton  = UIButton()
        closeButton.frame = CGRectMake(5, 30, 30, 30);
        closeButton.setImage(UIImage(named: "Back to previous screen") as UIImage?, forState: .Normal)
        closeButton.addTarget(self, action: "closeViewButton", forControlEvents:.TouchUpInside)
        self.friendsListView.addSubview(closeButton)
        
        
        let friendslistY: CGFloat = 80
        let friendslistHeight: CGFloat = self.friendsListView.frame.height-150
        
        // DONE button comment section
        let doneButton   = UIButton()
        doneButton.frame = CGRectMake(self.view.frame.size.width - 70.0 , 30, 65, 30)
        doneButton.layer.cornerRadius = 4
        
        doneButton.setTitleColor (UIColor.whiteColor() ,forState: .Normal)
        doneButton.backgroundColor = UIColor.blackColor()
        doneButton.titleLabel!.font = UIFont.boldSystemFontOfSize(16)
        doneButton.setTitle("Done", forState: UIControlState.Normal)
        doneButton.addTarget(self, action: "doneButtonAction", forControlEvents:.TouchUpInside)
        self.friendsListView.addSubview(doneButton)

        
        
        // table view declaration
        friendslistTableView.frame         =   CGRectMake(10, friendslistY, self.friendsListView.frame.width-20, friendslistHeight);
        friendslistTableView.delegate      =   self
        friendslistTableView.dataSource    =   self
        friendslistTableView.backgroundColor = UIColor.clearColor()
        friendslistTableView.separatorStyle = .None
        friendslistTableView.tableFooterView = UIView()
        friendslistTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.friendsListView.addSubview(friendslistTableView)
        
          }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
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
        userImage.layer.cornerRadius = 30
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
        
        if let dataDict = dataArray[indexPath.row] as? NSDictionary
        {
            if let firstName = dataDict["firstname"] as? NSString
            {
                var fullname = firstName
                if let lastName = dataDict["lastname"] as? NSString
                {
                    fullname = "\(firstName) \(lastName)"
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

        cellView.addSubview(userImage)
        cellView.addSubview(username)
        cellView.addSubview(fullName)

        let gap : CGFloat = 15
        let buttonHeight: CGFloat = 30
        let buttonWidth: CGFloat = 30
        let inviteButton = UIButton()
        
        inviteButton .setTitleColor( UIColor(red:235.0/255.0,green:129.0/255.0,blue:40.0/255.0,alpha:1.0), forState: .Normal)
        inviteButton.frame = CGRectMake(cellView.frame.size.width - gap - buttonWidth, gap, buttonWidth, buttonHeight)
        inviteButton.layer.cornerRadius = 0.5 * inviteButton.bounds.size.width
        inviteButton.backgroundColor = UIColor.whiteColor()
        inviteButton.layer.borderColor = UIColor.blackColor().CGColor;
        inviteButton.layer.borderWidth = 2.0

        inviteButton.tag = indexPath.row
        if invitedFriendsArray .containsObject(inviteButton.tag)
        {
            inviteButton.backgroundColor = UIColor.redColor()
        }
        else
        {
            inviteButton.backgroundColor = UIColor.whiteColor()
        }
        inviteButton.addTarget(self, action: "inviteButton:", forControlEvents: UIControlEvents.TouchUpInside)
        inviteButton.titleLabel!.font = UIFont.boldSystemFontOfSize(17)
        cellView.addSubview(inviteButton)
        
        return cell
    }
    
    
    func closeViewButton(){
        KGModal.sharedInstance().hideAnimated(true)
        main {
            self.submitButton.enabled = true
            self.upgrading = false
            self.textFields.first?.enabled = true
            self.navigationItem.setHidesBackButton(false, animated: true)
            self.friendsListView.hidden=false
        }
    }
    func doneButtonAction()
    {
        var InvitedFriendsIdSTr : NSString = ""
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
        guard let title = self.textFields.first!.text else { return }
        guard let description = self.timelineDetailTxtView.text else { return }

        Storage.performRequest(.CreateGroupTimeline(title,InvitedFriendsIdSTr  as members,description as groupdescription)) { (json) -> Void in
            print("Group timelime API response :\(json)")
            self.InvitedFriends_id.removeAllObjects()
            self.invitedFriendsArray.removeAllObjects()
            KGModal.sharedInstance().hideAnimated(true)
            main {
                self.textFields.first!.text = ""
                self.timelineDetailTxtView.text = ""
                self.submitButton.enabled = true
                self.upgrading = false
                self.textFields.first?.enabled = true
                self.navigationItem.setHidesBackButton(false, animated: true)
                self.friendsListView.hidden=false
            }

            switch json["status_code"] as? Int ?? 400 {
            case 400, 402: // payment required
                let alert = UIAlertController(title: local(LocalizedString.TimelineAlertLimitRequiredTitle),
                    message: local(LocalizedString.TimelineAlertLimitRequiredMessage),
                    preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: local(LocalizedString.TimelineAlertLimitRequiredActionUpgrade),
                    style: UIAlertActionStyle.Default,
                    handler: { _ in
                        self.upgrading = true
                        self.performSegueWithIdentifier("BuyUpgrade", sender: self)
                }))
                alert.addAction(UIAlertAction(title: local(LocalizedString.TimelineAlertLimitRequiredActionCancel),
                    style: UIAlertActionStyle.Cancel,
                    handler: { _ in
                        self.navigationController?.popViewControllerAnimated(true)
                }))
                self.presentAlertController(alert)
                
            default:
                if let error = (json["error"] as? String) ?? (json["error"] as? [AnyObject])?.first as? String {
                    main {
                        let alert = UIAlertController(title: local(.TimelineAlertCreateErrorTitle), message: error, preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: local(.TimelineAlertCreateErrorActionDismiss), style: .Default, handler: nil))
                        self.presentAlertController(alert)
                        
                        self.submitButton.enabled = true
                        self.textFields.first?.enabled = true
                        self.navigationItem.setHidesBackButton(false, animated: true)
                        self.upgrading = false
                    }
                }
            }
            
            if  let _ = json["id"] as? String,
                let _ = json["name"] as? String,
                let _ = json["updated_at"] as? String,
                let _ = json["created_at"] as? String,
                let _ = json["likers_count"] as? Int,
                let _ = json["followers_count"] as? Int
            {
                let user = Storage.session.currentUser
                let tl = Timeline(dict: json, parent: user)
                tl.persistent = false
                user?.timelines.append(tl)
                Storage.save()
                
                main {
                    self.upgrading = false
                    self.navigationController?.popViewControllerAnimated(true)
                    self.navigationController?.topViewController?.performSegueWithIdentifier("TimelineCreated", sender: tl)
                }
            }
        }
    }
    func inviteButton(sender: UIButton) {
        let indexPath = NSIndexPath(forRow: sender.tag, inSection: 0)
        let inviteButton = sender as UIButton
        
        var user_id : NSString = ""
        if let dataDict = self.dataArray[indexPath.row] as? NSDictionary
        {
            user_id = (dataDict["id"] as? String!)!
        }

        if invitedFriendsArray .containsObject(indexPath.row)
        {
            inviteButton.backgroundColor = UIColor.whiteColor()
            invitedFriendsArray .removeObject(indexPath.row)
            InvitedFriends_id .removeObject(user_id)
        }
        else
        {
            inviteButton.backgroundColor = UIColor.redColor()
            invitedFriendsArray .addObject(indexPath.row)
            InvitedFriends_id .addObject(user_id)
        }
        print("inviteButton: \(indexPath.row)")
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        switch segue.identifier ?? "" {
        case "BuyUpgrade":
            let dest = segue.destinationViewController as! UpgradeTableViewController
            dest.popOnAppear = true
        default:
            break
        }
    }

    // MARK: - TextFieldDelegate

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        // ALGORITHM HARDCODED - SEE TRENDING SEARCH
        let data = string.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: true)
        let temp = NSString(data: data!, encoding: NSASCIIStringEncoding) as! String
        let replacement = String(temp.characters.filter { (c: Character) -> Bool in
            return "abcdefghijklmnopqrstuvwxyz0123456789".rangeOfString(String(c).lowercaseString) != nil
        }).lowercaseString
        if warningLabel.hidden == true && string.characters.count != replacement.characters.count {
            warningLabel.alpha = 0.0
            warningLabel.hidden = false
            UIView.animateWithDuration(0.3) {
                self.warningLabel.alpha = 1.0
            }
        }
        
        if let stringRange = textField.text?.rangeFromNSRange(range)
        {
            textField.text?.replaceRange(stringRange, with: replacement)
        }
        // prefix with "#"
        if let pred = textField.text?.hasPrefix("#") where !pred {
            textField.text?.insert("#", atIndex: textField.text!.startIndex)
        }
        return false
    }
    
    
    // MARK: - TextViewDelegate
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        let newLength = text.characters.count + textView.text.characters.count - range.length
        if(newLength == 0)
        {
            DescribeTimelineHeaderLabel.hidden = false
        }
        else
        {
            DescribeTimelineHeaderLabel.hidden = true
        }
        if(newLength > 150)
        {
            textView.resignFirstResponder()
            return false
        }

        if(text == "\n") {
            if (text == "\n" && newLength == 1)
            {
                DescribeTimelineHeaderLabel.hidden = false
            }
            textView.resignFirstResponder()
            return false
        }
        
        return true
    }
}

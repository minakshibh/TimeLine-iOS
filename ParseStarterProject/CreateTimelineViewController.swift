//
//  CreateTimelineViewController.swift
//  Timeline
//
//  Created by Valentin Knabel on 08.08.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import UIKit
import KGModal

class CreateTimelineViewController: SubmitViewController ,UITableViewDataSource , UITableViewDelegate {

    @IBOutlet var submitButton: UIButton!
    @IBOutlet var warningLabel: UILabel!
    @IBOutlet var groupTimelineButton: UIButton!
    let friendsListView = UIView()
    let friendslistTableView = UITableView()
    
    var upgrading: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.addFriendsListView()

        self.friendsListView.hidden=true
        //tabBarController?.delegate = self
        //navigationController?.delegate = self

        // Do any additional setup after loading the view.
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
        main {
            guard let title = self.textFields.first!.text else { return }
            if title == "" {
                let alert = UIAlertController(title: local(.TimelineAlertCreateMissingTitle), message: local(.TimelineAlertCreateMissingMessage), preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: local(.TimelineAlertCreateMissingDismiss), style: .Default, handler: nil))
                self.presentAlertController(alert)
                return
            }
            self.submitButton.enabled = false
            self.textFields.first?.enabled = false
            self.navigationItem.setHidesBackButton(true, animated: true)
            self.upgrading = false
            Storage.performRequest(.CreateTimeline(title)) { (json) -> Void in
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
                        self.submitButton.enabled = true
                        self.upgrading = false
                        self.navigationController?.popViewControllerAnimated(true)
                        self.navigationController?.topViewController?.performSegueWithIdentifier("TimelineCreated", sender: tl)
                    }
                }
            }
        }
    }
    
    @IBAction func groupTimelineButtonAction(sender: UIButton) {
        main {
            guard let title = self.textFields.first!.text else { return }
            if title == "" {
                let alert = UIAlertController(title: local(.TimelineAlertCreateMissingTitle), message: local(.TimelineAlertCreateMissingMessage), preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: local(.TimelineAlertCreateMissingDismiss), style: .Default, handler: nil))
                self.presentAlertController(alert)
                return
            }
            self.groupTimelineButton.enabled = false
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
        self.friendsListView.backgroundColor = UIColor(white: 0 , alpha: 0.5)
        self.friendsListView.alpha = 1
        
        let viewTitle = UILabel()
        viewTitle.frame = CGRectMake(0, 0, screenWidth, 64)
        viewTitle.font = UIFont.boldSystemFontOfSize(20)
        viewTitle.textAlignment = .Center
        viewTitle.backgroundColor = UIColor(white: 0, alpha: 0.5)
        viewTitle.textColor = UIColor.whiteColor()
        viewTitle.text = "INVITE FRIENDS"
        self.friendsListView.addSubview(viewTitle)
        
        // close button comment section
        let closeButton  = UIButton()
        closeButton.frame = CGRectMake(5, 20, 30, 30);
        closeButton.setImage(UIImage(named: "close") as UIImage?, forState: .Normal)
        closeButton.addTarget(self, action: "closeViewButton", forControlEvents:.TouchUpInside)
        self.friendsListView.addSubview(closeButton)
        
        
        let friendslistY: CGFloat = 80
        let friendslistHeight: CGFloat = self.friendsListView.frame.height-150
        
        // DONE button comment section
        let doneButton   = UIButton()
        doneButton.frame = CGRectMake(self.friendsListView.frame.size.width/4 , friendslistY + friendslistHeight+10, self.friendsListView.frame.size.width/2 , 50)
        doneButton.layer.cornerRadius = 4
        doneButton.setTitleColor (UIColor.whiteColor() ,forState: .Normal)
        doneButton.backgroundColor = UIColor(red:235.0/255.0,green:129.0/255.0,blue:40.0/255.0,alpha:1.0)
        
        doneButton.setTitle("DONE", forState: UIControlState.Normal)
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
    
    var dataArray = ["Apple", "Apricot", "Banana", "Blueberry", "Cantaloupe", "Cherry",
        "Clementine", "Coconut", "Cranberry", "Fig", "Grape", "Grapefruit",
        "Kiwi fruit", "Lemon", "Lime", "Lychee", "Mandarine", "Mango",
        "Melon", "Nectarine", "Olive", "Orange", "Papaya", "Peach",
        "Pear", "Pineapple", "Raspberry", "Strawberry"]
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
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
        cellView.frame = CGRectMake(0, 5, cell.contentView.frame.size.width, 75)
        cellView.backgroundColor = UIColor(white: 0, alpha: 0.25)
        cell.contentView.addSubview(cellView)
        
        let userImage = UIImageView()
        userImage.frame = CGRectMake(5, 10, 60, 60)
        userImage.backgroundColor = UIColor.lightGrayColor()
        userImage.layer.cornerRadius = 30
        cellView.addSubview(userImage)
        
        let username = UILabel()
        username.frame = CGRectMake(80, 20, 250, 40)
        username.font = UIFont.boldSystemFontOfSize(18)
        //username.backgroundColor = UIColor(white: 0, alpha: 0.25)
        username.textColor = UIColor.whiteColor()
        username.text = "@\(dataArray[indexPath.row])"
        cellView.addSubview(username)
        
        let gap : CGFloat = 10
        let buttonHeight: CGFloat = 60
        let buttonWidth: CGFloat = 80
        let inviteButton = UIButton()
        
        inviteButton .setTitleColor( UIColor(red:235.0/255.0,green:129.0/255.0,blue:40.0/255.0,alpha:1.0), forState: .Normal)
        inviteButton.frame = CGRectMake(cellView.frame.size.width - gap - buttonWidth, gap, buttonWidth, buttonHeight)
        inviteButton .setTitle("INVITE +", forState: .Normal)
        inviteButton.tag = 100 + indexPath.row
        inviteButton.addTarget(self, action: "inviteButton:", forControlEvents: UIControlEvents.TouchUpInside)
        inviteButton.titleLabel!.font = UIFont.boldSystemFontOfSize(17)
        cellView.addSubview(inviteButton)
        
        return cell
    }
    
    
    func closeViewButton(){
        KGModal.sharedInstance().hideAnimated(true)
        main {
            self.groupTimelineButton.enabled = true
            self.upgrading = false
            self.textFields.first?.enabled = true
            self.navigationItem.setHidesBackButton(false, animated: true)
            self.friendsListView.hidden=false
        }
    }
    func doneButtonAction()
    {
        KGModal.sharedInstance().hideAnimated(true)
        main {
            self.textFields.first!.text = ""
            self.groupTimelineButton.enabled = true
            self.upgrading = false
            self.textFields.first?.enabled = true
            self.navigationItem.setHidesBackButton(false, animated: true)
            self.friendsListView.hidden=false
        }

    }
    func inviteButton(sender: UIButton) {
        print("inviteButton: \(sender.tag)")
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
    
}

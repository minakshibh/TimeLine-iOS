//
//  TrendingTimelineTableViewController.swift
//  Timeline
//
//  Created by Valentin Knabel on 18.08.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import UIKit
import Social
import MessageUI
import AddressBookUI
import AddressBook
import KGModal




class TrendingTimelineTableViewController: FlatTimelineTableViewController , FBSDKAppInviteDialogDelegate ,ABPeoplePickerNavigationControllerDelegate, MFMessageComposeViewControllerDelegate{
    
    var searchTag:String = "@"
    var searching: Bool = false
    var picker:ABPeoplePickerNavigationController!
    var scrollView: UIScrollView!
    let timelineCommentView = UIView()
    var tableViewContact: UITableView!
    var recipients = [String]()
    var numberArray: NSMutableArray! = []
    var nameArray: NSMutableArray! = []
    var selectedPeople: NSMutableArray! = []
    var errorText:UILabel?
    var emptyDictionary: CFDictionaryRef?
    var searchResults: [AnyObject] = [] {
        didSet {
            searching = false
            main {
                self.searchDisplayController?.searchResultsTableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerNib(UINib(nibName: "UserSummaryTableViewCell", bundle: nil), forCellReuseIdentifier: "UserCell")

        tableViewContact = UITableView(frame: CGRectMake(50, 50, 300, 300), style: .Plain)
        tableViewContact.delegate = self
        tableViewContact.dataSource = self
        tableViewContact.registerClass(UITableViewCell.self, forCellReuseIdentifier: "commentCellss")
        
        
        // Do any additional setup after loading the view.
        searchDisplayController?.searchBar.delegate = self
        searchDisplayController?.delegate = self
        
        searchDisplayController?.searchBar.scopeButtonTitles = [NSLocalizedString("Users", comment: "Country"),NSLocalizedString("Timeline", comment: "Capital")]
            
        
        
        
        
        
        delay(0.001) {
            if !Storage.session.walkedThroughTrends {
                Storage.session.walkedThroughTrends = true
                self.performSegueWithIdentifier("WalkthroughTrending", sender: self)
            }
        }
        
        
        let screenRect = UIScreen.mainScreen().bounds
        let screenWidth = screenRect.size.width;
        let screenHeight = screenRect.size.height;
        self.timelineCommentView.frame = CGRectMake(0, 0, screenWidth-60, screenHeight-110);
        self.timelineCommentView.backgroundColor = UIColor(white: 1 , alpha: 1)
//        self.timelineCommentView.alpha = 1
        self.tableViewContact.frame = CGRectMake(0, 0, screenWidth-60, screenHeight-160);
        self.timelineCommentView.layer.cornerRadius = 8.0
        self.tableViewContact.layer.cornerRadius = 8.0
        self.timelineCommentView.addSubview(self.tableViewContact)
        
        let Invitebutton: UIButton = UIButton(frame: CGRectMake(0, tableViewContact.frame.size.height, tableViewContact.frame.size.width, 50))
        Invitebutton.setTitle("Send Invites", forState: .Normal)
        Invitebutton.addTarget(self, action: "Invitebuttontapped:", forControlEvents: UIControlEvents.TouchUpInside)
        Invitebutton.backgroundColor = UIColor.blackColor()
        Invitebutton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        Invitebutton.titleLabel?.font = UIFont.systemFontOfSize(20)
        self.timelineCommentView.addSubview(Invitebutton)
        
        
        errorText = UILabel.init(frame: CGRectMake(0, Invitebutton.frame.origin.y-30 , Invitebutton.frame.size.width, 30 ))
        errorText!.font = UIFont.systemFontOfSize(15)
        errorText!.textColor = UIColor.redColor ()
        errorText!.textAlignment = NSTextAlignment.Center;
        
        
        
       
//        self.fetchContacts()
        var error: Unmanaged<CFError>?
        let addressBook: ABAddressBook? = ABAddressBookCreateWithOptions(nil, &error)?.takeRetainedValue()
        if addressBook == nil {
            print(error?.takeRetainedValue())
            return
        }
        ABAddressBookRequestAccessWithCompletion(addressBook) {
            granted, error in
            if !granted {
                // warn the user that because they just denied permission, this functionality won't work
                // also let them know that they have to fix this in settings
                return
            }
        }
    }
    
    
    func Invitebuttontapped(sender: UIButton!)
    {
        if selectedPeople.count == 0
        {
            errorText!.text = "Atleast Select one contact to send invite."
            self.timelineCommentView.addSubview(errorText!)
            return
        }
        
        
        if (MFMessageComposeViewController.canSendText()) {
            for (var i=0; i < selectedPeople.count; i++) {
               
                
                print("\(selectedPeople[i])")
                
                recipients.append(selectedPeople[i] as! String)
            }
            
            
            let controller = MFMessageComposeViewController()
            controller.body = "Message Body"
            controller.recipients = recipients
            controller.messageComposeDelegate = self
            self.presentViewController(controller, animated: true, completion: nil)
        }else{
            errorText!.font = UIFont.systemFontOfSize(13)
            errorText!.text = "Invite through contacts not supported on this device";
            self.timelineCommentView.addSubview(errorText!)
            return
        }
    }
    
    
    override func refreshTableView() {
        var first = true
        Timeline.getTimelines(.TimelineTrending) { tls in
            if !first {
                main { self.refreshControl?.endRefreshing() }
            }
            self.timelines = tls
            first = false
        }
    }
    @IBAction func btnInvite(sender: AnyObject) {
        
        let confirm = UIAlertController(title: "Send Invites", message: "", preferredStyle:UIAlertControllerStyle.ActionSheet)
        confirm.addAction(title: "Cancel",
            style: .Cancel,
            handler: nil)
        confirm.addAction(title: "Facebook Friends",
            style: .Default) { _ in
                let inviteDialog:FBSDKAppInviteDialog = FBSDKAppInviteDialog()
                if(inviteDialog.canShow()){
                    let inviteContent = FBSDKAppInviteContent.init()
                    inviteContent.appLinkURL = NSURL(string: "https://fb.me/170661636645442")!
                    inviteContent.appInvitePreviewImageURL = NSURL(string: "https://www.mydomain.com/my_invite_image.jpg")!
                    inviteDialog.content = inviteContent
                    inviteDialog.delegate = self
                    inviteDialog.show()
                }
               
        }
        confirm.addAction(title: "Contacts",
            style: .Default) { _ in
                
                self.fetchContacts()
           
                self.tableViewContact.reloadData()
                KGModal.sharedInstance().showWithContentView(self.timelineCommentView)
                KGModal.sharedInstance().closeButtonType = .None
                //KGModal.sharedInstance().showCloseButton = true
                //                    self.view.addSubview(self.tableViewContact)
                
                self.tableViewContact.reloadData()
            
    } //---end of confirm action
        self.tableViewContact.reloadData()
        self.presentAlertController(confirm)
  }
    
    
    func fetchContacts(){
        
        // user previously denied, to tell them to fix that in settings
        let status = ABAddressBookGetAuthorizationStatus()
        if status == .Denied || status == .Restricted {
            return
        }
        
        var error: Unmanaged<CFError>?
        let addressBook: ABAddressBook? = ABAddressBookCreateWithOptions(nil, &error)?.takeRetainedValue()
        if addressBook == nil {
            print(error?.takeRetainedValue())
            return
        }
        
        // request permission to use it
        ABAddressBookRequestAccessWithCompletion(addressBook) {
            granted, error in
            if !granted {
                // warn the user that because they just denied permission, this functionality won't work
                // also let them know that they have to fix this in settings
                return
            }
            
            
            // addressBook = !ABAddressBookCreateWithOptions(emptyDictionary,nil)
            let contactList: NSArray = ABAddressBookCopyArrayOfAllPeople(addressBook).takeRetainedValue()
            print("records in the array \(contactList.count)") // returns 0
            
            self.nameArray = []
            self.numberArray = []
            self.selectedPeople = []
            
            for record:ABRecordRef in contactList {
                let contactPerson: ABRecordRef = record
//                print("\(ABRecordCopyCompositeName(contactPerson).takeRetainedValue())")
//                let contactName: String = ABRecordCopyCompositeName(contactPerson).takeRetainedValue() as String
                
                
                if var contactName = ABRecordCopyCompositeName(contactPerson)?.takeRetainedValue(){
                    contactName = ABRecordCopyCompositeName(contactPerson).takeRetainedValue() as String
                    self.nameArray.addObject(contactName )
                }
                
                
                
                
                
//                let numbers:ABMultiValue = ABRecordCopyValue(
//                    contactPerson, kABPersonPhoneProperty).takeRetainedValue()
                if var numbers = ABRecordCopyValue(
                    contactPerson, kABPersonPhoneProperty)?.takeRetainedValue(){
                        numbers = ABRecordCopyValue(
                            contactPerson, kABPersonPhoneProperty).takeRetainedValue()

                        for ix in 0 ..< ABMultiValueGetCount(numbers) {
//                            let label = ABMultiValueCopyLabelAtIndex(numbers,ix).takeRetainedValue() as String
                            let value = ABMultiValueCopyValueAtIndex(numbers,ix).takeRetainedValue() as! String
                            
                            if var value = ABMultiValueCopyValueAtIndex(numbers,ix)?.takeRetainedValue(){
                                value = ABMultiValueCopyValueAtIndex(numbers,ix).takeRetainedValue() as! String
                                print("Phonenumber  is \(value)")
                                self.numberArray.addObject(value)
                            }
                            break
                        }
                        
                    
                }
                
                
                
                
                
            }
            
            
        }
    }
    
    override func removeTimelineFromCache(uuid: UUID) {
        Storage.session.trendingCache = Storage.session.trendingCache.filter { $0 != uuid }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == tableViewContact{
            return nameArray.count
        }else{
            
            if tableView == self.tableView {
                return super.tableView(tableView, numberOfRowsInSection: section)
            } else {
                return searching && searchResults.count == 0 ? 1 : searchResults.count
            }
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if tableView == tableViewContact{
            return 80
        }else{
        
        
            if tableView == self.tableView {
                return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
            } else {
                if searching && searchResults.count == 0 {
                    return 147
                } else if let _ = searchResults[indexPath.row] as? User {
                    return 100
                } else {
                    return 382
                }
            
            }
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // MARK: Causing TableView Crash
        if tableView == tableViewContact{
            
            errorText!.removeFromSuperview()
            
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
             let cell: UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
            let person = nameArray[indexPath.row]
            
            if cell.accessoryType == .None {
                cell.accessoryType = .Checkmark
                selectedPeople.addObject(person)
            }else if cell.accessoryType == .Checkmark {
                cell.accessoryType = .None
                selectedPeople.removeObject(person)
            }
            
            print("\(selectedPeople)")
            
        }else{
            if tableView == self.tableView {
                //super.tableView(tableView, didSelectRowAtIndexPath: indexPath)
            } else if let user = searchResults[indexPath.row] as? User {
                    performSegueWithIdentifier("ShowUser", sender: user)
            }
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView == tableViewContact{
            let cell = tableView.dequeueReusableCellWithIdentifier("commentCellss", forIndexPath: indexPath)
            
            
            for object in cell.contentView.subviews
            {
                object.removeFromSuperview();
            }
            
//            let cellView = UIView()
//            cell.contentView.frame = CGRectMake(0, 5, cell.contentView.frame.size.width, 75)
//            cell.contentView.backgroundColor = UIColor(white: 0, alpha: 0.25)
//            cell.addSubview(cellView)
            
            let text1:UILabel = UILabel.init(frame: CGRectMake(20, 10, 350, 30))
            text1.font = UIFont.systemFontOfSize(23)
            text1.text = nameArray[indexPath.row] as? String
            cell.contentView.addSubview(text1)
            
            let text2:UILabel = UILabel.init(frame: CGRectMake(20, text1.frame.origin.y+text1.frame.size.height , 350, 30 ))
            text2.font = UIFont.systemFontOfSize(15)
            text2.text = numberArray[indexPath.row] as? String
            text2.textColor = UIColor.lightGrayColor()
            cell.contentView.addSubview(text2)
            
            
            let text3:UILabel = UILabel.init(frame: CGRectMake(0, text2.frame.origin.y+text2.frame.size.height+6 , 350, 1 ))
            text3.font = UIFont.systemFontOfSize(15)
            text3.backgroundColor = UIColor.darkGrayColor()
            cell.contentView.addSubview(text3)
            
            
//            tableView.separatorStyle = .None

//            cell.textLabel!.font = UIFont.systemFontOfSize(18)
            return cell
       }else{
         if tableView == self.tableView {
                return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
            } else {
                if searching && searchResults.count == 0 {
                    let cell = self.tableView.dequeueReusableCellWithIdentifier("ActivityCell", forIndexPath: indexPath)
                    return cell
                } else if let user = searchResults[indexPath.row] as? User {
                    let cell = self.tableView.dequeueReusableCellWithIdentifier("UserCell", forIndexPath: indexPath) as! UserSummaryTableViewCell
                
                    // Configure the cell...
                
                    cell.user = user
                    cell.nameLabel.hidden = false
                
                    return cell
                } else {
                    let timeline = searchResults[indexPath.row] as! Timeline
                    let cell = self.tableView.dequeueReusableCellWithIdentifier("TimelineCell",     forIndexPath: indexPath) as! ModernTimelineTableViewCell
                
                    // Configure the cell...
                    cell.timeline = timeline
                
                    return cell
                }
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowTimeline" {
            let dest = segue.destinationViewController as! TimelineSummaryTableViewController
            let cell: ModernTimelineTableViewCell
            if let selectedIndex = tableView.indexPathForSelectedRow {
                cell = tableView.cellForRowAtIndexPath(selectedIndex) as! ModernTimelineTableViewCell
            } else {
                let selectedIndex = searchDisplayController!.searchResultsTableView.indexPathForSelectedRow!
                cell = searchDisplayController!.searchResultsTableView.cellForRowAtIndexPath(selectedIndex) as! ModernTimelineTableViewCell
            }
            dest.timeline = cell.timeline
        } else if segue.identifier == "ShowUser" {
            let dest = segue.destinationViewController as? UserSummaryTableViewController
            let user: User?
            if let pushable = sender as? User {
                user = pushable
            } else {
                let selectedIndex = searchDisplayController!.searchResultsTableView.indexPathForSelectedRow!
                let cell = searchDisplayController!.searchResultsTableView.cellForRowAtIndexPath(selectedIndex) as! UserSummaryTableViewCell
                user = cell.user
            }
            dest?.user = user
        } else {
            super.prepareForSegue(segue, sender: sender)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension TrendingTimelineTableViewController: UISearchDisplayDelegate {
    
    func searchDisplayControllerDidEndSearch(controller: UISearchDisplayController) {
        if let searchBar = searchDisplayController?.searchBar {
            tableView.insertSubview(searchBar, aboveSubview: tableView)
        }
    }
    
}

extension TrendingTimelineTableViewController: UISearchBarDelegate {
    
    func searchBar(searchBar: UISearchBar, shouldChangeTextInRange range: NSRange, replacementText string: String) -> Bool {
        // ALGORITHM HARDCODED - SEE CREATE TIMELINE
        let data = string.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: true)
        let temp = NSString(data: data!, encoding: NSASCIIStringEncoding) as! String
        var replacement = String(temp.characters.filter { (c: Character) -> Bool in
            return "abcdefghijklmnopqrstuvwxyz0123456789".rangeOfString(String(c).lowercaseString) != nil
            })
//        if range.location == 0 && string.hasPrefix("#") {
//            replacement = "#" + replacement
//        }
//        if range.location == 0 && string.hasPrefix("@") {
//            replacement = "@" + replacement
//        }
        if range.location == 0 && searchTag == "#" {
//            replacement = "#" + replacement
        }
        if range.location == 0 && searchTag == "@" {
//            replacement = "@" + replacement
        }
        if let stringRange = searchBar.text?.rangeFromNSRange(range)
        {
            searchBar.text?.replaceRange(stringRange, with: replacement)
        }
        
        self.searchBar(searchBar, textDidChange: searchBar.text ?? "")
        return false
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        var text: String = String((searchBar.text ?? "").characters.filter { (c: Character) -> Bool in
            return "abcdefghijklmnopqrstuvwxyz0123456789".rangeOfString(String(c).lowercaseString) != nil
            })
//        if text.characters.count < 2 { return }
//        if searchText.hasPrefix("#") {
//            text = "#" + text
//        } else if searchText.hasPrefix("@") {
//            text = "@" + text
//        }
        if searchTag == "#" {
            text = "#" + text
        } else if searchTag == "@" {
            text = "@" + text
        }
        if searchResults.count == 0 {
            searching = true
        }
        Storage.performRequest(ApiRequest.Search(text), completion: { (json) -> Void in
            var results = [AnyObject]()
            for r in json["result"] as? [[String: AnyObject]] ?? [] {
                if let _ = r["email"] as? String {
                    let user = User(dict: r, parent: nil)
                    if let uuid = user.state.uuid,
                        let existing = Storage.findUser(uuid)
                    {
                        results.append(existing)
                    } else {
                        results.append(user)
                    }
                }
                if let parentID = r["user_id"] as? UUID {
                    let timeline = Timeline(dict: r, parent: nil)
                    if let uuid = timeline.state.uuid,
                        let existing = Storage.findTimeline(uuid)
                    {
                        results.append(existing)
                    } else {
                        if let parentID = r["user_id"] as? UUID,
                            let parent = Storage.findUser(parentID)
                        {
                            parent.timelines.append(timeline)
                            results.append(timeline)
                        } else {
                            let _ = User(name: nil, email: nil, externalID: nil, timelinesPublic: nil, approveFollowers: nil, pendingFollowersCount: nil, followersCount: nil, followingCount: nil, likersCount: nil, liked: false, blocked: false, followed: .NotFollowing, timelines: [timeline], state: .Dummy(parentID), parent: nil)
                            results.append(timeline)
                            
                            Storage.performRequest(ApiRequest.UserProfile(parentID), completion: { (json) -> Void in
                                if let _ = json["error"] { return }
                                
                                let user = User(dict: json, parent: nil)
                                user.timelines.append(timeline)
                                Storage.session.users.append(user)
                            })
                        }
                    }
                }
            }
            main {
                self.searchResults = results
            }
        })
    }
   
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        if selectedScope==0 {
            print("----button pressed 11111-----")
            searchTag = "@"
            searchBar.text = ""
        }else{
            print("----button pressed 222222-----")
            searchTag = "#"
            searchBar.text = ""
        }
    }
    
    func appInviteDialog(appInviteDialog: FBSDKAppInviteDialog!, didCompleteWithResults results: [NSObject : AnyObject]!) {
        print("Complete invite without error")
    }
    
    func appInviteDialog(appInviteDialog: FBSDKAppInviteDialog!, didFailWithError error: NSError!) {
        print("Error in invite \(error)")
    }
    
    func peoplePickerNavigationControllerDidCancel(peoplePicker: ABPeoplePickerNavigationController!) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func peoplePickerNavigationController(peoplePicker: ABPeoplePickerNavigationController!, didSelectPerson person: ABRecord!) {
        let nameCFString : CFString = ABRecordCopyCompositeName(person).takeRetainedValue()
        let name : NSString = nameCFString as NSString
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController!, didFinishWithResult result: MessageComposeResult) {
        switch (result) {
        case MessageComposeResultSent: NSLog("SENT");
        self.dismissViewControllerAnimated(true, completion: nil)
        break;
            
        case MessageComposeResultFailed: NSLog("FAILED");
        self.dismissViewControllerAnimated(true, completion: nil)
        break;
            
        case MessageComposeResultCancelled: NSLog("CANCELLED");
        self.dismissViewControllerAnimated(true, completion: nil)
        break;
        
        default:
         self.dismissViewControllerAnimated(true, completion: nil)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

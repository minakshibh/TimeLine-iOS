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
import Contacts




class TrendingTimelineTableViewController: FlatTimelineTableViewController , FBSDKAppInviteDialogDelegate ,ABPeoplePickerNavigationControllerDelegate, MFMessageComposeViewControllerDelegate,UISearchResultsUpdating{
    
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
    var contactDict: NSMutableDictionary! = [:]
    var errorText:UILabel?
    var emptyDictionary: CFDictionaryRef?
    var view1:UIView!
    var view2:UIView!
    var invitedFriendsArray: NSMutableArray! = []
    var status:Bool = false
    var filteredTableData = [String]()
    var resultSearchController = UISearchController()
    var searchStatus:Bool = false
    
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

        
        
//        self.hidesBottomBarWhenPushed = true
        tableView.registerNib(UINib(nibName: "UserSummaryTableViewCell", bundle: nil), forCellReuseIdentifier: "UserCell")
        
        
        
        // Do any additional setup after loading the view.
        searchDisplayController?.searchBar.delegate = self
        searchDisplayController?.delegate = self
        
        searchDisplayController?.searchBar.scopeButtonTitles = [NSLocalizedString("Users", comment: "Country"),NSLocalizedString("Feedeo", comment: "Capital")]
            
        UIApplication.sharedApplication().statusBarStyle = .LightContent


        
        let right: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "Back to Record"), style: .Plain, target: self, action: "goToRecordScreen")
//        (title: "Save", style: .Plain, target: self, action: "SaveImage")
        let Add: UIBarButtonItem = UIBarButtonItem(title: "Invite", style: .Plain, target: self, action: "btnInvite")
//        (barButtonSystemItem: .Add, target: self, action: "AddComment:")
        let left: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "Back to previous screen"), style: .Plain, target: self, action: "goToRecordScreen")
    
        navigationItem.rightBarButtonItems = [right,Add]
        navigationItem.leftBarButtonItem = left
        
//        delay(0.001) {
//            if !Storage.session.walkedThroughTrends {
//                Storage.session.walkedThroughTrends = true
//                self.performSegueWithIdentifier("WalkthroughTrending", sender: self)
//            }
//        }
        
        
        let screenRect = UIScreen.mainScreen().bounds
        let screenWidth = screenRect.size.width;
        let screenHeight = screenRect.size.height;
        self.timelineCommentView.frame = CGRectMake(0, 0, screenWidth, screenHeight);
        self.timelineCommentView.backgroundColor = UIColor(white: 1 , alpha: 0)
//        self.timelineCommentView.alpha = 1
        
        let headerView = UIView(frame: CGRectMake(0, 0, timelineCommentView.frame.size.width, (navigationController?.navigationBar.frame.size.height)!+20))
        headerView.backgroundColor = UIColor.redColor()
        
        let headerTitle = UILabel(frame: CGRectMake(0, headerView.frame.size.height-50,headerView.frame.size.width , 50))
        headerTitle.text = "Select Contacts"
        headerTitle.font = UIFont.boldSystemFontOfSize(20.0)
        headerTitle.textAlignment = .Center
        headerTitle.textColor = UIColor.whiteColor()
        headerView.addSubview(headerTitle)
        
        let Invitebutton: UIButton = UIButton(frame: CGRectMake(headerView.frame.size.width-70-10, headerView.frame.size.height/4+5, 70, 35))
        Invitebutton.setTitle("Invite", forState: .Normal)
        Invitebutton.addTarget(self, action: "Invitebuttontapped", forControlEvents: UIControlEvents.TouchUpInside)
        Invitebutton.backgroundColor = UIColor.blackColor()
        Invitebutton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        Invitebutton.titleLabel?.font = UIFont.systemFontOfSize(20)
        Invitebutton.layer.cornerRadius = 8.0
        headerView.addSubview(Invitebutton)
        
        let btnBack: UIButton = UIButton(frame: CGRectMake(15, headerView.frame.size.height/4+5, 30, 35))
        btnBack.addTarget(self, action: "btnBackContact", forControlEvents: UIControlEvents.TouchUpInside)
        btnBack.setImage(UIImage(named: "Back to previous screen"), forState: .Normal)
        headerView.addSubview(btnBack)
        
        self.timelineCommentView.addSubview(headerView)
        
        
        
        tableViewContact = UITableView(frame: CGRectMake(50, 50, 300, 300), style: .Plain)
        tableViewContact.delegate = self
        tableViewContact.dataSource = self
        tableViewContact.registerClass(UITableViewCell.self, forCellReuseIdentifier: "commentCellss")
        self.tableViewContact.frame = CGRectMake(0, headerView.frame.size.height, screenWidth, screenHeight-headerView.frame.size.height);
        self.timelineCommentView.layer.cornerRadius = 8.0
//        self.tableViewContact.layer.cornerRadius = 8.0
        self.timelineCommentView.addSubview(self.tableViewContact)
        
        
        
        
        errorText = UILabel.init(frame: CGRectMake(0,tableViewContact.frame.size.height-30, tableViewContact.frame.size.width, 30 ))
        errorText!.font = UIFont.systemFontOfSize(15)
        errorText!.textColor = UIColor.redColor ()
        errorText!.textAlignment = NSTextAlignment.Center;
        
        
        self.tableViewContact.separatorStyle = .None
       
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
        
        self.resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            
            tableViewContact.tableHeaderView = controller.searchBar
            
            return controller
        })()
        
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        
        if(IPHONE6==1 || IPHONE5==1){
            if(self.navigationController!.navigationBar.frame.origin.y == 20.0){
                
            }else{
                self.navigationController!.navigationBar.frame = CGRectMake(0, 0, self.navigationController!.navigationBar.frame.size.width, self.navigationController!.navigationBar.frame.size.height+20)
                status = true
            }
        }
        
        if(IPHONE6P==1){
            if(self.navigationController!.navigationBar.frame.origin.y == 20.0){
                
            }else{
                self.navigationController!.navigationBar.frame = CGRectMake(0, 0, self.navigationController!.navigationBar.frame.size.width, self.navigationController!.navigationBar.frame.size.height+20)
                status = true
            }
        }
        

//        0.0, 687.0, 414.0, 49.0
        
        
        
//        self.tabBarController?.tabBar.frame = CGRectMake(0, self.view.bounds.height, self.view.bounds.width, self.view.bounds.height);
    }
    func btnBackContact(){
        self.errorText?.removeFromSuperview()
        KGModal.sharedInstance().hideAnimated(true)
    }
    func goToRecordScreen(){
        let viewController = UIApplication.sharedApplication().windows[0].rootViewController?.childViewControllers[1] as? drawer
        viewController?.profileButtonClick()
//        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        appDelegate.window = UIWindow(frame: UIScreen.mainScreen().bounds)
//        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc : drawer = storyboard.instantiateViewControllerWithIdentifier("drawerID") as! drawer
//        var nav = appDelegate.window?.rootViewController as? UINavigationController
//        NSUserDefaults.standardUserDefaults().setObject("Capture", forKey: "transitionTo")
//        nav = UINavigationController.init(rootViewController:vc )
//        
//        hidesBottomBarWhenPushed = true
//        
//        let transition: CATransition = CATransition()
//        let timeFunc : CAMediaTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
//        transition.duration = 0.25
//        transition.timingFunction = timeFunc
//        transition.type = kCATransitionPush
//        transition.subtype = kCATransitionFromRight    //kCATransitionFromLeft
//        nav!.view.layer.addAnimation(transition, forKey: kCATransition)
//        appDelegate.window?.rootViewController = nav
//        appDelegate.window?.makeKeyAndVisible()
    }
    
    func Invitebuttontapped()
    {
        if selectedPeople.count == 0
        {
            errorText!.text = "Atleast Select one contact to send invite."
            self.timelineCommentView.addSubview(errorText!)
            return
        }
        
        
        if (MFMessageComposeViewController.canSendText()) {
            for (var i=0; i < selectedPeople.count; i++) {
                
                let phoneno = selectedPeople[i] as! String
                let phonenoArr = phoneno.componentsSeparatedByString(",")
                if(phonenoArr.count==1){
                    recipients.append(selectedPeople[i] as! String)
                }else{
                    for(var g=0;g<phonenoArr.count;g++){
                    recipients.append(phonenoArr[g])
                    }
               }
            }
            
            selectedPeople = []
            self.timelineCommentView.removeFromSuperview()
            KGModal.sharedInstance().hideAnimated(true)
            
            let controller = MFMessageComposeViewController()
            controller.body = "This is for testing to send invites to multiple users..."
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
    func btnInvite() {

        let confirm = UIAlertController(title: "Send Invites", message: "", preferredStyle:UIAlertControllerStyle.ActionSheet)
        confirm.addAction(title: "Cancel",
            style: .Cancel,
            handler: nil)
        confirm.addAction(title: "Facebook",
            style: .Default) { _ in
                let inviteDialog:FBSDKAppInviteDialog = FBSDKAppInviteDialog()
                if(inviteDialog.canShow()){
                    let inviteContent = FBSDKAppInviteContent.init()
                    inviteContent.appLinkURL = NSURL(string: "https://fb.me/175079332870339")!
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
                self.tableViewContact.reloadData()
                self.tableView.reloadData()
                
                KGModal.sharedInstance().closeButtonType = .None
                KGModal.sharedInstance().showWithContentView(self.timelineCommentView)
//                KGModal.sharedInstance().closeButtonType = .Right
//                KGModal.sharedInstance().closeButtonType = none
                //KGModal.sharedInstance().showCloseButton = true
                //                    self.view.addSubview(self.tableViewContact)
                
                self.tableViewContact.reloadData()
                
                let timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "update", userInfo: nil, repeats: false)
                
//                 self.performSegueWithIdentifier("toContactView", sender: nil)
                
            
    } //---end of confirm action
        self.tableViewContact.reloadData()
        self.presentAlertController(confirm)
  }
    
    func update() {
       self.tableViewContact.reloadData()
        
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
//            print("records in the array \(contactList.count)") // returns 0
            self.nameArray = []
            self.numberArray = []
            self.selectedPeople = []
            for record:ABRecordRef in contactList {
                let contactPerson: ABRecordRef = record
                let randomArray: NSMutableArray! = []
                let labelArray: NSMutableArray! = []
                if var contactName = ABRecordCopyCompositeName(contactPerson)?.takeRetainedValue(){
                    contactName = ABRecordCopyCompositeName(contactPerson).takeRetainedValue() as String
//                    print("\(contactName)")
                    //                    self.nameArray.addObject(contactName )
                    if var numbers = ABRecordCopyValue(
                        contactPerson, kABPersonPhoneProperty)?.takeRetainedValue(){
                        numbers = ABRecordCopyValue(
                            contactPerson, kABPersonPhoneProperty).takeRetainedValue()
 //                       print("\(ABMultiValueGetCount(numbers))")
                        if (ABMultiValueGetCount(numbers) == 0)
                        {
                            self.nameArray.addObject("\(contactName)")
                            self.numberArray.addObject("--")
 //                           print("\(self.nameArray)---\(self.numberArray)")
                            //nhjjnj
                            //kkjmk
                        }
                        var swiftString = ""
                        for ix in 0 ..< ABMultiValueGetCount(numbers) {
                            var phones : ABMultiValueRef = ABRecordCopyValue(record,kABPersonPhoneProperty).takeUnretainedValue() as ABMultiValueRef
                            
                            if var value = ABMultiValueCopyValueAtIndex(numbers,ix)?.takeRetainedValue(){
                                value = ABMultiValueCopyValueAtIndex(numbers,ix).takeRetainedValue() as! String
//                                print("Phonenumber  is \(value)")
                                randomArray.addObject(value)
                                let locLabel : CFStringRef = (ABMultiValueCopyLabelAtIndex(phones, ix) != nil) ? ABMultiValueCopyLabelAtIndex(phones, ix).takeUnretainedValue() as CFStringRef : ""
                                let cfStr:CFTypeRef = locLabel
                                let nsTypeString = cfStr as! NSString
                                var swiftString:String = nsTypeString as String
//                                print("\(swiftString)")
                                if #available(iOS 9.0, *) {
                                    swiftString = CNLabeledValue.localizedStringForLabel(swiftString)
                                } else {
                                    if ("\(swiftString)").rangeOfString("<") != nil{
                                        var arrStr1 = swiftString.componentsSeparatedByString("<")
                                        swiftString =  arrStr1[1].componentsSeparatedByString(">")[0]
                                                                    }
                                }
                                labelArray.addObject(swiftString)
                            }
                        }
                    }
                    //                let numbers:ABMultiValue = ABRecordCopyValue(
                    //                    contactPerson, kABPersonPhoneProperty).takeRetainedValue()
                    let count:Int = randomArray.count
                    if(count == 1){
                        self.nameArray.addObject("\(contactName)")
                        self.numberArray.addObject(randomArray[0])
//                        print("\(self.nameArray)---\(self.numberArray)")
                    }else{
//            do{
                        for(var a=0;a<randomArray.count;a += 1){
                            
//                            if ("\(labelArray[a])").rangeOfString("<") != nil{
//                                var arrStr1 = labelArray[a].componentsSeparatedByString("<")
//                                let lblStr =  arrStr1[1].componentsSeparatedByString(">")[0]
//                                self.nameArray.addObject("\(contactName)-\(lblStr)")
//                                self.numberArray.addObject(randomArray[a])
//                            }else{
//                                print("crash")
                                self.nameArray.addObject("\(contactName)-\(labelArray[a])")
                                self.numberArray.addObject(randomArray[a])
//                            }
                        }
//            }catch {
//                            for(var a=0;a<randomArray.count;a++){
//                                var alert=UIAlertController(title: "CRASH", message: "App tried to cresh here-2", preferredStyle: UIAlertControllerStyle.Alert);
//                                //show it
//                                self.showViewController(alert, sender: self);
//                                    print("crash")
//                                    self.nameArray.addObject("\(contactName)-\(labelArray[a])")
//                                    self.numberArray.addObject(randomArray[a])
//                                
//                            }
//                }
                        //                           self.numberArray.addObject(arrStr)
                    }
                }
            }
//            print("\(self.nameArray)----\(self.nameArray.count)")
//            print("\(self.numberArray)---\(self.numberArray.count)")
            for(var k=0;k<self.nameArray.count;k++){
                self.contactDict.setValue(self.numberArray[k], forKey: self.nameArray[k] as! String)
            }
//            print("\(self.contactDict.allKeys)")
           
            let sortedArray = self.nameArray.sortedArrayUsingComparator {
                (obj1, obj2) -> NSComparisonResult in
                let p1 = obj1 as! String
                let p2 = obj2 as! String
                let result = p1.compare(p2)
                return result
            }
            self.nameArray.removeAllObjects()
            for(var v=0;v<sortedArray.count;v++)
            {
                self.nameArray.addObject(sortedArray[v])
            }
            print("\(self.numberArray)")
            print("\(self.nameArray)")
            self.selectedPeople = []
            self.tableViewContact.reloadData()
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
        
        if (self.resultSearchController.active) {
            return self.filteredTableData.count
        }
        
        
        if tableView == tableViewContact{
            print("\(nameArray.count)")
            print("\(numberArray.count)")
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
//                    return 100
                    return 60
                } else {
                    return 462
                }
            
            }
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // MARK: Causing TableView Crash
        if tableView == tableViewContact{
             errorText?.removeFromSuperview()
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }else{
            main{
            if tableView == self.tableView {
                //super.tableView(tableView, didSelectRowAtIndexPath: indexPath)
            } else if self.searchResults.count > 0{
                
                if let user = self.searchResults[indexPath.row] as? User {
                    if self.searchStatus {
                        self.performSegueWithIdentifier("ShowUser", sender: user)
                    }
                }
            }
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
            
  
            let text1:UILabel = UILabel.init(frame: CGRectMake(20, 10, 350, 30))
            text1.font = UIFont.systemFontOfSize(23)
            if (self.resultSearchController.active) {
                 text1.text = filteredTableData[indexPath.row]
            }else{
                 text1.text = nameArray[indexPath.row] as? String
            }
            cell.contentView.addSubview(text1)
            
            var text2:UILabel = UILabel.init(frame: CGRectMake(20, text1.frame.origin.y+text1.frame.size.height , 350, 30 ))
            text2.font = UIFont.systemFontOfSize(15)
//            let str = numberArray[indexPath.row] as? String
            var str = ""
            if (self.resultSearchController.active) {
                str = self.contactDict.valueForKey(filteredTableData[indexPath.row]) as! String
            }else{
               
                str = self.contactDict.valueForKey(nameArray[indexPath.row] as! String) as! String
            }
            let arr = str.componentsSeparatedByString(",")
            if(arr.count>3)
            {
                 text2 = UILabel.init(frame: CGRectMake(text2.frame.origin.x, text2.frame.origin.y-6, text2.frame.size.width, text2.frame.size.height+11))
                text2.numberOfLines = 2;
            }
            
            if (self.resultSearchController.active) {
                text2.text = self.contactDict.valueForKey(filteredTableData[indexPath.row]) as! String
            }else{
                text2.text = self.contactDict.valueForKey(nameArray[indexPath.row] as! String) as! String
            }
            
            text2.textColor = UIColor.lightGrayColor()
            cell.contentView.addSubview(text2)
            
            
            let text3:UILabel = UILabel.init(frame: CGRectMake(0, text2.frame.origin.y+text2.frame.size.height+6 , cell.frame.size.width, 1 ))
            text3.font = UIFont.systemFontOfSize(15)
            text3.backgroundColor = UIColor.darkGrayColor()
            cell.contentView.addSubview(text3)
            
            let gap : CGFloat = 15
            let buttonHeight: CGFloat = 30
            let buttonWidth: CGFloat = 30
            let inviteButton = UIButton()
            
            inviteButton .setTitleColor( UIColor(red:235.0/255.0,green:129.0/255.0,blue:40.0/255.0,alpha:1.0), forState: .Normal)
            inviteButton.frame = CGRectMake(cell.frame.size.width - gap - buttonWidth, cell.frame.size.height/3-3, buttonWidth, buttonHeight)
            inviteButton.layer.cornerRadius = 0.5 * inviteButton.bounds.size.width
            inviteButton.backgroundColor = UIColor.whiteColor()
            inviteButton.layer.borderColor = UIColor.blackColor().CGColor;
            inviteButton.layer.borderWidth = 1.0
            
            inviteButton.tag = indexPath.row
            print("\(selectedPeople)")
            if selectedPeople.containsObject(text2.text!)
            {
                inviteButton.backgroundColor = UIColor.redColor()
            }
            else
            {
                inviteButton.backgroundColor = UIColor.whiteColor()
            }
            inviteButton.addTarget(self, action: "inviteButton:", forControlEvents: UIControlEvents.TouchUpInside)
            inviteButton.titleLabel!.font = UIFont.boldSystemFontOfSize(17)
            cell.addSubview(inviteButton)
            
            return cell
       }else{
         if tableView == self.tableView {
                return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
            } else {
            
            
                if searching && searchResults.count == 0 {
                    let cell = self.tableView.dequeueReusableCellWithIdentifier("ActivityCell", forIndexPath: indexPath)
                    return cell
                } else if (searchResults[indexPath.row] as? User  != nil) {
                    let user = searchResults[indexPath.row] as? User
                    let cell = self.tableView.dequeueReusableCellWithIdentifier("UserCell", forIndexPath: indexPath) as! UserSummaryTableViewCell
                
                    // Configure the cell...
                
                    cell.user = user
                    cell.nameLabel.hidden = false
                    cell.nameLabel1.hidden = false
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
    func updateSearchResultsForSearchController(searchController: UISearchController)
    {
        filteredTableData.removeAll(keepCapacity: false)
        
        let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
        let array = (nameArray as NSArray).filteredArrayUsingPredicate(searchPredicate)
        filteredTableData = array as! [String]
        
        tableViewContact.reloadData()
    }
    func inviteButton(sender: UIButton) {
        let indexPath = NSIndexPath(forRow: sender.tag, inSection: 0)
        let inviteButton = sender as UIButton
        
        let person = numberArray[indexPath.row]
        
        
        var containObj :String = ""
        if(filteredTableData.count>0){
            containObj = "\(self.contactDict.valueForKey(filteredTableData[indexPath.row])!)"
        }else{
           containObj =  "\(self.contactDict.valueForKey(nameArray[indexPath.row] as! String)!)"
        }
        
        
        
        
        if selectedPeople .containsObject(containObj)
        {
            inviteButton.backgroundColor = UIColor.whiteColor()
            invitedFriendsArray .removeObject(indexPath.row)
            
            if(filteredTableData.count>0){
                selectedPeople.removeObject(self.contactDict.valueForKey(filteredTableData[indexPath.row]) as! String)
            }else{
             selectedPeople.removeObject(self.contactDict.valueForKey(nameArray[indexPath.row] as! String) as! String)
            }
        }
        else
        {
            inviteButton.backgroundColor = UIColor.redColor()
            invitedFriendsArray .addObject(indexPath.row)
            if(filteredTableData.count>0){
            selectedPeople.addObject(self.contactDict.valueForKey(filteredTableData[indexPath.row]) as! String)
            }else{
            selectedPeople.addObject(self.contactDict.valueForKey(nameArray[indexPath.row] as! String) as! String)
            }
        }
        
        print("\(filteredTableData)-----")
        print("\(selectedPeople)")
        print("inviteButton: \(indexPath.row)")
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
        } else if segue.identifier == "sample1" {
          super.prepareForSegue(segue, sender: sender)
        }else if segue.identifier == "goToCapture"{
        super.prepareForSegue(segue, sender: sender)
        }else if segue.identifier == "toContactView"{
        super.prepareForSegue(segue, sender: sender)
        }else {
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
        
        searchStatus = false
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
                            let _ = User(name: nil, email: nil, externalID: nil, timelinesPublic: nil, approveFollowers: nil, pendingFollowersCount: nil, followersCount: nil, followingCount: nil, likersCount: nil, liked: false, blocked: false, followed: .NotFollowing, timelines: [timeline], state: .Dummy(parentID), userfullname : nil,website: nil, other : nil, bio : nil , firstname : nil , lastname : nil , imageurl : nil , parent: nil)
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
                self.searchStatus = true
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
//        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

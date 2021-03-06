//
//  ProfileTableViewController.swift
//  Timeline
//
//  Created by Valentin Knabel on 31.07.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//
import Foundation
import UIKit
import Parse


class ProfileTableViewController: TintedHeaderTableViewController {

    @IBOutlet var userSummaryView: UserSummaryTableViewCell!

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var nameLabel1: UILabel!
    @IBOutlet var lblBio: UILabel!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var websiteButton: UIButton!
    @IBOutlet var othersLabel: UILabel!
    @IBOutlet var followingLabel: UILabel!
    @IBOutlet var followersLabel: UILabel!
    @IBOutlet var lovedLabel: UILabel!
    @IBOutlet var pendingLabel: UILabel!
    
    @IBOutlet var timelinesPublicSwitch: UISwitch!
    @IBOutlet var approveFollowersSwitch: UISwitch!
    
    @IBOutlet var userImageView: ProfileImageView!
    var status:Bool = false
    var pendingBadge: CustomBadge?
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerNib(UINib(nibName: "UserSummaryTableViewCell", bundle: nil), forCellReuseIdentifier: "UserCell")

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        navigationController?.delegate = self
        
        self.navigationController?.navigationBarHidden = false
        let left: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "Back to previous screen"), style: .Plain, target: self, action:"goToRecordScreen")
//
        navigationItem.leftBarButtonItem = left
       
    }
    
    @IBAction func websiteButton(sender: AnyObject) {
        
        let buttonTitle = (websiteButton.titleLabel?.text)!  as String
        let check = buttonTitle.stringByReplacingOccurrencesOfString("Website: ", withString: "")
        
        var resultingStr:String = ""
//        if check.length != 0 {
//            resultingStr = buttonTitle
//        }else{
//
//        }
        resultingStr = "http://\(check)"
        print(resultingStr)
        UIApplication.sharedApplication().openURL(NSURL(string: resultingStr)!)

    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        cleanUpHooking()
  
    }
    func goToRecordScreen(){
        cleanUpHooking()
        UIView.animateWithDuration(1.0,animations: { () -> Void in
        let viewController = UIApplication.sharedApplication().windows[0].rootViewController?.childViewControllers[1] as? drawer
        viewController?.timelineButtonCLick()
        })
        
//        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        appDelegate.window = UIWindow(frame: UIScreen.mainScreen().bounds)
//        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc : drawer = storyboard.instantiateViewControllerWithIdentifier("drawerID") as! drawer
//        var nav = appDelegate.window?.rootViewController as? UINavigationController
//        
//        nav = UINavigationController.init(rootViewController:vc )
//        
//        hidesBottomBarWhenPushed = true
//        NSUserDefaults.standardUserDefaults().setObject("Capture", forKey: "transitionTo")
//        
//        let transition: CATransition = CATransition()
//        let timeFunc : CAMediaTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
//        transition.duration = 0.1
//        transition.timingFunction = timeFunc
//        transition.type = kCATransitionPush
//        transition.subtype = kCATransitionFromLeft    //kCATransitionFromLeft
//        nav!.view.layer.addAnimation(transition, forKey: kCATransition)
//        appDelegate.window?.rootViewController = nav
//        appDelegate.window?.makeKeyAndVisible()
        
        
//        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        appDelegate.window = UIWindow(frame: UIScreen.mainScreen().bounds)
//        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc : drawer = storyboard.instantiateViewControllerWithIdentifier("drawerID") as! drawer
//        var nav = appDelegate.window?.rootViewController as? UINavigationController
//        
//        nav = UINavigationController.init(rootViewController:vc )
//        
//        hidesBottomBarWhenPushed = true
//        
//        let transition: CATransition = CATransition()
//        let timeFunc : CAMediaTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
//        transition.duration = 0.25
//        transition.timingFunction = timeFunc
//        transition.type = kCATransitionPush
//        transition.subtype = kCATransitionFromLeft    //kCATransitionFromLeft
//        nav!.view.layer.addAnimation(transition, forKey: kCATransition)
//        appDelegate.window?.rootViewController = nav
//        appDelegate.window?.makeKeyAndVisible()

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
//        NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "update", userInfo: nil, repeats: false)
        //main{
        self.update()
        //}
//        self.navigationController!.navigationBar.frame = CGRectMake(0, 0, self.navigationController!.navigationBar.frame.size.width, self.navigationController!.navigationBar.frame.size.height+20)
//        print("\(self.navigationController!.navigationBar.frame)")
        
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
//        main{
//        self.refresh()
//        }
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if (status && IPHONE6P==1) {
         self.tableView.headerViewForSection(0)?.frame = CGRectMake((self.tableView.headerViewForSection(0)?.frame.origin.x)!,(self.tableView.headerViewForSection(0)?.frame.origin.y)!-20,(self.tableView.headerViewForSection(0)?.frame.size.width)!,(self.tableView.headerViewForSection(0)?.frame.size.height)!)

        userSummaryView.frame = CGRectMake(userSummaryView.frame.origin.x,userSummaryView.frame.origin.y-20,userSummaryView.frame.size.width,userSummaryView.frame.size.height)
            status = false
        }
    }
    func update(){
        //delay (0.1) {
        self.setUpHooking()
        self.refresh()
        
        Storage.performRequest(ApiRequest.UserMe, completion: { (json) -> Void in
            //print("user details json: \(json)")
            if let user = Storage.session.currentUser {
                user.state = SynchronizationState(dict: json, parent: nil)
                
                if let timelinesPublic = json["timelines_public"] as? Bool {
                    user.timelinesPublic = timelinesPublic
                }
                if let approveFollowers = json["approve_followers"] as? Bool {
                    user.approveFollowers = approveFollowers
                }
                if let allowedTimelinesCount = json["allowed_timelines_count"] as? Int {
                    Storage.session.allowedTimelinesCount = allowedTimelinesCount
                }
                if let pendingFollowersCount = json["pending_followers"] as? Int {
                    user.pendingFollowersCount = pendingFollowersCount
                }
                if let likesCount = json["likers_count"] as? Int {
                    user.likesCount = likesCount
                }
                if let followersCount = json["followers_count"] as? Int {
                    user.followersCount = followersCount
                }
                if let followingCount = json["followees_users_count"] as? Int {
                    user.followingCount = followingCount
                }
                Storage.save()
                
                self.refresh()
                }
            })
        //}
    }
    
    private func refresh() {
        userSummaryView.user = Storage.session.currentUser

        // set title
        if PFUser.currentUser()?.authenticated ?? false {
            let user = PFUser.currentUser()!
            
            let isFacebook = NSUserDefaults.standardUserDefaults().valueForKey("facebook_login")
            if(isFacebook != nil)
            {
//            nameLabel.text = "\(user.username!)"
//            emailLabel.text = "\(user.email!)"
                let username = "\(NSUserDefaults.standardUserDefaults().valueForKey("fb_username")!)"
                let nameArr = username.componentsSeparatedByString("_")
                nameLabel1.text = "\(nameArr[0]) \(nameArr[1])"
                
                nameLabel.text = "\(username)"
                emailLabel.text = "\(NSUserDefaults.standardUserDefaults().valueForKey("fb_email")!)"
                navigationItem.title = "\(NSUserDefaults.standardUserDefaults().valueForKey("fb_username")!)"
                
//                lblBio.text = "Bio: "
                
                let attributedText: NSMutableAttributedString = NSMutableAttributedString(string: "Bio:  ")
                attributedText.addAttributes([NSFontAttributeName: UIFont.boldSystemFontOfSize(18)], range: NSRange(location: 0, length: 4))
                lblBio.attributedText = attributedText
            }else{
                
                var Firstname:String = ""
                var Lastname:String = ""
                print(user.firstname)
                print(user.lastname)
                if(user.firstname == "" && user.lastname == ""){
                    Firstname = "\(PFUser.currentUser()!.firstname)"
                    Lastname = "\(PFUser.currentUser()!.lastname)"
                }else{
                    Firstname = user.firstname!
                    Lastname = user.lastname!
                }
                
                navigationItem.title = "@\(user.username!)"
                nameLabel.text = "@\(user.username!)"
                nameLabel1.text = "\(Firstname) \(Lastname)"
                emailLabel.text = "\(user.email!)"
                
                var bioStr:String = ""
                if user.objectForKey("bio") != nil {
                    bioStr = "\(user.objectForKey("bio")!)"
                    let attributedTextBio: NSMutableAttributedString = NSMutableAttributedString(string: "Bio: \(bioStr)")
                    attributedTextBio.addAttributes([NSFontAttributeName: UIFont.boldSystemFontOfSize(18)], range: NSRange(location: 0, length: 4))
                    lblBio.attributedText = attributedTextBio
                }
                if user.objectForKey("bio") == nil {
                    bioStr = ""
                    lblBio.text = bioStr
//                    let heigh =  lblBio.frame.size.height
//                    lblBio.frame = CGRectMake(lblBio.frame.origin.x, lblBio.frame.origin.y, lblBio.frame.size.width, 0)
//                    userSummaryView.frame = CGRectMake(userSummaryView.frame.origin.x, userSummaryView.frame.origin.y, userSummaryView.frame.size.width, userSummaryView.frame.size.height-heigh)
                }
                
                
                var websiteStr:String = ""
                if user["website"] != nil {
                    websiteStr = "\(user.objectForKey("website")!)"
                    let attributedTextBio: NSMutableAttributedString = NSMutableAttributedString(string: "Website: \(websiteStr)")
                    attributedTextBio.addAttributes([NSFontAttributeName: UIFont.boldSystemFontOfSize(18) , NSForegroundColorAttributeName : UIColor.blackColor()], range: NSRange(location: 0, length: 8))
                    websiteButton.titleLabel?.textColor = UIColor.blackColor()
                    websiteButton.titleLabel?.font = UIFont.systemFontOfSize(16)
                    websiteButton.setAttributedTitle(attributedTextBio, forState: .Normal)
                    //websiteButton.setatt(attributedTextBio, forState: .Normal)
                }
                if user["website"] == nil {
                websiteStr = ""
                }
                
                
                
                var otherStr:String = ""
                if user["other"] != nil {
                    otherStr = "\(user.objectForKey("other")!)"
                    let attributedTextOther: NSMutableAttributedString = NSMutableAttributedString(string: "Other: \(otherStr)")
                    attributedTextOther.addAttributes([NSFontAttributeName: UIFont.boldSystemFontOfSize(18)], range: NSRange(location: 0, length: 6))
                    othersLabel.attributedText = attributedTextOther
                }
                if user["other"] == nil {
                    otherStr = ""
                }
                
                
//                if let website = user["website"] as? String {
//                    websiteLabel.text = website
//                }
//                if let other = user["other"] as? String {
//                    otherLabel.text = other
//                }
                
                
            }
            
            timelinesPublicSwitch.on = Storage.session.currentUser!.timelinesPublic!
            approveFollowersSwitch.on = Storage.session.currentUser!.approveFollowers!
            
//            user.badgePendingInBackground { pc -> Void in
//                main {
//                    if pc > 0 {
//                        let text = String(pc)
//                        if self.pendingBadge == nil {
//                            self.pendingBadge = CustomBadge(string: text, withStyle: BadgeStyle.defaultStyle())
//                            self.pendingLabel.superview?.addSubview(self.pendingBadge!)
//                            self.pendingBadge?.center = self.pendingLabel.center
//                        } else {
//                            self.pendingBadge?.badgeText = text
//                        }
//                    } else {
//                        self.pendingBadge?.removeFromSuperview()
//                    }
//                }
//            }
        } else {
            Storage.logout()
        }
        
        if let user = Storage.session.currentUser {
            pendingLabel.text = "\(user.pendingFollowersCount ?? 0)"
        }
        
         userImageView.user = Storage.session.currentUser
    }
    
    @IBAction func toggleTimelinesPublic() {
        let flag = timelinesPublicSwitch.on
        timelinesPublicSwitch.enabled = false
        Storage.performRequest(.UserSettings("timelines_public", flag)) { json in
            main {
                if let error = json["error"] as? String {
                    let alert = UIAlertController(title: local(.SettingsAlertTimelinesPublicErrorTitle), message: error, preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: local(.SettingsAlertTimelinesPublicErrorActionDismiss), style: .Default, handler: nil))
                    self.presentAlertController(alert)
                } else {
                    Storage.session.currentUser?.timelinesPublic = flag
                    Storage.save()
                    self.timelinesPublicSwitch.enabled = true
                }
            }
        }
    }
    
    @IBAction func toggleFollowersApprove() {
        let flag = approveFollowersSwitch.on
        approveFollowersSwitch.enabled = false
        Storage.performRequest(.UserSettings("approve_followers", flag)) { json in
            main {
                if let error = json["error"] as? String {
                    let alert = UIAlertController(title: local(.SettingsAlertFollowersApproveErrorTitle), message: error, preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: local(.SettingsAlertFollowersApproveErrorActionDismiss), style: .Default, handler: nil))
                    self.presentAlertController(alert)
                } else {
                    Storage.session.currentUser?.approveFollowers = flag
                    Storage.save()
                    self.approveFollowersSwitch.enabled = true
                }
            }
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let fl = sender as? Followable,
            let dest = segue.destinationViewController as? CallbackUserTableViewController
            where segue.identifier == "ShowUserList"
        {
            dest.callback = { fl.followers($0) }
            dest.navigationItem.title = local(.Followers)
        } else if let fl = sender as? Likeable,
            let dest = segue.destinationViewController as? CallbackUserTableViewController
            where segue.identifier == "ShowUserList"
        {
            dest.callback = { fl.likers($0) }
            dest.navigationItem.title = local(.Likes)
        }
    }

    @IBAction func shareApplication() {
        let activities = [local(.SettingsStringShareMessage), NSURL(string: local(.SettingsStringShareURL))!]
        let controller = UIActivityViewController(activityItems: activities, applicationActivities: nil)
        presentActivityViewController(controller)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source


    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    var hookingResponsibilities: [AnyObject?] = []
}

extension ProfileTableViewController: Hooking, UserMoreButtonBehavior, PushableBehavior, ShareableBehavior, BlockableBehavior {
    var hookingSetUps: [() -> AnyObject?] {
        return [setUpUserMoreButtonBehavior, setUpActiveControllerBehavior]
    }
    
    
}
extension String {
    var length: Int {
        return characters.count
    }
}

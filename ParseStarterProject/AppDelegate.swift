//
//  AppDelegate.swift
//
//  Copyright 2011-present Parse Inc. All rights reserved.
//

import UIKit

import Bolts
import Parse
import ParseFacebookUtilsV4
import FBSDKCoreKit
import FBSDKLoginKit
import QuartzCore

// If you want to use Crash Reporting - uncomment this line
import ParseCrashReporting

var followLoadingCountDidChange: ((Bool) -> Void)? = nil
var showActivityIndicator: Void?
var hideActivityIndicator : Void?
var notificationAPI : Void?

var followLoadingCount: Int = 0 {
    didSet {
        followLoadingCountDidChange?(followLoadingCount > 0)
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var walkDelegate: WalkthroughDelegate?
    var notificationCount : Int!
    var activityIndicator = UIActivityIndicatorView()
    let activityIndicatorView = UIView()
    var GroupTimeline : Bool = false
    var headerLabelSTr : (NSString) = ""
    
    //--------------------------------------
    // MARK: - UIApplicationDelegate
    //--------------------------------------

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "addAnimation", userInfo: nil, repeats: true)

        Parse.enableLocalDatastore()
        ParseCrashReporting.enable()
        //
        // Uncomment and fill in with your Parse credentials:
        Parse.setApplicationId("LiynFqjSP5wmP8QfzLQLgm8tGStY3Jt5FeH34lhS",
            clientKey: "TSMwY8Asxa08Br0pB0QR03bpGA5GjMLPYia9Ljka")
//        Parse.setApplicationId("Zlos4Gg3l7oIeyfekTgMNrA5ENWoHmyKGuRiM39C",
//            clientKey: "XAGhmOVc3POrGugXHlVYuySyWuOj0Q6hET3SE2fW")
        
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
        
        let defaultACL = PFACL()
        
        // If you would like all objects to be private by default, remove this line.
        defaultACL.publicReadAccess = true
        
        PFACL.setDefaultACL(defaultACL, withAccessForCurrentUser:true)
        
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        
        if application.applicationState != UIApplicationState.Background {
            // Track an app open here if we launch with a push, unless
            // "content_available" was used to trigger a background push (introduced in iOS 7).
            // In that case, we skip tracking here to avoid double counting the app-open.
            
            let preBackgroundPush = !application.respondsToSelector("backgroundRefreshStatus")
            let oldPushHandlerOnly = !self.respondsToSelector("application:didReceiveRemoteNotification:fetchCompletionHandler:")
            var noPushPayload = false
            if let options = launchOptions {
                noPushPayload = options[UIApplicationLaunchOptionsRemoteNotificationKey] != nil
            }
            if (preBackgroundPush || oldPushHandlerOnly || noPushPayload) {
                PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
            }
        }
        
        if let user = PFUser.currentUser() {
            user.fetchIfNeededInBackground()
        } else if let st = Storage.session.sessionToken {
            PFUser.becomeInBackground(st)
        }
        
        UINavigationBar.appearance().backIndicatorImage = UIImage(assetIdentifier: .BackIndicator)
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = UIImage(assetIdentifier: .BackIndicator)
        
        let backButtonTextOffset = UIOffsetMake(0, -60)
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(backButtonTextOffset, forBarMetrics: UIBarMetrics.Default)
        
        initializeRootViewController()
        
        return true
    }
    
    var timer: NSTimer!
    func addAnimation() {
        UIView.setAnimationsEnabled(true)
    }
    
    func initializeRootViewController() {
        print("initroot")
        notificationCount = 0
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let nav = window?.rootViewController as? UINavigationController else {
            print("AppDelegate.initializeRootViewController() nav not an UINavigationController")
            return
        }

        if let _ = Storage.session.webToken, let _ = Storage.session.currentUser, let _ = Storage.session.sessionToken {
            let vc = storyboard.instantiateViewControllerWithIdentifier("drawerID")
            nav.popViewControllerAnimated(false)
            nav.pushViewController(vc, animated: false)
            
            let application = UIApplication.sharedApplication()
            if application.respondsToSelector("registerUserNotificationSettings:") {
                let userNotificationTypes: UIUserNotificationType = [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound]
                let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
                application.registerUserNotificationSettings(settings)
                application.registerForRemoteNotifications()
            } else {
                let types: UIRemoteNotificationType = [UIRemoteNotificationType.Badge, UIRemoteNotificationType.Alert, UIRemoteNotificationType.Sound]
                application.registerForRemoteNotificationTypes(types)
            }
            
            async {
                for t in Storage.session.currentUser?.timelines ?? [] {
                    if t.persistent {
                        t.download { }
                    }
                }
            }
            notificationAPI()
//            Storage.performRequest(ApiRequest.UserNotifications, completion: { (json) -> Void in
//                print(json)
//                if let results = json["result"] as? [[String: AnyObject]] {
//                    self.notificationCount = results.count
//                    for not in results {
//                        if let raw = not["payload"] as? NSString,
//                            let data = raw.dataUsingEncoding(NSUTF8StringEncoding),
//                        let payload = (try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)) as? [String: AnyObject]
//                        {
//                            self.process(payload: payload)
//                        }
//                    }
//                }
//            })
        } else {
            walkDelegate = WalkthroughDelegate.instantiateDefaultWalkthrough()
            nav.topViewController?.dismissViewControllerAnimated(false, completion: nil)
            nav.popToRootViewControllerAnimated(false)
            nav.pushViewController(walkDelegate!.master, animated: false)
            
            //storyboard.instantiateViewControllerWithIdentifier("walk") as? UIViewController
        }
    }
    
    func notificationAPI()
    {
        Storage.performRequest(ApiRequest.UserNotifications, completion: { (json) -> Void in
            print(json)
            if let results = json["result"] as? [[String: AnyObject]] {
                self.notificationCount = results.count
                for not in results {
                    if let raw = not["payload"] as? NSString,
                        let data = raw.dataUsingEncoding(NSUTF8StringEncoding),
                        let payload = (try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)) as? [String: AnyObject]
                    {
                        self.process(payload: payload)
                    }
                }
            }
        })
    }
    func applicationDidBecomeActive(application: UIApplication) {
        let currentInstallation = PFInstallation.currentInstallation()
        if currentInstallation.badge != 0 {
            currentInstallation.badge = 0
            currentInstallation.saveEventually()
        }
        FBSDKAppEvents.activateApp()
//        if let _ = Storage.session.currentUser {
//            Storage.performRequest(ApiRequest.UserNotifications, completion: { (json) -> Void in
//                print(json)
//                if let results = json["result"] as? [[String: AnyObject]] {
//                    for not in results {
//                        if let raw = not["payload"] as? NSString,
//                            let data = raw.dataUsingEncoding(NSUTF8StringEncoding),
//                            let payload = (try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)) as? [String: AnyObject]
//                        {
//                            self.process(payload: payload)
//                        }
//                    }
//                }
//            })
//        }
    }
    
    //--------------------------------------
    // MARK: Push Notifications
    //--------------------------------------
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.saveInBackground()
        
        PFPush.subscribeToChannelInBackground("") { (succeeded: Bool, error: NSError?) in
            if succeeded {
                print("ParseStarterProject successfully subscribed to push notifications on the broadcast channel.");
            } else {
                print("ParseStarterProject failed to subscribe to push notifications on the broadcast channel with error = %@.", error)
            }
        }
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        if error.code == 3010 {
            print("Push notifications are not supported in the iOS Simulator.")
        } else {
            print("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
        }
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
            print("first")
    }
    
    private func start(payload payload: [String: AnyObject]) {
        let u = PFUser.currentUser()
        switch payload["action"] as? String ?? "" {
        case "follow_request":
            //u?.increaseBadgeUserInBackground()
            u?.increaseBadgePendingInBackground()
        case "create":
            u?.increaseBadgeFollowingInBackground()
            if --followLoadingCount < 1 {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            }
            
        case "like", "follow":
            u?.increaseBadgeMineInBackground()
            
        default:
            break
        }
        
        switch payload["action"] as? String ?? "" {
        case "create":
            followLoadingCount++
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            
        default:
            break
        }
    }
    
    private func finish(payload payload: [String: AnyObject]) {
        Storage.session.notificationDate = NSDate()
        Storage.save()
    }
    
    func process(payload payload: [String: AnyObject]) -> DeepLink? {
        let link = DeepLink.from(payload: payload)
        start(payload: payload)
        
        // increase counter
        if let link = link {
            switch link {
            case .MomentLink(_, let uuid, _):
                DeepLink.timeline(uuid: uuid, completion: { (tl) -> Void in
                    tl.hasNews = true
                    tl.parent?.hasNews = true
                    self.finish(payload: payload)
                })
            case .TimelineLink(_, let uuid):
                DeepLink.timeline(uuid: uuid, completion: { (tl) -> Void in
                    tl.hasNews = true
                    tl.parent?.hasNews = true
                    self.finish(payload: payload)
                })
            case .UserLink(_, _, let uuid):
                DeepLink.user(uuid: uuid, completion: { (u) -> Void in
                    u.hasNews = true
                    self.finish(payload: payload)
                })
            }
        }
        return link
    }
    func processAsync(payload payload: [String: AnyObject], completion: (DeepLink?) -> Void) {
        let link = DeepLink.from(payload: payload)
        start(payload: payload)
        
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
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        print("second")
        if application.applicationState == .Inactive {
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
        }
        print("aps")
        print("payload")
        if let _ = userInfo["aps"] as? [String: AnyObject],
            let payload = userInfo["payload"] as? [String: AnyObject]
        {
            processAsync(payload: payload) { link in
                if let link = link {
                completionHandler(.NewData)
                if application.applicationState == .Inactive {
                    self.handle(deepLink: link)
                }
                } else {
                    completionHandler(.NoData)
                }
            }
        } else {
            if application.applicationState == .Inactive {
                // campaign notification
                PFPush.handlePush(userInfo)
            }
            completionHandler(.NoData)
        }
    }
    
    func handle(deepLink link: DeepLink?) {
        main {
        let story = UIStoryboard(name: "Main", bundle: nil)
        if let push = story.instantiateViewControllerWithIdentifier("PushFetchViewController") as? PushFetchViewController,
            let presenter = self.window?.rootViewController?.presentedViewController ?? self.window?.rootViewController,
            let link = link
        {
            push.link = link
            presenter.presentViewController(push, animated: true, completion: nil)
        }
        }
    }
    
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        switch url.host ?? "" {
        case "user", "timeline", "moment":
            let link = DeepLink.from(payload: url.parameters as? [String: AnyObject])
            handle(deepLink: link)
            return link != nil
            
        default:
            return false
        }
    }

    func application(application: UIApplication,
        openURL url: NSURL,
        sourceApplication: String?,
        annotation: AnyObject) -> Bool {
            return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    func showActivityIndicator()
    {
        main{
            self.activityIndicatorView.frame = CGRectMake(0, 0, 70, 70);
            self.activityIndicatorView.backgroundColor = UIColor.grayColor()
            self.activityIndicatorView.alpha = 1
            self.activityIndicatorView.center = self.window!.center
            self.activityIndicatorView.layer.cornerRadius = 4
            self.window!.addSubview(self.activityIndicatorView)
            
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
        }
    }
    
    func hideActivityIndicator()
    {
        main{
            self.activityIndicator.stopAnimating()
            self.activityIndicator.removeFromSuperview()
            self.activityIndicatorView.removeFromSuperview()
        }
    }
}

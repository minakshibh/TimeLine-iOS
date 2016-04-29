 //
//  CaptureMomentViewController.swift
//  Timeline
//
//  Created by Valentin Knabel on 26.07.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox
import Parse
import SCRecorder
import CoreMedia
import MediaPlayer

/// The central view controller.
/// Contains a capture view and controls for navigation.
class CaptureMomentViewController: UIViewController ,UIScrollViewDelegate {
    
    var scrollView = UIScrollView()
    let closeButton  = UIButton()
    var drafts :NSMutableArray = []
    var reverseDrafts :NSMutableArray = []

    var recorder: SCRecorder!
    var badgeTimer: NSTimer!
    var badgeTimerEnabled: Bool = true
    var momentPlayerController: MomentPlayerController?

    @IBOutlet var previewView: CameraPreviewView!
    @IBOutlet var recordButton: UIButton!
    @IBOutlet var torchOnButton: UIButton!
    @IBOutlet var torchOffButton: UIButton!
    @IBOutlet var countdownLabel: UILabel!
    var videoPlayView: PlayerView!

    var countdown: Int = 1
    var timer: NSTimer? {
        didSet {
            oldValue?.invalidate()
        }
    }
    var torchEnabled = true
    @IBOutlet var menuControls: [UIButton]!
    @IBOutlet var nonRecordGestureRecognizers: [UIGestureRecognizer]!
    
    @IBOutlet var profileMenuButton: UIButton!
    @IBOutlet var timelineMenuButton: UIButton!
    @IBOutlet var allNotificationMenuButton: UIButton!

    var profileMenuBadge: CustomBadge?
    var timelineMenuBadge: CustomBadge?
    var notificationsMenuBadge: CustomBadge?

    var startDate: NSDate?
    var endTimer: NSTimer?
    
    /* SOUND: lazy var startRecording: AVAudioPlayer = {
        let url = NSBundle.mainBundle().URLForResource("record-start", withExtension: "mp3", subdirectory: nil)
        var player = AVAudioPlayer(contentsOfURL: url, error: nil)
        return player
        }()
    lazy var endRecording: AVAudioPlayer = {
        let url = NSBundle.mainBundle().URLForResource("record-end", withExtension: "mp3", subdirectory: nil)
        var player = AVAudioPlayer(contentsOfURL: url, error: nil)
        return player
        }()*/
    
    @IBAction func menuControls(sender: AnyObject) {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc  = storyboard.instantiateViewControllerWithIdentifier("Left")
        var nav = appDelegate.window?.rootViewController as? UINavigationController
        
        nav = UINavigationController.init(rootViewController:vc )
        
        hidesBottomBarWhenPushed = true
        
        let transition: CATransition = CATransition()
        let timeFunc : CAMediaTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.duration = 0.25
        transition.timingFunction = timeFunc
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft    //kCATransitionFromLeft
        nav!.view.layer.addAnimation(transition, forKey: kCATransition)
        appDelegate.window?.rootViewController = nav
        nav!.navigationBarHidden = true
        appDelegate.window?.makeKeyAndVisible()
    }
    @IBAction func timelineProfileButton(sender: AnyObject) {
        
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc : drawer = storyboard.instantiateViewControllerWithIdentifier("drawerID") as! drawer
        var nav = appDelegate.window?.rootViewController as? UINavigationController
        
        nav = UINavigationController.init(rootViewController:vc )
        
        hidesBottomBarWhenPushed = true
        NSUserDefaults.standardUserDefaults().setObject("Right", forKey: "transitionTo")
        
        let transition: CATransition = CATransition()
        let timeFunc : CAMediaTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.duration = 0.25
        transition.timingFunction = timeFunc
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight    //kCATransitionFromLeft
        nav!.view.layer.addAnimation(transition, forKey: kCATransition)
        appDelegate.window?.rootViewController = nav
        appDelegate.window?.makeKeyAndVisible()

        
//        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        appDelegate.window = UIWindow(frame: UIScreen.mainScreen().bounds)
//        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc  = storyboard.instantiateViewControllerWithIdentifier("Right")
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
//        nav!.navigationBarHidden = true
//        appDelegate.window?.makeKeyAndVisible()
    }
    @IBAction func timelineMenuButton(sender: AnyObject) {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc : drawer = storyboard.instantiateViewControllerWithIdentifier("drawerID") as! drawer
        var nav = appDelegate.window?.rootViewController as? UINavigationController
        
        nav = UINavigationController.init(rootViewController:vc )
        
        hidesBottomBarWhenPushed = true
        NSUserDefaults.standardUserDefaults().setObject("Left", forKey: "transitionTo")
        
        let transition: CATransition = CATransition()
        let timeFunc : CAMediaTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.duration = 0.25
        transition.timingFunction = timeFunc
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft    //kCATransitionFromLeft
        nav!.view.layer.addAnimation(transition, forKey: kCATransition)
        appDelegate.window?.rootViewController = nav
        appDelegate.window?.makeKeyAndVisible()
        
//       
//        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        appDelegate.window = UIWindow(frame: UIScreen.mainScreen().bounds)
//        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc  = storyboard.instantiateViewControllerWithIdentifier("Left")
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
//        nav!.navigationBarHidden = true
//        appDelegate.window?.makeKeyAndVisible()
        
    }
    override func viewDidLoad() {
//        hidesBottomBarWhenPushed = true
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.None)
        tabBarController?.tabBar.hidden = true
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
        
        
        badgeTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "reloadBadges", userInfo: nil, repeats: true)
        
        transitionCoordinator()?.animateAlongsideTransition({ _ -> Void in
            self.reloadBadges()
            (self.previewView?.layer as? AVCaptureVideoPreviewLayer)?.connection?.videoOrientation = UIApplication.sharedApplication().statusBarOrientation.captureVideoOrientation
            }, completion: { _ in
                
        })
        
        self.menuControls.each { $0.hidden = false }
        self.menuControls.each { $0.alpha = 1.0 }
        self.countdownLabel.alpha = 0.0
        self.countdownLabel.text = 1.description
        
        recorder = SCRecorder.sharedRecorder()
        //recorder.captureSessionPreset = SCRecorderTools.bestCaptureSessionPresetCompatibleWithAllDevices()
        recorder.captureSessionPreset = AVCaptureSessionPresetHigh
        recorder.delegate = self
        recorder.videoConfiguration.sizeAsSquare = true
        recorder.videoConfiguration.enabled = true
        recorder.initializeSessionLazily = false
        recorder.autoSetVideoOrientation = true
        //recorder.previewView = previewView
        let session = SCRecordSession()
        session.fileType = AVFileTypeMPEG4
        recorder.session = session
        let audio = recorder.audioConfiguration
        audio.enabled = true
        //audio.format// = kAudioFormatMPEG4AAC
        
        if !recorder.isPrepared {
            _ = try? recorder.prepare()
        }
        main{
        self.previewView.session = self.recorder.captureSession
        }
//        delay(0.001) {
//            if !Storage.session.walkedThroughCamera {
//                Storage.session.walkedThroughCamera = true
//                self.performSegueWithIdentifier("WalkthroughCamera", sender: self)
//            }
//        }
        
        self.addScrollView()
        
        if PFUser.currentUser()?.authenticated ?? false {
            let user = PFUser.currentUser()!
            
                if user.objectForKey("bio") != nil {
                    NSUserDefaults.standardUserDefaults().setObject(user.objectForKey("bio"), forKey: "user_bio")
                }
                if user.objectForKey("bio") == nil {
                     NSUserDefaults.standardUserDefaults().setObject(" ", forKey: "user_bio")
                }
                
                if user["website"] != nil {
                NSUserDefaults.standardUserDefaults().setObject(user["website"], forKey: "user_website")
                }
                if user["website"] == nil {
                NSUserDefaults.standardUserDefaults().setObject(" ", forKey: "user_website")
                }
                
                if user["other"] != nil {
                NSUserDefaults.standardUserDefaults().setObject(user["other"], forKey: "user_other")
               }
                if user["other"] == nil {
                NSUserDefaults.standardUserDefaults().setObject(" ", forKey: "user_other")

                }
        }

    }
    func removeScrollView() {
        main
            {
                self.closeViewButton()
                for subUIView in self.scrollView.subviews as [UIView] {
                    subUIView.removeFromSuperview()
                }
                self.drafts.removeAllObjects()
                self.closeButton.hidden = true
        }
    }
    func addScrollView() {
        //Scroll view with preview of videos
        self.scrollView = UIScrollView(frame: view.bounds)
        self.scrollView.frame = CGRectMake(0,70, self.view.frame.width, 65)
        self.scrollView.backgroundColor = UIColor.clearColor()
        self.scrollView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.scrollView.contentOffset = CGPoint(x: 1000, y: 450)
        self.scrollView.delegate = self
        self.view.addSubview(self.scrollView)
        
        self.videoPlayView = PlayerView(frame: previewView.bounds)
        self.videoPlayView.frame = CGRectMake(0,135, self.view.frame.width, self.previewView.frame.size.height)
        self.videoPlayView.backgroundColor = UIColor.blackColor()
        self.videoPlayView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.view.addSubview(self.videoPlayView)
        self.videoPlayView.hidden = true

        // close button
        self.closeButton.frame = CGRectMake(10, self.videoPlayView.frame.origin.y + 10, 30, 30);
        self.closeButton.setImage(UIImage(named: "close") as UIImage?, forState: .Normal)
        self.closeButton.addTarget(self, action: "closeViewButton", forControlEvents:.TouchUpInside)
        self.view.addSubview(self.closeButton)
        self.closeButton.hidden = true
    }
    
    
    func addImagesToScrollView()
    {

        let subViews = self.scrollView.subviews
        for subview in subViews{
            subview.removeFromSuperview()
        }
        self.scrollView.frame = CGRectMake(0,self.previewView.frame.origin.y - self.view.frame.width / 4, self.view.frame.width, self.view.frame.width / 4 )
        self.closeButton.frame = CGRectMake(10, self.previewView.frame.origin.y + 10, 30, 30);
        self.videoPlayView.frame = CGRectMake(0,self.previewView.frame.origin.y, self.view.frame.width,self.previewView.frame.size.height)

        let scrollViewWidth:CGFloat = self.scrollView.frame.width/4
        let scrollViewHeight:CGFloat = self.scrollView.frame.height
        
        var start: Int = 0
        var end: Int = self.drafts.count-1
        self.reverseDrafts.removeAllObjects()
        self.reverseDrafts = self.drafts.mutableCopy() as! NSMutableArray
        while start < end {
            self.reverseDrafts.exchangeObjectAtIndex(start, withObjectAtIndex: end)
            start++
            end--
        }

        
        for var index = 0; index < self.reverseDrafts.count; ++index {
              let previewImg = UIImageView(frame: CGRectMake(scrollViewWidth * CGFloat(index), 0,scrollViewWidth-4, scrollViewHeight-4))
            previewImg.tag = index
            let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:Selector("videoImageTapped:"))
            previewImg.userInteractionEnabled = true
            previewImg.addGestureRecognizer(tapGestureRecognizer)
            
            UIImage.getImage(self.reverseDrafts[index] as! Moment) { image in
                main {
                    previewImg.image = image
                    self.scrollView.addSubview(previewImg)
                    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    appDelegate.hideActivityIndicator()

                }
            }
        }
        self.scrollView.contentSize = CGSizeMake(scrollViewWidth * CGFloat(self.drafts.count), self.scrollView.frame.height)
    }
    
    func videoImageTapped(gestureRecognizer: UITapGestureRecognizer) {
        //tappedImageView will be the image view that was tapped.
        //dismiss it, animate it off screen, whatever.
        momentPlayerController = nil
        UIView.animateWithDuration(0.2,animations: { () -> Void in
            self.menuControls.each { $0.alpha = 0.5 }
            self.torchEnabled = false
            self.profileMenuBadge?.alpha = 0.5
            self.timelineMenuBadge?.alpha = 0.5
            self.notificationsMenuBadge?.alpha = 0.5
            self.recordButton.alpha = 0.5
            self.previewView.hidden = true
            self.recordButton.enabled = false
            }) { (flag) -> Void in
            self.menuControls.each { $0.enabled = false }
        }
        self.videoPlayView.hidden = false
        self.closeButton.hidden = false
        
        let tappedImageView = gestureRecognizer.view!
        let index : Int = tappedImageView.tag
        let moment = self.reverseDrafts[index]
        let moments: [Moment] = [moment as! Moment]
        
        if momentPlayerController == nil {
            momentPlayerController = MomentPlayerController(moments: moments   , inView: videoPlayView)
        }
        momentPlayerController?.play()
    }
    
    func closeViewButton()
    {
        momentPlayerController?.pause()
        momentPlayerController = nil

        UIView.animateWithDuration(0.2,animations: { () -> Void in
            self.menuControls.each { $0.alpha = 1.0 }
            self.torchEnabled = true
            self.profileMenuBadge?.alpha = 1.0
            self.timelineMenuBadge?.alpha = 1.0
            self.notificationsMenuBadge?.alpha = 1.0
            self.recordButton.alpha = 1.0
            self.previewView.hidden = false
            self.recordButton.enabled = true
            }) { (flag) -> Void in
                self.menuControls.each { $0.enabled = true }
        }
        self.videoPlayView.hidden = true
        self.closeButton.hidden = true
    }

    
    func reloadBadges() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if appDelegate.notificationCount > 0{
             let style = BadgeStyle.defaultStyle()
            let text = String(appDelegate.notificationCount)
            if self.notificationsMenuBadge == nil {
                self.notificationsMenuBadge = CustomBadge(string: text, withStyle: style)
                self.allNotificationMenuButton.superview?.insertSubview(self.notificationsMenuBadge!, aboveSubview: self.allNotificationMenuButton)
                self.notificationsMenuBadge?.frame.origin = CGPoint(
                    x: self.allNotificationMenuButton!.frame.origin.x + self.allNotificationMenuButton!.frame.width / 1.5,
                    y: self.allNotificationMenuButton!.frame.origin.y-10
                )
            }
            self.notificationsMenuBadge?.badgeText = text
            self.notificationsMenuBadge?.autoBadgeSizeWithString(text)
            self.notificationsMenuBadge?.hidden = false
        } else {
            self.notificationsMenuBadge?.hidden = true
        }

    }

//    func reloadBadges() {
//        if !badgeTimerEnabled {
//            return
//        }
//        let style = BadgeStyle.defaultStyle()
//        let user = PFUser.currentUser()
//        
//        user?.badgeUserAndPendingInBackground { uc, pc in
//            main {
//                if uc + pc > 0 {
//                    let text = String(uc + pc)
//                    if self.profileMenuBadge == nil {
//                        self.profileMenuBadge = CustomBadge(string: text, withStyle: style)
//                        self.profileMenuButton.superview?.insertSubview(self.profileMenuBadge!, aboveSubview: self.profileMenuButton)
//                        self.profileMenuBadge?.frame.origin = CGPoint(
//                            x: self.profileMenuButton!.frame.origin.x + self.profileMenuButton!.frame.width / 2.0,
//                            y: self.profileMenuButton!.frame.origin.y
//                        )
//                    }
//                    self.profileMenuBadge?.badgeText = text
//                    self.profileMenuBadge?.autoBadgeSizeWithString(text)
//                } else {
//                    self.profileMenuBadge?.removeFromSuperview()
//                }
//            }
//        }
//        
//        user?.badgeMineAndFollowingInBackground { mc, fc in
//            if mc + fc > 0 {
//                self.timelineMenuBadge?.removeFromSuperview()
//                let text = String(mc + fc)
//                self.timelineMenuBadge = CustomBadge(string: text, withStyle: style)
//                self.timelineMenuButton.superview?.insertSubview(self.timelineMenuBadge!, aboveSubview: self.timelineMenuButton)
//                self.timelineMenuBadge?.frame.origin = CGPoint(
//                    x: self.timelineMenuButton!.frame.origin.x + self.timelineMenuButton!.frame.width / 2.0,
//                    y: self.timelineMenuButton!.frame.origin.y
//                )
//                self.timelineMenuBadge?.autoBadgeSizeWithString(text)
//            } else {
//                self.timelineMenuBadge?.removeFromSuperview()
//            }
//        }
//    }
    
    override func viewWillAppear(animated: Bool) {
       NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "update", userInfo: nil, repeats: false)
       delay (0.60) {
       
        }
  }
    
    func update(){
       
        self.scrollView.hidden = false
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.notificationAPI ()
         recorder.startRunning()
        
        delay (0.01) {
            
            self.reloadBadges()
        }
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.stop()
        self.recorder.stopRunning()
        self.refreshTorches()
        self.reloadBadges()
        self.removeScrollView()
//        videoPreviewView.hidden = true
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return .Fade
    }
    
    override func shouldAutorotate() -> Bool {
        print("should: \(!(recorder?.isRecording ?? false))")
        return !(recorder?.isRecording ?? false)
    }
    
    //@availability(iOS 8, *)
    /*override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        //UIView.setAnimationsEnabled(false)
        println("transition")
    }*/
    
    //@availability(iOS, introduced=2.0, deprecated=8.0)
    func willRotateToInterfaceOrientation(toInterfaceOrientation orientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let value = UIInterfaceOrientation.Portrait.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
        
        
        if segue.identifier == "ShowTab" || segue.identifier == "ShowMoments" {
            let tabBarController = segue.destinationViewController as! UITabBarController
            tabBarController.delegate = self
            guard let viewControllers = tabBarController.viewControllers else { return }
            let user = PFUser.currentUser()
            user?.badgeMineInBackground {
                viewControllers[0].tabBarItem.badgeValue = $0 > 0 ? String($0) : nil
            }
            user?.badgeFollowingInBackground {
                viewControllers[3].tabBarItem.badgeValue = $0 > 0 ? String($0) : nil
            }
        }
        if segue.identifier == "ShowMoments" {
            let tabBarController = segue.destinationViewController as! UITabBarController
            tabBarController.selectedIndex = 1
        }
    }
    
}


// MARK: IBActions
extension CaptureMomentViewController {
    
    func refreshTorches() {
        main {
            self.torchOffButton.enabled = self.recorder.deviceHasFlash && self.torchEnabled
            self.torchOnButton.enabled = self.recorder.deviceHasFlash && self.torchEnabled
            self.torchOnButton.hidden = self.recorder.flashMode != .Light
            self.torchOffButton.hidden = self.recorder.flashMode == .Light
        }
    }
    
    @IBAction func toggleTorch() {
        recorder.flashMode = recorder.flashMode == .Light ? .Off : .Light
    }
    
    @IBAction func focusAndExposeTap(sender: UITapGestureRecognizer) {
        recorder.continuousFocusAtPoint(recorder.convertToPointOfInterestFromViewCoordinates(sender.locationInView(previewView)))
    }
    
    @IBAction func flipCamera(sender: AnyObject!) {
        recorder.flashMode = recorder.flashMode == .Light ? .Off : .Off
        recorder.switchCaptureDevices()
        //toggleTorch()
        refreshTorches()
         recorder.flashMode = recorder.flashMode == .Light ? .Off : .Off
        
//         recorder.flashMode =  .Off 
    }
    
    @IBAction func startRecording(sender: AnyObject) {
        //AudioServicesPlaySystemSound(recordStartSoundID)
        badgeTimerEnabled = false
        // SOUND: startRecording.play()
        recorder.autoSetVideoOrientation = false
        
        self.countdown = 1
        self.countdownLabel.text = "1"
        
        UIView.animateWithDuration(0.0/* SOUND: startRecording.duration*/,animations: { () -> Void in
            self.menuControls.each { $0.alpha = 0.0 }
            self.countdownLabel.alpha = 1.0
            self.countdownLabel.hidden = false
            self.torchEnabled = false
            self.profileMenuBadge?.alpha = 0.0
            self.timelineMenuBadge?.alpha = 0.0
            self.notificationsMenuBadge?.alpha=0.0
            self.scrollView.alpha = 0.0
            self.closeButton.alpha = 0.0
            }) { (flag) -> Void in
                self.menuControls.each { $0.enabled = false }
        }
        
        // SOUND: delay(startRecording.duration + 0.2) {
            // SOUND: self.startDate = NSDate(timeIntervalSinceNow: self.startRecording.duration)
            
            self.recorder.record()
            self.timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "adjustCountdownLabel", userInfo: nil, repeats: true)
            self.timer?.fire()
        // SOUND: }
    }
    
    @IBAction func stopRecording(sender: AnyObject) {
        // SOUND: if startDate < NSDate() {
        delay(0.5) { self.stop() }
        /* SOUND: }
        else if let d = startDate {
            let leftInterval = d.timeIntervalSinceNow
            endTimer = NSTimer.scheduledTimerWithTimeInterval(leftInterval, target: self, selector: "stop", userInfo: nil, repeats: false)
        }*/
    }
    func stop() {
        recorder.pause {
            print("paused")
            self.recorder.autoSetVideoOrientation = true
        }
        
        // SOUND: endRecording.play()
        
        timer?.invalidate()
        timer = nil
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.menuControls.each { $0.alpha = 1.0 }
            self.countdownLabel.alpha = 0.0
            self.torchEnabled = true
            self.profileMenuBadge?.alpha = 1.0
            self.timelineMenuBadge?.alpha = 1.0
            self.notificationsMenuBadge?.alpha = 1.0
            self.scrollView.alpha = 1.0
            self.closeButton.alpha = 1.0

            }) { (flag) -> Void in
                self.countdownLabel.hidden = false
                self.menuControls.each { $0.enabled = true }
                self.badgeTimerEnabled = true
        }
    }
    
    @IBAction func handlePinchToZoomRecognizer(sender: UIPinchGestureRecognizer) {
        let pinchZoomScaleDivider: CGFloat = 5.0
        if sender.state == .Changed {
            let temp = recorder.videoZoomFactor + atan(sender.velocity / pinchZoomScaleDivider)
            recorder.videoZoomFactor = max(temp, 1)
        }
    }
    
    func adjustCountdownLabel() {
        let attributes = [NSForegroundColorAttributeName: countdown > 10 ? UIColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 1.0) : UIColor.whiteColor()]
        countdownLabel.attributedText = NSAttributedString(string: "\(countdown++)", attributes: attributes)
    }
    
    func enableAllControls(enabled: Bool) {
        recordButton.enabled = enabled
        nonRecordGestureRecognizers.each { $0.enabled = enabled }
        menuControls.each { $0.enabled = enabled }
    }
    
}

extension CaptureMomentViewController: SCRecorderDelegate {
    
    func recorder(recorder: SCRecorder, didCompleteSegment segment: SCRecordSessionSegment?, inSession session: SCRecordSession, error: NSError?) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        main{
            appDelegate.showActivityIndicator()
        }

        recorder.flashMode = .Off
        recorder.session?.mergeSegmentsUsingPreset(AVAssetExportPresetHighestQuality, completionHandler: { (url, parentError) -> Void in
            if let url = url {
                let name = Moment.newName()
                let newURL = Moment.documentURL(name, suffix: "mp4")
                do {
                    
                    let asset1 = AVURLAsset(URL: url, options: nil)
                    let seconds1 = Int(round(CMTimeGetSeconds(asset1.duration)))
                    
                    if seconds1 > 10 {
                        
                        let tenSecsVideo = seconds1/10 as Int
                        let remainingTime  = seconds1 - tenSecsVideo*10
                        
                        var status = 0;
                        if (remainingTime > 0) {
                            status = 1
                        }
                        let count = tenSecsVideo + status
                        
//                        self.cropVideo(url)
                        
                        if status==1{
                        //for loop with status
                            for (var a=0;a<count;a++){
                                var stattime:Int
                                var endTime:Int
                                
                                let left = count-1
                                if (a == left){
                                    stattime = 0+10*a
                                    endTime = stattime + remainingTime
                                }else{
                                stattime = 0 + 10*a
                                endTime = 10 + 10*a
                                }
                                self.cropVideo(url, statTime: Float(stattime), endTime: Float(endTime))
                            }
                        }
                         if status==0{
                        //for loop without status
                            for (var a=0;a<count-1;a++){
                                
                                let stattime = 0 + 10*a
                                let endTime = 10 + 10*a
                                self.cropVideo(url, statTime: Float(stattime), endTime: Float(endTime))
                            }
                        }
                        return
                    }
//                    return
                    try NSFileManager.defaultManager().moveItemAtURL(url, toURL: newURL)
                    let asset = AVURLAsset(URL: newURL, options: nil)
                    let seconds = Int(round(CMTimeGetSeconds(asset.duration)))
                    
                    let newMoment = Moment(persistent: true, pathName: name, remoteStreamURL: nil, remoteVideoURL: nil, remoteThumbURL: nil, size: nil, duration: seconds, contentType: nil, overlayPosition: nil, overlayText: nil, overlaySize: nil, overlayColor: nil, state: .LocalOnly, parent: nil)
                    
                    
                    Storage.session.drafts.append(newMoment)
                    Storage.save()
                    
                    self.drafts.addObject(newMoment)
                    self.addImagesToScrollView()

                    //  self.performSegueWithIdentifier("ShowMoments", sender: self)
                    print("segued")
                } catch {
                    print(error)
                }
            } else {
                main{
                    appDelegate.hideActivityIndicator()
                }
                
                print("parentError: \(parentError)")
            }
        })
        recorder.session?.removeAllSegments()
        print(error)
        enableAllControls(true)
        refreshTorches()
    }
    
    func recorder(recorder: SCRecorder, didCompleteSession session: SCRecordSession) {
        print("complete")
    }
    
    func cropVideo(sourceURL1: NSURL, statTime:Float, endTime:Float)
    {
        let manager = NSFileManager.defaultManager()
        
        guard let documentDirectory = try? manager.URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true) else {return}
        guard let mediaType = "mp4" as? String else {return}
        guard let url = sourceURL1 as? NSURL else {return}
        
        if mediaType == kUTTypeMovie as String || mediaType == "mp4" as String {
            let asset = AVAsset(URL: url)
            let length = Float(asset.duration.value) / Float(asset.duration.timescale)
            print("video length: \(length) seconds")
            
            let start = statTime
            let end = endTime
            
            var outputURL = documentDirectory.URLByAppendingPathComponent("output")
            do {
                try manager.createDirectoryAtURL(outputURL, withIntermediateDirectories: true, attributes: nil)
                let name = Moment.newName()
                outputURL = outputURL.URLByAppendingPathComponent("\(name).mp4")
            }catch let error {
                print(error)
            }
            
            //Remove existing file
            _ = try? manager.removeItemAtURL(outputURL)
            
            
            guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {return}
            exportSession.outputURL = outputURL
            exportSession.outputFileType = AVFileTypeMPEG4
            
            let startTime = CMTime(seconds: Double(start ?? 0), preferredTimescale: 1000)
            let endTime = CMTime(seconds: Double(end ?? length), preferredTimescale: 1000)
            let timeRange = CMTimeRange(start: startTime, end: endTime)
            
            exportSession.timeRange = timeRange
            exportSession.exportAsynchronouslyWithCompletionHandler{
                switch exportSession.status {
                case .Completed:
                    print("exported at \(outputURL)")
                   self.saveVideoTimeline(outputURL)
                case .Failed:
                    print("failed \(exportSession.error)")
                    
                case .Cancelled:
                    print("cancelled \(exportSession.error)")
                    
                default: break
                }
            }
        }
    }
    
    func saveVideoTimeline(url:NSURL) {
        let name = Moment.newName()
        let newURL = Moment.documentURL(name, suffix: "mp4")
        do {
            try NSFileManager.defaultManager().moveItemAtURL(url, toURL: newURL)
            let asset = AVURLAsset(URL: newURL, options: nil)
            let seconds = Int(round(CMTimeGetSeconds(asset.duration)))
            let newMoment = Moment(persistent: true, pathName: name, remoteStreamURL: nil, remoteVideoURL: nil, remoteThumbURL: nil, size: nil, duration: seconds, contentType: nil, overlayPosition: nil, overlayText: nil, overlaySize: nil, overlayColor: nil, state: .LocalOnly, parent: nil)
            
            
            Storage.session.drafts.append(newMoment)
            Storage.save()
            self.drafts.addObject(newMoment)
            self.addImagesToScrollView()
            
            //  self.performSegueWithIdentifier("ShowMoments", sender: self)
            print("segued")
        } catch {
            print(error)
        }
    }
    //-------------------------
    /**
    Called when the flashMode has changed
    */
    func recorder(recorder: SCRecorder, didChangeFlashMode flashMode: SCFlashMode, error: NSError?) {
        refreshTorches()
    }
    /**
    Called when the recorder has initialized the audio in a session
    */
    func recorder(recorder: SCRecorder, didInitializeAudioInSession session: SCRecordSession, error: NSError?) {
        
    }
    
    /**
    Called when the recorder has initialized the video in a session
    */
    func recorder(recorder: SCRecorder, didInitializeVideoInSession session: SCRecordSession, error: NSError?) {
        refreshTorches()
    }
    
    func recorder(recorder: SCRecorder, didReconfigureVideoInput videoInputError: NSError?) {
        refreshTorches()
    }
    
}

extension CaptureMomentViewController: UITabBarControllerDelegate {
    
    func tabBarControllerSupportedInterfaceOrientations(tabBarController: UITabBarController) -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    func tabBarControllerPreferredInterfaceOrientationForPresentation(tabBarController: UITabBarController) -> UIInterfaceOrientation {
        return .Portrait
    }
    
}


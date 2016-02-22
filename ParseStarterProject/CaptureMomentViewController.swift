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

/// The central view controller.
/// Contains a capture view and controls for navigation.
class CaptureMomentViewController: UIViewController {
    
    var recorder: SCRecorder!
    var badgeTimer: NSTimer!
    var badgeTimerEnabled: Bool = true
    @IBOutlet var previewView: CameraPreviewView!
    @IBOutlet var recordButton: UIButton!
    @IBOutlet var torchOnButton: UIButton!
    @IBOutlet var torchOffButton: UIButton!
    @IBOutlet var countdownLabel: UILabel!
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        previewView.session = recorder.captureSession
        
        delay(0.001) {
            if !Storage.session.walkedThroughCamera {
                Storage.session.walkedThroughCamera = true
                self.performSegueWithIdentifier("WalkthroughCamera", sender: self)
            }
        }
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
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.notificationAPI ()
        recorder.startRunning()
        
        delay (0.01) {
            self.reloadBadges()
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.recorder.stopRunning()
        self.refreshTorches()
        self.reloadBadges()
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
        recorder.switchCaptureDevices()
        toggleTorch()
        refreshTorches()
    }
    
    @IBAction func startRecording(sender: AnyObject) {
        //AudioServicesPlaySystemSound(recordStartSoundID)
        badgeTimerEnabled = false
        // SOUND: startRecording.play()
        recorder.autoSetVideoOrientation = false
        
        self.countdown = 1
        self.countdownLabel.text = "1"
        
        UIView.animateWithDuration(0.2/* SOUND: startRecording.duration*/,animations: { () -> Void in
            self.menuControls.each { $0.alpha = 0.0 }
            self.countdownLabel.alpha = 1.0
            self.countdownLabel.hidden = false
            self.torchEnabled = false
            self.profileMenuBadge?.alpha = 0.0
            self.timelineMenuBadge?.alpha = 0.0
            self.notificationsMenuBadge?.alpha=0.0
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
        recorder.flashMode = .Off
        recorder.session?.mergeSegmentsUsingPreset(AVAssetExportPresetHighestQuality, completionHandler: { (url, parentError) -> Void in
            if let url = url {
                let name = Moment.newName()
                let newURL = Moment.documentURL(name, suffix: "mp4")
                do {
                    try NSFileManager.defaultManager().moveItemAtURL(url, toURL: newURL)
                    let asset = AVURLAsset(URL: newURL, options: nil)
                    let seconds = Int(round(CMTimeGetSeconds(asset.duration)))
                    Storage.session.drafts.append(Moment(persistent: true, pathName: name, remoteStreamURL: nil, remoteVideoURL: nil, remoteThumbURL: nil, size: nil, duration: seconds, contentType: nil, overlayPosition: nil, overlayText: nil, overlaySize: nil, overlayColor: nil, state: .LocalOnly, parent: nil))
                    Storage.save()
                    
                    self.performSegueWithIdentifier("ShowMoments", sender: self)
                    print("segued")
                } catch {
                    print(error)
                }
            } else {
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


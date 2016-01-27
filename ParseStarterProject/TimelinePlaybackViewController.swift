//
//  TimelinePlaybackViewController.swift
//  Timeline
//
//  Created by Valentin Knabel on 04.09.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import UIKit

class TimelinePlaybackViewController: UIViewController {

    var timeline: Timeline!
    var moment: Moment? {
        didSet {
            timeline = moment?.parent
        }
    }
    
    @IBOutlet var draftPreviewView: DraftPreviewView!
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet var foreignButtons: [UIButton]!
    @IBOutlet var foreignLayoutConstraint: NSLayoutConstraint!
    @IBOutlet var heartButton: UIButton!
    @IBOutlet var followButton: UIButton!
    @IBOutlet var deleteOrFlagButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        refresh()
        
        // Do any additional setup after loading the view.
        draftPreviewView.draftPreview.setTimeline(timeline)
        if let m = moment {
            draftPreviewView.draftPreview.setCurrentMoment(m)
        }
        draftPreviewView.draftPreview.playMoment()
        
        timeline.hasNews = false
    }
    
    func refresh() {
        main {
        self.buttons.each { $0.imageView!.contentMode = .ScaleAspectFit }
        self.foreignButtons.each { $0.hidden = self.timeline.parent?.uuid == Storage.session.currentUser?.uuid }
        self.foreignLayoutConstraint.constant = self.timeline.parent?.uuid == Storage.session.currentUser?.uuid ? -(self.heartButton.frame.size.width + self.followButton.frame.size.width) : self.foreignLayoutConstraint.constant
        
        self.heartButton.setImage(UIImage(assetIdentifier: self.timeline.liked ? UIImage.AssetIdentifier.Unheart : UIImage.AssetIdentifier.Heart), forState: UIControlState.Normal)
        self.followButton.setImage(UIImage(assetIdentifier: self.timeline.followed == .NotFollowing ? UIImage.AssetIdentifier.FollowTimeline : UIImage.AssetIdentifier.UnfollowTimeline), forState: UIControlState.Normal)
            self.deleteOrFlagButton.setImage(UIImage(assetIdentifier: self.timeline.parent?.uuid == Storage.session.currentUser?.uuid ? UIImage.AssetIdentifier.Delete : (self.timeline.blocked ? UIImage.AssetIdentifier.Unreport : UIImage.AssetIdentifier.Report)), forState: UIControlState.Normal)
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func viewWillDisappear(animated: Bool) {
        draftPreviewView.draftPreview.pause()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismiss() {
        self.dismissViewControllerWithAnimation(self)
    }
    
    @IBAction func share() {
        let urlString = lformat(LocalizedString.TimelineStringShareURL2s, args: timeline?.parent?.name ?? "", timeline?.name ?? "")
        let messageString = lformat(LocalizedString.TimelineStringShareMessage2s, args: timeline?.parent?.name ?? "", timeline?.name ?? "")
        let activities = [messageString, NSURL(string: urlString)!]
        let controller = UIActivityViewController(activityItems: activities, applicationActivities: nil)
        self.presentActivityViewController(controller)
    }
    
    @IBAction func toggleLike() {
        if timeline.liked {
            timeline?.unlike(self.refresh)
            self.refresh()
        } else {
            timeline?.like(self.refresh)
            self.refresh()
        }
    }
    
    @IBAction func toggleFollow() {
        if timeline.followed == .NotFollowing {
            timeline?.follow(self.refresh)
            self.refresh()
        } else {
            timeline?.unfollow(self.refresh)
            self.refresh()
        }
    }
    
    @IBAction func deleteOrFlag() {
        if timeline.parent?.uuid == Storage.session.currentUser?.uuid {
            
            func performDelete(action: UIAlertAction!) {
                
                let alert = UIAlertController(title: local(.TimelineAlertDeleteWaitTitle), message: local(.TimelineAlertDeleteWaitMessage), preferredStyle: .Alert)
                self.presentAlertController(alert)
                
                // Delete the row from the data source
                let del = timeline
                Storage.performRequest(ApiRequest.DestroyTimeline(del.state.uuid!), completion: { (json) -> Void in
                    alert.dismissViewControllerAnimated(true) {
                        if let error = json["error"] as? String {
                            let alert = UIAlertController(title: local(.TimelineAlertDeleteErrorTitle), message: error, preferredStyle: .Alert)
                            alert.addAction(UIAlertAction(title: local(.TimelineAlertDeleteErrorActionDismiss), style: .Default, handler: nil))
                            self.presentAlertController(alert)
                            return
                        }
                        
                        for i in 0..<(Storage.session.currentUser?.timelines.count ?? 0) {
                            let t = Storage.session.currentUser!.timelines[i]
                            if del.state.uuid == t.state.uuid {
                                Storage.session.currentUser!.timelines.removeAtIndex(i)
                                break
                            }
                        }
                        async {
                            for m in del.moments {
                                if let url = m.localVideoURL {
                                    do {
                                        try NSFileManager.defaultManager().removeItemAtURL(url)
                                    } catch _ {
                                    }
                                }
                            }
                        }
                        
                        delay(0.1) {
                            self.dismissViewControllerAnimated(true, completion: nil)
                        }
                    }
                })
            }
            let confirmation = UIAlertController(title: local(.TimelineAlertDeleteConfirmTitle), message: local(.TimelineAlertDeleteConfirmMessage), preferredStyle: .Alert)
            confirmation.addAction(UIAlertAction(title: local(.TimelineAlertDeleteConfirmActionDelete), style: .Destructive, handler: performDelete))
            confirmation.addAction(UIAlertAction(title: local(.TimelineAlertDeleteConfirmActionCancel), style: .Cancel, handler: { _ in
            }))
            presentAlertController(confirmation)
            
        } else {
            let alert = UIAlertController(
                title: local(!self.timeline!.blocked ? LocalizedString.TimelineAlertBlockTitle : LocalizedString.TimelineAlertUnblockTitle),
                message: lformat(!self.timeline!.blocked ? LocalizedString.TimelineAlertBlockMessage1s : LocalizedString.TimelineAlertUnblockMessage1s, args: timeline?.name ?? ""),
                preferredStyle: .Alert
            )
            alert.addAction(UIAlertAction(
                title: local(!self.timeline!.blocked ? LocalizedString.TimelineAlertBlockActionCancel : LocalizedString.TimelineAlertUnblockActionCancel),
                style: .Cancel,
                handler: nil
                ))
            alert.addAction(UIAlertAction(
                title: local(!self.timeline!.blocked ? LocalizedString.TimelineAlertBlockActionBlock : LocalizedString.TimelineAlertUnblockActionUnblock),
                style: .Destructive,
                handler: { (_) -> Void in
                    (self.timeline!.blocked ? self.timeline!.unblock : self.timeline!.block) {
                        self.refresh()
                    }
                    self.refresh()
            }))
            self.presentAlertController(alert)
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

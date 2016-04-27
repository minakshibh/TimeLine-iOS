//
//  ModernTimelineBehavior.swift
//  Timeline
//
//  Created by Valentin Knabel on 17.11.15.
//  Copyright © 2015 Conclurer GbR. All rights reserved.
//

import Foundation
import ConclurerHook


extension HookKey {
    static var StopAllPlaybacks: HookKey<String, Void, Void> {
        return HookKey<String, Void, Void>(rawValue: "ModernTimelineBehavior.StopAllPlayback")
    }
    static var PlaybackStarted: HookKey<String, (ModernTimelineBehavior, Moment), Void> {
        return HookKey<String, (ModernTimelineBehavior, Moment), Void>(rawValue: "ModernTimelineBehavior.PlaybackStarted")
    }
    static var PlaybackStopped: HookKey<String, ModernTimelineBehavior, Void> {
        return HookKey<String, ModernTimelineBehavior, Void>(rawValue: "ModernTimelineBehavior.PlaybackStopped")
    }
}

class ModernTimelineBehavior {

    var callbacks: [AnyObject?] = []
    init() {
        self.callbacks.append(serialHook.add(key: .PlaybackStarted) { behavior, moment in
            if case .Playing = self.state where self !== behavior {
                print("Stop: \(self.timeline?.name)")
                self.stopPlayback(animated: true)
            }
        })
        self.callbacks.append(serialHook.add(key: .StopAllPlaybacks) {
            if case .Playing = self.state {
                self.stopPlayback(animated: true)
            }
        })
    }

    weak var modernTimelineView: ModernTimelineView?

    private var viewingRights: TimelineViewingRight = .NotPublic("")
    var timeline: Timeline? {
        didSet {
            main { self.refresh() }
        }
    }

    enum PlaybackState {
        case Preview
        case Playing
    }
    var state: PlaybackState = .Preview
    var centerConstraints: [NSLayoutConstraint] = []

    func refresh() {
        stopPlayback(animated: false)
        viewingRights = TimelineViewingRight(timeline: timeline)

        if timeline?.hasNews ?? false {
            modernTimelineView?.newsBadge?.removeFromSuperview()
            modernTimelineView?.newsBadge = nil

            let title = "!"
            modernTimelineView?.newsBadge = CustomBadge(string: title, withScale: 1.2, withStyle: BadgeStyle.defaultStyle())
            let anchor = modernTimelineView!.lastMomentPreviews.last!
            modernTimelineView?.newsBadge?.center = CGPoint(x: anchor.frame.origin.x + anchor.frame.width, y: anchor.frame.origin.y)
            anchor.superview?.addSubview(modernTimelineView!.newsBadge!)
            modernTimelineView?.newsBadge?.autoBadgeSizeWithString(title)
        } else {
            modernTimelineView?.newsBadge?.removeFromSuperview()
            modernTimelineView?.newsBadge = nil
        }

        if case .Viewable = viewingRights {
            modernTimelineView?.firstMomentPreview.moment = timeline?.moments.first

            guard let all = timeline?.moments
                where all.count > 1
                else {
                    for prev in modernTimelineView?.lastMomentPreviews ?? [] {
                        prev.moment = nil
                    }
                    return
            }

            var latest = all
            for prev in modernTimelineView?.lastMomentPreviews.reverse() ?? []{
                prev.moment = latest.popLast()
            }

            return
        }

        let message: String
        switch viewingRights {
        case .NotPublic(let userName):
            message = lformat(LocalizedString.TimelineAlertNotPublicMessage1s, userName)
        case let .BlockedUser(userName, timelineName):
            message = lformat(LocalizedString.TimelineAlertBlockedUserMessage2s, args: userName, timelineName)
        case let .BlockedTimeline(userName, timelineName):
            message = lformat(LocalizedString.TimelineAlertBlockedTimelineMessage2s, args: userName, timelineName)
        default:
            assertionFailure("Invalid viewing rights")
            message = "Unknown error."
        }
        print(message)
    }
}

extension ModernTimelineBehavior {

    func playMoment(target: UIView, moment: Moment) {
        defer {
            state = .Playing
            serialHook.perform(key: .PlaybackStarted, argument: (self, moment))
        }
        guard let playerView = modernTimelineView?.playerView else { return }

        timeline?.hasNews = false
        modernTimelineView?.newsBadge?.removeFromSuperview()
        modernTimelineView?.newsBadge = nil
        playerView.superview?.removeConstraints(self.centerConstraints)

        for v in self.modernTimelineView?.playbackItems ?? [] {
            v.hidden = false
            v.alpha = 0.0
        }
        /*centerConstraints = [
            NSLayoutConstraint(item: playerView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: target, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: playerView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: target, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: playerView, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: target, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: playerView, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: target, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: 0.0)
        ]*/
        self.centerConstraints = [
            NSLayoutConstraint(item: playerView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: playerView.superview, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: -0),
            NSLayoutConstraint(item: playerView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: playerView.superview, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: -0),
            NSLayoutConstraint(item: playerView, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: playerView.superview, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: -0),
            NSLayoutConstraint(item: playerView, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: playerView.superview, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: -0)
        ]
        playerView.superview?.addConstraints(centerConstraints)
        playerView.superview?.sendSubviewToBack(playerView)
        playerView.superview?.layoutIfNeeded()
        playerView.draftPreview.setTimeline(moment.parent)
        playerView.draftPreview.setCurrentMoment(moment)
        


        UIView.animateWithDuration(0.01, animations: {
            /*playerView.superview?.removeConstraints(self.centerConstraints)

            self.centerConstraints = [
                NSLayoutConstraint(item: playerView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: playerView.superview, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: -0),
                NSLayoutConstraint(item: playerView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: playerView.superview, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: -0),
                NSLayoutConstraint(item: playerView, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: playerView.superview, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: -0),
                NSLayoutConstraint(item: playerView, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: playerView.superview, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: -0)
            ]
            playerView.superview?.addConstraints(self.centerConstraints)*/

            for v in self.modernTimelineView?.previewItems ?? [] {
                v.alpha = 0.0
            }
            for v in self.modernTimelineView?.playbackItems ?? [] {
                v.alpha = 1.0
            }
            playerView.superview?.layoutIfNeeded()
        })
            { bool in
                for v in self.modernTimelineView?.previewItems ?? [] {
                    v.userInteractionEnabled = false
                }
                for v in self.modernTimelineView?.playbackItems ?? [] {
                    v.userInteractionEnabled = true
                }
                playerView.draftPreview.playMoment()
        }
    }

    func stopPlayback(animated animated: Bool) {
        defer {
            state = .Preview
            serialHook.perform(key: .PlaybackStopped, argument: self)
        }
        guard let playerView = modernTimelineView?.playerView else { return }

        for v in self.modernTimelineView?.previewItems ?? [] {
            
            v.userInteractionEnabled = true
        }
        UIView.animateWithDuration(animated ? 0.01 : 0.0, animations: {
            for v in self.modernTimelineView?.previewItems ?? [] {
                v.alpha = 1.0
            }
            for v in self.modernTimelineView?.playbackItems ?? [] {
                v.alpha = 0.0
            }
        },
        completion: { bool in
            playerView.superview?.removeConstraints(self.centerConstraints)
            self.centerConstraints = []
            main{
            self.modernTimelineView?.playerView.draftPreview.stop()
            }
            for v in self.modernTimelineView?.playbackItems ?? [] {
                self.modernTimelineView?.momentScroller.hidden = false
                self.modernTimelineView?.seperatorLineView.hidden = false
                v.hidden = true
            }
        })
    }
    
    func tappedItem(sender: UITapGestureRecognizer) {
        //print(sender.view)
        guard let target = sender.view,
            let tlview = modernTimelineView
            else { return }

        let moment: Moment?
        if let preview = tlview.firstMomentPreview where target == preview {
            moment = preview.moment
        } else {
            moment = tlview.lastMomentPreviews.filter { $0 == target }.first?.moment
        }
        guard let m = moment else {
            self.modernTimelineView?.momentScroller.hidden = false
            let alert = UIAlertView()
            alert.title = ""
            alert.message = "Sorry, this timeline has no moments. Follow to get updates or check back later."
            alert.addButtonWithTitle(local(.MomentAlertUploadErrorActionDismiss))
            alert.show()
            
            return
        }
        main{
            self.playMoment(target, moment: m)
        }
    }

}

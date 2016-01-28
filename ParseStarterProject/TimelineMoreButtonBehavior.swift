//
//  TimelineMoreButtonBehavior.swift
//  Timeline
//
//  Created by Valentin Knabel on 08.12.15.
//  Copyright © 2015 Conclurer GbR. All rights reserved.
//

import UIKit
import ConclurerHook

extension HookKey {
    static var TimelineMoreButtonTapped: HookKey<String, Timeline, Void> {
        return HookKey<String, Timeline, Void>(rawValue: "ModernTimelineView.TimelineMoreButtonTapped")
    }
}

protocol TimelineMoreButtonBehavior: Hooking { }

extension TimelineMoreButtonBehavior where Self: UIViewController, Self: Reloadable, Self: PushableBehavior, Self: ShareableBehavior, Self: DeleteableBehavior, Self: BlockableBehavior {

    func setUpTimelineMoreWithoutUserButtonButtonBehavior() -> AnyObject? {
        return serialHook.add(key: .TimelineMoreButtonTapped, closure: triggerMoreButtonWithoutUserButtonBehavior)
    }
    
    func setUpTimelineMoreButtonBehavior() -> AnyObject? {
        return serialHook.add(key: .TimelineMoreButtonTapped, closure: triggerMoreButtonBehavior)
    }
    
    func triggerMoreButtonWithoutUserButtonBehavior(timeline: Timeline) {
        let sheet = UIAlertController(title: lformat(.TimelineSheetMoreButtonTitle1s, timeline.name), message: local(.TimelineSheetMoreButtonMessage), preferredStyle: .ActionSheet)
        sheet.addAction(title: local(.TimelineSheetMoreButtonCancel), style: .Cancel, handler: nil)
        
        sheet.addAction(title: local(.TimelineSheetMoreButtonShare), style: .Default, handler: performShareableBehaviorAction(timeline))
        
//        if let user = timeline.parent {
//            sheet.addAction(title: lformat(LocalizedString.TimelineSheetMoreButtonUser1s, user.name), style: .Default, handler: performPushableBehaviorAction(user))
//        }
        
        sheet.addAction(title: local(.TimelineSheetMoreButtonFollowers), style: .Default) { _ in
            self.performSegueWithIdentifier("ShowUserList", sender: FollowableValue(followable: timeline))
        }
        sheet.addAction(title: local(.TimelineSheetMoreButtonLikers), style: .Default) { _ in
            self.performSegueWithIdentifier("ShowUserList", sender: LikeableValue(likeable: timeline))
        }
        
        if timeline.isOwn {
            sheet.addAction(title: local(.TimelineSheetMoreButtonAdd), style: .Default, handler: addMoment(timeline))
            sheet.addAction(title: local(timeline.persistent ? .TimelineSheetMoreButtonNoDownload: .TimelineSheetMoreButtonDownload), style: .Default, handler: toggleTimelinePersistence(timeline))
            
            sheet.addAction(title: local(.TimelineSheetMoreButtonDelete), style: .Destructive, handler: confirmDeleteableBehavior(timeline))
        } else {
            sheet.addAction(title: local(timeline.blocked ? .TimelineSheetMoreButtonUnblock: .TimelineSheetMoreButtonBlock), style: .Destructive, handler: confirmBlockableBehavior(timeline))
        }
        self.presentAlertController(sheet)
    }
    
    func triggerMoreButtonBehavior(timeline: Timeline) {
        let sheet = UIAlertController(title: lformat(.TimelineSheetMoreButtonTitle1s, timeline.name), message: local(.TimelineSheetMoreButtonMessage), preferredStyle: .ActionSheet)
        sheet.addAction(title: local(.TimelineSheetMoreButtonCancel), style: .Cancel, handler: nil)

        sheet.addAction(title: local(.TimelineSheetMoreButtonShare), style: .Default, handler: performShareableBehaviorAction(timeline))
        
        if let user = timeline.parent {
            sheet.addAction(title: lformat(LocalizedString.TimelineSheetMoreButtonUser1s, user.name), style: .Default, handler: performPushableBehaviorAction(user))
        }

        sheet.addAction(title: local(.TimelineSheetMoreButtonFollowers), style: .Default) { _ in
            self.performSegueWithIdentifier("ShowUserList", sender: FollowableValue(followable: timeline))
        }
        sheet.addAction(title: local(.TimelineSheetMoreButtonLikers), style: .Default) { _ in
            self.performSegueWithIdentifier("ShowUserList", sender: LikeableValue(likeable: timeline))
        }

        if timeline.isOwn {
            sheet.addAction(title: local(.TimelineSheetMoreButtonAdd), style: .Default, handler: addMoment(timeline))
            sheet.addAction(title: local(timeline.persistent ? .TimelineSheetMoreButtonNoDownload: .TimelineSheetMoreButtonDownload), style: .Default, handler: toggleTimelinePersistence(timeline))

            sheet.addAction(title: local(.TimelineSheetMoreButtonDelete), style: .Destructive, handler: confirmDeleteableBehavior(timeline))
        } else {
            sheet.addAction(title: local(timeline.blocked ? .TimelineSheetMoreButtonUnblock: .TimelineSheetMoreButtonBlock), style: .Destructive, handler: confirmBlockableBehavior(timeline))
        }
        self.presentAlertController(sheet)
    }

    // TODO: decouple this method
    func addMoment(timeline: Timeline)(action: UIAlertAction) {
        performSegueWithIdentifier("TimelineCreated", sender: timeline)
    }

    func toggleTimelinePersistence(timeline: Timeline)(action: UIAlertAction) {
        guard timeline.isOwn else { return }
        guard !timeline.persistent else {
            timeline.removeDownload { }
            return
        }
        let alert = UIAlertController(
            title: local(LocalizedString.TimelineAlertDownloadInfoTitle),
            message: lformat(LocalizedString.TimelineAlertDownloadInfoMessage1s, timeline.name ?? ""),
            preferredStyle: .Alert
        )
        alert.addAction(
            title: local(LocalizedString.TimelineAlertDownloadInfoActionDismiss),
            style: .Cancel,
            handler: nil
            )
        alert.addAction(
            title: local(LocalizedString.TimelineAlertDownloadInfoActionDownload),
            style: .Default,
            handler: { (_) -> Void in
                timeline.download { }
        })
        presentAlertController(alert)

    }

}

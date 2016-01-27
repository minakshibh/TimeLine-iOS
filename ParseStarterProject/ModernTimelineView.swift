//
//  ModernTimelineView.swift
//  Timeline
//
//  Created by Valentin Knabel on 17.11.15.
//  Copyright © 2015 Conclurer GbR. All rights reserved.
//

import UIKit
import SWFrameButton
import ConclurerHook

class ModernTimelineView: UIView {

    lazy var behavior: ModernTimelineBehavior = {
        let behavior = ModernTimelineBehavior()
        behavior.modernTimelineView = self
        return behavior
        }()

    var timeline: Timeline? {
        get {
            return behavior.timeline
        }
        set {
            behavior.timeline = newValue
            refresh()
        }
    }

    @IBOutlet var firstMomentPreview: MomentImageView!
    @IBOutlet var lastMomentPreviews: [MomentImageView] = []
    @IBOutlet var previewItems: [UIView] = []
    @IBOutlet var playbackItems: [UIView] = []
    @IBOutlet var playerView: DraftPreviewView!
    var newsBadge: CustomBadge?

    @IBAction func tappedItem(sender: UITapGestureRecognizer) {
        behavior.tappedItem(sender)
    }

    @IBAction func moreButtonTapped() {
        guard let tl: Timeline = timeline else { return }
        serialHook.perform(key: .TimelineMoreButtonTapped, argument: tl)
    }

    // MARK: -
    // MARK: NamedBehavior:
    @IBOutlet var nameLabel: UILabel!

    // MARK: LikeableBehavior:
    @IBOutlet var likeButton: SWFrameButton!

    // MARK: FollowableBehavior:
    @IBOutlet var followButton: SWFrameButton!

    // MARK: DurationalBehavior:
    @IBOutlet var durationLabel: UILabel!

}

extension ModernTimelineView: Refreshable {
    var refreshers: [() -> ()] {
        return [refreshDurationalBehavior, refreshNamedBehavior, refreshFollowableBehavior, refreshLikeableBehavior]
    }
}

extension ModernTimelineView: DurationalBehavior, NamedBehavior { }

extension ModernTimelineView: FollowableBehavior, LikeableBehavior {
    typealias TargetBehaviorType = Timeline
    
    var behaviorTarget: TargetBehaviorType? {
        return timeline
    }

    @IBAction func followButtonTapped() {
        toggleFollowState()
    }

    @IBAction func likeButtonTapped() {
        toggleLiked()
    }
}

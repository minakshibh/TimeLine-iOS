//
//  UserSummaryTableViewCell.swift
//  Timeline
//
//  Created by Valentin Knabel on 10.12.15.
//  Copyright © 2015 Conclurer GbR. All rights reserved.
//

import UIKit
import SWFrameButton

class UserSummaryTableViewCell: UITableViewCell {

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var profileImageView: ProfileImageView!
    @IBOutlet var likeButton: SWFrameButton!
    @IBOutlet var followButton: SWFrameButton!
    @IBOutlet var approveButton: SWFrameButton!
    @IBOutlet var approveConstraint: NSLayoutConstraint!
    var hidesApproveButton: Bool = true

    var user: User? {
        didSet {
            profileImageView.user = user
            refresh()
        }
    }

    var refreshers: [() -> ()] {
        return [refreshLikeableBehavior, refreshFollowableBehavior, refreshApproveableBehavior, refreshNamedBehavior]
    }
}

extension UserSummaryTableViewCell: Refreshable, LikeableBehavior, FollowableBehavior, ApproveableBehavior, NamedBehavior {

    typealias TargetBehaviorType = User
    var behaviorTarget: TargetBehaviorType? {
        return user
    }

    @IBAction func tappedLikeButton() {
        toggleLiked()
    }
    @IBAction func tappedFollowButton() {
        toggleFollowState()
    }
    @IBAction func tappedApproveButton() {
        triggerApproveableBehavior()
    }
    @IBAction func tappedMoreButton() {
        guard let user = user else { return }
        serialHook.perform(key: .UserMoreButtonTapped, argument: user)
    }
}

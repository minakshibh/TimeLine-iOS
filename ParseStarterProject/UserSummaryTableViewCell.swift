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

    @IBOutlet var imageheart: UIImageView!
    @IBOutlet var imagePerson: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var nameLabel1: UILabel!
    @IBOutlet var lblBio: UILabel!
    @IBOutlet var lblOthers: UILabel!
    @IBOutlet var btnWebsite: SWFrameButton!

    @IBOutlet var profileImageView: ProfileImageView!
    @IBOutlet var likeButton: SWFrameButton!
    @IBOutlet var likeTimelineButton: UIButton!
    @IBOutlet var followTimelineButton: UIButton!

    @IBOutlet var updatedFollowButton: SWFrameButton!
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
        return [refreshLikeableBehavior, refreshFollowableBehavior, refreshApproveableBehavior, refreshNamedBehavior ,refreshFirstLastName, refreshLikeableBehavior2, refreshwebsiteButtonClick, refreshLikeableBehaviorCount, refreshFollowableBehaviorCount]
    }
}

extension UserSummaryTableViewCell: Refreshable, LikeableBehavior, FollowableBehavior, ApproveableBehavior, NamedBehavior ,FirstLastName, LikeableBehavior2 , websiteButtonClick, LikeableBehaviorCount, FollowableBehaviorCount {

    typealias TargetBehaviorType = User
    var behaviorTarget: TargetBehaviorType? {
        return user
    }

    @IBAction func tappedLikeButton() {
        toggleLiked()
    }
    
     @IBAction func toggleLikeForHeart() {
        toggleLikeForHeartOther()
        }
    
    @IBAction func updatedFollowBtn(){
        toggleLiked2()
    }
    
    @IBAction func tappedFollowButton() {
        toggleFollowState()
    }
    @IBAction func toggleFollowForUser() {
        toggleFollowUser()
    }
    @IBAction func tappedApproveButton() {
              triggerApproveableBehavior()
    }
    @IBAction func tappedMoreButton() {
        guard let user = user else { return }
        serialHook.perform(key: .UserMoreButtonTapped, argument: user)
    }
    @IBAction func btnWebsiteAction() {
        websiteButtonClickAction()
    }
}

//
//  LikeableBehavior.swift
//  Timeline
//
//  Created by Valentin Knabel on 07.12.15.
//  Copyright © 2015 Conclurer GbR. All rights reserved.
//

import SWFrameButton

protocol LikeableBehavior {
    typealias TargetBehaviorType: Likeable
    var behaviorTarget: TargetBehaviorType? { get }
    var likeButton: SWFrameButton! { get }
}

private extension UIColor {
    static var likeableTintColor: UIColor! {
        return UIColor.from(hexString: "FF502C")
    }
}

extension LikeableBehavior where TargetBehaviorType: Ownable {

    func refreshLikeableBehavior() {
        likeButton.cornerRadius =!= 7
//        likeButton.tintColor =!= .likeableTintColor
        likeButton.normalImage =!= UIImage(assetIdentifier: .LikeableButton)
        likeButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 3, bottom: 0, right: 0)

        likeButton.setNeedsLayout()

        if let behaviorTarget = behaviorTarget {
            likeButton.setTitle("\(behaviorTarget.likesCount)", forState: .Normal)
            likeButton.selected =!= behaviorTarget.liked
            likeButton.enabled =!= true
            print("\(behaviorTarget.likesCount)-----\(behaviorTarget.isOwn)")
//            likeButton.borderWidth =!= behaviorTarget.isOwn ? 0 : 1.5
            //           
            
            likeButton.borderWidth =!= 0
//            likeButton.tintColor =!= behaviorTarget.isOwn ? UIColor.blackColor() : .likeableTintColor
            likeButton.tintColor =!=  UIColor.blackColor()
        } else {
            likeButton.enabled =!= false
            likeButton.selected =!= false
            likeButton.normalTitle =!= "0"
//            likeButton.borderWidth =!= 1.5

            likeButton.borderWidth =!= 0
}
    }

    func toggleLiked() {
        if let target = behaviorTarget where !target.isOwn {
        target.toggleLiked {
            self.refreshLikeableBehavior()
        }
            refreshLikeableBehavior()
        } else if let likeable = behaviorTarget as? Likeable {
            guard let controller = activeController() else { return }
            controller.performSegueWithIdentifier("ShowUserList", sender: LikeableValue(likeable: likeable))
        }
    }
    
}

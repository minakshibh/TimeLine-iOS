//
//  LikeableBehavior.swift
//  Timeline
//
//  Created by Valentin Knabel on 07.12.15.
//  Copyright © 2015 Conclurer GbR. All rights reserved.
//

import SWFrameButton

protocol LikeableBehavior2 {
    typealias TargetBehaviorType: Likeable
    var behaviorTarget: TargetBehaviorType? { get }
    var likeButton1: SWFrameButton! { get }
}

private extension UIColor {
    static var likeableTintColor: UIColor! {
        return UIColor.from(hexString: "0A256C")
    }
}

extension LikeableBehavior2 where TargetBehaviorType: Ownable {

    func refreshLikeableBehavior2() {
//        likeButton1.cornerRadius =!= 7
//        likeButton.tintColor =!= .likeableTintColor
        likeButton1.normalImage =!= UIImage(assetIdentifier: .likeImage)
//        likeButton1.titleEdgeInsets = UIEdgeInsets(top: 0, left: 3, bottom: 0, right: 0)

//        likeButton1.setNeedsLayout()

        if let behaviorTarget = behaviorTarget {
//            likeButton1.setTitle("\(behaviorTarget.likesCount)", forState: .Normal)
           // print("****\(behaviorTarget.liked) 0-----\(behaviorTarget.isOwn)")
//            likeButton1.selected =!= behaviorTarget.liked
            likeButton1.enabled =!= true
            likeButton1.selected = false
            likeButton1.borderWidth = 0
//            likeButton1.borderWidth =!= behaviorTarget.isOwn ? 0 : 1.5
//            likeButton1.tintColor =!= behaviorTarget.isOwn ? UIColor.blackColor() : .likeableTintColor
            likeButton1.normalImage =!= behaviorTarget.liked ? UIImage(named: "dislikeImage") : UIImage(named: "likeImage")
        } else {
            likeButton1.enabled =!= false
            likeButton1.selected =!= false
            likeButton1.normalTitle =!= "0"
//            likeButton1.borderWidth =!= 1.5
        }
    }

    func toggleLiked2() {
        if let target = behaviorTarget where !target.isOwn {
        target.toggleLiked {
            
            self.refreshLikeableBehavior2()
        }
            refreshLikeableBehavior2()
        } else if let likeable = behaviorTarget as? Likeable {
            guard let controller = activeController() else { return }
            controller.performSegueWithIdentifier("ShowUserList", sender: LikeableValue(likeable: likeable))
        }
    }
    
}

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
    var likeTimelineButton: UIButton! { get }
//    var imageheart: UIImageView! { get }
}

private extension UIColor {
    static var likeableTintColor: UIColor! {
        return UIColor.from(hexString: "FF502C")
    }
}

extension LikeableBehavior where TargetBehaviorType: Ownable {

    func refreshLikeableBehavior() {
        likeButton.cornerRadius =!= 7
        likeButton.normalImage =!= UIImage(assetIdentifier: .LikeableButton)
        likeButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 3, bottom: 0, right: 0)

        likeButton.setNeedsLayout()

        if let behaviorTarget = behaviorTarget {
            likeButton.setTitle("\(behaviorTarget.likesCount)", forState: .Normal)
            likeButton.borderWidth =!= 0
            likeButton.tintColor =!=  UIColor.blackColor()
            
            if (likeTimelineButton != nil)
            {
                likeTimelineButton.hidden =!= behaviorTarget.isOwn ? true : false
                likeTimelineButton.selected =!= behaviorTarget.liked
                likeTimelineButton.enabled =!= true
                likeTimelineButton.tintColor =!=  UIColor.redNavbarColor()
                if(behaviorTarget.liked){
                    likeTimelineButton.titleLabel?.textColor = UIColor.redNavbarColor()
                    likeTimelineButton.setTitle("Unlike", forState: .Normal)
                    
                }else{
                    likeTimelineButton.setTitle("Like", forState: .Normal)
                    likeTimelineButton.titleLabel?.textColor = UIColor.groupTableViewBackgroundColor()
                }
                likeTimelineButton.normalImage =!= behaviorTarget.liked ? UIImage(assetIdentifier: .RedHeart) : UIImage(assetIdentifier: .whiteHeart)
            }
        } else {
            likeButton.enabled =!= false
            likeButton.selected =!= false
            likeButton.normalTitle =!= "0"
            likeButton.borderWidth =!= 0
            if (likeTimelineButton != nil)
            {
                likeTimelineButton.selected =!= false
                likeTimelineButton.enabled =!= false
            }
        }
    }

    func toggleLiked() {
         if let target = behaviorTarget where !target.isOwn {
            if let likeable = behaviorTarget as? Likeable {
                guard let controller = activeController() else { return }
                controller.performSegueWithIdentifier("ShowUserList", sender: LikeableValue(likeable: likeable))
                return
            }
        }
        
        if let target = behaviorTarget where !target.isOwn {
        target.toggleLiked {
            self.refreshLikeableBehavior()
        }
            refreshLikeableBehavior()
        }
        else if let likeable = behaviorTarget as? Likeable {
            guard let controller = activeController() else { return }
            controller.performSegueWithIdentifier("ShowUserList", sender: LikeableValue(likeable: likeable))
        }
    }
    
    func toggleLikeForHeartOther() {
        if let target = behaviorTarget where !target.isOwn {
            target.toggleLiked {
                self.refreshLikeableBehavior()
            }
            refreshLikeableBehavior()
        }
    }
    
    func toggledLiked() {
        if let target = behaviorTarget where !target.isOwn {
            target.toggleLiked {
                self.refreshLikeableBehavior()
            }
            refreshLikeableBehavior()
        }
    }
    func showLikes() {
        if let likeable = behaviorTarget as? Likeable {
            guard let controller = activeController() else { return }
            controller.performSegueWithIdentifier("ShowUserList", sender: LikeableValue(likeable: likeable))
        }
    }
}

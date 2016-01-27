//
//  TimelineView.swift
//  Timeline
//
//  Created by Valentin Knabel on 14.08.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import UIKit

class TimelineView: UIView {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var followerLabel: UILabel!
    @IBOutlet var likeLabel: UILabel!
    @IBOutlet var elementCount: UILabel!
    @IBOutlet var momentImageViews: [MomentImageView]!
    var newsBadge: CustomBadge?

    var timeline: Timeline? {
        didSet {
            main { [weak self] in self?.refresh() }
        }
    }
    
    func refresh() {
        let t = timeline
        let momCount = t?.moments.count ?? 0
        let moms = t?.moments
        
        titleLabel.text = "#" + (t?.name ?? "")
        followerLabel.text = t?.followersCount.description ?? "0"
        likeLabel.text = t?.likesCount.description ?? "0"
        elementCount.text = lformat(LocalizedString.DurationFormatLimitedSeconds1d, t?.duration ?? 0) //t?.moments.count.description ?? "0"

        for i in 0..<momentImageViews.count {
            let miv = momentImageViews[i]
            if i >= momCount {
                miv.moment = nil
            } else {
                let m = moms?[i]
                miv.moment = m
            }
        }
        
        if timeline?.hasNews ?? false {
            newsBadge?.removeFromSuperview()
            newsBadge = nil
            
            let title = "!"
            newsBadge = CustomBadge(string: title, withScale: 1.2, withStyle: BadgeStyle.defaultStyle())
            let anchor = momentImageViews.last!.superview!
            newsBadge?.center = CGPoint(x: anchor.frame.origin.x + anchor.frame.width, y: anchor.frame.origin.y)
            anchor.superview?.addSubview(newsBadge!)
            newsBadge?.autoBadgeSizeWithString(title)
        } else {
            newsBadge?.removeFromSuperview()
            newsBadge = nil
        }
    }
    
}

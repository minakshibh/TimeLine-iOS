//
//  TimelineTableHeaderView.swift
//  Timeline
//
//  Created by Valentin Knabel on 31.07.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import UIKit

class TimelineTableHeaderView: UIView {

    static var Height: CGFloat = 58
    
    @IBOutlet var imageView: ProfileImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var followerLabel: UILabel!
    @IBOutlet var likeLabel: UILabel!
    @IBOutlet var fullNameLabel: UILabel!
    
    var user: User? {
        didSet {
            refresh()
        }
    }
    
    func refresh() {
        let empty = ""
        likeLabel.text = "\(user?.likesCount ?? 0)"
        titleLabel.text = "@\(user?.name ?? empty)"
        followerLabel.text = "\(user?.followersCount ?? 0)"
        imageView.user = user
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}

import ConclurerHook
extension TimelineTableHeaderView {
    @IBAction func pushUser() {
        guard let user = user as? Pushable else { return }
        serialHook.perform(key: .TriggerPushable, argument: user)
    }
}

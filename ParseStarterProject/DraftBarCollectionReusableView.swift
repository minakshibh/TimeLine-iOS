//
//  DraftBarCollectionReusableView.swift
//  Timeline
//
//  Created by Valentin Knabel on 14.08.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import UIKit

class DraftBarCollectionReusableView: UICollectionReusableView {
    
    @IBOutlet var durationLabel: UILabel?
    @IBOutlet var controlButtons: [UIButton]! = []
    @IBOutlet var sendToTimelineButton: UIButton!
    
    var moment: Moment? {
        didSet {
            for cb in controlButtons {
                cb.enabled = moment != nil
            }
            
            self.sendToTimelineButton.enabled = moment?.duration ?? Int.max <= 10
//            print("\(LocalizedString.DurationFormatSeconds1d)*****\(moment?.duration)")
            
            
            let user = NSUserDefaults.standardUserDefaults()
            
            if(moment?.duration != nil)
            {
                let selectedVideoLocalThumbURL = moment!.localThumbURL
                user.setObject("\(moment!.localThumbURL)", forKey: "selectedVideoLocalThumbURL")
                let selectedVideoTime = moment!.duration
//                print("-----------\(selectedVideoTime)----------------")
                user.setObject(selectedVideoTime, forKey: "selectedVideoTime")
            }
            self.durationLabel?.text = lformat(LocalizedString.DurationFormatSeconds1d, moment?.duration ?? 0)
        }
    }
    
}

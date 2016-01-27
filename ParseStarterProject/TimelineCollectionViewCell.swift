//
//  TimelineCollectionViewCell.swift
//  Timeline
//
//  Created by Valentin Knabel on 14.08.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import UIKit

class TimelineCollectionViewCell: UICollectionViewCell {
    
    var timelineView: TimelineView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.timelineView = UINib(nibName: "TimelineView", bundle: nil).instantiateWithOwner(self, options: [:]).first as! TimelineView
        self.addSubview(self.timelineView)
        self.timelineView.frame.size = self.bounds.size
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.timelineView = UINib(nibName: "TimelineView", bundle: nil).instantiateWithOwner(self, options: [:]).first as! TimelineView
        self.addSubview(self.timelineView)
        self.timelineView.frame.size = self.bounds.size
    }

}

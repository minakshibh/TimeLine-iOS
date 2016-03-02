//
//  ModernTimelineTableViewCell.swift
//  Timeline
//
//  Created by Valentin Knabel on 17.11.15.
//  Copyright © 2015 Conclurer GbR. All rights reserved.
//

import UIKit

class ModernTimelineTableViewCell: UITableViewCell {

    var timeline: Timeline? {
        get {
            return timelineView.timeline
        }
        set {
            
            timelineView.timeline = newValue
        }
    }
    var timelineView: ModernTimelineView!

    private func innerFrame() -> CGRect {
        return self.bounds
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        timelineView = UINib(nibName: "ModernTimelineView", bundle: nil).instantiateWithOwner(self, options: nil).first as! ModernTimelineView
        contentView.addSubview(timelineView)
        timelineView.frame = innerFrame()
 
        
    }

    override func layoutSubviews() {
        timelineView.frame = innerFrame()
        super.layoutSubviews()
    }

    //MARK: Generated

    override func awakeFromNib() {
        super.awakeFromNib()

        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

//
//  NotificationTableViewCell.swift
//  Timeline
//
//  Created by Br@R on 16/02/16.
//  Copyright © 2016 Conclurer GbR. All rights reserved.
//

import Foundation
import Parse
import SWFrameButton
import UIKit
import QuartzCore

class NotificationTableViewCell: UITableViewCell {
    // MARK: Properties
    
    @IBOutlet var photoImageView: ProfileImageView!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var notificationTxtLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.photoImageView.layer.masksToBounds = true
        self.photoImageView.layer.cornerRadius = photoImageView.frame.size.width/2
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

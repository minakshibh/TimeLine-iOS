//
//  DraftPreviewTableViewCell.swift
//  Timeline
//
//  Created by Valentin Knabel on 15.08.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import UIKit

class DraftPreviewTableViewCell: UITableViewCell {

    var draftPreview: DraftPreview!

    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.draftPreview = UINib(nibName: "DraftPreview", bundle: nil).instantiateWithOwner(self, options: [:]).first as! DraftPreview
        self.addSubview(self.draftPreview)
        self.draftPreview.frame.size = self.bounds.size
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.draftPreview = UINib(nibName: "DraftPreview", bundle: nil).instantiateWithOwner(self, options: [:]).first as! DraftPreview
        self.addSubview(self.draftPreview)
        self.draftPreview.frame.size = self.bounds.size
    }

}

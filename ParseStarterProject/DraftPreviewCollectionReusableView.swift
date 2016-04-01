//
//  DraftPreviewCollectionReusableView.swift
//  Timeline
//
//  Created by Valentin Knabel on 11.08.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import UIKit
import AVFoundation

class DraftPreviewCollectionReusableView: UICollectionReusableView {
    
    var draftPreview: DraftPreview!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.draftPreview = UINib(nibName: "DraftPreview", bundle: nil).instantiateWithOwner(self, options: [:]).first as! DraftPreview
        self.clipsToBounds = true
        self.addSubview(self.draftPreview)
        self.draftPreview.frame.size = self.bounds.size
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.draftPreview = UINib(nibName: "DraftPreview", bundle: nil).instantiateWithOwner(self, options: [:]).first as! DraftPreview
        self.clipsToBounds = true
        self.addSubview(self.draftPreview)
        self.draftPreview.frame.size = self.bounds.size
        

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.draftPreview.frame = self.bounds
        self.draftPreview.layoutSubviews()
    }
    
}

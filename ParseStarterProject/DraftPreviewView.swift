//
//  DraftPreviewView.swift
//  Timeline
//
//  Created by Valentin Knabel on 04.09.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import Foundation

class DraftPreviewView: UIView {
    
    weak var draftPreview: DraftPreview!
    
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

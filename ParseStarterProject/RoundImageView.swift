//
//  RoundImageView.swift
//  Timeline
//
//  Created by Valentin Knabel on 26.07.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import UIKit

class RoundImageView: UIImageView {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.cornerRadius = self.frame.size.width / 2.0
        self.clipsToBounds = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = self.frame.size.width / 2.0
        self.clipsToBounds = true
    }

}

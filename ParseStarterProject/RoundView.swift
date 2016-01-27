//
//  RoundView.swift
//  Timeline
//
//  Created by Valentin Knabel on 05.08.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import UIKit

class RoundView: UIView {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.cornerRadius = self.frame.size.width / 2.0
        self.clipsToBounds = true
    }
    
}

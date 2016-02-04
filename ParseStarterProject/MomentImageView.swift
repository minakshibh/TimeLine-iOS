//
//  MomentImageView.swift
//  Timeline
//
//  Created by Valentin Knabel on 19.08.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import UIKit

class MomentImageView: UIImageView {

    var moment: Moment? {
        didSet {
            if moment?.state.uuid != oldValue?.state.uuid {
                image = nil
            }
            if let moment = moment {
                UIImage.getImage(moment) { [weak self] image in
                    if let s = self,
                        let m = s.moment
                        where m === moment
                    {
                        self?.image = image
                    }
                }
            } else {
                image = nil
            }
        }
    }

}
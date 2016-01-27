//
//  NormalButtonProperties.swift
//  Timeline
//
//  Created by Valentin Knabel on 10.12.15.
//  Copyright © 2015 Conclurer GbR. All rights reserved.
//

import UIKit

extension UIButton {
    var normalImage: UIImage? {
        get {
            return imageForState(.Normal)
        }
        set {
            setImage(newValue, forState: .Normal)
        }
    }
    var normalTitle: String? {
        get {
            return titleForState(.Normal)
        }
        set {
            setTitle(newValue, forState: .Normal)
        }
    }
    var selectedImage: UIImage? {
        get {
            return imageForState(.Selected)
        }
        set {
            setImage(newValue, forState: .Selected)
        }
    }
}

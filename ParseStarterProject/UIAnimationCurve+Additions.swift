//
//  UIAnimationCurve+Additions.swift
//  Timeline
//
//  Created by Valentin Knabel on 03.09.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import UIKit

public extension UIViewAnimationCurve {
    
    public func animationOptionsValue() -> UIViewAnimationOptions {
        switch self {
        case .EaseIn: return .CurveEaseIn
        case .EaseInOut: return .CurveEaseInOut
        case .EaseOut: return .CurveEaseOut
        case .Linear: return .CurveLinear
        }
    }
    
}

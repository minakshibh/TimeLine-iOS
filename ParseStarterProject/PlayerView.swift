//
//  PlayerView.swift
//  Timeline
//
//  Created by Valentin Knabel on 19.08.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import UIKit
import AVFoundation

class PlayerView: UIView {
    
    override class func layerClass() -> AnyClass {
        return AVPlayerLayer.self
    }
    
    var playerLayer: AVPlayerLayer! {
        return self.layer as! AVPlayerLayer
    }
    
}

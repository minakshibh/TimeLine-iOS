import UIKit
import AVFoundation

public extension AVCaptureVideoOrientation {
    
    public init(interfaceOrientation: UIInterfaceOrientation) {
        switch interfaceOrientation {
        case .Unknown:
            self = .LandscapeLeft
        case .Portrait:
            self = .Portrait
        case .PortraitUpsideDown:
            self = .PortraitUpsideDown
        case .LandscapeLeft:
            self = .LandscapeLeft
        case .LandscapeRight:
            self = .LandscapeRight
        }
    }
    
    public var interfaceOrientation: UIInterfaceOrientation {
        switch self {
        case .Portrait:
            return .Portrait
        case .PortraitUpsideDown:
            return .PortraitUpsideDown
        case .LandscapeLeft:
            return .LandscapeLeft
        case .LandscapeRight:
            return .LandscapeRight
        }
    }
    
}

public extension UIInterfaceOrientation {
    
    public init(captureVideoOrientation: AVCaptureVideoOrientation) {
        self = captureVideoOrientation.interfaceOrientation
    }
    
    public var captureVideoOrientation: AVCaptureVideoOrientation {
        return AVCaptureVideoOrientation(interfaceOrientation: self)
    }
    
}

func CGAffineTransformMakeOrientation(captureVideoOrientation: AVCaptureVideoOrientation) -> CGAffineTransform {
    let angle: CGFloat
    switch captureVideoOrientation {
    case .Portrait:
        angle = 90.0
    case .PortraitUpsideDown:
        angle = 270.0
    case .LandscapeLeft:
        angle = 0.0
    case .LandscapeRight:
        angle = 180.0
    }
    return CGAffineTransformMakeRotation(CGFloat(M_PI) * angle / 180)
}

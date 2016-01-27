import UIKit
import AVFoundation

public class CameraPreviewView: UIView {

    override public class func layerClass() -> AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    public var session: AVCaptureSession! {
        get {
            let layer = self.layer as? AVCaptureVideoPreviewLayer
            return layer?.session
        }
        set {
            if let layer = self.layer as? AVCaptureVideoPreviewLayer {
                layer.session = newValue
                let bounds = layer.bounds
                layer.videoGravity = AVLayerVideoGravityResizeAspectFill
                layer.bounds = bounds
                layer.position = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds))
            }
        }
    }
    
}

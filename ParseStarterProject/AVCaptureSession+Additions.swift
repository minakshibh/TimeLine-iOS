import AVFoundation

public extension AVCaptureSession {
    
    public func configuration(operation: () -> ()) {
        self.beginConfiguration()
        operation()
        self.commitConfiguration()
    }
    
}

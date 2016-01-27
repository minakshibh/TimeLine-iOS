import AVFoundation

public typealias AVMediaType = String

public extension AVCaptureDevice {
    
    public class func device(mediaType: AVMediaType, position: AVCaptureDevicePosition) -> AVCaptureDevice? {
        let all = AVCaptureDevice.devicesWithMediaType(mediaType) as? [AVCaptureDevice] ?? []
        for dev in all {
            if dev.position == position {
                return dev
            }
        }
        return all.first
    }
    
    public func lockedConfiguration(operation: () -> ()) throws {
        var error: NSError! = NSError(domain: "Migrator", code: 0, userInfo: nil)
        // TODO: Swift 2.0 reimplement
        do {
            try self.lockForConfiguration()
            operation()
            self.unlockForConfiguration()
            return
        } catch let error1 as NSError {
            error = error1
        }
        throw error
    }
    
    public func focusWithMode(focusMode: AVCaptureFocusMode, exposeWithMode exposureMode: AVCaptureExposureMode, atDevicePoint point: CGPoint, monitorSubjectAreaChange: Bool) {
        var error: NSError?
        do {
            try self.lockedConfiguration {
                if self.focusPointOfInterestSupported && self.isFocusModeSupported(focusMode) {
                    self.focusMode = focusMode
                    self.focusPointOfInterest = point
                }
                if self.exposurePointOfInterestSupported && self.isExposureModeSupported(exposureMode) {
                    self.exposureMode = exposureMode
                    self.exposurePointOfInterest = point
                }
                self.subjectAreaChangeMonitoringEnabled = monitorSubjectAreaChange
            }
        } catch let error1 as NSError {
            error = error1
        }
        if let error = error {
            print("-AVCaptureDevice.focusWithMode(_:, exposeWithMode:, atDevicePoint:, monitorSubjectAreaChange:) \(error)", terminator: "")
        }
        
    }
    
}

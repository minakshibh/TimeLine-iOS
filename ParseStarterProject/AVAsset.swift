import AVFoundation


public extension AVAsset {
    
    public var timeRange: CMTimeRange {
        return CMTimeRange(start: kCMTimeZero, duration: self.duration)
    }

}

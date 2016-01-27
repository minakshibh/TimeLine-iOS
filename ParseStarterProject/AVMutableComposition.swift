import AVFoundation


public extension AVMutableComposition {
    
    public func appendAsset(asset: AVAsset) throws {
        try insertTimeRange(asset.timeRange, ofAsset: asset, atTime: self.duration)
    }
    
    public func appendAsset(asset: AVAsset, transform: CGAffineTransform) throws {
        let error: NSError! = NSError(domain: "Migrator", code: 0, userInfo: nil)
        let duration = self.duration
        
        let videoTrack = self.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
        videoTrack.preferredTransform = transform
        let audioTrack = self.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
        
        do {
            guard let track = asset.tracksWithMediaType(AVMediaTypeVideo).first else { throw error }
            try videoTrack.insertTimeRange(asset.timeRange, ofTrack: track, atTime: duration)
            try audioTrack.insertTimeRange(asset.timeRange, ofTrack: track, atTime: duration)
            return
        } catch {
            throw error
        }
    }
    
}

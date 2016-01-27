//
//  VideoComposer.swift
//  Timeline
//
//  Created by Valentin Knabel on 17.07.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import Foundation
import AVFoundation
import Bolts

class VideoComposer {
    private var queue: NSOperationQueue = SerialOperationQueue(name: "video composition")
    private func generateTmpURL() -> NSURL {
        let name = String(characters: String.NameCharacters, length: 10)
        return NSURL(fileURLWithPath: NSTemporaryDirectory() + name + ".mov")!
    }
    
    var composition = AVMutableComposition()
    var finished: Bool {
        return queue.operationCount == 0
    }
    
    /// BFTask: Either<NSURL, NSError>
    func append(URL: NSURL, orientation: AVCaptureVideoOrientation) -> BFTask {
        let task = BFTaskCompletionSource()
        queue.addOperationWithBlock {
            let asset = AVURLAsset(URL: URL, options: [:])
            
            var error: NSError?
            let comp = self.composition
            comp.appendAsset(asset, error: &error)
            if let error = error {
                println("-VideoComposer.append(_:,orientation:): comp.appendAsset(_:,error:)\n\(error)")
                return task.setError(error)
            }
            
            
            let exportSession = AVAssetExportSession(asset: comp, presetName: AVAssetExportPresetHighestQuality)
            exportSession.outputURL = self.generateTmpURL()
            exportSession.outputFileType = "com.apple.quicktime-movie"
            exportSession.shouldOptimizeForNetworkUse = true
            // MAKE THE EXPORT SYNCHRONOUS
            let semaphore: dispatch_semaphore_t = dispatch_semaphore_create(0)
            
            exportSession.exportAsynchronouslyWithCompletionHandler {
                dispatch_semaphore_signal(semaphore)
                
                switch exportSession.status {
                case .Completed:
                    task.setResult(exportSession.outputURL)
                    self.composition = AVMutableComposition()
                    self.composition.appendAsset(AVURLAsset(URL: exportSession.outputURL, options: [:]), error: nil)
                default:
                    println("-VideoComposer.append(_:,orientation:): exportSession.error\n\(exportSession.error)")
                    task.setError(exportSession.error)
                }
            }
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
            
            NSFileManager.defaultManager().removeItemAtURL(URL, error: nil)
            
            
        }
        return task.task
    }
}


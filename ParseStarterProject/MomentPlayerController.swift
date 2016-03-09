//
//  MomentPlayerController.swift
//  Timeline
//
//  Created by Valentin Knabel on 19.08.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import UIKit
import MediaPlayer

class MomentPlayerController: NSObject {
    
    let items: [(Moment, AVPlayerItem)]
    private var currentIndex = 0
    private let queuePlayer: AVQueuePlayer
    weak var playerLayer: AVPlayerLayer?
    var playing: Bool = false
    var finished: Bool = false
    var observing: Bool = false
    var modernTimeline : ModernTimelineView!
    
    weak var delegate: MomentPlayerControllerDelegate?
    //lazy var queue: NSOperationQueue = SerialOperationQueue(name: "queue player")

    convenience init(timeline: Timeline?, inView view: PlayerView) {
        let moms = TimelineViewingRight.viewableMoments(timeline)
        self.init(moments: moms, inView: view)
    }
    
    init(moments: [Moment], inView view: PlayerView) {
        
        items = moments.sort(<).map { ($0, AVPlayerItem(URL: $0.bestVideoURL ?? $0.alternativeVideoURL!)) }
        
        queuePlayer = AVQueuePlayer(items: items.map { $0.1 })
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategorySoloAmbient)
        } catch _ {
        }
        queuePlayer.actionAtItemEnd = .None
        playerLayer = view.playerLayer
        playerLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        playerLayer?.player = queuePlayer
        
        super.init()
        
        
    }
    
    var isFirst: Bool {
        return queuePlayer.currentItem == items.first?.1
    }
    var isLast: Bool {
        return queuePlayer.items().count <= 1
    }
    
    func setCurrentMoment(moment: Moment) {
        //queue.addOperationWithBlock { () -> Void in
            print("set current moment")
            var insert = false
        
            for i in 0..<self.items.count {
                if moment.state.uuid == self.items[i].0.state.uuid {
                    self.queuePlayer.removeAllItems()
                    insert = true
                    currentIndex = i
                }
                if insert {
                    self.queuePlayer.insertItem(self.items[i].1, afterItem: nil)
                }
            }
        //}
    }
    
    func currentMoment() -> Moment? {
        if currentIndex >= 0 && currentIndex < items.count {
            let current = items[currentIndex].0
            return current
        } else if let current = self.queuePlayer.currentItem {
            for i in self.items {
                if current == i.1 {
                    return i.0
                }
            }
        }
        return nil
    }
    func currentIndexOfMoment() -> Int {
        
        return currentIndex
        
    }
    func previous() {
        
        print("previous: \(self.currentIndex)")
        if self.currentIndex > 0
        {
            self.queuePlayer.seekToTime(kCMTimeZero)
            //queue.addOperationWithBlock {
            if self.currentMoment() == nil {
                var prev: AVPlayerItem? = nil
                for i in (self.items.map { $0.1 }) {
                    self.queuePlayer.insertItem(i, afterItem: prev)
                    prev = i
                }
            } else {
                if --currentIndex < items.count {
                    let previous =  self.items[self.currentIndex].1
                    let current = self.queuePlayer.currentItem
                    self.queuePlayer.replaceCurrentItemWithPlayerItem(previous)
                    self.queuePlayer.insertItem(current!, afterItem: previous)
                    self.queuePlayer.seekToTime(kCMTimeZero)
                }
            }
            
        }
        //}
    }
    
    func play() {
        main{
        //queue.addOperationWithBlock {
        if self.currentMoment() == nil {
            var prev: AVPlayerItem? = nil
            for i in (self.items.map { $0.1 }) {
                self.queuePlayer.insertItem(i, afterItem: prev)
                prev = i
            }
        }
        
        if !self.observing {
            self.observing = true
            self.queuePlayer.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions.New, context: nil)
            self.queuePlayer.addObserver(self, forKeyPath: "currentItem", options: NSKeyValueObservingOptions.New, context: nil)
            for o in self.items {
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "didFinishPlaying:", name: AVPlayerItemDidPlayToEndTimeNotification, object: o.1)
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "stalled:", name: AVPlayerItemPlaybackStalledNotification, object: o.1)
            }
            
            print("subbed")
            
            self.delegate?.momentPlayerControllerItemDidChange(self, moment: self.currentMoment())
        }
        
        self.queuePlayer.play()
        self.playing = true
        }
    }
    func stalled(notification: NSNotification) {
        print("stalled")
        pause()
        play()
    }
    
    func stop() {
        //queue.addOperationWithBlock {
        self.pause()
        self.queuePlayer.removeAllItems()
        //}
    }
    
    func pause() {
        //queue.addOperationWithBlock {
            print("paused")
            if self.observing {
                self.queuePlayer.removeObserver(self, forKeyPath: "rate", context: nil)
                self.queuePlayer.removeObserver(self, forKeyPath: "currentItem", context: nil)
                for o in self.items {
                    NSNotificationCenter.defaultCenter().removeObserver(self, name: AVPlayerItemDidPlayToEndTimeNotification, object: o.1)
                    NSNotificationCenter.defaultCenter().removeObserver(self, name: AVPlayerItemPlaybackStalledNotification, object: o.1)
                    
                }
                self.observing = false
                print("unsubbed")
            }
            
            self.queuePlayer.pause()
            self.playing = false
        //}
    }
    
    func next() {
        
        print("next: \(self.currentIndex)")
        //queue.addOperationWithBlock {
            if self.queuePlayer.items().count > 1 {
                self.currentIndex++
                _ = items[currentIndex].1
                queuePlayer.advanceToNextItem()
            } else {
                
        }
        //}
    }
    
    deinit {
        //queue.addOperationWithBlock {
            playing = false
            print("deinit")
            self.stop()
        //}
        //queue.waitUntilAllOperationsAreFinished()
    }
    
    func didFinishPlaying(notifcation: NSNotification) {
        //queue.addOperationWithBlock {
        self.queuePlayer.seekToTime(kCMTimeZero)
        
        if let playerItem = notifcation.object as? AVPlayerItem {
            if playerItem == self.items.last?.1 {
                print("finished")
                self.delegate?.momentPlayerControllerDidFinishPlaying(self)
            } else {
                self.next()
            }
        }
        //}
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        print("keyPath: \(keyPath!)")
        switch keyPath ?? "" {
        case "currentItem":
            let current = currentMoment()
            delegate?.momentPlayerControllerItemDidChange(self, moment: current)
            fallthrough
            
        case "rate":
            print(queuePlayer.rate)
            if queuePlayer.rate < 1.0 && playing {
                self.delegate?.momentPlayerController(self, isBuffering: true)
                let current = queuePlayer.currentItem
                
                delay(0.01) { [weak self] in
                    if current == self?.queuePlayer.currentItem {
                        self?.play()
                    }
                }
            }
            if queuePlayer.rate == 1.0 {
                self.delegate?.momentPlayerController(self, isBuffering: false)
            }
            
        default:
            break
        }
    }
    
}

protocol MomentPlayerControllerDelegate: class {
    
    func momentPlayerControllerDidFinishPlaying(momentPlayerController: MomentPlayerController?)
    func momentPlayerController(momentPlayerController: MomentPlayerController, isBuffering: Bool)
    
    func momentPlayerControllerItemDidChange(momentPlayerController: MomentPlayerController, moment: Moment?)
    
}


private extension Moment {
    
    var bestVideoURL: NSURL? {
        if let localURL = self.localVideoURL,
            let path = localURL.path
        {
            if NSFileManager.defaultManager().fileExistsAtPath(path) {
                return localURL
            }
        }
        return self.remoteStreamURL
    }
    
    var alternativeVideoURL: NSURL? {
        if let localURL = self.localVideoURL,
            let path = localURL.path
        {
            if NSFileManager.defaultManager().fileExistsAtPath(path) {
                return self.remoteStreamURL
            }
        }
        return self.remoteVideoURL
    }
    
}
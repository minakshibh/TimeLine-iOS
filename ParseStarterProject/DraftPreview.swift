//
//  DraftPreview.swift
//  Timeline
//
//  Created by Valentin Knabel on 15.08.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import UIKit
import MediaPlayer


class DraftPreview: UIView {
    
    enum RightError {
    case BlockedTimeline(String, String)
    case BlockedUser(String, String)
    case NotPublic(String)
    case Viewable
    }
    
    var rightError: RightError = .Viewable
    var moment: Moment? {
        get {
            return moments.first
        }
        set {
            if let m = newValue {
                moments = [m]
            } else {
                moments = []
            }
        }
    }
    private var moments: [Moment] = [] {
        didSet {
            if let moment = moments.sort(<).first {
                previewImageView.moment = moment
            } else {
                previewImageView.moment = nil
            }
            playButton.enabled = moments.count != 0
            momentPlayerController?.pause()
            momentPlayerController = nil
            playbackContainer.hidden = true
            bufferIndicator.hidden = true
        }
    }
    func setTimeline(timeline: Timeline?) {
        if let timeline = timeline,
            let owner = timeline.parent,
            let user = Storage.session.currentUser
        {
            if user.uuid == owner.uuid {
                self.moments = timeline.moments
                rightError = .Viewable
            } else if owner.blocked {
                self.moments = []
                rightError = .BlockedUser(owner.name ?? "", timeline.name)
            } else if timeline.blocked {
                self.moments = []
                rightError = .BlockedTimeline(owner.name ?? "", timeline.name)
            } else if !(owner.timelinesPublic ?? true) && owner.followed != FollowState.Following {
                self.moments = []
                rightError = .NotPublic(owner.name ?? "")
            } else {
                self.moments = timeline.moments
                rightError = .Viewable
            }
        } else {
            self.moments = timeline?.moments ?? []
            rightError = .Viewable
        }
    }
    
    @IBOutlet var previewImageView: MomentImageView!
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet var playButton: UIButton!

    var momentPlayerController: MomentPlayerController?
    @IBOutlet var playbackContainer: PlayerView!
    @IBOutlet var bufferIndicator: UIActivityIndicatorView!
    @IBOutlet var pausePlayButton: UIButton!
    @IBOutlet var playPlayButton: UIButton!
    @IBOutlet var previousPlayButton: UIButton!
    @IBOutlet var nextPlayButton: UIButton!
    
    // MARK: - Overlay start
    //// The maximum to the top: >= 8
    @IBOutlet var topLayoutConstraint: NSLayoutConstraint!
    /// The minimum to the bottom: <= -8
    @IBOutlet var bottomLayoutConstraint: NSLayoutConstraint!
    /// MIN: topLayoutConstraint.constant
    /// MAX: momentImageView.frame.size.height + bottomLayoutConstraint.constant
    @IBOutlet var positioningLayoutConstraint: NSLayoutConstraint!
    
    @IBOutlet var textField: UILabel!
    @IBOutlet var textFieldContainer: UIView!
    
    // MARK: Overlay end
    // MARK: -
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.previewImageView?.frame = self.bounds
        self.playbackContainer?.frame = self.bounds
    }
    
    @IBAction func playMoment() {
        func error(title title: String, message: String, button: String) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: button, style: .Default, handler: nil))
            
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let rootViewController = appDelegate.window?.rootViewController
            (rootViewController?.presentedViewController ?? rootViewController)?.presentAlertController(alert)
        }
        
        switch rightError {
        case .Viewable:
            if momentPlayerController == nil {
                momentPlayerController = MomentPlayerController(moments: moments, inView: playbackContainer)
                momentPlayerController?.delegate = self
                pausePlayButton.hidden = false
                playPlayButton.hidden = true
            }
            momentPlayerController?.play()
            playbackContainer.hidden = false
            bufferIndicator.hidden = false
        case let .BlockedTimeline(u, t):
            error(
                title: lformat(LocalizedString.TimelineAlertBlockedTimelineTitle1s, t),
                message: lformat(LocalizedString.TimelineAlertBlockedTimelineMessage2s, args: u, t),
                button: local(LocalizedString.TimelineAlertBlockedTimelineActionDismiss)
            )
        case let .BlockedUser(u, t):
            error(
                title: lformat(LocalizedString.TimelineAlertBlockedUserTitle1s, u),
                message: lformat(LocalizedString.TimelineAlertBlockedUserMessage2s, args: u, t),
                button: local(LocalizedString.TimelineAlertBlockedUserActionDismiss)
            )
        case let .NotPublic(u):
            error(
                title: lformat(LocalizedString.TimelineAlertNotPublicTitle1s, u),
                message: lformat(LocalizedString.TimelineAlertNotPublicMessage1s, u),
                button: local(LocalizedString.TimelineAlertNotPublicActionDismiss)
            )
        }
    }
    
    @IBAction func play() {
        pausePlayButton.hidden = false
        playPlayButton.hidden = true
        momentPlayerController?.play()
    }
    
    @IBAction func pause() {
        pausePlayButton.hidden = true
        playPlayButton.hidden = false
        momentPlayerController?.pause()
    }
    
    @IBAction func previous() {
        momentPlayerController?.previous()
    }
    
    @IBAction func next() {
        momentPlayerController?.next()
    }
    
    @IBAction func stop() {
        momentPlayerController?.stop()
        momentPlayerController = nil
        playbackContainer.hidden = true
        bufferIndicator.hidden = true

        serialHook.perform(key: .StopAllPlaybacks, argument: ())
    }
    
    func setCurrentMoment(moment: Moment) {
        if momentPlayerController == nil {
            momentPlayerController = MomentPlayerController(moments: moments, inView: playbackContainer)
            momentPlayerController?.delegate = self
            pausePlayButton.hidden = false
            playPlayButton.hidden = true
        }
        momentPlayerController?.setCurrentMoment(moment)
    }

    deinit {
        print("Draft deinited")
    }
}

extension DraftPreview: MomentPlayerControllerDelegate {

    func momentPlayerControllerDidFinishPlaying(momentPlayerController: MomentPlayerController?) {
        main {
            self.playbackContainer.hidden = true
            self.bufferIndicator.hidden = true
            self.stop()
        }
    }
    
    func momentPlayerController(momentPlayerController: MomentPlayerController, isBuffering: Bool) {
        main {
            if isBuffering {
                self.bufferIndicator.startAnimating()
                self.bufferIndicator.hidden = false
            } else {
                self.bufferIndicator.stopAnimating()
                self.bufferIndicator.hidden = true
            }
        }
    }
    
    func momentPlayerControllerItemDidChange(momentPlayerController: MomentPlayerController, moment: Moment?) {
        
        main {
        UIView.animateWithDuration(0.5, animations: {
            self.previousPlayButton.alpha = momentPlayerController.isFirst ? 0.0 : 1.0
            self.nextPlayButton.alpha = momentPlayerController.isLast ? 0.0 : 1.0
            
            (self.previousPlayButton.hidden, self.nextPlayButton.hidden) = (false, false)
            
            self.previousPlayButton.enabled = !momentPlayerController.isFirst
            self.nextPlayButton.enabled = !momentPlayerController.isLast
            
            if let moment = moment,
                let text = moment.overlayText,
                let color = moment.overlayColor,
                let position = moment.overlayPosition,
                let size = moment.overlaySize
            {
                self.textField.text = text
                self.textField.textColor = color
                self.textField.font = UIFont(descriptor: self.textField.font.fontDescriptor(), size: CGFloat(size))
                self.positioningLayoutConstraint.constant = self.validPosition(self.minPosition + CGFloat(position) * self.maxPosition)
                self.textFieldContainer.hidden = false
                //self.textFieldContainer.alpha = 1.0
            } else {
                //self.textFieldContainer.alpha = 0.0
                self.textFieldContainer.hidden = true
            }
            self.layoutIfNeeded()
            }) { _ in
                self.previousPlayButton.hidden = momentPlayerController.isFirst
                self.nextPlayButton.hidden = momentPlayerController.isLast
        }
    }
    }
}

// MARK: - UIGestureRecognizerDelegate
extension DraftPreview {
    
    private var minPosition: CGFloat {
        return topLayoutConstraint.constant
    }
    private var maxPosition: CGFloat {
        return previewImageView.frame.size.height - abs(bottomLayoutConstraint.constant) - textFieldContainer.frame.size.height
    }
    private var relativePosition: CGFloat {
        return (positioningLayoutConstraint.constant - minPosition) / maxPosition
    }
    private func validPosition(newPosition: CGFloat) -> CGFloat {
        return max(minPosition, min(newPosition, maxPosition))
    }
}

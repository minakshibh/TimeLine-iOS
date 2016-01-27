//
//  CaptureViewController.swift
//  Timeline
//
//  Created by Valentin Knabel on 13.07.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import UIKit
import AVFoundation

private let MaximumMomentDraftDuration: NSTimeInterval = 10.0

protocol CaptureViewControllerDelegate {
    
    func captureViewControllerDidFinishWithURL(URL: NSURL?)
    
}

class CaptureViewController: UIViewController {
    
    // MARK: Set on segue
    var orientationMask: UIInterfaceOrientationMask = .All
    var delegate: CaptureViewControllerDelegate?
    
    // MARK: IBOutlets
    @IBOutlet private weak var recordButton: UIButton!
    @IBOutlet private weak var finishButton: UIButton!
    @IBOutlet private weak var cameraButton: UIButton!
    @IBOutlet private weak var previewView: CameraPreviewView!
    
    // MARK: Movie Session
    /// AVCaptureSession is not thread-safe
    private var sessionQueue: NSOperationQueue = SerialOperationQueue(name: "session queue")
    private var session: AVCaptureSession!
    private var videoDeviceInput: AVCaptureDeviceInput!
    // kvo
    var movieFileOutput: AVCaptureMovieFileOutput!
    var resultURL: NSURL?
    
    // MARK: Helper
    private let videoComposer = VideoComposer()
    private var backgroundRecordingID: UIBackgroundTaskIdentifier?
    private enum SessionStatus {
        case Recording
        case Ready
        case Forbidden
    }
    private var sessionStatus = SessionStatus.Forbidden {
        didSet {
            switch sessionStatus {
            case .Forbidden:
                enableButtons(false)
            default:
                enableButtons(true)
            }
        }
    }
    private var defaultDevicePosition: AVCaptureDevicePosition {
        return .Front
    }
    private var previewLayer: AVCaptureVideoPreviewLayer! {
        return previewView.layer as! AVCaptureVideoPreviewLayer
    }
    private var tmpURL: NSURL {
        let name = String(characters: String.NameCharacters, length: 10)
        return NSURL(fileURLWithPath: NSTemporaryDirectory() + name + ".mov")!
    }
    
    // MARK: override
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup session
        session = AVCaptureSession()
        previewView.session = session
     
        checkDeviceAuthorizationStatus()
        sessionQueue.addOperationWithBlock(initializeSessionInputs)
    }
    
    override func viewWillAppear(animated: Bool) {
        sessionQueue.addOperationWithBlock {
            self.subscribeNotifications()
            self.session.startRunning()
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        sessionQueue.addOperationWithBlock {
            self.unsubscribeNotifications()
            self.session.stopRunning()
        }
    }

}

// MARK: IBActions
private extension CaptureViewController {
    
    func refreshFinishButton() {
        main {
            if let _ = self.resultURL where self.videoComposer.finished && self.cameraButton.enabled == true && self.sessionStatus == .Ready {
                self.finishButton.enabled = true
            } else {
                self.finishButton.enabled = false
            }
        }
    }
    
    func enableButtons(enabled: Bool) {
        main {
            let buttons = [self.recordButton, self.cameraButton]
            buttons.map { $0.enabled = enabled }
            
            self.refreshFinishButton()
        }
    }
    
    @IBAction func finishSession(sender: AnyObject) {
        if sessionStatus == .Recording {
            self.movieFileOutput.stopRecording()
            self.sessionStatus = .Ready
        }
        dismissViewControllerAnimated(true) {
            NSNotificationCenter.defaultCenter().removeObserver(self, name: AVCaptureDeviceSubjectAreaDidChangeNotification, object: self.videoDeviceInput.device)
            self.delegate?.captureViewControllerDidFinishWithURL(self.resultURL)
        }
    }
    
    @IBAction func cancelSession(sender: AnyObject) {
        dismissViewControllerAnimated(true) {
            NSNotificationCenter.defaultCenter().removeObserver(self, name: AVCaptureDeviceSubjectAreaDidChangeNotification, object: self.videoDeviceInput.device)
        }
    }
    
    @IBAction func toggleRecording(sender: AnyObject) {
        enableButtons(false)
        
        sessionQueue.addOperationWithBlock {
            switch self.sessionStatus {
            case .Ready:
                if UIDevice.currentDevice().multitaskingSupported {
                    self.backgroundRecordingID = UIApplication.sharedApplication().beginBackgroundTaskWithName("capture moment", expirationHandler: nil)
                }
                self.movieFileOutput.connectionWithMediaType(AVMediaTypeVideo).videoOrientation = self.previewLayer.connection.videoOrientation
                
                self.movieFileOutput.startRecordingToOutputFileURL(self.tmpURL, recordingDelegate: self)
                self.sessionStatus = .Recording
                
            case .Recording:
                self.movieFileOutput.stopRecording()
                self.sessionStatus = .Ready
                
            default:
                break
            }
        }
    }
    
    
    
    @IBAction func focusAndExposeTap(sender: UITapGestureRecognizer) {
        let devPoint = previewLayer.captureDevicePointOfInterestForPoint(sender.location)
        
        async {
            self.videoDeviceInput.device.focusWithMode(.AutoFocus,
                exposeWithMode: .ContinuousAutoExposure,
                atDevicePoint: devPoint,
                monitorSubjectAreaChange: true)
        }

    }
    
    var subjectAreaDidChangeSelector: Selector {
        return "subjectAreaDidChange:"
    }
    @objc func subjectAreaDidChange(notification: NSNotification) {
        let devPoint = CGPoint(x: 0.5, y: 0.5)
        
        async { () -> () in
            self.videoDeviceInput.device.focusWithMode(.AutoFocus,
                exposeWithMode: .ContinuousAutoExposure,
                atDevicePoint: devPoint,
                monitorSubjectAreaChange: false)
        }
    }
    
}

// MARK: 
private extension CaptureViewController {
    
    func checkDeviceAuthorizationStatus() {
        AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo) { (granted) -> Void in
            self.sessionStatus = granted ? .Ready : .Forbidden
            
            if !granted {
                let alert = UIAlertController(title: LocalizedString.CaptureAuthorizationFailureTitle.localized,
                    message: LocalizedString.CaptureAuthorizationFailureMessage.localized,
                    preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: LocalizedString.CaptureAuthorizationFailureDismiss.localized,
                    style: UIAlertActionStyle.Cancel,
                    handler: nil))
                self.presentViewController(alert, animated: true) { () -> Void in
                    //<#code#>
                }
            }
        }
    }
    
    func initializeSessionInputs() {
        // this error can be reused, when used with `if-let`
        var error: NSError?
        
        // video
        let videoDevice = AVCaptureDevice.device(AVMediaTypeVideo, position: self.defaultDevicePosition)
        if let videoDeviceInput = AVCaptureDeviceInput(device: videoDevice, error: &error) {
            if session.canAddInput(videoDeviceInput) {
                self.session.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
                
                main {
                    print(self.previewLayer.connection)
                    self.previewLayer.connection.videoOrientation = AVCaptureVideoOrientation(interfaceOrientation: self.interfaceOrientation)
                }
            }
        } else {
            print("-CaptureViewController.initializeSessionInputs(): \(error)")
        }
        
        // audio
        if let audioDevice = AVCaptureDevice.devicesWithMediaType(AVMediaTypeAudio).first as? AVCaptureDevice,
            audioDeviceInput = AVCaptureDeviceInput(device: audioDevice, error: &error)
        {
            if session.canAddInput(audioDeviceInput) {
                session.addInput(audioDeviceInput)
            }
        } else {
            print("-CaptureViewController.initializeSessionInputs(): \(error)")
        }
        
        // movie output
        let movieFileOutput = AVCaptureMovieFileOutput()
        if session.canAddOutput(movieFileOutput) {
            session.addOutput(movieFileOutput)
            
            // connect
            let connection = movieFileOutput.connectionWithMediaType(AVMediaTypeVideo)
            // video stabilization
            // TODO: Swift 2.0 #available(iOS 8, *)
            if connection.respondsToSelector("activeVideoStabilizationMode") {
                connection.preferredVideoStabilizationMode = .Cinematic
            } else {
                if connection.videoStabilizationEnabled {
                    connection.enablesVideoStabilizationWhenAvailable = true
                }
            }
            self.movieFileOutput = movieFileOutput
        }
    }
    
}

// MARK: AVCaptureFileOutputRecordingDelegate
extension CaptureViewController: AVCaptureFileOutputRecordingDelegate {
    
    //optional func captureOutput(captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAtURL fileURL: NSURL!, fromConnections connections: [AnyObject]!)
    
    func captureOutput(captureOutput: AVCaptureFileOutput!,
        didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!,
        fromConnections connections: [AnyObject]!,
        error: NSError!)
    {
        let videoOrientation = previewLayer.connection.videoOrientation
        sessionStatus = .Ready
        
        videoComposer.append(outputFileURL, orientation: videoOrientation).continueWithBlock { (task) -> AnyObject! in
            main {
                if let url = task.result as? NSURL {
                    self.resultURL = url
                }
                delay(0.1) { self.refreshFinishButton() }
                
                // TODO: Swift 2.0 defer
                if let id = self.backgroundRecordingID {
                    UIApplication.sharedApplication().endBackgroundTask(id)
                }
            }
            return nil
        }
        
    }
    
}

// MARK: KVO
extension CaptureViewController {
    
    private var movieFileOutputRecordingKeyPath: String {
        return "movieFileOutput.recording"
    }
    private func subscribeNotifications() {
        self.addObserver(self, forKeyPath: movieFileOutputRecordingKeyPath,
            options: (NSKeyValueObservingOptions.Old|NSKeyValueObservingOptions.New),
            context: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: subjectAreaDidChangeSelector,
            name: AVCaptureDeviceSubjectAreaDidChangeNotification,
            object: self.videoDeviceInput.device)
    }
    
    private func unsubscribeNotifications() {
        removeObserver(self, forKeyPath: movieFileOutputRecordingKeyPath)
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: AVCaptureDeviceSubjectAreaDidChangeNotification,
            object: self.videoDeviceInput.device)
    }
    
    override func observeValueForKeyPath(keyPath: String, 
        ofObject object: AnyObject,
        change: [NSObject : AnyObject],
        context: UnsafeMutablePointer<Void>)
    {   
        switch keyPath {
        case movieFileOutputRecordingKeyPath:
            switch sessionStatus {
            case .Forbidden:
                enableButtons(false)
            case .Recording:
                cameraButton.enabled = false
                recordButton.enabled = true
                recordButton.setTitle(LocalizedString.CaptureRecordButtonTitleStop.localized, forState: .Normal)
            case .Ready:
                cameraButton.enabled = true
                recordButton.enabled = false
                recordButton.setTitle(LocalizedString.CaptureRecordButtonTitleStart.localized, forState: .Normal)
            }
        default:
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
}

// MARK: Autorotation
extension CaptureViewController {
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(orientationMask.rawValue)
    }
    
    override func shouldAutorotate() -> Bool {
        return !(sessionStatus == .Recording) && (self.resultURL == nil)
    }

    private func rotateToOrientation(toInterfaceOrientation orientation: UIInterfaceOrientation) {
        previewLayer.connection.videoOrientation = orientation.captureVideoOrientation
    }
    
    //@availability(iOS 8, *)
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animateAlongsideTransition({ _ -> Void in
            self.rotateToOrientation(toInterfaceOrientation: UIApplication.sharedApplication().statusBarOrientation)
            }, completion: nil)
    }
    
    //@availability(iOS, introduced=2.0, deprecated=8.0)
    func willRotateToInterfaceOrientation(toInterfaceOrientation orientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        rotateToOrientation(toInterfaceOrientation: orientation)
    }
    
}

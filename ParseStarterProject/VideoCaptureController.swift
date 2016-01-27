//
//  VideoCaptureController.swift
//  Timeline
//
//  Created by Valentin Knabel on 26.07.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import UIKit
import AVFoundation

public protocol VideoCaptureControllerDelegate {
    
    var interfaceOrientation: UIInterfaceOrientation { get }
    
    func videoCaptureSessionStartsFinishing(videoCapture: VideoCaptureController)
    func videoCaptureSessionStatusWillChange(videoCapture: VideoCaptureController, from: VideoCaptureController.SessionStatus, to: VideoCaptureController.SessionStatus)
    func videoCaptureSessionStatusDidChange(videoCapture: VideoCaptureController, from: VideoCaptureController.SessionStatus, to: VideoCaptureController.SessionStatus)
    
}

public class VideoCaptureController: NSObject {

    // MARK: Configuration
    /// The delegate for callbacks.
    public var delegate: VideoCaptureControllerDelegate?
    /// The max duration of the video draft
    public var maximumDuration: CGFloat?
    /// All allowed orientations
    public var orientationMask: UIInterfaceOrientationMask = .All
    /// The default position of the device
    public var defaultDevicePosition: AVCaptureDevicePosition = .Back
    
    // MARK: IBOutlets
    /// The generated camera preview view.
    public var previewView: CameraPreviewView? {
        didSet {
            oldValue?.session = nil
            previewView?.session = session
            let bounds = previewLayer?.bounds
            previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            previewLayer?.bounds = previewLayer!.bounds
            previewLayer?.position = CGPoint(x: CGRectGetMidX(bounds!), y: CGRectGetMidY(bounds!))
        }
    }

    // MARK: Movie Session
    /// AVCaptureSession is not thread-safe
    private var sessionQueue: NSOperationQueue = SerialOperationQueue(name: "session queue")
    private var session: AVCaptureSession = AVCaptureSession()
    private var videoDeviceInput: AVCaptureDeviceInput?
    // kvo
    // TODO: Remove KVO
    var movieFileOutput: AVCaptureMovieFileOutput?
    var resultURL: NSURL?
    
    // MARK: Helper
    private var backgroundRecordingID: UIBackgroundTaskIdentifier?
    public enum SessionStatus {
        case Recording
        case Ready
        case Forbidden
    }
    public var sessionStatus = SessionStatus.Forbidden {
        willSet {
            delegate?.videoCaptureSessionStatusWillChange(self, from: sessionStatus, to: newValue)
        }
        didSet {
            delegate?.videoCaptureSessionStatusDidChange(self, from: oldValue, to: sessionStatus)
        }
    }
    private var previewLayer: AVCaptureVideoPreviewLayer? {
        return previewView?.layer as? AVCaptureVideoPreviewLayer
    }
    private func tmpURL() -> NSURL {
        let name = String(characters: String.NameCharacters, length: 10)
        return NSURL(fileURLWithPath: NSTemporaryDirectory() + name + ".mov")!
    }
    
    public init(configure: (VideoCaptureController) -> ()) {
        super.init()
        configure(self)
        
        checkDeviceAuthorizationStatus()
        sessionQueue.addOperationWithBlock { () -> Void in
            self.initializeSessionInputs()
            self.subscribeNotifications()
            self.session.startRunning()
        }
    }
    
    deinit {
        sessionQueue.addOperationWithBlock { () -> Void in
            self.unsubscribeNotifications()
            self.session.stopRunning()
        }
    }
    
    func checkDeviceAuthorizationStatus() {
        AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo) { (granted) -> Void in
            self.sessionStatus = granted ? .Ready : .Forbidden
        }
    }
    
    private func initializeSessionInputs() {
        // this error can be reused, when used with `if-let`
        var error: NSError?
        
        // video
        let videoDevice = AVCaptureDevice.device(AVMediaTypeVideo, position: self.defaultDevicePosition)
        
        if let videoDeviceInput = AVCaptureDeviceInput(device: videoDevice, error: &error) {
            if session.canAddInput(videoDeviceInput) {
                self.session.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
                
                main {
                    self.previewLayer?.connection.videoOrientation = AVCaptureVideoOrientation(interfaceOrientation: self.delegate?.interfaceOrientation ?? .Portrait)
                }
            }
        } else {
            println("-CaptureViewController.initializeSessionInputs(): \(error)")
        }
        
        // audio
        if let audioDevice = AVCaptureDevice.devicesWithMediaType(AVMediaTypeAudio).first as? AVCaptureDevice,
            audioDeviceInput = AVCaptureDeviceInput(device: audioDevice, error: &error)
        {
            if session.canAddInput(audioDeviceInput) {
                session.addInput(audioDeviceInput)
            }
        } else {
            println("-CaptureViewController.initializeSessionInputs(): \(error)")
        }
        
        // movie output
        let movieFileOutput = AVCaptureMovieFileOutput()
        if session.canAddOutput(movieFileOutput) {
            session.addOutput(movieFileOutput)
            
            // connect
            if let connection = movieFileOutput.connectionWithMediaType(AVMediaTypeVideo) {
                connection.videoOrientation = .Portrait
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
    
    private func subscribeNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: subjectAreaDidChangeSelector,
            name: AVCaptureDeviceSubjectAreaDidChangeNotification,
            object: self.videoDeviceInput?.device)
    }
    
    private func unsubscribeNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: AVCaptureDeviceSubjectAreaDidChangeNotification,
            object: self.videoDeviceInput?.device)
    }
    
    private var subjectAreaDidChangeSelector: Selector {
        return "subjectAreaDidChange:"
    }
    @objc public func subjectAreaDidChange(notification: NSNotification) {
        let devPoint = CGPoint(x: 0.5, y: 0.5)
        
        async { () -> () in
            self.videoDeviceInput?.device.focusWithMode(.AutoFocus,
                exposeWithMode: .ContinuousAutoExposure,
                atDevicePoint: devPoint,
                monitorSubjectAreaChange: false)
        }
    }
    
    public func focusAndExposeTap(sender: UITapGestureRecognizer) {
        if let devPoint = previewLayer?.captureDevicePointOfInterestForPoint(sender.location) {
            
            async {
                self.videoDeviceInput?.device.focusWithMode(.AutoFocus,
                    exposeWithMode: .ContinuousAutoExposure,
                    atDevicePoint: devPoint,
                    monitorSubjectAreaChange: true)
            }
        }
    }
    
    // MARK: IBAction
    
    public func restartSession() {
        session.startRunning()
    }
    
    public func terminateSession() {
        session.stopRunning()
    }
    
    public var isTorchAvailable: Bool {
        return self.videoDeviceInput?.device.torchAvailable ?? false
    }
    public var isTorchActive: Bool {
        return self.videoDeviceInput?.device.torchActive ?? false
    }
    
    public func toggleTorch(completion: () -> ()) {
        if !isTorchAvailable { return }
        
        sessionQueue.addOperationWithBlock { () -> Void in
            self.videoDeviceInput!.device.lockedConfiguration(nil) {
                if self.videoDeviceInput!.device.torchActive {
                    self.videoDeviceInput!.device.torchMode = .Off
                } else {
                    self.videoDeviceInput!.device.torchMode = .On
                }
            }
            completion()
        }
    }
    
    public func changeCamera(completion: () -> ()) {
        // disable buttons => possible thread issues
        
        // perform async
        sessionQueue.addOperationWithBlock {
            let currentDev = self.videoDeviceInput?.device
            
            let preferredPos: AVCaptureDevicePosition
            switch currentDev?.position {
            case .Some(.Unspecified):
                preferredPos = self.defaultDevicePosition
            case .Some(.Front):
                preferredPos = .Back
            default:
                preferredPos = .Front
            }
            
            let newVideoDevice = AVCaptureDevice.device(AVMediaTypeVideo, position: preferredPos)
            newVideoDevice?.lockedConfiguration(nil) {
                newVideoDevice!.activeFormat = newVideoDevice!.formats.last as! AVCaptureDeviceFormat
            }
            if let newVideoDeviceInput = AVCaptureDeviceInput(device: newVideoDevice, error: nil) {
                
                // add new input if possible
                self.session.configuration {
                    // need to remove current input to test if new can be added
                    self.session.removeInput(self.videoDeviceInput)
                    
                    if self.session.canAddInput(newVideoDeviceInput) {
                        // need to update notifications
                        NSNotificationCenter.defaultCenter().removeObserver(self, name: AVCaptureDeviceSubjectAreaDidChangeNotification, object: currentDev)
                        NSNotificationCenter.defaultCenter().addObserver(self,
                            selector: self.subjectAreaDidChangeSelector,
                            name: AVCaptureDeviceSubjectAreaDidChangeNotification,
                            object: newVideoDevice)
                        
                        self.session.addInput(newVideoDeviceInput)
                        self.videoDeviceInput = newVideoDeviceInput
                    } else {
                        // use old input on failure
                        self.session.addInput(self.videoDeviceInput)
                    }
                }
                
            }
            completion()
        }
    }
    
    @IBAction func finishSession(sender: AnyObject) {
        if sessionStatus == .Recording {
            self.movieFileOutput?.stopRecording()
        }
    }
    
    @IBAction func toggleRecording(sender: AnyObject) {
        sessionQueue.addOperationWithBlock {
            switch self.sessionStatus {
            case .Ready:
                if UIDevice.currentDevice().multitaskingSupported {
                    self.backgroundRecordingID = UIApplication.sharedApplication().beginBackgroundTaskWithName("capture moment", expirationHandler: nil)
                }
                //self.movieFileOutput?.connectionWithMediaType(AVMediaTypeVideo).videoOrientation = self.previewLayer!.connection.videoOrientation
                
                self.movieFileOutput!.startRecordingToOutputFileURL(self.tmpURL(), recordingDelegate: self)
                self.sessionStatus = .Recording
                
            case .Recording:
                self.movieFileOutput?.stopRecording()
                
            default:
                break
            }
        }
    }
    
    @IBAction func handlePinchToZoomRecognizer(sender: UIPinchGestureRecognizer) {
        sessionQueue.addOperationWithBlock {
        let pinchZoomScaleDivider: CGFloat = 5.0
        if sender.state == .Changed {
            var error: NSError?
            if self.videoDeviceInput!.device.lockForConfiguration(&error) {
                let temp = self.videoDeviceInput!.device.videoZoomFactor + atan(sender.velocity / pinchZoomScaleDivider)
                if 1.0 <= temp && temp <= self.videoDeviceInput!.device.activeFormat.videoMaxZoomFactor {
                    self.videoDeviceInput!.device.videoZoomFactor = temp
                }
                self.videoDeviceInput!.device.unlockForConfiguration()
            } else {
                println("error: \(error)");
            }
        }
        }
    }
    
    func rotateToOrientation(toInterfaceOrientation orientation: UIInterfaceOrientation) {
        previewLayer?.connection.videoOrientation = orientation.captureVideoOrientation
        //self.movieFileOutput?.connectionWithMediaType(AVMediaTypeVideo).videoOrientation = orientation.captureVideoOrientation
    }
    
}

// MARK: AVCaptureFileOutputRecordingDelegate
extension VideoCaptureController: AVCaptureFileOutputRecordingDelegate {
    
    //optional func captureOutput(captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAtURL fileURL: NSURL!, fromConnections connections: [AnyObject]!)
    
    @objc public func captureOutput(captureOutput: AVCaptureFileOutput!,
        didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!,
        fromConnections connections: [AnyObject]!,
        error: NSError!)
    {
        if let outputFileURL = outputFileURL {
            delegate?.videoCaptureSessionStartsFinishing(self)
            VideoSquareCropper.squaredVideoURL(AVURLAsset(URL: outputFileURL, options: nil), fromOrientation: delegate!.interfaceOrientation, completion: { (url) -> Void in
                self.resultURL = url
                self.sessionStatus = .Ready
                
                // TODO: Swift 2.0 defer
                if let id = self.backgroundRecordingID {
                    UIApplication.sharedApplication().endBackgroundTask(id)
                }
            })
        } else {

        }
    }
    
}

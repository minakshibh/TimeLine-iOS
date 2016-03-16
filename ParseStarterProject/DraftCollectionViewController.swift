//
//  DraftCollectionViewController.swift
//  Timeline
//
//  Created by Valentin Knabel on 10.08.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import UIKit
import MediaPlayer
import MobileCoreServices

private let reuseIdentifier = "DraftCell"

class DraftCollectionViewController: UICollectionViewController, UIVideoEditorControllerDelegate, UIImagePickerControllerDelegate {
    
    var timeline: Timeline?
    
    private var layout: CSStickyHeaderFlowLayout? {
        return collectionViewLayout as? CSStickyHeaderFlowLayout
    }
    
    var selectedIndex: Int = 0 {
        willSet {
            if newValue == selectedIndex { return }
            let new = self.collectionView?.cellForItemAtIndexPath(NSIndexPath(forItem: newValue, inSection: 0)) as? DraftCollectionViewCell
            new?.previewed = true
            let old = self.collectionView?.cellForItemAtIndexPath(NSIndexPath(forItem: self.selectedIndex, inSection: 0)) as? DraftCollectionViewCell
            old?.previewed = false
        }
        didSet {
            self.barView?.moment = self.drafts.count == 0 ? nil : self.drafts[self.selectedIndex]
            self.headerView?.draftPreview.moment = self.drafts.count == 0 ? nil : self.drafts[self.selectedIndex]
            self.headerView?.setNeedsDisplay()
            
            self.collectionViewLayout.invalidateLayout()
        }
    }
    var drafts = Array(Storage.session.drafts.reverse())
    weak var headerView: DraftPreviewCollectionReusableView?
    var barView: DraftBarCollectionReusableView?
    var titleView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarController?.delegate = self
        navigationController?.delegate = self
        
//         self.hidesBottomBarWhenPushed = true
        //navigationItem.setRightBarButtonItems(buttons, animated: true)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Do any additional setup after loading the view.
        self.collectionView?.reloadData()
        
        if let tl = timeline,
            let _ = navigationController
        {
            navigationItem.rightBarButtonItem = nil
            navigationItem.title = tl.name
        }
        
        self.collectionView?.registerClass(DraftPreviewCollectionReusableView.self, forSupplementaryViewOfKind: CSStickyHeaderParallaxHeader, withReuseIdentifier: "ParallaxHeader")
        //self.collectionView?.registerClass(DraftPreviewCollectionReusableView.self, forSupplementaryViewOfKind: CSStickyHeaderParallaxHeader, withReuseIdentifier: "ParallaxHeader")
        self.layout?.parallaxHeaderReferenceSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.width)
        //self.collectionView?.registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "StickyHeader")
        self.layout?.headerReferenceSize = CGSizeMake(self.view.frame.size.width, 53)
        self.collectionView?.registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "Footer")
        
        delay(0.001) {
            if !Storage.session.walkedThroughMoments {
                Storage.session.walkedThroughMoments = true
                self.performSegueWithIdentifier("WalkthroughMoments", sender: self)
            }
        }
        let right: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "Back to Record"), style: .Plain, target: self, action: "goToRecordScreen")
        let left: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "Back to previous screen"), style: .Plain, target: self, action: "goToRecordScreen")
        navigationItem.leftBarButtonItem = left
        navigationItem.rightBarButtonItem = right
        
        NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "update", userInfo: nil, repeats: false)

    }
    func update(){
//        self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height+1)
    }
    override func viewWillAppear(animated: Bool) {
        NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "update", userInfo: nil, repeats: false)

    }
    func goToRecordScreen () {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc : drawer = storyboard.instantiateViewControllerWithIdentifier("drawerID") as! drawer
        var nav = appDelegate.window?.rootViewController as? UINavigationController
        
        nav = UINavigationController.init(rootViewController:vc )
        
        hidesBottomBarWhenPushed = true
        
        let transition: CATransition = CATransition()
        let timeFunc : CAMediaTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.duration = 0.25
        transition.timingFunction = timeFunc
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight    //kCATransitionFromLeft
        nav!.view.layer.addAnimation(transition, forKey: kCATransition)
        appDelegate.window?.rootViewController = nav
        appDelegate.window?.makeKeyAndVisible()

    }
    
    override func viewWillDisappear(animated: Bool) {
        self.headerView?.draftPreview.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if segue.identifier == "SendMoment" {
            let dest = segue.destinationViewController as! SendMomentTableViewController
            dest.moment = drafts[selectedIndex]
        } else if segue.identifier == "Upload" {
            let dest = segue.destinationViewController as! ModalUploadViewController
            dest.moment = drafts[selectedIndex]
            dest.timeline = timeline!
        } else if segue.identifier == "EditOverlay" {
            let dest = segue.destinationViewController as! EditOverlayViewController
            dest.moment = drafts[selectedIndex]
        }
    }
    
    // MARK: IBActions
    
    @IBAction func dismissFix() {
        weak var s = self
        delay(0.1) { s?.dismissViewControllerAnimated(true, completion: nil) }
    }
    
    @IBAction func deleteCurrent() {
        headerView?.draftPreview.stop()
        
        let alert = UIAlertController(title: local(.MomentAlertDeleteConfirmTitle), message: local(.MomentAlertDeleteConfirmMessage), preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: local(.MomentAlertDeleteConfirmActionCancel), style: .Default, handler: nil))
        alert.addAction(UIAlertAction(title: local(.MomentAlertDeleteConfirmActionDelete), style: .Destructive) { _ in
            self.headerView?.draftPreview.moment = nil
            
            let oldIndex = self.selectedIndex
            let oldURL = self.drafts[oldIndex].localVideoURL!
            Storage.session.drafts.removeAtIndex(Storage.session.drafts.count - (oldIndex+1))
            Storage.save()
            async {
                _ = try? NSFileManager.defaultManager().removeItemAtURL(oldURL)
            }
                
            self.drafts.removeAtIndex(oldIndex)
            self.collectionView?.deleteItemsAtIndexPaths([NSIndexPath(forItem: oldIndex, inSection: 0)])
            self.selectedIndex = max(0, oldIndex - 1)
        })
        presentAlertController(alert) { [weak self] in
            self?.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        //#warning Incomplete method implementation -- Return the number of sections
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //#warning Incomplete method implementation -- Return the number of items in the section
        //print("Drafts: \(drafts.count)")
        return drafts.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! DraftCollectionViewCell
            
        // Configure the cell
        cell.moment = drafts[indexPath.item]
        if indexPath.item == selectedIndex {
            cell.previewed = true
        } else {
            cell.previewed = false
        }
    
        return cell
    }

    // MARK: UICollectionViewDelegate
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        switch kind {
        case CSStickyHeaderParallaxHeader:
            headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "ParallaxHeader", forIndexPath: indexPath) as? DraftPreviewCollectionReusableView
            if drafts.count > selectedIndex {
                headerView?.draftPreview.moment = drafts[selectedIndex]
            } else {
                headerView?.draftPreview.moment = nil
            }
            return headerView!
            
        case UICollectionElementKindSectionHeader:
            barView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "StickyHeader", forIndexPath: indexPath) as? DraftBarCollectionReusableView
            if drafts.count > selectedIndex {
                barView?.moment = drafts[selectedIndex]
            } else {
                barView?.moment = nil
            }
            return barView!
            
        default:
            return collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "Footer", forIndexPath: indexPath) 
        }
    }
    
    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        selectedIndex = indexPath.item
    }
    
    @IBAction func trimMoment() {
        headerView?.draftPreview.stop()
        
        let editor = UIVideoEditorController()
        editor.delegate = self
        editor.videoQuality = .TypeHigh
        editor.videoMaximumDuration = 10.0
        editor.videoPath = drafts[selectedIndex].localVideoURL!.path!
        presentViewController(editor, animated: true) {
            editor.navigationBar.tintColor = .barButtonTintColor()
            editor.navigationBar.barTintColor = .topBarTintColor()
            editor.toolbar.barStyle = .Black
            editor.toolbar.tintColor = .barButtonTintColor()
            editor.toolbar.barTintColor = .bottomBarTintColor()
        }
        editor.navigationBar.tintColor = UIColor.barButtonTintColor()
        editor.navigationBar.barTintColor = UIColor.topBarTintColor()
        editor.toolbar.barStyle = .Black
        editor.toolbar.tintColor = UIColor.barButtonTintColor()
        editor.toolbar.barTintColor = UIColor.bottomBarTintColor()
    }

    var imagePicker: UIImagePickerController?
    @IBAction func presentImagePicker() {
        imagePicker = UIImagePickerController()
        imagePicker?.delegate = self
        imagePicker?.mediaTypes = [kUTTypeMovie as String]
        imagePicker?.sourceType = .PhotoLibrary
        presentViewController(imagePicker!, animated: true, completion: nil)
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let url = info[UIImagePickerControllerMediaURL] as? NSURL {
            let name = Moment.newName()
            let newURL = Moment.documentURL(name, suffix: "mp4")
            let asset = AVAsset(URL: url)
            VideoSquareCropper.squaredVideoURL(asset, fromOrientation: .Unknown, completion: { (url) -> Void in
                do {
                    try NSFileManager.defaultManager().moveItemAtURL(url, toURL: newURL)
                    let asset = AVURLAsset(URL: newURL, options: nil)
                    let seconds = Int(round(CMTimeGetSeconds(asset.duration)))
                    let newMoment = Moment(persistent: true, pathName: name, remoteStreamURL: nil, remoteVideoURL: nil, remoteThumbURL: nil, size: nil, duration: seconds, contentType: nil, overlayPosition: nil, overlayText: nil, overlaySize: nil, overlayColor: nil, state: .LocalOnly, parent: nil)
                    Storage.session.drafts.append(newMoment)
                    Storage.save()
                    self.drafts.insert(newMoment, atIndex: 0)
                    self.reloadData()
                    self.selectedIndex = 0


                } catch {
                    print(error)
                }
            })
            picker.dismissViewControllerAnimated(true, completion: nil)
        }
    }
/*
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return true
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
        
    }*/

}

extension DraftCollectionViewController {
    
    func reportError(editor: UIVideoEditorController, error: NSError?) {
        editor.dismissViewControllerAnimated(true) {
            let moment = self.drafts[self.selectedIndex]
            let old = moment.localVideoURL
            if let error = error {
                let alert = UIAlertController(title: local(.MomentAlertTrimErrorTitle), message: error.localizedDescription, preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: local(.MomentAlertTrimErrorActionDismiss), style: .Default, handler: nil))
                self.presentAlertController(alert)
            } else {
                UIImage.invalidateMoment(moment)
                self.headerView?.draftPreview.moment = moment
                self.headerView?.setNeedsDisplay()
                let draftCell = self.collectionView?.cellForItemAtIndexPath(NSIndexPath(forItem: self.selectedIndex, inSection: 0)) as? DraftCollectionViewCell
                draftCell?.moment = moment
                self.barView?.moment = moment
                
                async { _ = try? NSFileManager.defaultManager().removeItemAtURL(old!) }
            }
        }
    }
    
    func videoEditorController(editor: UIVideoEditorController, didSaveEditedVideoToPath editedVideoPath: String) {
        let asset = AVURLAsset(URL: NSURL(fileURLWithPath: editedVideoPath), options: nil)
        let seconds = Int(round(CMTimeGetSeconds(asset.duration)))
        
        let alert = UIAlertController(title: local(.MomentAlertTrimKeepTitle), message: local(.MomentAlertTrimKeepMessage), preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: local(.MomentAlertTrimKeepActionDelete), style: .Destructive, handler: { _ in
            // override moment-file
            let moment = self.drafts[self.selectedIndex]

            let newName = Moment.newName()
            do {
                try NSFileManager.defaultManager().moveItemAtURL(NSURL(fileURLWithPath: editedVideoPath), toURL: Moment.documentURL(newName, suffix: "mp4"))
                let old = moment.localVideoURL
                moment.pathName = newName
                moment.duration = seconds
                Storage.save()
                
                try NSFileManager.defaultManager().removeItemAtURL(old!)
                
                self.collectionView?.reloadData()
                editor.dismissViewControllerAnimated(true, completion: nil)
            } catch let error as NSError {
                self.reportError(editor, error: error)
            } catch {
                fatalError()
            }
        }))
        alert.addAction(UIAlertAction(title: local(.MomentAlertTrimKeepActionKeep), style: .Default, handler: { _ in
            let newMoment = Moment(persistent: true, pathName: Moment.newName(), remoteStreamURL: nil, remoteVideoURL: nil, remoteThumbURL: nil, size: nil, duration: seconds, contentType: nil, overlayPosition: nil, overlayText: nil, overlaySize: nil, overlayColor: nil, state: .LocalOnly, parent: nil)
            do {
                try NSFileManager.defaultManager().moveItemAtURL(NSURL(fileURLWithPath: editedVideoPath), toURL: newMoment.localVideoURL!)
                Storage.session.drafts.append(newMoment)
                Storage.save()
                self.drafts = Array(Storage.session.drafts.reverse())
                self.collectionView?.reloadData()
                
                editor.dismissViewControllerAnimated(true, completion: nil)
                
            } catch let error as NSError {
                self.reportError(editor, error: error)
            } catch {
                fatalError()
            }
        }))
        editor.presentAlertController(alert)
    }
    
}

extension DraftCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        func calcWidth(count: Int) -> CGFloat {
            let c = CGFloat(count)
            return floor((collectionView.bounds.size.width - 2*5.0 - c * 3.0) / c)
        }
        let width: CGFloat
        switch UIApplication.sharedApplication().statusBarOrientation {
        case .LandscapeLeft, .LandscapeRight:
            width = calcWidth(4)
        case .Portrait, .PortraitUpsideDown, .Unknown:
            width = calcWidth(3)
        }
        return CGSize(width: width, height: width)
    }

    override func willTransitionToTraitCollection(newCollection: UITraitCollection, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animateAlongsideTransition({ _ in }) { _ in
            self.collectionView!.performBatchUpdates({
                
                self.collectionView?.collectionViewLayout.invalidateLayout()
                },
                completion: nil)
        }
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        self.collectionView!.performBatchUpdates({
            
            self.collectionView?.collectionViewLayout.invalidateLayout()
            },
            completion: nil)
    }
    
}

extension DraftCollectionViewController {
    
    @IBAction func sendMoment() {
        headerView?.draftPreview.stop()
        if(Storage.session.currentUser?.timelines.count != nil)
        {  if(Storage.session.currentUser!.timelines.count==1)
        {
            Storage.session.currentUser?.timelines.each({ tl in
                //                print("\(tl.fullName) ******\(tl.duration) ***** )  ***** \(local(.DraftAlertConfirmUploadMessage))")
                //                print("-------\(tl.duration)-------")
                let profileTimeUsed = tl.duration as Int
                let selectedVideoTime = NSUserDefaults.standardUserDefaults().valueForKey("selectedVideoTime") as! Int
                let totalTime = selectedVideoTime + profileTimeUsed
                let leftTime = 300 - profileTimeUsed;
//                print("profileTimeUsed = \(profileTimeUsed) and selectedVideoTime= \(selectedVideoTime)")
                if(totalTime>300)
                {
                    let alert=UIAlertController(title: "Limit Exceed", message: "You have \(leftTime)s left. Kindly trim the video before uplaod", preferredStyle: UIAlertControllerStyle.Alert)
                    
                    //no event handler (just close dialog box)
                    alert.addAction(title: "Okay",
                        style: .Default) { _ in
                            
                            self.trimVideo(leftTime)
                    }
                    //event handler with closure
                    self.presentViewController(alert, animated: true, completion: nil)
                   return 
                }
                
            })
            
            }
        }
        
        if let _ = timeline {
            performSegueWithIdentifier("Upload", sender: nil)
        } else {
            let alert = UIAlertController(title: local(.DraftAlertPickTimelineTitle),
                message: local(.DraftAlertPickTimelineMessage),
                preferredStyle: .ActionSheet)
            alert.addAction(title: local(.DraftAlertPickTimelineCancel), style: .Cancel, handler: nil)
            
            //             print(" \(LocalizedString.DurationFormatSeconds1d)   **** \(self.moment?.duration))")
            
            Storage.session.currentUser?.timelines.each({ tl in
                alert.addAction(title: tl.fullName, style: .Default, handler: { (_) -> Void in
                    
                    //--- check if loged in user timline limit exceeds
                    let profileTimeUsed = tl.duration as Int
                    let selectedVideoTime = NSUserDefaults.standardUserDefaults().valueForKey("selectedVideoTime") as! Int
                    let totalTime = selectedVideoTime + profileTimeUsed
                    let leftTime = 300 - profileTimeUsed;
//                    print("profileTimeUsed = \(profileTimeUsed) and selectedVideoTime= \(selectedVideoTime)")
                    if(totalTime>300)
                    {
                        let alert=UIAlertController(title: "Limit Exceed", message: "You have \(leftTime)s left. Kindly trim the video before uplaod", preferredStyle: UIAlertControllerStyle.Alert)
                        
                        //no event handler (just close dialog box)
                        alert.addAction(title: "Okay",
                            style: .Default) { _ in
                                
                                self.trimVideo(leftTime)
                        }
                        //event handler with closure
                        self.presentViewController(alert, animated: true, completion: nil)
                        return
                    }
                    //------
                    
                    
                    let confirm = UIAlertController(title: lformat(.DraftAlertConfirmUploadTitle1s, tl.fullName),
                        message: local(.DraftAlertConfirmUploadMessage),
                        preferredStyle: .Alert)
                    confirm.addAction(title: local(.DraftAlertConfirmUploadCancel),
                        style: .Cancel,
                        handler: nil)
                    confirm.addAction(title: local(.DraftAlertConfirmUploadUpload),
                        style: .Default) { _ in
                            
                            self.timeline = tl
                            self.performSegueWithIdentifier("Upload", sender: nil)
                    }
                    //print("\(tl.fullName) ******\(tl.duration) *****   ***** \(local(.DraftAlertConfirmUploadMessage))")
                    self.presentAlertController(confirm)
                })
            })
            view.tintColor = UIColor.tintColor()
            presentAlertController(alert)
        }
    }
    func trimVideo(videoTime: Int)  {
        headerView?.draftPreview.stop()
        
        let editor = UIVideoEditorController()
        editor.delegate = self
        editor.videoQuality = .TypeHigh
        editor.videoMaximumDuration = Double(videoTime)
        editor.videoPath = drafts[selectedIndex].localVideoURL!.path!
        presentViewController(editor, animated: true) {
            editor.navigationBar.tintColor = .barButtonTintColor()
            editor.navigationBar.barTintColor = .topBarTintColor()
            editor.toolbar.barStyle = .Black
            editor.toolbar.tintColor = .barButtonTintColor()
            editor.toolbar.barTintColor = .bottomBarTintColor()
        }
        editor.navigationBar.tintColor = UIColor.barButtonTintColor()
        editor.navigationBar.barTintColor = UIColor.topBarTintColor()
        editor.toolbar.barStyle = .Black
        editor.toolbar.tintColor = UIColor.barButtonTintColor()
        editor.toolbar.barTintColor = UIColor.bottomBarTintColor()
        
    }
}

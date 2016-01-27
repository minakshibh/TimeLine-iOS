//
//  EditProfileTableViewController.swift
//  Timeline
//
//  Created by Valentin Knabel on 06.08.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import UIKit
import Parse

class EditProfileTableViewController: TintedHeaderTableViewController {

    var imagePicker: UIImagePickerController?
    
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var userImageView: ProfileImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = true
        
        if let user = PFUser.currentUser() {
            userNameLabel.text = user.username
            emailLabel.text = user.email
            userImageView.user = Storage.session.currentUser
        }

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.Done, target: self, action: "saveUser")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.item {
        case 1:
            self.changeProfileImage()
            
        default:
            break
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}

import MobileCoreServices

extension EditProfileTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func changeProfileImage() {
        let alert = UIAlertController(title: local(.SettingsSheetImageSourceTitle), message: nil, preferredStyle: .ActionSheet)
        alert.addAction(UIAlertAction(title: local(.SettingsSheetImageSourceActionCancel), style: UIAlertActionStyle.Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: local(.SettingsSheetImageSourceActionCamera), style: UIAlertActionStyle.Default, handler: presentImagePicker(.Camera)))
        alert.addAction(UIAlertAction(title: local(.SettingsSheetImageSourceActionLibrary), style: UIAlertActionStyle.Default, handler: presentImagePicker(.PhotoLibrary)))
        presentAlertController(alert)
    }
    
    func presentImagePicker(sourceType: UIImagePickerControllerSourceType)(alert: UIAlertAction!) {
        imagePicker = UIImagePickerController()
        imagePicker?.delegate = self
        imagePicker?.mediaTypes = [kUTTypeImage as String]
        imagePicker?.sourceType = sourceType
        if sourceType == .Camera {
            imagePicker?.showsCameraControls = true
            imagePicker?.cameraDevice = .Front
        }
        presentViewController(imagePicker!, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        print(info)
        if let rawImage = (info[UIImagePickerControllerEditedImage] ?? info[UIImagePickerControllerOriginalImage]) as? UIImage {
            let orientation = UIImageOrientation(rawValue: 0)!
            let image = rawImage.rotateImageAppropriately(orientation)
            userImageView.setUserImage(image)
            picker.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
}

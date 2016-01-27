//
//  SignUpViewController.swift
//  Timeline
//
//  Created by Valentin Knabel on 05.08.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import UIKit
import Bolts
import Parse
import ParseUI

class SignUpViewController: PFSignUpViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // adjust color
        let tintedImage = signUpView?.dismissButton?.imageView?.image?.imageWithRenderingMode(.AlwaysTemplate)
        signUpView?.dismissButton?.imageView?.tintColor = UIColor.whiteColor()
        signUpView?.dismissButton?.setImage(tintedImage, forState: UIControlState.Normal)
        signUpView?.dismissButton?.imageView?.image = nil
        signUpView?.dismissButton?.imageView?.image = tintedImage
        
        // set title
        self.signUpView?.logo = UIImageView(image: UIImage(assetIdentifier: .Logo))
        (self.signUpView?.logo as? UIImageView)?.contentMode = .ScaleAspectFill
        
        // set background
        let backgroundView = UIImageView(image: UIImage(assetIdentifier: .Background))
        backgroundView.contentMode = .ScaleAspectFill
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        self.signUpView?.insertSubview(backgroundView, atIndex: 0)
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[back]-0-|", options: NSLayoutFormatOptions.AlignAllCenterY, metrics: nil, views: ["back": backgroundView]))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[back]-0-|", options: NSLayoutFormatOptions.AlignAllCenterX, metrics: nil, views: ["back": backgroundView]))
        
        signUpView?.usernameField?.delegate = self
    }

    override func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let result = (textField.text ?? "" as NSString).stringByReplacingCharactersInRange(range, withString: string)
        textField.text = result.lowercaseString
        return false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

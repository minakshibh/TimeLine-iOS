//
//  EditOverlayViewController.swift
//  Timeline
//
//  Created by Valentin Knabel on 03.09.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import UIKit

class EditOverlayViewController: UIViewController {

    var moment: Moment!
    
    /// The maximum to the top: >= 8
    @IBOutlet var topLayoutConstraint: NSLayoutConstraint!
    /// The minimum to the bottom: <= -8
    @IBOutlet var bottomLayoutConstraint: NSLayoutConstraint!
    /// MIN: topLayoutConstraint.constant
    /// MAX: momentImageView.frame.size.height + bottomLayoutConstraint.constant
    @IBOutlet var positioningLayoutConstraint: NSLayoutConstraint!
    @IBOutlet var keyboardLayoutConstraint: NSLayoutConstraint!
    @IBOutlet var positioningGestureRecognizer: UIGestureRecognizer!
    
    @IBOutlet var momentImageView: MomentImageView!
    @IBOutlet var textField: UITextField!
    @IBOutlet var textFieldContainer: UIView!
    
    private var initialY: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // auto rotation
        navigationController?.delegate = self
        
        // apply moment
        momentImageView.moment = moment
        textField.attributedPlaceholder = NSAttributedString(string: textField.text ?? "",
            attributes:[NSForegroundColorAttributeName: UIColor.from(hexString: "DADADA")!])
        textField.textColor = moment.overlayColor ?? textField.textColor
        textField.text = moment.overlayText
        textField.font = UIFont(descriptor: textField.font!.fontDescriptor(), size: CGFloat(moment.overlaySize ?? textField.font!.pointSize))
        
        // notifications
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: #selector(EditOverlayViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: #selector(EditOverlayViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        view.setNeedsLayout()
        delay(0.01) {
            self.positioningLayoutConstraint.constant = self.validPosition(CGFloat(self.moment.overlayPosition ?? 0.66) * self.maxPosition)
            
            // initiate
            self.textField.becomeFirstResponder()
        }
        
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
}

// MARK: - UIGestureRecognizerDelegate
extension EditOverlayViewController: UIGestureRecognizerDelegate {
    
    private var minPosition: CGFloat {
        return topLayoutConstraint.constant
    }
    private var maxPosition: CGFloat {
        return momentImageView.frame.size.height - abs(bottomLayoutConstraint.constant) - textFieldContainer.frame.size.height
    }
    private var relativePosition: CGFloat {
        return (positioningLayoutConstraint.constant - minPosition) / maxPosition
    }
    private func validPosition(newPosition: CGFloat) -> CGFloat {
        return max(minPosition, min(newPosition, maxPosition))
    }
    
    @IBAction func moveOverlay(sender: UIPanGestureRecognizer) {
        
        var translatedY = sender.translationInView(momentImageView).y
        
        if sender.state == UIGestureRecognizerState.Began {
            initialY = positioningLayoutConstraint.constant
        }
        
        translatedY = initialY + translatedY
        
        //sender.view!.frame.origin = translatedPoint
        positioningLayoutConstraint.constant = validPosition(translatedY)
        view.layoutIfNeeded()
        
        if sender.state == UIGestureRecognizerState.Ended {
            let velocityY = 0.2 * sender.velocityInView(view).x
            
            let finalY = translatedY + velocityY
            
            let animationDuration: NSTimeInterval = NSTimeInterval(abs(velocityY) * 0.0002 + 0.2)
            
            UIView.animateWithDuration(animationDuration, animations: { () -> Void in
                self.positioningLayoutConstraint.constant = self.validPosition(finalY)
                self.view.layoutIfNeeded()
            })
        }
    }
}

// MARK: IBAction
extension EditOverlayViewController {
    
    @IBAction func saveMoment() {
        let text = (textField.text ?? "").stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        let color = textField.textColor
        let size = Int(textField.font?.pointSize ?? 0)
        let position = Float(relativePosition)
        if text.characters.count > 0 {
            moment.overlayText = text
            moment.overlayColor = color
            moment.overlaySize = size
            moment.overlayPosition = position
            Storage.save()
            
            self.dismissViewControllerAnimated(true, completion: nil)
        } else {
            let alert = UIAlertController(
                title: local(LocalizedString.MomentAlertOverlayNoneTitle),
                message: local(.MomentAlertOverlayNoneMessage),
                preferredStyle: .Alert)
            alert.addAction(UIAlertAction(
                title: local(.MomentAlertOverlayNoneActionSave),
                style: .Default,
                handler: { _ in
                    self.moment.overlayText = nil
                    self.moment.overlayColor = nil
                    self.moment.overlaySize = nil
                    self.moment.overlayPosition = nil
                    Storage.save()
                    
                    self.dismissKeyboard()
                    
                    self.dismissViewControllerAnimated(true, completion: nil)
            }))
            alert.addAction(UIAlertAction(
                title: local(.MomentAlertOverlayNoneActionDismiss),
                style: .Cancel,
                handler: nil)
            )
            presentAlertController(alert)
        }
    }
    
}

// MARK: - Keyboard
extension EditOverlayViewController {
    
    private func animateKeyboard(notification notification: NSNotification, animation: (CGFloat) -> (), completion: (Bool) -> ()) {
        let info  = notification.userInfo!
        let value: AnyObject = info[UIKeyboardFrameEndUserInfoKey]!
        let duration = info[UIKeyboardAnimationDurationUserInfoKey] as! Double
        let animationCurve = UIViewAnimationCurve(rawValue: info[UIKeyboardAnimationCurveUserInfoKey] as! Int)!
        
        let rawFrame = value.CGRectValue
        let keyboardFrame = view.convertRect(rawFrame, fromView: nil)
        
        view.layoutIfNeeded()
        
        UIView.animateWithDuration(duration,
            delay: 0.0,
            options: animationCurve.animationOptionsValue(),
            animations: {
                animation(keyboardFrame.height)
                self.view.layoutIfNeeded()
            },
            completion: completion)
    }
    
    @IBAction func dismissKeyboard() {
        textField.resignFirstResponder()
    }
    
    func keyboardWillShow(notification: NSNotification) {
        keyboardLayoutConstraint.constant = textFieldContainer.frame.origin.y + textFieldContainer.frame.size.height
        positioningLayoutConstraint.active = false
        
        animateKeyboard(notification: notification, animation: {
            self.keyboardLayoutConstraint.constant = $0
            }, completion: { _ in
                self.positioningGestureRecognizer.enabled = false
        })
    }
    
    func keyboardWillHide(notification: NSNotification) {
        animateKeyboard(notification: notification, animation: { _ in
                self.positioningLayoutConstraint.active = true
            }, completion: { _ in
                self.positioningGestureRecognizer.enabled = true
        })
    }
    
}

// MARK: - UITextFieldDelegate
extension EditOverlayViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        dismissKeyboard()
        return false
    }
    
}

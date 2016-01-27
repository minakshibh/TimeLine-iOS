//
//  DraftCollectionViewCell.swift
//  Timeline
//
//  Created by Valentin Knabel on 11.08.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import UIKit
import AVFoundation

class DraftCollectionViewCell: UICollectionViewCell {
    
    var previewed: Bool = false {
        willSet {
            UIView.animateWithDuration(0.3,
                animations: {
                    self.selectionView.hidden = false
                    self.selectionView.alpha = newValue ? 1.0 : 0.0
                    return
                },
                completion: { b in
                    self.selectionView.hidden = !newValue
                    return
            })
        }
    }
    var moment: Moment? {
        didSet {
            UIImage.getImage(self.moment!) { image in
                main {
                    self.activityIndicatorView.stopAnimating()
                    //self.playImageView.hidden = false
                    self.previewImageView.image = image
                    self.durationLabel.text = lformat(LocalizedString.DurationFormatSeconds1d, self.moment?.duration ?? 0)
                }
            }
        }
    }
    @IBOutlet var previewImageView: UIImageView!
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet var selectionView: UIView!
    @IBOutlet var durationLabel: UILabel!
    //@IBOutlet var playImageView: UIImageView!
    
}

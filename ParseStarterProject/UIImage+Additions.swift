//
//  UIImage+Additions.swift
//  Timeline
//
//  Created by Valentin Knabel on 11.08.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import UIKit
import AVFoundation
import CoreGraphics
import Alamofire

private let momentNameImageCache = NSCache()

extension UIImage {

    static func invalidateMoment(moment: Moment) {
        if let name = moment.pathName {
            momentNameImageCache.removeObjectForKey(name)
        }
    }

    static func getImage(moment: Moment, completion: (UIImage?) -> Void) {
        // file > cache
        // movie > file > cache
        // thumb url > file > cache
        // movie > m file > file > cache
        if let name = moment.pathName {
            // in cache
            if let image: AnyObject = momentNameImageCache.objectForKey(name) {
                completion(UIImage(CGImage: image as! CGImageRef))
                return
            }
            async {
                // image > cache
                if let _ = moment.localThumbURL {
                    if let path = moment.localThumbURL?.path,
                        let image = UIImage(contentsOfFile: path)
                    {
                        momentNameImageCache.setObject(image.CGImage!, forKey: name)
                        main { completion(image) }
                        return
                    }
                }

                // video > image > cache
                if let videoURL = moment.localVideoURL
                {
                    let asset = AVAsset(URL: videoURL)
                    let imageGenerator = AVAssetImageGenerator(asset: asset)
                    imageGenerator.appliesPreferredTrackTransform = true

                    var time = asset.duration
                    //If possible - take not the first frame (it could be completely black or white on camara's videos)
                    time.value = min(time.value, 1)

                    do {
                        let imageRef = try imageGenerator.copyCGImageAtTime(time, actualTime: nil)
                        let image = UIImage(CGImage: imageRef)
                        momentNameImageCache.setObject(imageRef, forKey: name)
                        main { completion(image) }
                        return
                    } catch {

                    }
                }

                // thumb url > image > cache
                if let remoteThumbURL = moment.remoteThumbURL {
                    let request = download(.GET, remoteThumbURL) { (localURL, response) -> NSURL in
                        if response.statusCode == 200 {
                            return moment.localThumbURL!
                        }
                        return localURL
                    }
                    request.delegate.queue.addOperationWithBlock {
                        if let image = UIImage(contentsOfFile: moment.localThumbURL!.path!) {
                            momentNameImageCache.setObject(image.CGImage!, forKey: name)
                            main { completion(image) }
                        } else {
                            main { completion(nil) }
                        }
                    }
                    return
                } else {
                    main { completion(nil) }
                }
            }
        }
    }

    func rotateImageAppropriately(imageOrientation: UIImageOrientation) -> UIImage {
        print(self.imageOrientation.rawValue)

        if (self.imageOrientation == UIImageOrientation.Up) {
            return self
        }

        UIGraphicsBeginImageContextWithOptions(self.size, true, self.scale)
        self.drawInRect(CGRect(origin: CGPoint(x: 0, y: 0), size: size))
        let properlyRotatedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return properlyRotatedImage
        
    }
}


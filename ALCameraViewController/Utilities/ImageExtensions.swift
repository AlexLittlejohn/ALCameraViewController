//
//  ALImageExtensions.swift
//  ALCameraViewController
//
//  Created by Alex Littlejohn on 2015/11/06.
//  Copyright © 2015 zero. All rights reserved.
//

import UIKit

extension UIImage {
    func crop(frame: CGRect, scale: CGFloat) -> UIImage {
        
        if frame.size == size && frame.origin == CGPoint.zero {
            return self
        }
        
        let drawPoint = CGPointZero
        UIGraphicsBeginImageContext(frame.size)
        let context = UIGraphicsGetCurrentContext()
        CGContextTranslateCTM(context, -frame.origin.x, -frame.origin.y)
        drawAtPoint(drawPoint)
        let croppedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        return croppedImage
    }
    
    func fixFrontCameraOrientation() -> UIImage {
        var newOrient:UIImageOrientation
        switch imageOrientation {
        case .Up:
            newOrient = .UpMirrored
        case .UpMirrored:
            newOrient = .Up
        case .Down:
            newOrient = .DownMirrored
        case .DownMirrored:
            newOrient = .Down
        case .Left:
            newOrient = .RightMirrored
        case .LeftMirrored:
            newOrient = .Right
        case .Right:
            newOrient = .LeftMirrored
        case .RightMirrored:
            newOrient = .Left
        }
        return UIImage(CGImage: CGImage!, scale: scale, orientation: newOrient)
    }
}
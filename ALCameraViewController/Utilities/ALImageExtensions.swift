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
        let screenScale = UIScreen.mainScreen().scale
        var mutableRect = frame
        mutableRect.origin.x *= screenScale
        mutableRect.origin.y *= screenScale
        mutableRect.size.width *= screenScale
        mutableRect.size.height *= screenScale
        let drawPoint = CGPointZero
        UIGraphicsBeginImageContextWithOptions(mutableRect.size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        CGContextTranslateCTM(context, -mutableRect.origin.x, -mutableRect.origin.y)
        CGContextScaleCTM(context, scale * screenScale, scale * screenScale)
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
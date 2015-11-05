//
//  ALUtilities.swift
//  ALCameraViewController
//
//  Created by Alex Littlejohn on 2015/06/25.
//  Copyright (c) 2015 zero. All rights reserved.
//

import UIKit

internal func radians(degrees: Double) -> Double {
    return degrees / 180 * M_PI
}

internal func SpringAnimation(animations: () -> Void) {
    UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: [UIViewAnimationOptions.CurveEaseInOut, UIViewAnimationOptions.BeginFromCurrentState], animations: {
        animations()
        }, completion: nil)
}

internal func LocalizedString(key: String) -> String {
    return NSLocalizedString(key, tableName: "ALCameraView", bundle: NSBundle(forClass: ALCameraViewController.self), comment: key)
}

internal func currentRotation() -> Double {
    var rotation: Double = 0
    
    if UIDevice.currentDevice().orientation == .LandscapeLeft {
        rotation = 90
    } else if UIDevice.currentDevice().orientation == .LandscapeRight {
        rotation = 270
    } else if UIDevice.currentDevice().orientation == .PortraitUpsideDown {
        rotation = 180
    }
    
    return rotation
}

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
    
    func rotate(degrees: Double) -> UIImage {
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        let rads = CGFloat(radians(degrees))
        CGContextRotateCTM(context, rads)
        drawAtPoint(CGPointMake(0, 0))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
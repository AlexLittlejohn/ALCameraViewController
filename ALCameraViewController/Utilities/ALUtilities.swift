//
//  ALUtilities.swift
//  ALCameraViewController
//
//  Created by Alex Littlejohn on 2015/06/25.
//  Copyright (c) 2015 zero. All rights reserved.
//

import UIKit

internal func SpringAnimation(animations: () -> Void) {
    UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: UIViewAnimationOptions.CurveEaseInOut | UIViewAnimationOptions.BeginFromCurrentState, animations: {
        animations()
        }, completion: nil)
}

internal func LocalizedString(key: String) -> String {
    return NSLocalizedString(key, tableName: "ALCameraView", bundle: NSBundle(forClass: ALCameraViewController.self), comment: key)
}

extension UIImage {
    func crop(frame: CGRect, scale: CGFloat) -> UIImage {
        
        var drawPoint = CGPointZero
        
        UIGraphicsBeginImageContextWithOptions(frame.size, false, 0)
        
        let context = UIGraphicsGetCurrentContext()
        
        CGContextTranslateCTM(context, -frame.origin.x, -frame.origin.y)
        CGContextScaleCTM(context, scale, scale)
        drawAtPoint(drawPoint)
        
        let croppedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext();
        
        return croppedImage
    }
}
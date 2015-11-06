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
    
    func rotate(degrees: Double) -> UIImage {
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        let rads = CGFloat(radians(degrees))
        CGContextRotateCTM(context, rads)
        drawAtPoint(CGPointZero)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func fixFrontCameraOrientation() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, true, 1)
        let context = UIGraphicsGetCurrentContext()
        
        
        CGContextRotateCTM(context, CGFloat(M_PI/2));
        CGContextTranslateCTM(context, 0, -size.width);
        CGContextScaleCTM(context, size.height/size.width, size.width/size.height);
        
        
        CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), CGImage);
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image;
    }
    
    func fixOrientation() -> UIImage {
        if imageOrientation == .Up {
            return self
        }
        
        var transform = CGAffineTransformIdentity
        
        switch imageOrientation {
        case .Down, .DownMirrored:
            transform = CGAffineTransformTranslate(transform, size.width, size.height)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI))
            break
        case .Left, .LeftMirrored:
            transform = CGAffineTransformTranslate(transform, size.width, 0)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI_2))
            break
        case .Right, .RightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, size.height)
            transform = CGAffineTransformRotate(transform, -CGFloat(M_PI_2))
            break
        case .Up, .UpMirrored:
            break
        }
        
        switch imageOrientation {
        case .UpMirrored, .DownMirrored:
            transform = CGAffineTransformTranslate(transform, size.width, 0)
            transform = CGAffineTransformScale(transform, -1, 1)
            break
            
        case .LeftMirrored, .RightMirrored:
            transform = CGAffineTransformTranslate(transform, size.height, 0)
            transform = CGAffineTransformScale(transform, -1, 1)
            break
        case .Up, .Down, .Left, .Right:
            break;
        }
        
        let context = CGBitmapContextCreate(nil, Int(size.width), Int(size.height), CGImageGetBitsPerComponent(CGImage), 0, CGImageGetColorSpace(CGImage), CGImageGetBitmapInfo(CGImage).rawValue)
        CGContextConcatCTM(context, transform);
        
        switch imageOrientation {
        case .Left, .LeftMirrored, .Right, .RightMirrored:
            CGContextDrawImage(context, CGRectMake(0, 0, size.height, size.width), CGImage)
            break
        default:
            CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), CGImage)
            break
        }
        
        let _CGImage = CGBitmapContextCreateImage(context)
        let image = UIImage(CGImage: _CGImage!)
        
        return image;
    }
}
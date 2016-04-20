//
//  ALUtilities.swift
//  ALCameraViewController
//
//  Created by Alex Littlejohn on 2015/06/25.
//  Copyright (c) 2015 zero. All rights reserved.
//

import UIKit
import AVFoundation

internal func radians(degrees: Double) -> Double {
    return degrees / 180 * M_PI
}

internal func localizedString(key: String) -> String {
    return NSLocalizedString(key, tableName: CameraGlobals.shared.stringsTable, bundle: CameraGlobals.shared.bundle, comment: key)
}

internal func currentRotation(oldOrientation: UIInterfaceOrientation, newOrientation: UIInterfaceOrientation) -> Double {
    switch oldOrientation {
        case .Portrait:
            switch newOrientation {
                case .LandscapeLeft: return 90
                case .LandscapeRight: return -90
                case .PortraitUpsideDown: return 180
                default: return 0
            }
            
        case .LandscapeLeft:
            switch newOrientation {
                case .Portrait: return -90
                case .LandscapeRight: return 180
                case .PortraitUpsideDown: return 90
                default: return 0
            }
            
        case .LandscapeRight:
            switch newOrientation {
                case .Portrait: return 90
                case .LandscapeLeft: return 180
                case .PortraitUpsideDown: return -90
                default: return 0
            }
            
        default: return 0
    }
}

internal func largestPhotoSize() -> CGSize {
    let scale = UIScreen.mainScreen().scale
    let screenSize = UIScreen.mainScreen().bounds.size
    let size = CGSize(width: screenSize.width * scale, height: screenSize.height * scale)
    return size
}

internal func errorWithKey(key: String, domain: String) -> NSError {
    let errorString = localizedString(key)
    let errorInfo = [NSLocalizedDescriptionKey: errorString]
    let error = NSError(domain: domain, code: 0, userInfo: errorInfo)
    return error
}

internal func normalizedRect(rect: CGRect, orientation: UIImageOrientation) -> CGRect {
    let normalizedX = rect.origin.x
    let normalizedY = rect.origin.y
    
    let normalizedWidth = rect.width
    let normalizedHeight = rect.height
    
    var normalizedRect: CGRect
    
    switch orientation {
    case .Up, .UpMirrored:
        normalizedRect = CGRect(x: normalizedX, y: normalizedY, width: normalizedWidth, height: normalizedHeight)
    case .Down, .DownMirrored:
        normalizedRect = CGRect(x: 1-normalizedX-normalizedWidth, y: 1-normalizedY-normalizedHeight, width: normalizedWidth, height: normalizedHeight)
    case .Left, .LeftMirrored:
        normalizedRect = CGRect(x: 1-normalizedY-normalizedHeight, y: normalizedX, width: normalizedHeight, height: normalizedWidth)
    case .Right, .RightMirrored:
        normalizedRect = CGRect(x: normalizedY, y: 1-normalizedX-normalizedWidth, width: normalizedHeight, height: normalizedWidth)
    }
    
    return normalizedRect
}

internal func flashImage(mode: AVCaptureFlashMode) -> String {
    let image: String
    switch mode {
    case .Auto:
        image = "flashAutoIcon"
    case .On:
        image = "flashOnIcon"
    case .Off:
        image = "flashOffIcon"
    }
    return image
}

struct ScreenSize {
    static let SCREEN_WIDTH         = UIScreen.mainScreen().bounds.size.width
    static let SCREEN_HEIGHT        = UIScreen.mainScreen().bounds.size.height
    static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

struct DeviceConfig {
    static let SCREEN_MULTIPLIER : CGFloat = {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            switch ScreenSize.SCREEN_MAX_LENGTH {
                case 568.0: return 1.5
                case 667.0: return 2.0
                case 736.0: return 4.0
                default: return 1.0
            }
        } else {
            return 1.0
        }
    }()
}

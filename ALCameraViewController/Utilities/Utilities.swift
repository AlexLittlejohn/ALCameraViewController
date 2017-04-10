//
//  ALUtilities.swift
//  ALCameraViewController
//
//  Created by Alex Littlejohn on 2015/06/25.
//  Copyright (c) 2015 zero. All rights reserved.
//

import UIKit
import AVFoundation

internal func radians(_ degrees: Double) -> Double {
    return degrees / 180 * Double.pi
}

internal func localizedString(_ key: String) -> String {
    return NSLocalizedString(key, tableName: CameraGlobals.shared.stringsTable, bundle: CameraGlobals.shared.bundle, comment: key)
}

internal func currentRotation(_ oldOrientation: UIInterfaceOrientation, newOrientation: UIInterfaceOrientation) -> Double {
    switch oldOrientation {
        case .portrait:
            switch newOrientation {
                case .landscapeLeft: return 90
                case .landscapeRight: return -90
                case .portraitUpsideDown: return 180
                default: return 0
            }
            
        case .landscapeLeft:
            switch newOrientation {
                case .portrait: return -90
                case .landscapeRight: return 180
                case .portraitUpsideDown: return 90
                default: return 0
            }
            
        case .landscapeRight:
            switch newOrientation {
                case .portrait: return 90
                case .landscapeLeft: return 180
                case .portraitUpsideDown: return -90
                default: return 0
            }
            
        default: return 0
    }
}

internal func largestPhotoSize() -> CGSize {
    let scale = UIScreen.main.scale
    let screenSize = UIScreen.main.bounds.size
    let size = CGSize(width: screenSize.width * scale, height: screenSize.height * scale)
    return size
}

internal func errorWithKey(_ key: String, domain: String) -> NSError {
    let errorString = localizedString(key)
    let errorInfo = [NSLocalizedDescriptionKey: errorString]
    let error = NSError(domain: domain, code: 0, userInfo: errorInfo)
    return error
}

internal func normalizedRect(_ rect: CGRect, orientation: UIImageOrientation) -> CGRect {
    let normalizedX = rect.origin.x
    let normalizedY = rect.origin.y
    
    let normalizedWidth = rect.width
    let normalizedHeight = rect.height
    
    var normalizedRect: CGRect
    
    switch orientation {
    case .up, .upMirrored:
        normalizedRect = CGRect(x: normalizedX, y: normalizedY, width: normalizedWidth, height: normalizedHeight)
    case .down, .downMirrored:
        normalizedRect = CGRect(x: 1-normalizedX-normalizedWidth, y: 1-normalizedY-normalizedHeight, width: normalizedWidth, height: normalizedHeight)
    case .left, .leftMirrored:
        normalizedRect = CGRect(x: 1-normalizedY-normalizedHeight, y: normalizedX, width: normalizedHeight, height: normalizedWidth)
    case .right, .rightMirrored:
        normalizedRect = CGRect(x: normalizedY, y: 1-normalizedX-normalizedWidth, width: normalizedHeight, height: normalizedWidth)
    }
    
    return normalizedRect
}

internal func flashImage(_ mode: AVCaptureFlashMode) -> String {
    let image: String
    switch mode {
    case .auto:
        image = "flashAutoIcon"
    case .on:
        image = "flashOnIcon"
    case .off:
        image = "flashOffIcon"
    }
    return image
}

struct ScreenSize {
    static let SCREEN_WIDTH         = UIScreen.main.bounds.size.width
    static let SCREEN_HEIGHT        = UIScreen.main.bounds.size.height
    static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

struct DeviceConfig {
    static let SCREEN_MULTIPLIER : CGFloat = {
        if UIDevice.current.userInterfaceIdiom == .phone {
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

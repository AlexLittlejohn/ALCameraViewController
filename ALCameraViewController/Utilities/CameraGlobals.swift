//
//  CameraGlobals.swift
//  ALCameraViewController
//
//  Created by Alex Littlejohn on 2016/02/16.
//  Copyright © 2016 zero. All rights reserved.
//

import UIKit
import AVFoundation

internal let itemSpacing: CGFloat = 1
internal let columns: CGFloat = 4
internal let thumbnailDimension = (UIScreen.main.bounds.width - ((columns * itemSpacing) - itemSpacing))/columns
internal let scale = UIScreen.main.scale

open class CameraGlobals {
    open static let shared = CameraGlobals()
    
    open var bundle = Bundle(for: CameraViewController.self)
    open var stringsTable = "CameraView"
    open var photoLibraryThumbnailSize = CGSize(width: thumbnailDimension, height: thumbnailDimension)
    open var defaultCameraPosition = AVCaptureDevicePosition.back
}

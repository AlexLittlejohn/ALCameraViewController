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
internal let thumbnailDimension = (UIScreen.mainScreen().bounds.width - ((columns * itemSpacing) - itemSpacing))/columns
internal let scale = UIScreen.mainScreen().scale

public class CameraGlobals {
    public static let shared = CameraGlobals()
    
    public var bundle = NSBundle(forClass: CameraViewController.self)
    public var stringsTable = "CameraView"
    public var photoLibraryThumbnailSize = CGSizeMake(thumbnailDimension, thumbnailDimension)
    public var defaultCameraPosition = AVCaptureDevicePosition.Back
}

//
//  CameraGlobals.swift
//  ALCameraViewController
//
//  Created by Alex Littlejohn on 2016/02/16.
//  Copyright © 2016 zero. All rights reserved.
//

import UIKit

internal let itemSpacing: CGFloat = 1
internal let columns: CGFloat = 4
internal let thumbnailDimension = (UIScreen.mainScreen().bounds.width - ((columns * itemSpacing) - itemSpacing))/columns
internal let scale = UIScreen.mainScreen().scale

public class CameraGlobals {
    public static let shared = CameraGlobals()
    
    var bundle = NSBundle(forClass: ALCameraViewController.self)
    var stringsTable = "CameraView"
    
    var photoLibraryThumbnailSize = CGSizeMake(thumbnailDimension, thumbnailDimension)
}

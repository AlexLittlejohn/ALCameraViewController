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
internal let thumbnailDimension = (UIScreen.main.bounds.width - ((columns * itemSpacing) - itemSpacing))/columns
internal let scale = UIScreen.main.scale

public class CameraGlobals {
    public static let shared = CameraGlobals()
    
    var bundle = Bundle(for: CameraViewController.self)
    var stringsTable = "CameraView"
    var photoLibraryThumbnailSize = CGSize(width: thumbnailDimension, height: thumbnailDimension)
}

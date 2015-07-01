//
//  ALImageModel.swift
//  ALImagePickerViewController
//
//  Created by Alex Littlejohn on 2015/06/09.
//  Copyright (c) 2015 zero. All rights reserved.
//

import UIKit
import Photos

class ALImageModel: NSObject {
    
    var selected = false
    
    let imageAsset: PHAsset
    let imageManager: PHCachingImageManager

    init(imageAsset: PHAsset, imageManager: PHCachingImageManager) {
        self.imageAsset = imageAsset
        self.imageManager = imageManager
        super.init()
    }
    
    weak var view: ALImageCell?
}

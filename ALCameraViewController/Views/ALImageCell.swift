//
//  ALImageCell.swift
//  ALImagePickerViewController
//
//  Created by Alex Littlejohn on 2015/06/09.
//  Copyright (c) 2015 zero. All rights reserved.
//

import UIKit
import Photos

internal let itemSpacing: CGFloat = 1
internal let columns: CGFloat = 4
internal let screenWidth = (UIScreen.mainScreen().bounds.size.width - ((columns * itemSpacing) - itemSpacing))/columns
internal let scale = UIScreen.mainScreen().scale
public let ALImageCellSize = CGSizeMake(screenWidth, screenWidth)
public let ALThumbnailSize = CGSizeMake(ALImageCellSize.width * scale, ALImageCellSize.height * scale)

class ALImageCell: UICollectionViewCell {
    
    let imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        contentView.addSubview(imageView)
        
        imageView.contentMode = .ScaleAspectFill
        imageView.layer.masksToBounds = true
    }

    func layout() {
        imageView.frame = CGRectMake(0, 0, ALImageCellSize.width, ALImageCellSize.height)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = UIImage(named: "ALPlaceholder", inBundle: NSBundle(forClass: ALCameraViewController.self), compatibleWithTraitCollection: nil)
    }
    
    func configureWithModel(model: ALImageModel) {
        
        imageView.image = UIImage(named: "ALPlaceholder", inBundle: NSBundle(forClass: ALCameraViewController.self), compatibleWithTraitCollection: nil)
        
        if tag != 0 {
            model.imageManager.cancelImageRequest(PHImageRequestID(tag))
        }
        
        tag = Int(model.imageManager.requestImageForAsset(model.imageAsset, targetSize: ALThumbnailSize, contentMode: .AspectFill, options: nil) { image, info in
            self.imageView.image = image
        })
        
        layout()
    }
}

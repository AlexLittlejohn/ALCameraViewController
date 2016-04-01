//
//  ImageCell.swift
//  ALImagePickerViewController
//
//  Created by Alex Littlejohn on 2015/06/09.
//  Copyright (c) 2015 zero. All rights reserved.
//

import UIKit
import Photos

class ImageCell: UICollectionViewCell {
    
    let imageView : UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .ScaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.image = UIImage(named: "placeholder",
                                  inBundle: CameraGlobals.shared.bundle,
                                  compatibleWithTraitCollection: nil)
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = UIImage(named: "placeholder",
                                  inBundle: CameraGlobals.shared.bundle,
                                  compatibleWithTraitCollection: nil)
    }
    
    func configureWithModel(model: PHAsset) {
        
        if tag != 0 {
            PHImageManager.defaultManager().cancelImageRequest(PHImageRequestID(tag))
        }
        
        tag = Int(PHImageManager.defaultManager().requestImageForAsset(model, targetSize: contentView.bounds.size, contentMode: .AspectFill, options: nil) { image, info in
            self.imageView.image = image
        })
    }
}

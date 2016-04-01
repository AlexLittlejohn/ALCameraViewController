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
    
    var didUpdateConstraints = false
    
    let imageView : UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .ScaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.image = UIImage(named: "ALPlaceholder",
                                  inBundle: CameraGlobals.shared.bundle,
                                  compatibleWithTraitCollection: nil)
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(imageView)
        self.contentView.setNeedsUpdateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func updateConstraints() {
        if !didUpdateConstraints {
            didUpdateConstraints = true
            configCameraViewConstraints()
        }
        super.updateConstraints()
    }
    
    func configCameraViewConstraints() {
        self.contentView.addConstraint(NSLayoutConstraint(item: self.imageView,
            attribute: NSLayoutAttribute.Left,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.contentView,
            attribute: NSLayoutAttribute.Left,
            multiplier: 1.0, constant: 0))
        self.contentView.addConstraint(NSLayoutConstraint(item: self.imageView,
            attribute: NSLayoutAttribute.Right,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.contentView,
            attribute: NSLayoutAttribute.Right,
            multiplier: 1.0, constant: 0))
        self.contentView.addConstraint(NSLayoutConstraint(item: self.imageView,
            attribute: NSLayoutAttribute.Top,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.contentView,
            attribute: NSLayoutAttribute.Top,
            multiplier: 1.0, constant: 0))
        self.contentView.addConstraint(NSLayoutConstraint(item: self.imageView,
            attribute: NSLayoutAttribute.Bottom,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.contentView,
            attribute: NSLayoutAttribute.Bottom,
            multiplier: 1.0, constant: 0))
    }
    
    func configureWithModel(model: PHAsset) {
        
        if tag != 0 {
            PHImageManager.defaultManager().cancelImageRequest(PHImageRequestID(tag))
        }
        
        tag = Int(PHImageManager.defaultManager().requestImageForAsset(model, targetSize:
        self.contentView.bounds.size, contentMode: .AspectFill, options: nil) { image, info in
            self.imageView.image = image
        })
    }
}

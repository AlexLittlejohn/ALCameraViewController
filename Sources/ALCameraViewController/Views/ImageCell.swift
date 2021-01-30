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
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.image = UIImage(named: "placeholder",
                                  in: CameraGlobals.shared.bundle,
                                  compatibleWith: nil)
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
                                  in: CameraGlobals.shared.bundle,
                                  compatibleWith: nil)
    }
    
    func configureWithModel(_ model: PHAsset) {
        
        if tag != 0 {
            PHImageManager.default().cancelImageRequest(PHImageRequestID(tag))
        }
        
        tag = Int(PHImageManager.default().requestImage(for: model, targetSize: contentView.bounds.size, contentMode: .aspectFill, options: nil) { image, info in
            self.imageView.image = image
        })
    }
}

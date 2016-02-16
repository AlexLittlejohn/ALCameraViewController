//
//  SingleImageFetcher.swift
//  ALCameraViewController
//
//  Created by Alex Littlejohn on 2016/02/16.
//  Copyright © 2016 zero. All rights reserved.
//

import UIKit
import Photos

public typealias SingleImageFetcherSuccess = (image: UIImage) -> Void
public typealias SingleImageFetcherFailure = (error: NSError) -> Void

public class SingleImageFetcher {
    private let errorDomain = "com.zero.singleImageSaver"
    
    private var success: SingleImageFetcherSuccess?
    private var failure: SingleImageFetcherFailure?
    
    private var asset: PHAsset?
    private var targetSize = PHImageManagerMaximumSize
    private var cropRect: CGRect?
    
    public func onSuccess(success: SingleImageFetcherSuccess) -> Self {
        self.success = success
        return self
    }
    
    public func onFailure(failure: SingleImageFetcherFailure) -> Self {
        self.failure = failure
        return self
    }
    
    public func setAsset(asset: PHAsset) -> Self {
        self.asset = asset
        return self
    }
    
    public func setTargetSize(targetSize: CGSize) -> Self {
        self.targetSize = targetSize
        return self
    }
    
    public func setCropRect(cropRect: CGRect) -> Self {
        self.cropRect = cropRect
        return self
    }
    
    public func fetch() -> Self {
        
        guard let asset = asset else {
            let error = errorWithKey("error.cant-fetch-photo", domain: errorDomain)
            failure?(error: error)
            return self
        }
        
        var contentMode = PHImageContentMode.AspectFill
        
        let options = PHImageRequestOptions()

        if let cropRect = cropRect {
            
            let transform = CGAffineTransformMakeScale(1 / CGFloat(asset.pixelWidth), 1 / CGFloat(asset.pixelHeight))
            let normalizedRect = CGRectApplyAffineTransform(cropRect, transform)
            
            print(normalizedRect)
            
            options.normalizedCropRect = normalizedRect
            options.resizeMode = .Exact
            
            contentMode = .AspectFit
        } else {
            options.deliveryMode = .HighQualityFormat
        }
        
        PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: targetSize, contentMode: contentMode, options: options) { image, _ in
            if let image = image {
                self.success?(image: image)
            } else {
                let error = errorWithKey("error.cant-fetch-photo", domain: self.errorDomain)
                self.failure?(error: error)
            }
        }
        
        return self
    }
}

//
//  SingleImageFetcher.swift
//  ALCameraViewController
//
//  Created by Alex Littlejohn on 2016/02/16.
//  Copyright © 2016 zero. All rights reserved.
//

import UIKit
import Photos

public typealias SingleImageFetcherSuccess = (_ image: UIImage) -> Void
public typealias SingleImageFetcherFailure = (_ error: NSError) -> Void

open class SingleImageFetcher {
    fileprivate let errorDomain = "com.zero.singleImageSaver"
    
    fileprivate var success: SingleImageFetcherSuccess?
    fileprivate var failure: SingleImageFetcherFailure?
    
    fileprivate var asset: PHAsset?
    fileprivate var targetSize = PHImageManagerMaximumSize
    fileprivate var cropRect: CGRect?
    
    public init() { }
    
    open func onSuccess(_ success: @escaping SingleImageFetcherSuccess) -> Self {
        self.success = success
        return self
    }
    
    open func onFailure(_ failure: @escaping SingleImageFetcherFailure) -> Self {
        self.failure = failure
        return self
    }
    
    open func setAsset(_ asset: PHAsset) -> Self {
        self.asset = asset
        return self
    }
    
    open func setTargetSize(_ targetSize: CGSize) -> Self {
        self.targetSize = targetSize
        return self
    }
    
    open func setCropRect(_ cropRect: CGRect) -> Self {
        self.cropRect = cropRect
        return self
    }
    
    open func fetch() -> Self {
        _ = PhotoLibraryAuthorizer { error in
            if error == nil {
                self._fetch()
            } else {
                self.failure?(error!)
            }
        }
        return self
    }
    
    fileprivate func _fetch() {
    
        guard let asset = asset else {
            let error = errorWithKey("error.cant-fetch-photo", domain: errorDomain)
            failure?(error)
            return
        }
        
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true

        if let cropRect = cropRect {

            options.normalizedCropRect = cropRect
            options.resizeMode = .exact
            
            let targetWidth = floor(CGFloat(asset.pixelWidth) * cropRect.width)
            let targetHeight = floor(CGFloat(asset.pixelHeight) * cropRect.height)
            let dimension = max(min(targetHeight, targetWidth), 1024 * scale)
            
            targetSize = CGSize(width: dimension, height: dimension)
        }
        
        PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options) { image, _ in
            if let image = image {
                self.success?(image)
            } else {
                let error = errorWithKey("error.cant-fetch-photo", domain: self.errorDomain)
                self.failure?(error)
            }
        }
    }
}

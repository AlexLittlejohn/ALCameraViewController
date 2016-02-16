//
//  SingleImageSavingInteractor.swift
//  ALCameraViewController
//
//  Created by Alex Littlejohn on 2016/02/16.
//  Copyright © 2016 zero. All rights reserved.
//

import UIKit
import Photos

public typealias SingleImageSaverSuccess = (asset: PHAsset) -> Void
public typealias SingleImageSaverFailure = (error: NSError) -> Void

public class SingleImageSaver {
    private let errorDomain = "com.zero.singleImageSaver"
    
    private var success: SingleImageSaverSuccess?
    private var failure: SingleImageSaverFailure?
    
    private var image: UIImage?
    
    public func onSuccess(success: SingleImageSaverSuccess) -> Self {
        self.success = success
        return self
    }
    
    public func onFailure(failure: SingleImageSaverFailure) -> Self {
        self.failure = failure
        return self
    }
    
    public func setImage(image: UIImage) -> Self {
        self.image = image
        return self
    }
    
    public func save() -> Self {
        
        guard let image = image else {
            let error = errorWithKey("error.cant-fetch-photo", domain: errorDomain)
            failure?(error: error)
            return self
        }
        
        var assetIdentifier: PHObjectPlaceholder?
        
        PHPhotoLibrary.sharedPhotoLibrary()
            .performChanges({
                let request = PHAssetChangeRequest.creationRequestForAssetFromImage(image)
                assetIdentifier = request.placeholderForCreatedAsset
            }) { finished, error in
                if let assetIdentifier = assetIdentifier where finished {
                    self.fetch(assetIdentifier)
                }
            }

        return self
    }
    
    private func fetch(assetIdentifier: PHObjectPlaceholder) {
        
        let assets = PHAsset.fetchAssetsWithLocalIdentifiers([assetIdentifier.localIdentifier], options: nil)
        
        guard let asset = assets.firstObject as? PHAsset else {
            let error = errorWithKey("error.cant-fetch-photo", domain: errorDomain)
            dispatch_async(dispatch_get_main_queue()) {
                self.failure?(error: error)
            }
            return
        }
        dispatch_async(dispatch_get_main_queue()) {
            self.success?(asset: asset)
        }
    }
}

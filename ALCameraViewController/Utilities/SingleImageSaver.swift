//
//  SingleImageSavingInteractor.swift
//  ALCameraViewController
//
//  Created by Alex Littlejohn on 2016/02/16.
//  Copyright © 2016 zero. All rights reserved.
//

import UIKit
import Photos

public typealias SingleImageSaverSuccess = (_ asset: PHAsset) -> Void
public typealias SingleImageSaverFailure = (_ error: NSError) -> Void

open class SingleImageSaver {
    fileprivate let errorDomain = "com.zero.singleImageSaver"
    
    fileprivate var success: SingleImageSaverSuccess?
    fileprivate var failure: SingleImageSaverFailure?
    
    fileprivate var image: UIImage?
    
    public init() { }
    
    open func onSuccess(_ success: @escaping SingleImageSaverSuccess) -> Self {
        self.success = success
        return self
    }
    
    open func onFailure(_ failure: @escaping SingleImageSaverFailure) -> Self {
        self.failure = failure
        return self
    }
    
    open func setImage(_ image: UIImage) -> Self {
        self.image = image
        return self
    }
    
    open func save() -> Self {
        
        _ = PhotoLibraryAuthorizer { error in
            if error == nil {
                self._save()
            } else {
                self.failure?(error!)
            }
        }

        return self
    }
    
    fileprivate func _save() {
        guard let image = image else {
            self.invokeFailure()
            return
        }
        
        var assetIdentifier: PHObjectPlaceholder?
        
        PHPhotoLibrary.shared()
            .performChanges({
                let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
                assetIdentifier = request.placeholderForCreatedAsset
            }) { finished, error in
                
                guard let assetIdentifier = assetIdentifier , finished else {
                    self.invokeFailure()
                    return
                }
                
                self.fetch(assetIdentifier)
        }
    }
    
    fileprivate func fetch(_ assetIdentifier: PHObjectPlaceholder) {
        
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: [assetIdentifier.localIdentifier], options: nil)
        
        DispatchQueue.main.async {
            guard let asset = assets.firstObject else {
                self.invokeFailure()
                return
            }
            
            self.success?(asset)
        }
    }
    
    fileprivate func invokeFailure() {
        let error = errorWithKey("error.cant-fetch-photo", domain: errorDomain)
        failure?(error)
    }
}

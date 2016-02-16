//
//  ALImageFetchingInteractor.swift
//  ALImagePickerViewController
//
//  Created by Alex Littlejohn on 2015/06/09.
//  Copyright (c) 2015 zero. All rights reserved.
//

import UIKit
import Photos

public typealias ImageFetcherSuccess = (assets: PHFetchResult) -> ()
public typealias ImageFetcherFailure = (error: NSError) -> ()

extension PHFetchResult: SequenceType {
    public func generate() -> NSFastGenerator {
        return NSFastGenerator(self)
    }
}

public class ImageFetcher {

    private var success: ImageFetcherSuccess?
    private var failure: ImageFetcherFailure?
    
    private var authRequested = false
    private let errorDomain = "com.zero.imageFetcher"
    
    let libraryQueue = dispatch_queue_create("com.zero.ALCameraViewController.LibraryQueue", DISPATCH_QUEUE_SERIAL);
    
    public func onSuccess(success: ImageFetcherSuccess) -> Self {
        self.success = success
        return self
    }
    
    public func onFailure(failure: ImageFetcherFailure) -> Self {
        self.failure = failure
        return self
    }
    
    public func fetch() -> Self {
        handleAuthorization(PHPhotoLibrary.authorizationStatus())
        return self
    }
    
    private func onAuthorized() {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        dispatch_async(libraryQueue) {
            let assets = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: options)
            dispatch_async(dispatch_get_main_queue()) {
                self.success?(assets: assets)
            }
        }
    }
    
    private func onDeniedOrRestricted() {
        let error = errorWithKey("error.access-denied", domain: errorDomain)
        dispatch_async(dispatch_get_main_queue()) {
            self.failure?(error: error)
        }
    }
    
    private func handleAuthorization(status: PHAuthorizationStatus) -> Void {
        switch status {
        case .NotDetermined:
            if !authRequested {
                PHPhotoLibrary.requestAuthorization(handleAuthorization)
                authRequested = true
            } else {
                onDeniedOrRestricted()
            }
            break
        case .Authorized:
            onAuthorized()
            break
        case .Denied, .Restricted:
            onDeniedOrRestricted()
            break
        }
    }
}

//
//  ALImageFetchingInteractor.swift
//  ALImagePickerViewController
//
//  Created by Alex Littlejohn on 2015/06/09.
//  Copyright (c) 2015 zero. All rights reserved.
//

import UIKit
import Photos

public typealias ALImageFetchingInteractorSuccess = (assets: [PHAsset]) -> ()
public typealias ALImageFetchingInteractorFailure = (error: NSError) -> ()

extension PHFetchResult: SequenceType {
    public func generate() -> NSFastGenerator {
        return NSFastGenerator(self)
    }
}

public class ALImageFetchingInteractor {

    private var success: ALImageFetchingInteractorSuccess?
    private var failure: ALImageFetchingInteractorFailure?
    
    private var authRequested = false
    private let errorDomain = "com.zero.imageFetcher"
    
    let libraryQueue = dispatch_queue_create("com.zero.ALCameraViewController.LibraryQueue", DISPATCH_QUEUE_SERIAL);
    
    public func onSuccess(success: ALImageFetchingInteractorSuccess) -> Self {
        self.success = success
        return self
    }
    
    public func onFailure(failure: ALImageFetchingInteractorFailure) -> Self {
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
            var imageAssets = [PHAsset]()
            for asset in assets {
                imageAssets.append(asset as! PHAsset)
            }
            dispatch_async(dispatch_get_main_queue()) {
                self.success?(assets: imageAssets)
            }
        }
    }
    
    private func onDeniedOrRestricted() {
        let errorString = NSLocalizedString("error.access-denied", tableName: StringsTableName, comment: "error.access-denied")
        let errorInfo = [NSLocalizedDescriptionKey: errorString]
        let error = NSError(domain: errorDomain, code: 0, userInfo: errorInfo)
        
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

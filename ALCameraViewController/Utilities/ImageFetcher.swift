//
//  ALImageFetchingInteractor.swift
//  ALImagePickerViewController
//
//  Created by Alex Littlejohn on 2015/06/09.
//  Copyright (c) 2015 zero. All rights reserved.
//

import UIKit
import Photos

public typealias ImageFetcherSuccess = (_ assets: PHFetchResult<AnyObject>) -> ()
public typealias ImageFetcherFailure = (_ error: NSError) -> ()


open class ImageFetcher {

    fileprivate var success: ImageFetcherSuccess?
    fileprivate var failure: ImageFetcherFailure?
    
    fileprivate var authRequested = false
    fileprivate let errorDomain = "com.zero.imageFetcher"
    
    let libraryQueue = DispatchQueue(label: "com.zero.ALCameraViewController.LibraryQueue", attributes: []);
    
    public init() { }
    
    open func onSuccess(_ success: @escaping ImageFetcherSuccess) -> Self {
        self.success = success
        return self
    }
    
    open func onFailure(_ failure: @escaping ImageFetcherFailure) -> Self {
        self.failure = failure
        return self
    }
    
    open func fetch() -> Self {
        _ = PhotoLibraryAuthorizer { error in
            if error == nil {
                self.onAuthorized()
            } else {
                self.failure?(error!)
            }
        }
        return self
    }
    
    fileprivate func onAuthorized() {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        libraryQueue.async {
            let assets = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: options)
            DispatchQueue.main.async {
                self.success?(assets as! PHFetchResult<AnyObject>)
            }
        }
    }
}

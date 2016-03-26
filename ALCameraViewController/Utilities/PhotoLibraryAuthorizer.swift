//
//  PhotoLibraryAuthorizer.swift
//  ALCameraViewController
//
//  Created by Alex Littlejohn on 2016/03/26.
//  Copyright © 2016 zero. All rights reserved.
//

import UIKit
import Photos

public typealias PhotoLibraryAuthorizerCompletion = (error: NSError?) -> Void

class PhotoLibraryAuthorizer {

    private let errorDomain = "com.zero.imageFetcher"
    private let completion: PhotoLibraryAuthorizerCompletion

    init(completion: PhotoLibraryAuthorizerCompletion) {
        self.completion = completion
        handleAuthorization(PHPhotoLibrary.authorizationStatus())
    }
    
    func onDeniedOrRestricted() {
        let error = errorWithKey("error.access-denied", domain: errorDomain)
        completion(error: error)
    }
    
    func handleAuthorization(status: PHAuthorizationStatus) {
        switch status {
        case .NotDetermined:
            PHPhotoLibrary.requestAuthorization(handleAuthorization)
            break
        case .Authorized:
            dispatch_async(dispatch_get_main_queue()) {
                self.completion(error: nil)
            }
            break
        case .Denied, .Restricted:
            dispatch_async(dispatch_get_main_queue()) {
                self.onDeniedOrRestricted()
            }
            break
        }
    }
}

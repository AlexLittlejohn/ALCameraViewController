//
//  PhotoLibraryAuthorizer.swift
//  ALCameraViewController
//
//  Created by Alex Littlejohn on 2016/03/26.
//  Copyright © 2016 zero. All rights reserved.
//

import UIKit
import Photos

public typealias PhotoLibraryAuthorizerCompletion = (_ error: NSError?) -> Void

class PhotoLibraryAuthorizer {

    fileprivate let errorDomain = "com.zero.imageFetcher"
    fileprivate let completion: PhotoLibraryAuthorizerCompletion

    init(completion: @escaping PhotoLibraryAuthorizerCompletion) {
        self.completion = completion
        handleAuthorization(PHPhotoLibrary.authorizationStatus())
    }
    
    func onDeniedOrRestricted() {
        let error = errorWithKey("error.access-denied", domain: errorDomain)
        completion(error)
    }
    
    func handleAuthorization(_ status: PHAuthorizationStatus) {
        switch status {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(handleAuthorization)
            break
        case .authorized:
            DispatchQueue.main.async {
                self.completion(nil)
            }
            break
        case .denied, .restricted:
            DispatchQueue.main.async {
                self.onDeniedOrRestricted()
            }
            break
        }
    }
}

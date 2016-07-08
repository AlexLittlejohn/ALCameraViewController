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

    init(completion: PhotoLibraryAuthorizerCompletion) {
        handleAuthorization(status: PHPhotoLibrary.authorizationStatus(), completion: completion)
    }
    
    func onDeniedOrRestricted(completion: PhotoLibraryAuthorizerCompletion) {
        let error = errorWithKey("error.access-denied", domain: errorDomain)
        completion(error: error)
    }
    
    func handleAuthorization(status: PHAuthorizationStatus, completion: PhotoLibraryAuthorizerCompletion) {
        switch status {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(handleAuthorization)
            break
        case .authorized:
            DispatchQueue.main.async {
                completion(error: nil)
            }
            break
        case .denied, .restricted:
            DispatchQueue.main.async {
                self.onDeniedOrRestricted(completion: completion)
            }
            break
        }
    }
}

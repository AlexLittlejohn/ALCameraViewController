//
//  PhotoLibraryAuthorizer.swift
//  ALCameraViewController
//
//  Created by Alex Littlejohn on 2016/03/26.
//  Copyright © 2016 zero. All rights reserved.
//

import UIKit
import Photos

public typealias PhotoLibraryAuthorizerCompletion = (NSError?) -> Void

class PhotoLibraryAuthorizer {

    private let errorDomain = "com.zero.imageFetcher"

    private let completion: PhotoLibraryAuthorizerCompletion

    init(completion: @escaping PhotoLibraryAuthorizerCompletion) {
        self.completion = completion
        handleAuthorization(status: PHPhotoLibrary.authorizationStatus())
    }
    
    func onDeniedOrRestricted(completion: PhotoLibraryAuthorizerCompletion) {
        let error = errorWithKey("error.access-denied", domain: errorDomain)
        completion(error)
    }
    
    func handleAuthorization(status: PHAuthorizationStatus) {
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
                self.onDeniedOrRestricted(completion: self.completion)
            }
            break
        }
    }
}

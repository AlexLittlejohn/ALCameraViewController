//
//  CameraShot.swift
//  ALCameraViewController
//
//  Created by Alex Littlejohn on 2015/06/17.
//  Copyright (c) 2015 zero. All rights reserved.
//

import UIKit
import AVFoundation

public typealias CameraShotCompletion = (UIImage?) -> Void

public func takePhoto(stillImageOutput: AVCaptureStillImageOutput, videoOrientation: AVCaptureVideoOrientation, cropSize: CGSize, completion: CameraShotCompletion) {
    
    guard let videoConnection: AVCaptureConnection = stillImageOutput.connectionWithMediaType(AVMediaTypeVideo) else {
        completion(nil)
        return
    }
    
    videoConnection.videoOrientation = videoOrientation
    
    stillImageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: { buffer, error in
        
        guard let buffer = buffer, imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer), image = UIImage(data: imageData) else {
            completion(nil)
            return
        }
        
        completion(image)
    })
}
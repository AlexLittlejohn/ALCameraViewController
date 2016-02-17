//
//  ALCameraShot.swift
//  ALCameraViewController
//
//  Created by Alex Littlejohn on 2015/06/17.
//  Copyright (c) 2015 zero. All rights reserved.
//

import UIKit
import AVFoundation

public typealias ALCameraShotCompletion = (UIImage) -> Void

internal class CameraShot: NSObject {
    func takePhoto(stillImageOutput: AVCaptureStillImageOutput, videoOrientation: AVCaptureVideoOrientation, cropSize: CGSize, completion: ALCameraShotCompletion) {
        
        guard let videoConnection: AVCaptureConnection = stillImageOutput.connectionWithMediaType(AVMediaTypeVideo) else {
            return
        }
        
        videoConnection.videoOrientation = videoOrientation
        
        stillImageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: { buffer, error in
            
            guard let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer), image = UIImage(data: imageData) else {
                return
            }
            
            completion(image)
        })
    }
}

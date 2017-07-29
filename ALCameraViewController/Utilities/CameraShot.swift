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

public func takePhoto(_ stillImageOutput: AVCaptureStillImageOutput, videoOrientation: AVCaptureVideoOrientation, cameraPosition: AVCaptureDevicePosition, cropSize: CGSize, completion: @escaping CameraShotCompletion) {
    
    guard let videoConnection: AVCaptureConnection = stillImageOutput.connection(withMediaType: AVMediaTypeVideo) else {
        completion(nil)
        return
    }
    
    videoConnection.videoOrientation = videoOrientation
    
    stillImageOutput.captureStillImageAsynchronously(from: videoConnection, completionHandler: { buffer, error in
        
        guard let buffer = buffer,
            let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer),
            var image = UIImage(data: imageData) else {
            completion(nil)
            return
        }

        // flip the image to match the orientation of the preview
        if cameraPosition == .front, let cgImage = image.cgImage {
            switch image.imageOrientation {
            case .leftMirrored:
                image = UIImage(cgImage: cgImage, scale: image.scale, orientation: .right)
            case .left:
                image = UIImage(cgImage: cgImage, scale: image.scale, orientation: .rightMirrored)
            case .rightMirrored:
                image = UIImage(cgImage: cgImage, scale: image.scale, orientation: .left)
            case .right:
                image = UIImage(cgImage: cgImage, scale: image.scale, orientation: .leftMirrored)
            case .up:
                image = UIImage(cgImage: cgImage, scale: image.scale, orientation: .upMirrored)
            case .upMirrored:
                image = UIImage(cgImage: cgImage, scale: image.scale, orientation: .up)
            case .down:
                image = UIImage(cgImage: cgImage, scale: image.scale, orientation: .downMirrored)
            case .downMirrored:
                image = UIImage(cgImage: cgImage, scale: image.scale, orientation: .down)
            }
        }
        
        completion(image)
    })
}

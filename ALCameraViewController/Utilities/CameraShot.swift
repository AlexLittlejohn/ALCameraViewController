//
//  CameraShot.swift
//  ALCameraViewController
//
//  Created by Alex Littlejohn on 2015/06/17.
//  Copyright (c) 2015 zero. All rights reserved.
//

import UIKit
import AVFoundation

public typealias CameraShotCompletion = (Data?, UIImage?) -> Void

public func takePhoto(_ stillImageOutput: AVCaptureStillImageOutput, videoOrientation: AVCaptureVideoOrientation, cameraPosition: AVCaptureDevicePosition, cropSize _: CGSize, completion: @escaping CameraShotCompletion) {

    guard let videoConnection: AVCaptureConnection = stillImageOutput.connection(withMediaType: AVMediaTypeVideo) else {
        completion(nil, nil)
        return
    }

    videoConnection.videoOrientation = videoOrientation

    stillImageOutput.captureStillImageAsynchronously(from: videoConnection, completionHandler: { buffer, _ in

        guard let buffer = buffer,
            let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer),
            var image = UIImage(data: imageData) else {
            completion(nil, nil)
            return
        }
        // flip the image to match the orientation of the preview
        if let cgImage = image.cgImage {
            switch image.imageOrientation {
            case .leftMirrored:
                image = UIImage(cgImage: cgImage, scale: 1.5, orientation: .right)
            case .left:
                image = UIImage(cgImage: cgImage, scale: 1.5, orientation: .rightMirrored)
            case .rightMirrored:
                image = UIImage(cgImage: cgImage, scale: 1.5, orientation: .left)
            case .right:
                image = UIImage(cgImage: cgImage, scale: 1.5, orientation: .leftMirrored)
            case .up:
                image = UIImage(cgImage: cgImage, scale: 1.5, orientation: .upMirrored)
            case .upMirrored:
                image = UIImage(cgImage: cgImage, scale: 1.5, orientation: .up)
            case .down:
                image = UIImage(cgImage: cgImage, scale: 1.5, orientation: .downMirrored)
            case .downMirrored:
                image = UIImage(cgImage: cgImage, scale: 1.5, orientation: .down)
            }
        }
        completion(imageData, image)
    })
}

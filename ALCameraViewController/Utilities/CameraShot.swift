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

public func takePhoto(_ stillImageOutput: AVCaptureStillImageOutput, videoOrientation: AVCaptureVideoOrientation, cameraPosition: AVCaptureDevicePosition, cropSize _: CGSize, outputScale: CGFloat, completion: @escaping CameraShotCompletion) {

    guard let videoConnection: AVCaptureConnection = stillImageOutput.connection(withMediaType: AVMediaTypeVideo) else {
        completion(nil, nil)
        return
    }

    videoConnection.videoOrientation = videoOrientation

    stillImageOutput.captureStillImageAsynchronously(from: videoConnection, completionHandler: { buffer, _ in

        guard let buffer = buffer,
            let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer),
            var image = UIImage(data: imageData),
            let cgImage = image.cgImage else {
            completion(nil, nil)
            return
        }
        // flip the image to match the orientation of the preview
        // Half size is large for now
        if cameraPosition == .front {
            switch image.imageOrientation {
            case .leftMirrored:
                image = UIImage(cgImage: cgImage, scale: outputScale, orientation: .right)
            case .left:
                image = UIImage(cgImage: cgImage, scale: outputScale, orientation: .rightMirrored)
            case .rightMirrored:
                image = UIImage(cgImage: cgImage, scale: outputScale, orientation: .left)
            case .right:
                image = UIImage(cgImage: cgImage, scale: outputScale, orientation: .leftMirrored)
            case .up:
                image = UIImage(cgImage: cgImage, scale: outputScale, orientation: .upMirrored)
            case .upMirrored:
                image = UIImage(cgImage: cgImage, scale: outputScale, orientation: .up)
            case .down:
                image = UIImage(cgImage: cgImage, scale: outputScale, orientation: .downMirrored)
            case .downMirrored:
                image = UIImage(cgImage: cgImage, scale: outputScale, orientation: .down)
            }
        } else {
            image = UIImage(cgImage: cgImage, scale: outputScale, orientation: image.imageOrientation)
        }
        completion(imageData, image)
    })
}

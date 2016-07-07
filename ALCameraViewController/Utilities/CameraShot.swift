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

        completion(cropTo16x9(image))
    })
}

func cropTo16x9(image: UIImage) -> UIImage? {

    let contextSize: CGSize = image.size

    var cgwidth: CGFloat = contextSize.width
    var cgheight: CGFloat = cgwidth * (9/16)

    let rect: CGRect = CGRectMake(0, (contextSize.height - cgheight) / 2, cgwidth, cgheight)

    guard let cgImage = image.CGImage, imageRef = CGImageCreateWithImageInRect(cgImage, rect) else {
        return nil
    }

    return UIImage(CGImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
}
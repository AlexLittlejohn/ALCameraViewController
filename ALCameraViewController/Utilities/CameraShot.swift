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

public func takePhoto(_ stillImageOutput: AVCaptureStillImageOutput, videoOrientation: AVCaptureVideoOrientation, cropSize: CGSize, completion: @escaping CameraShotCompletion) {
    
    guard let videoConnection: AVCaptureConnection = stillImageOutput.connection(withMediaType: AVMediaTypeVideo) else {
        completion(nil)
        return
    }

    videoConnection.videoOrientation = videoOrientation
    
    stillImageOutput.captureStillImageAsynchronously(from: videoConnection, completionHandler: { buffer, error in
        
        guard let buffer = buffer,
            let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer),
            let image = UIImage(data: imageData) else {
            completion(nil)
            return
        }

        completion(cropTo16x9(image: image))
    })
}

func cropTo16x9(image: UIImage) -> UIImage? {

    let contextSize: CGSize = image.size

    let cgwidth: CGFloat = contextSize.width
    let cgheight: CGFloat = cgwidth * (9/16)

    let rect = CGRect(x: 0, y: (contextSize.height - cgheight) / 2, width: cgwidth, height: cgheight)


    guard let cgImage = image.cgImage, let imageRef = cgImage.cropping(to: rect) else {
        return nil
    }

    return UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
}

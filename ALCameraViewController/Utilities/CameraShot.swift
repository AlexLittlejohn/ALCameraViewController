//
//  CameraShot.swift
//  ALCameraViewController
//
//  Created by Alex Littlejohn on 2015/06/17.
//  Copyright (c) 2015 zero. All rights reserved.
//

import UIKit
import AVFoundation
import Mixpanel

public typealias CameraShotCompletion = (Data?, UIImage?) -> Void

public func takePhoto(_ stillImageOutput: AVCaptureStillImageOutput, videoOrientation: AVCaptureVideoOrientation, cameraPosition: AVCaptureDevicePosition, cropSize _: CGSize, outputScale: CGFloat, completion: @escaping CameraShotCompletion) {

    guard let videoConnection: AVCaptureConnection = stillImageOutput.connection(withMediaType: AVMediaTypeVideo) else {
        completion(nil, nil)
        return
    }

    videoConnection.videoOrientation = videoOrientation

    stillImageOutput.captureStillImageAsynchronously(from: videoConnection, completionHandler: { buffer, _ in
        
        guard let buffer = buffer,
            let exifAttachments = CMGetAttachment(buffer, kCGImagePropertyExifDictionary, nil),
            let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer),
            var image = UIImage(data: imageData),
            let cgImage = image.cgImage else {
                completion(nil, nil)
                return
        }
        
        
        
        // TODO: Return EXIF attachments
        
        
        Mixpanel.sharedInstance(withToken: "c1d6c864d27021f89cd630064b6b1454").track("--==EXIF==--", properties: {"data": exif})
        
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

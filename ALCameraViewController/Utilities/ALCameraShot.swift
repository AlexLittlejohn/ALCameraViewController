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

internal class ALCameraShot: NSObject {
    func takePhoto(stillImageOutput: AVCaptureStillImageOutput, videoOrientation: AVCaptureVideoOrientation, cropSize: CGSize, completion: ALCameraShotCompletion) {
        var videoConnection: AVCaptureConnection? = nil
        
        for connection in stillImageOutput.connections {
            for port in (connection as! AVCaptureConnection).inputPorts {
                if port.mediaType == AVMediaTypeVideo {
                    videoConnection = connection as? AVCaptureConnection
                    break;
                }
            }
            
            if videoConnection != nil {
                break;
            }
        }
        
        videoConnection?.videoOrientation = videoOrientation
        
        stillImageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection!, completionHandler: { buffer, error in
            if buffer != nil {
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer)
                let image = UIImage(data: imageData)!
                let croppedImage = self.cropImage(image, cropSize: cropSize)
                completion(croppedImage)
            }
        })
    }
    
    func cropImage(image: UIImage, cropRect: CGRect) -> UIImage {
        var newImage: UIImage? = nil;
        
        let imageSize = image.size;
        let width = imageSize.width;
        let height = imageSize.height;
        
        let targetWidth = cropRect.size.width;
        let targetHeight = cropRect.size.height;
        
        var scaleFactor: CGFloat = 0;
        var scaledWidth = targetWidth;
        var scaledHeight = targetHeight;
        
        let thumbnailPoint = cropRect.origin;
        
        if (CGSizeEqualToSize(imageSize, cropRect.size) == false) {
            let widthFactor = targetWidth / width;
            let heightFactor = targetHeight / height;
            
            if (widthFactor > heightFactor) {
                scaleFactor = widthFactor;
            } else {
                scaleFactor = heightFactor;
            }
            
            scaledWidth  = width * scaleFactor;
            scaledHeight = height * scaleFactor;
        }
        
        UIGraphicsBeginImageContextWithOptions(cropRect.size, true, 0);
        
        var thumbnailRect = CGRectZero;
        thumbnailRect.origin = thumbnailPoint;
        thumbnailRect.size.width  = scaledWidth;
        thumbnailRect.size.height = scaledHeight;
        
        image.drawInRect(thumbnailRect)
        
        newImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        return newImage!;
    }
    
    func cropImage(image: UIImage, cropSize: CGSize) -> UIImage {
        var newImage: UIImage? = nil;
        
        let imageSize = image.size;
        let width = imageSize.width;
        let height = imageSize.height;
        
        let targetWidth = cropSize.width;
        let targetHeight = cropSize.height;
        
        var scaleFactor: CGFloat = 0;
        var scaledWidth = targetWidth;
        var scaledHeight = targetHeight;
        
        var thumbnailPoint = CGPointMake(0, 0);
        
        if (CGSizeEqualToSize(imageSize, cropSize) == false) {
            let widthFactor = targetWidth / width;
            let heightFactor = targetHeight / height;
            
            if (widthFactor > heightFactor) {
                scaleFactor = widthFactor;
            } else {
                scaleFactor = heightFactor;
            }
            
            scaledWidth  = width * scaleFactor;
            scaledHeight = height * scaleFactor;
            
            
            if (widthFactor > heightFactor) {
                thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
            } else {
                if (widthFactor < heightFactor) {
                    thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
                }
            }
        }
        
        UIGraphicsBeginImageContextWithOptions(cropSize, true, 0);
        
        var thumbnailRect = CGRectZero;
        thumbnailRect.origin = thumbnailPoint;
        thumbnailRect.size.width  = scaledWidth;
        thumbnailRect.size.height = scaledHeight;
        
        image.drawInRect(thumbnailRect)
        
        newImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        return newImage!;
    }
}

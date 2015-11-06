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
                completion(image)
            }
        })
    }
}

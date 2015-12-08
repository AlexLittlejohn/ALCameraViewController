//
//  ALCameraView.swift
//  ALCameraViewController
//
//  Created by Alex Littlejohn on 2015/06/17.
//  Copyright (c) 2015 zero. All rights reserved.
//

import UIKit
import AVFoundation

public class ALCameraView: UIView {
    
    var session: AVCaptureSession!
    var input: AVCaptureDeviceInput!
    var device: AVCaptureDevice!
    var imageOutput: AVCaptureStillImageOutput!
    var preview: AVCaptureVideoPreviewLayer!
    
    
    public var currentPosition = AVCaptureDevicePosition.Back
    
    public func startSession() {
        createPreview()
        session.startRunning()
    }
    
    public func stopSession() {
        session?.stopRunning()
        preview?.removeFromSuperlayer()
      
        session = nil
        input = nil
        imageOutput = nil
        preview = nil
        device = nil
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if let p = preview {
            p.frame = bounds
        }
    }
    
    private func createPreview() {
        session = AVCaptureSession()
        session.sessionPreset = AVCaptureSessionPresetHigh
        
        device = cameraWithPosition(currentPosition)
        
        let outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG]
        
        do {
            input = try AVCaptureDeviceInput(device: device)
        } catch let error as NSError {
            input = nil
            print("Error: \(error.localizedDescription)")
            return
        }
        
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        imageOutput = AVCaptureStillImageOutput()
        imageOutput.outputSettings = outputSettings
        
        session.addOutput(imageOutput)
        
        preview = AVCaptureVideoPreviewLayer(session: session)
        preview.videoGravity = AVLayerVideoGravityResizeAspectFill
        preview.frame = bounds
        
        layer.addSublayer(preview)
    }
    
    private func cameraWithPosition(position: AVCaptureDevicePosition) -> AVCaptureDevice? {
        let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        var _device: AVCaptureDevice?
        for d in devices {
            if d.position == position {
                _device = d as? AVCaptureDevice
                break
            }
        }
        
        return _device
    }
    
    public func capturePhoto(completion: ALCameraShotCompletion) {
        let orientation = AVCaptureVideoOrientation(rawValue: UIDevice.currentDevice().orientation.rawValue)!
        ALCameraShot().takePhoto(self.imageOutput, videoOrientation: orientation, cropSize: self.frame.size) { image in
        
          var correctedImage = image
        
          if self.currentPosition == .Front {
            correctedImage = image.fixFrontCameraOrientation()
          }
        
          completion(correctedImage)
        }
    }

    public func swapCameraInput() {
        if session != nil && input != nil {
            session.beginConfiguration()
            session.removeInput(input)
            
            if input.device.position == AVCaptureDevicePosition.Back {
                currentPosition = AVCaptureDevicePosition.Front
                device = cameraWithPosition(currentPosition)
            } else {
                currentPosition = AVCaptureDevicePosition.Back
                device = cameraWithPosition(currentPosition)
            }
            
            let error = NSErrorPointer()
            do {
                input = try AVCaptureDeviceInput(device: device)
            } catch let error1 as NSError {
                error.memory = error1
                input = nil
            }
            
            session.addInput(input)
            session.commitConfiguration()
        }
    }

}

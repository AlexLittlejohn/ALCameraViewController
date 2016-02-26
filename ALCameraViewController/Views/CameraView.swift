//
//  CameraView.swift
//  ALCameraViewController
//
//  Created by Alex Littlejohn on 2015/06/17.
//  Copyright (c) 2015 zero. All rights reserved.
//

import UIKit
import AVFoundation

public class CameraView: UIView {
    
    var session: AVCaptureSession!
    var input: AVCaptureDeviceInput!
    var device: AVCaptureDevice!
    var imageOutput: AVCaptureStillImageOutput!
    var preview: AVCaptureVideoPreviewLayer!
    
    let cameraQueue = dispatch_queue_create("com.zero.ALCameraViewController.Queue", DISPATCH_QUEUE_SERIAL);
    
    let focusView = CropOverlay(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
    
    public var currentPosition = AVCaptureDevicePosition.Back
    
    public func startSession() {
        dispatch_async(cameraQueue) {
            self.createSession()
            self.session?.startRunning()
        }
    }
    
    public func stopSession() {
        dispatch_async(cameraQueue) {
            self.session?.stopRunning()
            self.preview?.removeFromSuperlayer()
            
            self.session = nil
            self.input = nil
            self.imageOutput = nil
            self.preview = nil
            self.device = nil
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if let p = preview {
            p.frame = bounds
        }
    }
    
    public func configureFocus() {
        
        if let gestureRecognizers = gestureRecognizers {
            for gesture in gestureRecognizers {
                removeGestureRecognizer(gesture)
            }
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "focus:")
        addGestureRecognizer(tapGesture)
        userInteractionEnabled = true
        addSubview(focusView)
        
        focusView.hidden = true
        
        let lines = focusView.horizontalLines + focusView.verticalLines + focusView.outerLines
        
        lines.forEach { line in
            line.alpha = 0
        }
        
    }
    
    internal func focus(gesture: UITapGestureRecognizer) {
        let point = gesture.locationInView(self)
        guard let device = device else { return }
        do { try device.lockForConfiguration() } catch {
            return
        }
        
        if device.isFocusModeSupported(.Locked) {
            
            let focusPoint = CGPoint(x: point.x / frame.width, y: point.y / frame.height)
            
            device.focusPointOfInterest = focusPoint
            device.unlockForConfiguration()
            
            focusView.hidden = false
            focusView.center = point
            focusView.alpha = 0
            focusView.transform = CGAffineTransformMakeScale(1.2, 1.2)

            bringSubviewToFront(focusView)
            
            UIView.animateKeyframesWithDuration(1.5, delay: 0, options: UIViewKeyframeAnimationOptions(), animations: {
                
                UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 0.15, animations: { () -> Void in
                    self.focusView.alpha = 1
                    self.focusView.transform = CGAffineTransformIdentity
                })
                
                UIView.addKeyframeWithRelativeStartTime(0.80, relativeDuration: 0.20, animations: { () -> Void in
                    self.focusView.alpha = 0
                    self.focusView.transform = CGAffineTransformMakeScale(0.8, 0.8)
                })
                
                
            }, completion: { finished in
                if finished {
                    self.focusView.hidden = true
                }
            })
        }
    }
    
    private func createSession() {
        session = AVCaptureSession()
        session.sessionPreset = AVCaptureSessionPresetHigh
        dispatch_async(dispatch_get_main_queue()) {
            self.createPreview()
        }
    }
    
    private func createPreview() {
        device = cameraWithPosition(currentPosition)
        if device.hasFlash {
            do {
                try device.lockForConfiguration()
                device.flashMode = .Auto
                device.unlockForConfiguration()
            } catch _ {}
        }
        
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
        dispatch_async(cameraQueue) {
            let orientation = AVCaptureVideoOrientation(rawValue: UIDevice.currentDevice().orientation.rawValue)!
            CameraShot().takePhoto(self.imageOutput, videoOrientation: orientation, cropSize: self.frame.size) { image in
                completion(image)
            }
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

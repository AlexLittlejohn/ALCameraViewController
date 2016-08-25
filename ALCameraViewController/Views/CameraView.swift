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
    
    let cameraQueue = dispatch_queue_create("com.zero.ALCameraViewController.Queue", DISPATCH_QUEUE_SERIAL)
    
    let focusView = CropOverlay(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
    
    public var currentPosition = CameraGlobals.shared.defaultCameraPosition
    
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
        preview?.frame = bounds
    }
    
    public func configureFocus() {
        
        if let gestureRecognizers = gestureRecognizers {
            gestureRecognizers.forEach({ removeGestureRecognizer($0) })
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(focus(_:)))
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
        
        guard focusCamera(point) else {
            return
        }
        
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
    
    private func createSession() {
        session = AVCaptureSession()
        session.sessionPreset = AVCaptureSessionPresetPhoto
        dispatch_async(dispatch_get_main_queue()) {
            self.createPreview()
        }
    }
    
    private func createPreview() {
        device = cameraWithPosition(currentPosition)
        if let device = device where device.hasFlash {
            do {
                try device.lockForConfiguration()
                device.flashMode = .Auto
                device.unlockForConfiguration()
            } catch _ {}
        }
        
        let outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        
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
        guard let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo) as? [AVCaptureDevice] else {
            return nil
        }
        return devices.filter { $0.position == position }.first
    }
    
    public func capturePhoto(completion: CameraShotCompletion) {
        userInteractionEnabled = false
        dispatch_async(cameraQueue) {
            
            var i = 0
            
            if let device = self.device {
                while device.adjustingWhiteBalance || device.adjustingExposure || device.adjustingFocus {
                    i += 1 // this is strange but we have to do something while we wait
                }
            }
            
            let orientation = AVCaptureVideoOrientation(rawValue: UIDevice.currentDevice().orientation.rawValue)!
            takePhoto(self.imageOutput, videoOrientation: orientation, cropSize: self.frame.size) { image in
                dispatch_async(dispatch_get_main_queue()) {
                    self.userInteractionEnabled = true
                    completion(image)
                }
            }
        }
    }
    
    public func focusCamera(toPoint: CGPoint) -> Bool {
        
        guard let device = device where device.isFocusModeSupported(.ContinuousAutoFocus) else {
            return false
        }
        
        do { try device.lockForConfiguration() } catch {
            return false
        }
        
        // focus points are in the range of 0...1, not screen pixels
        let focusPoint = CGPoint(x: toPoint.x / frame.width, y: toPoint.y / frame.height)
        
        device.focusMode = AVCaptureFocusMode.ContinuousAutoFocus
        device.exposurePointOfInterest = focusPoint
        device.exposureMode = AVCaptureExposureMode.ContinuousAutoExposure
        device.unlockForConfiguration()
        
        return true
    }
    
    public func cycleFlash() {
        guard let device = device where device.hasFlash else {
            return
        }
        
        do {
            try device.lockForConfiguration()
            if device.flashMode == .On {
                device.flashMode = .Off
            } else if device.flashMode == .Off {
                device.flashMode = .Auto
            } else {
                device.flashMode = .On
            }
            device.unlockForConfiguration()
        } catch _ { }
    }

    public func swapCameraInput() {
        
        guard let session = session, input = input else {
            return
        }
        
        session.beginConfiguration()
        session.removeInput(input)
        
        if input.device.position == AVCaptureDevicePosition.Back {
            currentPosition = AVCaptureDevicePosition.Front
            device = cameraWithPosition(currentPosition)
        } else {
            currentPosition = AVCaptureDevicePosition.Back
            device = cameraWithPosition(currentPosition)
        }
        
        guard let i = try? AVCaptureDeviceInput(device: device) else {
            return
        }
        
        self.input = i
        
        session.addInput(i)
        session.commitConfiguration()
    }
  
    public func rotatePreview() {
      
        guard preview != nil else {
            return
        }
        switch UIApplication.sharedApplication().statusBarOrientation {
            case .Portrait:
              preview?.connection.videoOrientation = AVCaptureVideoOrientation.Portrait
              break
            case .PortraitUpsideDown:
              preview?.connection.videoOrientation = AVCaptureVideoOrientation.PortraitUpsideDown
              break
            case .LandscapeRight:
              preview?.connection.videoOrientation = AVCaptureVideoOrientation.LandscapeRight
              break
            case .LandscapeLeft:
              preview?.connection.videoOrientation = AVCaptureVideoOrientation.LandscapeLeft
              break
            default: break
        }
    }
    
}

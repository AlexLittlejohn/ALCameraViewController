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
    
    let cameraQueue = DispatchQueue(label: "com.zero.ALCameraViewController.Queue")
    
    let focusView = CropOverlay(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
    
    public var currentPosition = AVCaptureDevicePosition.back
    
    public func startSession() {
        cameraQueue.async {
            self.createSession()
            self.session?.startRunning()
        }
    }
    
    public func stopSession() {
        cameraQueue.async {
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
        isUserInteractionEnabled = true
        addSubview(focusView)
        
        focusView.isHidden = true
        
        let lines = focusView.horizontalLines + focusView.verticalLines + focusView.outerLines
        
        lines.forEach { line in
            line.alpha = 0
        }
    }
    
    internal func focus(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: self)
        
        guard focusCamera(point) else {
            return
        }
        
        focusView.isHidden = false
        focusView.center = point
        focusView.alpha = 0
        focusView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        
        bringSubview(toFront: focusView)
        
        UIView.animateKeyframes(withDuration: 1.5, delay: 0, options: UIViewKeyframeAnimationOptions(), animations: {
            
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.15, animations: { () -> Void in
                self.focusView.alpha = 1
                self.focusView.transform = CGAffineTransform.identity
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.80, relativeDuration: 0.20, animations: { () -> Void in
                self.focusView.alpha = 0
                self.focusView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            })
            
            
            }, completion: { finished in
                if finished {
                    self.focusView.isHidden = true
                }
        })
    }
    
    private func createSession() {
        session = AVCaptureSession()
        session.sessionPreset = AVCaptureSessionPresetPhoto
        DispatchQueue.main.async {
            self.createPreview()
        }
    }
    
    private func createPreview() {
        device = cameraWithPosition(currentPosition)
        if let device = device, device.hasFlash {
            do {
                try device.lockForConfiguration()
                device.flashMode = .auto
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
    
    private func cameraWithPosition(_ position: AVCaptureDevicePosition) -> AVCaptureDevice? {
        guard let devices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo) as? [AVCaptureDevice] else {
            return nil
        }
        return devices.filter { $0.position == position }.first
    }
    
    public func capturePhoto(_ completion: @escaping CameraShotCompletion) {
        isUserInteractionEnabled = false
        cameraQueue.async {
            
            var i = 0
            
            if let device = self.device {
                while device.isAdjustingWhiteBalance || device.isAdjustingExposure || device.isAdjustingFocus {
                    i += 1 // this is strange but we have to do something while we wait
                }
            }
            
            let orientation = AVCaptureVideoOrientation(rawValue: UIDevice.current.orientation.rawValue)!
            takePhoto(self.imageOutput, videoOrientation: orientation, cropSize: self.frame.size) { image in
                DispatchQueue.main.async {
                    self.isUserInteractionEnabled = true
                    completion(image)
                }
            }
        }
    }
    
    public func focusCamera(_ toPoint: CGPoint) -> Bool {
        
        guard let device = device, device.isFocusModeSupported(.continuousAutoFocus) else {
            return false
        }
        
        do { try device.lockForConfiguration() } catch {
            return false
        }
        
        // focus points are in the range of 0...1, not screen pixels
        let focusPoint = CGPoint(x: toPoint.x / frame.width, y: toPoint.y / frame.height)
        
        device.focusMode = AVCaptureFocusMode.continuousAutoFocus
        device.exposurePointOfInterest = focusPoint
        device.exposureMode = AVCaptureExposureMode.continuousAutoExposure
        device.unlockForConfiguration()
        
        return true
    }
    
    public func cycleFlash() {
        guard let device = device, device.hasFlash else {
            return
        }
        
        do {
            try device.lockForConfiguration()
            if device.flashMode == .on {
                device.flashMode = .off
            } else if device.flashMode == .off {
                device.flashMode = .auto
            } else {
                device.flashMode = .on
            }
            device.unlockForConfiguration()
        } catch _ { }
    }

    public func swapCameraInput() {
        
        guard let session = session, let input = input else {
            return
        }
        
        session.beginConfiguration()
        session.removeInput(input)
        
        if input.device.position == AVCaptureDevicePosition.back {
            currentPosition = AVCaptureDevicePosition.front
            device = cameraWithPosition(currentPosition)
        } else {
            currentPosition = AVCaptureDevicePosition.back
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
        switch UIApplication.shared.statusBarOrientation {
            case .portrait:
              preview?.connection.videoOrientation = AVCaptureVideoOrientation.portrait
              break
            case .portraitUpsideDown:
              preview?.connection.videoOrientation = AVCaptureVideoOrientation.portraitUpsideDown
              break
            case .landscapeRight:
              preview?.connection.videoOrientation = AVCaptureVideoOrientation.landscapeRight
              break
            case .landscapeLeft:
              preview?.connection.videoOrientation = AVCaptureVideoOrientation.landscapeLeft
              break
            default: break
        }
    }
    
}

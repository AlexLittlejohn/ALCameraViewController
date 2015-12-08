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
  
  let cameraQueue = dispatch_queue_create("com.zero.ALCameraViewController.Queue", DISPATCH_QUEUE_SERIAL);
  
  public var currentPosition = AVCaptureDevicePosition.Back
  
  public func startSession() {
    dispatch_async(cameraQueue) {
      self.createPreview()
      self.session.startRunning()
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
  
  private func createPreview() {
    session = AVCaptureSession()
    
    dispatch_async(dispatch_get_main_queue()) {
      
      self.session.sessionPreset = AVCaptureSessionPresetHigh
      
      self.device = self.cameraWithPosition(self.currentPosition)
      
      let outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG]
      
      do {
        self.input = try AVCaptureDeviceInput(device: self.device)
      } catch let error as NSError {
        self.input = nil
        print("Error: \(error.localizedDescription)")
        return
      }
      
      if self.session.canAddInput(self.input) {
        self.session.addInput(self.input)
      }
      
      self.imageOutput = AVCaptureStillImageOutput()
      self.imageOutput.outputSettings = outputSettings
      
      self.session.addOutput(self.imageOutput)
      
      self.preview = AVCaptureVideoPreviewLayer(session: self.session)
      self.preview.videoGravity = AVLayerVideoGravityResizeAspectFill
      self.preview.frame = self.bounds
      
      self.layer.addSublayer(self.preview)
    }
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
      ALCameraShot().takePhoto(self.imageOutput, videoOrientation: orientation, cropSize: self.frame.size) { image in
        
        var correctedImage = image
        
        if self.currentPosition == .Front {
          correctedImage = image.fixFrontCameraOrientation()
        }
        
        completion(correctedImage)
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

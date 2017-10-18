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

    let minimumZoom: CGFloat = 1.0
    let maximumZoom: CGFloat = 3.0
    var lastZoomFactor: CGFloat = 1.0

    public var currentPosition = CameraGlobals.shared.defaultCameraPosition

    public func startSession() {
        session = AVCaptureSession()
        session.sessionPreset = AVCaptureSessionPresetPhoto

        device = cameraWithPosition(position: currentPosition)
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

        cameraQueue.sync {
            session.startRunning()
            DispatchQueue.main.async { [weak self] in
                self?.createPreview()
            }
        }
    }

    public func stopSession() {
        cameraQueue.sync {
            session?.stopRunning()
            preview?.removeFromSuperlayer()

            session = nil
            input = nil
            imageOutput = nil
            preview = nil
            device = nil
        }
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        preview?.frame = bounds
        print("bounds updated: \(bounds)")
    }

    public func configureFocus() {

        if let gestureRecognizers = gestureRecognizers {
            gestureRecognizers.forEach({ removeGestureRecognizer($0) })
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(focus(gesture:)))
        addGestureRecognizer(tapGesture)
        isUserInteractionEnabled = true
        addSubview(focusView)

        focusView.isHidden = true

        let lines = focusView.horizontalLines + focusView.verticalLines + focusView.outerLines

        lines.forEach { line in
            line.alpha = 0
        }

        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinch(gesture:)))
        addGestureRecognizer(pinchGesture)
    }

    internal func focus(gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: self)

        guard focusCamera(toPoint: point) else {
            return
        }

        focusView.isHidden = false
        focusView.center = point
        focusView.alpha = 0
        focusView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)

        bringSubview(toFront: focusView)

        UIView.animateKeyframes(withDuration: 1.5, delay: 0, options: UIViewKeyframeAnimationOptions(), animations: {

            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.15, animations: { [weak self] in
                self?.focusView.alpha = 1
                self?.focusView.transform = CGAffineTransform.identity
            })

            UIView.addKeyframe(withRelativeStartTime: 0.80, relativeDuration: 0.20, animations: { [weak self] in
                self?.focusView.alpha = 0
                self?.focusView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            })

        }, completion: { [weak self] finished in
            if finished {
                self?.focusView.isHidden = true
            }
        })
    }

    internal func pinch(gesture: UIPinchGestureRecognizer) {
        guard let device = device else { return }

        // Return zoom value between the minimum and maximum zoom values
        func minMaxZoom(_ factor: CGFloat) -> CGFloat {
            return min(min(max(factor, minimumZoom), maximumZoom), device.activeFormat.videoMaxZoomFactor)
        }

        func update(scale factor: CGFloat) {
            do {
                try device.lockForConfiguration()
                defer { device.unlockForConfiguration() }
                device.videoZoomFactor = factor
            } catch {
                print("\(error.localizedDescription)")
            }
        }

        let newScaleFactor = minMaxZoom(gesture.scale * lastZoomFactor)

        switch gesture.state {
        case .began: fallthrough
        case .changed: update(scale: newScaleFactor)
        case .ended:
            lastZoomFactor = minMaxZoom(newScaleFactor)
            update(scale: lastZoomFactor)
        default: break
        }
    }

    private func createPreview() {
        preview = AVCaptureVideoPreviewLayer(session: session)
        preview.videoGravity = AVLayerVideoGravityResizeAspect
        preview.frame = bounds
        layer.addSublayer(preview)
    }

    private func cameraWithPosition(position: AVCaptureDevicePosition) -> AVCaptureDevice? {
        guard let devices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo) as? [AVCaptureDevice] else {
            return nil
        }
        return devices.filter { $0.position == position }.first
    }

    public func capturePhoto(scale: CGFloat, completion: @escaping CameraShotCompletion) {
        isUserInteractionEnabled = false

        guard let output = imageOutput, let orientation = AVCaptureVideoOrientation(rawValue: UIDevice.current.orientation.rawValue) else {
            completion(nil, nil, nil, nil)
            return
        }

        let outputScale = scale
        let size = frame.size

        cameraQueue.sync {
            takePhoto(output, videoOrientation: orientation, cameraPosition: device.position, cropSize: size, outputScale: outputScale) { imageData, image, errorData, exifData in
                DispatchQueue.main.async() { [weak self] in
                    self?.isUserInteractionEnabled = true
                    completion(imageData, image, errorData, exifData)
                }
            }
        }
    }

    public func focusCamera(toPoint: CGPoint) -> Bool {

        guard let device = device, let preview = preview, device.isFocusModeSupported(.continuousAutoFocus) else {
            return false
        }

        do { try device.lockForConfiguration() } catch {
            return false
        }

        let focusPoint = preview.captureDevicePointOfInterest(for: toPoint)

        device.focusPointOfInterest = focusPoint
        device.focusMode = .continuousAutoFocus

        device.exposurePointOfInterest = focusPoint
        device.exposureMode = .continuousAutoExposure

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
        } catch _ {}
    }

    public func swapCameraInput() {

        guard let session = session, let currentInput = input else {
            return
        }

        session.beginConfiguration()
        session.removeInput(currentInput)

        if currentInput.device.position == AVCaptureDevicePosition.back {
            currentPosition = AVCaptureDevicePosition.front
            device = cameraWithPosition(position: currentPosition)
        } else {
            currentPosition = AVCaptureDevicePosition.back
            device = cameraWithPosition(position: currentPosition)
        }

        guard let newInput = try? AVCaptureDeviceInput(device: device) else {
            return
        }

        input = newInput

        session.addInput(newInput)
        session.commitConfiguration()
    }

    public func rotateCameraButtons(button:UIButton) {
        
        guard preview != nil else {
            return
        }
        switch UIApplication.shared.statusBarOrientation {
        case .portrait:
            button.setImage(UIImage.init(cgImage: (button.currentImage?.cgImage)!, scale: 1.0, orientation: .down), for: .normal)
            break
        case .portraitUpsideDown:
            button.setImage(UIImage.init(cgImage: (button.currentImage?.cgImage)!, scale: 1.0, orientation: .up), for: .normal)
            break
        case .landscapeRight:
            button.setImage(UIImage.init(cgImage: (button.currentImage?.cgImage)!, scale: 1.0, orientation: .right), for: .normal)
            break
        case .landscapeLeft:
            button.setImage(UIImage.init(cgImage: (button.currentImage?.cgImage)!, scale: 1.0, orientation: .left), for: .normal)
            break
        default: break
        }
    }
}

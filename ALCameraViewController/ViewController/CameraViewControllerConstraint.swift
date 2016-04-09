//
//  CameraViewControllerConstraint.swift
//  CameraViewControllerConstraint
//
//  Created by Pedro Paulo de Amorim.
//  Copyright (c) 2016 zero. All rights reserved.
//

import UIKit
import AVFoundation

/**
 * This extension provides the configuration of
 * constraints for CameraViewController.
 */
extension CameraViewController {
    
    /**
     * To attach the view to the edges of the superview, it needs
     to be pinned on the sides of the self.view, based on the
     edges of this superview.
     * This configure the cameraView to show, in real time, the
     * camera.
     */
    func configCameraViewConstraints() {
        [.Left, .Right, .Top, .Bottom].forEach({
            view.addConstraint(NSLayoutConstraint(
                item: cameraView,
                attribute: $0,
                relatedBy: .Equal,
                toItem: view,
                attribute: $0,
                multiplier: 1.0,
                constant: 0))
        })
    }
    
    /**
     * Add the constraints based on the device orientation,
     * this pin the button on the bottom part of the screen
     * when the device is portrait, when landscape, pin
     * the button on the right part of the screen.
     */
    func configCameraButtonEdgeConstraint(statusBarOrientation: UIInterfaceOrientation) {
        view.autoRemoveConstraint(cameraButtonEdgeConstraint)
        
        let attribute : NSLayoutAttribute = {
            switch statusBarOrientation {
            case .Portrait: return .Bottom
            case .LandscapeRight: return .Right
            case .LandscapeLeft: return .Left
            default: return .Top
            }
        }()
        
        cameraButtonEdgeConstraint = NSLayoutConstraint(
            item: cameraButton,
            attribute: attribute,
            relatedBy: .Equal,
            toItem: view,
            attribute: attribute,
            multiplier: 1.0,
            constant: attribute == .Right || attribute == .Bottom ? -8 : 8)
        view.addConstraint(cameraButtonEdgeConstraint!)
    }
    
    /**
     * Add the constraints based on the device orientation,
     * centerX the button based on the width of screen.
     * When the device is landscape orientation, centerY
     * the button based on the height of screen.
     */
    func configCameraButtonGravityConstraint(portrait: Bool) {
        view.autoRemoveConstraint(cameraButtonGravityConstraint)
        let attribute : NSLayoutAttribute = portrait ? .CenterX : .CenterY
        cameraButtonGravityConstraint = NSLayoutConstraint(
            item: cameraButton,
            attribute: attribute,
            relatedBy: .Equal,
            toItem: view,
            attribute: attribute,
            multiplier: 1.0,
            constant: 0)
        view.addConstraint(cameraButtonGravityConstraint!)
    }
    
    /**
     * Remove the constraints of container.
     */
    func removeContainerConstraints() {
        view.autoRemoveConstraint(containerButtonsEdgeOneConstraint)
        view.autoRemoveConstraint(containerButtonsEdgeTwoConstraint)
        view.autoRemoveConstraint(containerButtonsGravityConstraint)
    }
    
    /**
     * Configure the edges constraints of container that 
     * handle the center position of SwapButton and
     * LibraryButton.
     */
    func configContainerEdgeConstraint(statusBarOrientation : UIInterfaceOrientation) {
        
        let attributeOne : NSLayoutAttribute
        let attributeTwo : NSLayoutAttribute
        
        switch statusBarOrientation {
        case .Portrait:
            attributeOne = .Left
            attributeTwo = .Right
            break
        case .LandscapeRight:
            attributeOne = .Bottom
            attributeTwo = .Top
            break
        case .LandscapeLeft:
            attributeOne = .Top
            attributeTwo = .Bottom
            break
        default:
            attributeOne = .Right
            attributeTwo = .Left
            break
        }
        
        containerButtonsEdgeOneConstraint = NSLayoutConstraint(
            item: containerSwapLibraryButton,
            attribute: attributeOne,
            relatedBy: .Equal,
            toItem: cameraButton,
            attribute: attributeTwo,
            multiplier: 1.0,
            constant: 0)
        view.addConstraint(containerButtonsEdgeOneConstraint!)
        
        containerButtonsEdgeTwoConstraint = NSLayoutConstraint(
            item: containerSwapLibraryButton,
            attribute: attributeTwo,
            relatedBy: .Equal,
            toItem: view,
            attribute: attributeTwo,
            multiplier: 1.0,
            constant: 0)
        view.addConstraint(containerButtonsEdgeTwoConstraint!)

    }
    
    /**
     * Configure the gravity of container, based on the
     * orientation of the device.
     */
    func configContainerGravityConstraint(statusBarOrientation : UIInterfaceOrientation) {
        let attributeCenter : NSLayoutAttribute = statusBarOrientation.isPortrait ? .CenterY : .CenterX
        containerButtonsGravityConstraint = NSLayoutConstraint(
            item: containerSwapLibraryButton,
            attribute: attributeCenter,
            relatedBy: .Equal,
            toItem: cameraButton,
            attribute: attributeCenter,
            multiplier: 1.0,
            constant: 0)
        view.addConstraint(containerButtonsGravityConstraint!)
    }
    
    /**
     * Remove the SwapButton constraints to be updated when
     * the device was rotated.
     */
    func removeSwapButtonConstraints() {
        view.autoRemoveConstraint(swapButtonEdgeOneConstraint)
        view.autoRemoveConstraint(swapButtonEdgeTwoConstraint)
        view.autoRemoveConstraint(swapButtonGravityConstraint)
    }
    
    /**
     * If the device is portrait, pin the SwapButton on the
     * right side of the CameraButton.
     * If landscape, pin the SwapButton on the top of the
     * CameraButton.
     */
    func configSwapButtonEdgeConstraint(statusBarOrientation : UIInterfaceOrientation) {
        
        let attributeOne : NSLayoutAttribute
        let attributeTwo : NSLayoutAttribute

        switch statusBarOrientation {
        case .Portrait:
            attributeOne = .Top
            attributeTwo = .Bottom
            break
        case .LandscapeRight:
            attributeOne = .Left
            attributeTwo = .Right
            break
        case .LandscapeLeft:
            attributeOne = .Right
            attributeTwo = .Left
            break
        default:
            attributeOne = .Bottom
            attributeTwo = .Top
            break
        }
        
        swapButtonEdgeOneConstraint = NSLayoutConstraint(
            item: swapButton,
            attribute: attributeOne,
            relatedBy: .Equal,
            toItem: containerSwapLibraryButton,
            attribute: attributeOne,
            multiplier: 1.0,
            constant: 0)
        view.addConstraint(swapButtonEdgeOneConstraint!)
        
        swapButtonEdgeTwoConstraint = NSLayoutConstraint(
            item: swapButton,
            attribute: attributeTwo,
            relatedBy: .Equal,
            toItem: containerSwapLibraryButton,
            attribute: attributeTwo,
            multiplier: 1.0,
            constant: 0)
        view.addConstraint(swapButtonEdgeTwoConstraint!)
        
    }
    
    /**
     * Configure the center of SwapButton, based on the
     * axis center of CameraButton.
     */
    func configSwapButtonGravityConstraint(portrait: Bool) {
        swapButtonGravityConstraint = NSLayoutConstraint(
            item: swapButton,
            attribute: portrait ? .Right : .Bottom,
            relatedBy: .LessThanOrEqual,
            toItem: containerSwapLibraryButton,
            attribute: portrait ? .CenterX : .CenterY,
            multiplier: 1.0,
            constant: -4.0 * DeviceConfig.SCREEN_MULTIPLIER)
        view.addConstraint(swapButtonGravityConstraint!)
    }
    
    func removeCloseButtonConstraints() {
        view.autoRemoveConstraint(closeButtonEdgeConstraint)
        view.autoRemoveConstraint(closeButtonGravityConstraint)
    }
    
    /**
     * Pin the close button to the left of the superview.
     */
    func configCloseButtonEdgeConstraint(statusBarOrientation : UIInterfaceOrientation) {
        
        let attribute : NSLayoutAttribute = {
            switch statusBarOrientation {
            case .Portrait: return .Left
            case .LandscapeRight, .LandscapeLeft: return .CenterX
            default: return .Right
            }
        }()

        closeButtonEdgeConstraint = NSLayoutConstraint(
            item: closeButton,
            attribute: attribute,
            relatedBy: .Equal,
            toItem: attribute != .CenterX ? view : cameraButton,
            attribute: attribute,
            multiplier: 1.0,
            constant: attribute != .CenterX ? 16 : 0)
        view.addConstraint(closeButtonEdgeConstraint!)
    }
    
    /**
     * Add the constraint for the CloseButton, based on
     * the device orientation.
     * If portrait, it pin the CloseButton on the CenterY
     * of the CameraButton.
     * Else if landscape, pin this button on the Bottom
     * of superview.
     */
    func configCloseButtonGravityConstraint(statusBarOrientation : UIInterfaceOrientation) {
        
        let attribute : NSLayoutAttribute
        let constant : CGFloat
        
        switch statusBarOrientation {
        case .Portrait:
            attribute = .CenterY
            constant = 0.0
            break
        case .LandscapeRight:
            attribute = .Bottom
            constant = -16.0
            break
        case .LandscapeLeft:
            attribute = .Top
            constant = 16.0
            break
        default:
            attribute = .CenterX
            constant = 0.0
            break
        }
        
        closeButtonGravityConstraint = NSLayoutConstraint(
            item: closeButton,
            attribute: attribute,
            relatedBy: .Equal,
            toItem: attribute == .Bottom || attribute == .Top ? view : cameraButton,
            attribute: attribute,
            multiplier: 1.0,
            constant: constant)
        
        view.addConstraint(closeButtonGravityConstraint!)
    }
    
    /**
     * Remove the LibraryButton constraints to be updated when
     * the device was rotated.
     */
    func removeLibraryButtonConstraints() {
        view.autoRemoveConstraint(libraryButtonEdgeOneConstraint)
        view.autoRemoveConstraint(libraryButtonEdgeTwoConstraint)
        view.autoRemoveConstraint(libraryButtonGravityConstraint)
    }
    
    /**
     * Add the constraint of the LibraryButton, if the device
     * orientation is portrait, pin the right side of SwapButton
     * to the left side of LibraryButton.
     * If landscape, pin the bottom side of CameraButton on the
     * top side of LibraryButton.
     */
    func configLibraryEdgeButtonConstraint(statusBarOrientation : UIInterfaceOrientation) {

        let attributeOne : NSLayoutAttribute
        let attributeTwo : NSLayoutAttribute
        
        switch statusBarOrientation {
        case .Portrait:
            attributeOne = .Top
            attributeTwo = .Bottom
            break
        case .LandscapeRight:
            attributeOne = .Left
            attributeTwo = .Right
            break
        case .LandscapeLeft:
            attributeOne = .Right
            attributeTwo = .Left
            break
        default:
            attributeOne = .Bottom
            attributeTwo = .Top
            break
        }
        
        libraryButtonEdgeOneConstraint = NSLayoutConstraint(
            item: libraryButton,
            attribute: attributeOne,
            relatedBy: .Equal,
            toItem: containerSwapLibraryButton,
            attribute: attributeOne,
            multiplier: 1.0,
            constant: 0)
        view.addConstraint(libraryButtonEdgeOneConstraint!)
        
        libraryButtonEdgeTwoConstraint = NSLayoutConstraint(
            item: libraryButton,
            attribute: attributeTwo,
            relatedBy: .Equal,
            toItem: containerSwapLibraryButton,
            attribute: attributeTwo,
            multiplier: 1.0,
            constant: 0)
        view.addConstraint(libraryButtonEdgeTwoConstraint!)
        
    }
    
    /**
     * Set the center gravity of the LibraryButton based
     * on the position of CameraButton.
     */
    func configLibraryGravityButtonConstraint(portrait: Bool) {
        libraryButtonGravityConstraint = NSLayoutConstraint(
            item: libraryButton,
            attribute: portrait ? .Left : .Top,
            relatedBy: .LessThanOrEqual,
            toItem: containerSwapLibraryButton,
            attribute: portrait ? .CenterX : .CenterY,
            multiplier: 1.0,
            constant: 4.0 * DeviceConfig.SCREEN_MULTIPLIER)
        view.addConstraint(libraryButtonGravityConstraint!)
    }
    
    /**
     * If the device orientation is portrait, pin the top of
     * FlashButton to the top side of superview.
     * Else if, pin the FlashButton bottom side on the top side
     * of SwapButton.
     */
    func configFlashEdgeButtonConstraint(statusBarOrientation: UIInterfaceOrientation) {
        view.autoRemoveConstraint(flashButtonEdgeConstraint)
        
        let constraintRight = statusBarOrientation == .Portrait || statusBarOrientation == .LandscapeRight
        let attribute : NSLayoutAttribute = constraintRight ? .Top : .Bottom
        
        flashButtonEdgeConstraint = NSLayoutConstraint(
            item: flashButton,
            attribute: attribute,
            relatedBy: .Equal,
            toItem: view,
            attribute: attribute,
            multiplier: 1.0,
            constant: constraintRight ? 8 : -8)
        view.addConstraint(flashButtonEdgeConstraint!)
    }
    
    /**
     * If the device orientation is portrait, pin the
     right side of FlashButton to the right side of
     * superview.
     * Else if, centerX the FlashButton on the CenterX
     * of CameraButton.
     */
    func configFlashGravityButtonConstraint(statusBarOrientation: UIInterfaceOrientation) {
        view.autoRemoveConstraint(flashButtonGravityConstraint)
        
        let constraintRight = statusBarOrientation == .Portrait || statusBarOrientation == .LandscapeLeft
        let attribute : NSLayoutAttribute = constraintRight ? .Right : .Left
        
        flashButtonGravityConstraint = NSLayoutConstraint(
            item: flashButton,
            attribute: attribute,
            relatedBy: .Equal,
            toItem: view,
            attribute: attribute,
            multiplier: 1.0,
            constant: constraintRight ? -8 : 8)
        view.addConstraint(flashButtonGravityConstraint!)
    }
    
    /**
     * Used to create a perfect square for CameraOverlay.
     * This method will determinate the size of CameraOverlay,
     * if portrait, it will use the width of superview to
     * determinate the height of the view. Else if landscape,
     * it uses the height of the superview to create the width
     * of the CameraOverlay.
     */
    func configCameraOverlayWidthConstraint(portrait: Bool) {
        view.autoRemoveConstraint(cameraOverlayWidthConstraint)
        cameraOverlayWidthConstraint = NSLayoutConstraint(
            item: cameraOverlay,
            attribute: portrait ? .Height : .Width,
            relatedBy: .Equal,
            toItem: cameraOverlay,
            attribute: portrait ? .Width : .Height,
            multiplier: 1.0,
            constant: 0)
        view.addConstraint(cameraOverlayWidthConstraint!)
    }
    
    /**
     * This method will center the relative position of
     * CameraOverlay, based on the biggest size of the
     * superview.
     */
    func configCameraOverlayCenterConstraint(portrait: Bool) {
        view.autoRemoveConstraint(cameraOverlayCenterConstraint)
        let attribute : NSLayoutAttribute = portrait ? .CenterY : .CenterX
        cameraOverlayCenterConstraint = NSLayoutConstraint(
            item: cameraOverlay,
            attribute: attribute,
            relatedBy: .Equal,
            toItem: view,
            attribute: attribute,
            multiplier: 1.0,
            constant: 0)
        view.addConstraint(cameraOverlayCenterConstraint!)
    }
    
    /**
     * Remove the CameraOverlay constraints to be updated when
     * the device was rotated.
     */
    func removeCameraOverlayEdgesConstraints() {
        view.autoRemoveConstraint(cameraOverlayEdgeOneConstraint)
        view.autoRemoveConstraint(cameraOverlayEdgeTwoConstraint)
    }
    
    /**
     * It needs to get a determined smallest size of the screen
     to create the smallest size to be used on CameraOverlay.
     It uses the orientation of the screen to determinate where
     the view will be pinned.
     */
    func configCameraOverlayEdgeOneContraint(portrait: Bool, padding: CGFloat) {
        let attribute : NSLayoutAttribute = portrait ? .Left : .Bottom
        cameraOverlayEdgeOneConstraint = NSLayoutConstraint(
            item: cameraOverlay,
            attribute: attribute,
            relatedBy: .Equal,
            toItem: view,
            attribute: attribute,
            multiplier: 1.0,
            constant: padding)
        view.addConstraint(cameraOverlayEdgeOneConstraint!)
    }
    
    /**
     * It needs to get a determined smallest size of the screen
     to create the smallest size to be used on CameraOverlay.
     It uses the orientation of the screen to determinate where
     the view will be pinned.
     */
    func configCameraOverlayEdgeTwoConstraint(portrait: Bool, padding: CGFloat) {
        let attributeTwo : NSLayoutAttribute = portrait ? .Right : .Top
        cameraOverlayEdgeTwoConstraint = NSLayoutConstraint(
            item: cameraOverlay,
            attribute: attributeTwo,
            relatedBy: .Equal,
            toItem: view,
            attribute: attributeTwo,
            multiplier: 1.0,
            constant: -padding)
        view.addConstraint(cameraOverlayEdgeTwoConstraint!)
    }
    
}
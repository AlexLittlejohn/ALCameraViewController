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
        [.left, .right, .top, .bottom].forEach({
            view.addConstraint(NSLayoutConstraint(
                item: cameraView,
                attribute: $0,
                relatedBy: .equal,
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
    func configCameraButtonEdgeConstraint(_ statusBarOrientation: UIInterfaceOrientation) {
        view.autoRemoveConstraint(cameraButtonEdgeConstraint)
        
        let attribute : NSLayoutConstraint.Attribute = {
            switch statusBarOrientation {
            case .portrait: return .bottomMargin
            case .landscapeRight: return .rightMargin
            case .landscapeLeft: return .leftMargin
            default: return .topMargin
            }
        }()
        
        cameraButtonEdgeConstraint = NSLayoutConstraint(
            item: cameraButton,
            attribute: attribute,
            relatedBy: .equal,
            toItem: view,
            attribute: attribute,
            multiplier: 1.0,
            constant: -8)
        view.addConstraint(cameraButtonEdgeConstraint!)
    }
    
    /**
     * Add the constraints based on the device orientation,
     * centerX the button based on the width of screen.
     * When the device is landscape orientation, centerY
     * the button based on the height of screen.
     */
    func configCameraButtonGravityConstraint(_ portrait: Bool) {
        view.autoRemoveConstraint(cameraButtonGravityConstraint)
        let attribute : NSLayoutConstraint.Attribute = portrait ? .centerX : .centerY
        cameraButtonGravityConstraint = NSLayoutConstraint(
            item: cameraButton,
            attribute: attribute,
            relatedBy: .equal,
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
    func configContainerEdgeConstraint(_ statusBarOrientation : UIInterfaceOrientation) {
        
        let attributeOne : NSLayoutConstraint.Attribute
        let attributeTwo : NSLayoutConstraint.Attribute
        
        switch statusBarOrientation {
        case .portrait:
            attributeOne = .left
            attributeTwo = .right
            break
        case .landscapeRight:
            attributeOne = .bottom
            attributeTwo = .top
            break
        case .landscapeLeft:
            attributeOne = .top
            attributeTwo = .bottom
            break
        default:
            attributeOne = .right
            attributeTwo = .left
            break
        }
        
        containerButtonsEdgeOneConstraint = NSLayoutConstraint(
            item: containerSwapLibraryButton,
            attribute: attributeOne,
            relatedBy: .equal,
            toItem: cameraButton,
            attribute: attributeTwo,
            multiplier: 1.0,
            constant: 0)
        view.addConstraint(containerButtonsEdgeOneConstraint!)
        
        containerButtonsEdgeTwoConstraint = NSLayoutConstraint(
            item: containerSwapLibraryButton,
            attribute: attributeTwo,
            relatedBy: .equal,
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
    func configContainerGravityConstraint(_ statusBarOrientation : UIInterfaceOrientation) {
        let attributeCenter : NSLayoutConstraint.Attribute = statusBarOrientation.isPortrait ? .centerY : .centerX
        containerButtonsGravityConstraint = NSLayoutConstraint(
            item: containerSwapLibraryButton,
            attribute: attributeCenter,
            relatedBy: .equal,
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
    func configSwapButtonEdgeConstraint(_ statusBarOrientation : UIInterfaceOrientation) {
        
        let attributeOne : NSLayoutConstraint.Attribute
        let attributeTwo : NSLayoutConstraint.Attribute

        switch statusBarOrientation {
        case .portrait:
            attributeOne = .top
            attributeTwo = .bottom
            break
        case .landscapeRight:
            attributeOne = .left
            attributeTwo = .right
            break
        case .landscapeLeft:
            attributeOne = .right
            attributeTwo = .left
            break
        default:
            attributeOne = .bottom
            attributeTwo = .top
            break
        }
        
        swapButtonEdgeOneConstraint = NSLayoutConstraint(
            item: swapButton,
            attribute: attributeOne,
            relatedBy: .equal,
            toItem: containerSwapLibraryButton,
            attribute: attributeOne,
            multiplier: 1.0,
            constant: 0)
        view.addConstraint(swapButtonEdgeOneConstraint!)
        
        swapButtonEdgeTwoConstraint = NSLayoutConstraint(
            item: swapButton,
            attribute: attributeTwo,
            relatedBy: .equal,
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
    func configSwapButtonGravityConstraint(_ portrait: Bool) {
        swapButtonGravityConstraint = NSLayoutConstraint(
            item: swapButton,
            attribute: portrait ? .right : .bottom,
            relatedBy: .lessThanOrEqual,
            toItem: containerSwapLibraryButton,
            attribute: portrait ? .centerX : .centerY,
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
    func configCloseButtonEdgeConstraint(_ statusBarOrientation : UIInterfaceOrientation) {
        
        let attribute : NSLayoutConstraint.Attribute = {
            switch statusBarOrientation {
            case .portrait: return .left
            case .landscapeRight, .landscapeLeft: return .centerX
            default: return .right
            }
        }()

        closeButtonEdgeConstraint = NSLayoutConstraint(
            item: closeButton,
            attribute: attribute,
            relatedBy: .equal,
            toItem: attribute != .centerX ? view : cameraButton,
            attribute: attribute,
            multiplier: 1.0,
            constant: attribute != .centerX ? 16 : 0)
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
    func configCloseButtonGravityConstraint(_ statusBarOrientation : UIInterfaceOrientation) {
        
        let attribute : NSLayoutConstraint.Attribute
        let constant : CGFloat
        
        switch statusBarOrientation {
        case .portrait:
            attribute = .centerY
            constant = 0.0
            break
        case .landscapeRight:
            attribute = .bottom
            constant = -16.0
            break
        case .landscapeLeft:
            attribute = .top
            constant = 16.0
            break
        default:
            attribute = .centerX
            constant = 0.0
            break
        }
        
        closeButtonGravityConstraint = NSLayoutConstraint(
            item: closeButton,
            attribute: attribute,
            relatedBy: .equal,
            toItem: attribute == .bottom || attribute == .top ? view : cameraButton,
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
    func configLibraryEdgeButtonConstraint(_ statusBarOrientation : UIInterfaceOrientation) {

        let attributeOne : NSLayoutConstraint.Attribute
        let attributeTwo : NSLayoutConstraint.Attribute
        
        switch statusBarOrientation {
        case .portrait:
            attributeOne = .top
            attributeTwo = .bottom
            break
        case .landscapeRight:
            attributeOne = .left
            attributeTwo = .right
            break
        case .landscapeLeft:
            attributeOne = .right
            attributeTwo = .left
            break
        default:
            attributeOne = .bottom
            attributeTwo = .top
            break
        }
        
        libraryButtonEdgeOneConstraint = NSLayoutConstraint(
            item: libraryButton,
            attribute: attributeOne,
            relatedBy: .equal,
            toItem: containerSwapLibraryButton,
            attribute: attributeOne,
            multiplier: 1.0,
            constant: 0)
        view.addConstraint(libraryButtonEdgeOneConstraint!)
        
        libraryButtonEdgeTwoConstraint = NSLayoutConstraint(
            item: libraryButton,
            attribute: attributeTwo,
            relatedBy: .equal,
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
    func configLibraryGravityButtonConstraint(_ portrait: Bool) {
        libraryButtonGravityConstraint = NSLayoutConstraint(
            item: libraryButton,
            attribute: portrait ? .left : .top,
            relatedBy: .lessThanOrEqual,
            toItem: containerSwapLibraryButton,
            attribute: portrait ? .centerX : .centerY,
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
    func configFlashEdgeButtonConstraint(_ statusBarOrientation: UIInterfaceOrientation) {
        view.autoRemoveConstraint(flashButtonEdgeConstraint)
        
        let constraintRight = statusBarOrientation == .portrait || statusBarOrientation == .landscapeRight
        let attribute : NSLayoutConstraint.Attribute = constraintRight ? .topMargin : .bottomMargin
        
        flashButtonEdgeConstraint = NSLayoutConstraint(
            item: flashButton,
            attribute: attribute,
            relatedBy: .equal,
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
    func configFlashGravityButtonConstraint(_ statusBarOrientation: UIInterfaceOrientation) {
        view.autoRemoveConstraint(flashButtonGravityConstraint)
        
        let constraintRight = statusBarOrientation == .portrait || statusBarOrientation == .landscapeLeft
        let attribute : NSLayoutConstraint.Attribute = constraintRight ? .right : .left
        
        flashButtonGravityConstraint = NSLayoutConstraint(
            item: flashButton,
            attribute: attribute,
            relatedBy: .equal,
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
    func configCameraOverlayWidthConstraint(_ portrait: Bool) {
        view.autoRemoveConstraint(cameraOverlayWidthConstraint)
        cameraOverlayWidthConstraint = NSLayoutConstraint(
            item: cameraOverlay,
            attribute: portrait ? .height : .width,
            relatedBy: .equal,
            toItem: cameraOverlay,
            attribute: portrait ? .width : .height,
            multiplier: 1.0,
            constant: 0)
        view.addConstraint(cameraOverlayWidthConstraint!)
    }
    
    /**
     * This method will center the relative position of
     * CameraOverlay, based on the biggest size of the
     * superview.
     */
    func configCameraOverlayCenterConstraint(_ portrait: Bool) {
        view.autoRemoveConstraint(cameraOverlayCenterConstraint)
        let attribute : NSLayoutConstraint.Attribute = portrait ? .centerY : .centerX
        cameraOverlayCenterConstraint = NSLayoutConstraint(
            item: cameraOverlay,
            attribute: attribute,
            relatedBy: .equal,
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
    func configCameraOverlayEdgeOneContraint(_ portrait: Bool, padding: CGFloat) {
        let attribute : NSLayoutConstraint.Attribute = portrait ? .left : .bottom
        cameraOverlayEdgeOneConstraint = NSLayoutConstraint(
            item: cameraOverlay,
            attribute: attribute,
            relatedBy: .equal,
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
    func configCameraOverlayEdgeTwoConstraint(_ portrait: Bool, padding: CGFloat) {
        let attributeTwo : NSLayoutConstraint.Attribute = portrait ? .right : .top
        cameraOverlayEdgeTwoConstraint = NSLayoutConstraint(
            item: cameraOverlay,
            attribute: attributeTwo,
            relatedBy: .equal,
            toItem: view,
            attribute: attributeTwo,
            multiplier: 1.0,
            constant: -padding)
        view.addConstraint(cameraOverlayEdgeTwoConstraint!)
    }
    
}

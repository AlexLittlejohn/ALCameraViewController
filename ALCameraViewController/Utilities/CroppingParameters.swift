//
//  CroppingParameters.swift
//  ALCameraViewController
//
//  Created by Guillaume Bellut on 02/09/2017.
//  Copyright © 2017 zero. All rights reserved.
//

import UIKit

public struct CroppingParameters {
    
    public enum ResizingMode {
        case none
        case rectangle
        case square
    }

    /// Enable the cropping feature.
    /// Default value is set to false.
    var isEnabled: Bool

    /// Select resizing mode for the cropping frame.
    /// Use .rectangle for free form resizing, .square for square resizing and .none if you want to disable resizing
    var resizingMode: ResizingMode

    /// Allow the cropping area to be moved by the user.
    /// Default value is set to false.
    var allowMoving: Bool

    /// Prevent the user to resize the cropping area below a minimum size.
    /// Default value is (60, 60). Below this value, corner buttons will overlap.
    var minimumSize: CGSize

    public init(isEnabled: Bool = false,
                resizingMode: ResizingMode = .rectangle,
                allowMoving: Bool = true,
         minimumSize: CGSize = CGSize(width: 60, height: 60)) {

        self.isEnabled = isEnabled
        self.resizingMode = resizingMode
        self.allowMoving = allowMoving
        self.minimumSize = minimumSize
    }
}

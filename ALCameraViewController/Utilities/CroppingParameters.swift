//
//  CroppingParameters.swift
//  ALCameraViewController
//
//  Created by Guillaume Bellut on 02/09/2017.
//  Copyright © 2017 zero. All rights reserved.
//

import UIKit

public struct CroppingParameters {

    /// Enable the cropping feature.
    /// Default value is set to false.
    var isEnabled: Bool

    /// Allow the cropping area to be resized by the user.
    /// Default value is set to true.
    var allowResizing: Bool

    /// Allow the cropping area to be moved by the user.
    /// Default value is set to false.
    var allowMoving: Bool

    /// Prevent the user to resize the cropping area below a minimum size.
    /// Default value is (60, 60). Below this value, corner buttons will overlap.
    var minimumSize: CGSize

    public init(isEnabled: Bool = false,
                allowResizing: Bool = true,
                allowMoving: Bool = true,
         minimumSize: CGSize = CGSize(width: 60, height: 60)) {

        self.isEnabled = isEnabled
        self.allowResizing = allowResizing
        self.allowMoving = allowMoving
        self.minimumSize = minimumSize
    }
}

//
//  ALCropOverlay.swift
//  ALCameraViewController
//
//  Created by Alex Littlejohn on 2015/06/30.
//  Copyright (c) 2015 zero. All rights reserved.
//

import UIKit

internal class ALCropOverlay: UIView {

    var outerLines = [UIView]()
    var horizontalLines = [UIView]()
    var verticalLines = [UIView]()
    
    var topLeftCornerLines = [UIView]()
    var topRightCornerLines = [UIView]()
    var bottomLeftCornerLines = [UIView]()
    var bottomRightCornerLines = [UIView]()
    
    let cornerDepth: CGFloat = 3
    let cornerWidth: CGFloat = 20
    let lineWidth: CGFloat = 1
    
    internal init() {
        super.init(frame: CGRectZero)
        createLines()
    }

    internal required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createLines()
    }
    
    override func layoutSubviews() {
        
        let size = bounds.size
        
        for i in 0..<outerLines.count {
            let line = outerLines[i]
            var lineFrame: CGRect
            switch (i) {
            case 0:
                lineFrame = CGRectMake(0, 0, size.width, lineWidth)
                break
            case 1:
                lineFrame = CGRectMake(size.width - lineWidth, 0, lineWidth, size.height)
                break
            case 2:
                lineFrame = CGRectMake(0, size.height - lineWidth, size.width, lineWidth)
                break
            case 3:
                lineFrame = CGRectMake(0, 0, lineWidth, size.height)
                break
            default:
                lineFrame = CGRectZero
                break
            }
            
            line.frame = lineFrame
        }
        
        let corners = [topLeftCornerLines, topRightCornerLines, bottomLeftCornerLines, bottomRightCornerLines]
        for i in 0..<corners.count {
            let corner = corners[i]
            var horizontalFrame: CGRect
            var verticalFrame: CGRect
            
            switch (i) {
            case 0:
                verticalFrame = CGRectMake(-cornerDepth, -cornerDepth, cornerDepth, cornerWidth)
                horizontalFrame = CGRectMake(-cornerDepth, -cornerDepth, cornerWidth, cornerDepth)
                break
            case 1:
                verticalFrame = CGRectMake(size.width, -cornerDepth, cornerDepth, cornerWidth)
                horizontalFrame = CGRectMake(size.width + cornerDepth - cornerWidth, -cornerDepth, cornerWidth, cornerDepth)
                break
            case 2:
                verticalFrame = CGRectMake(-cornerDepth, size.height + cornerDepth - cornerWidth, cornerDepth, cornerWidth)
                horizontalFrame = CGRectMake(-cornerDepth, size.height, cornerWidth, cornerDepth)
                break
            case 3:
                verticalFrame = CGRectMake(size.width, size.height + cornerDepth - cornerWidth, cornerDepth, cornerWidth)
                horizontalFrame = CGRectMake(size.width + cornerDepth - cornerWidth, size.height, cornerWidth, cornerDepth)
                break
            default:
                verticalFrame = CGRectZero
                horizontalFrame = CGRectZero
                break
            }
            
            corner[0].frame = verticalFrame
            corner[1].frame = horizontalFrame
        }
        
        let lineThickness = lineWidth / UIScreen.mainScreen().scale
        let padding = (size.height - (lineThickness * CGFloat(horizontalLines.count))) / CGFloat(horizontalLines.count + 1)
        
        for i in 0..<horizontalLines.count {
            let hLine = horizontalLines[i]
            let vLine = verticalLines[i]
            
            let spacing = (padding * CGFloat(i + 1)) + (lineThickness * CGFloat(i))
            
            hLine.frame = CGRectMake(0, spacing, size.width, lineThickness)
            vLine.frame = CGRectMake(spacing, 0, lineThickness, size.height)
        }
        
    }
    
    func createLines() {
        
        outerLines = [createLine(), createLine(), createLine(), createLine()]
        horizontalLines = [createLine(), createLine()]
        verticalLines = [createLine(), createLine()]
        
        topLeftCornerLines = [createLine(), createLine()]
        topRightCornerLines = [createLine(), createLine()]
        bottomLeftCornerLines = [createLine(), createLine()]
        bottomRightCornerLines = [createLine(), createLine()]
        
        userInteractionEnabled = false
    }
    
    func createLine() -> UIView {
        let line = UIView()
        line.backgroundColor = UIColor.whiteColor()
        addSubview(line)
        return line
    }
}

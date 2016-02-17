//
//  CropOverlay.swift
//  ALCameraViewController
//
//  Created by Alex Littlejohn on 2015/06/30.
//  Copyright (c) 2015 zero. All rights reserved.
//

import UIKit

internal class CropOverlay: UIView {

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
    
    internal override init(frame: CGRect) {
        super.init(frame: frame)
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
                lineFrame = CGRect(x: 0, y: 0, width: size.width, height: lineWidth)
                break
            case 1:
                lineFrame = CGRect(x: size.width - lineWidth, y: 0, width: lineWidth, height:  size.height)
                break
            case 2:
                lineFrame = CGRect(x: 0, y: size.height - lineWidth, width: size.width, height:  lineWidth)
                break
            case 3:
                lineFrame = CGRect(x: 0, y: 0, width: lineWidth, height: size.height)
                break
            default:
                lineFrame = CGRect.zero
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
                verticalFrame = CGRect(x: -cornerDepth, y:  -cornerDepth, width:  cornerDepth, height:  cornerWidth)
                horizontalFrame = CGRect(x: -cornerDepth, y:  -cornerDepth, width:  cornerWidth, height:  cornerDepth)
                break
            case 1:
                verticalFrame = CGRect(x: size.width, y:  -cornerDepth, width:  cornerDepth, height:  cornerWidth)
                horizontalFrame = CGRect(x: size.width + cornerDepth - cornerWidth, y:  -cornerDepth, width:  cornerWidth, height:  cornerDepth)
                break
            case 2:
                verticalFrame = CGRect(x: -cornerDepth, y:  size.height + cornerDepth - cornerWidth, width:  cornerDepth, height:  cornerWidth)
                horizontalFrame = CGRect(x: -cornerDepth, y:  size.height, width:  cornerWidth, height:  cornerDepth)
                break
            case 3:
                verticalFrame = CGRect(x: size.width, y:  size.height + cornerDepth - cornerWidth, width:  cornerDepth, height:  cornerWidth)
                horizontalFrame = CGRect(x: size.width + cornerDepth - cornerWidth, y:  size.height, width:  cornerWidth, height:  cornerDepth)
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
            
            hLine.frame = CGRect(x: 0, y: spacing, width: size.width, height:  lineThickness)
            vLine.frame = CGRect(x: spacing, y: 0, width: lineThickness, height: size.height)
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

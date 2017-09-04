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

    var cornerButtons = [UIButton]()

    let cornerLineDepth: CGFloat = 3
    let cornerLineWidth: CGFloat = 22.5
    var cornerButtonWidth: CGFloat {
        return self.cornerLineWidth * 2
    }

    let lineWidth: CGFloat = 1

    let outterGapRatio: CGFloat = 1/3
    var outterGap: CGFloat {
        return self.cornerButtonWidth * self.outterGapRatio
    }

    var isResizable: Bool = false
    var isMovable: Bool = false
    var minimumSize: CGSize = CGSize.zero

    internal override init(frame: CGRect) {
        super.init(frame: frame)
        createLines()
    }

    internal required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createLines()
    }
    
    override func layoutSubviews() {
        
        for i in 0..<outerLines.count {
            let line = outerLines[i]
            var lineFrame: CGRect
            switch (i) {
            case 0:
                lineFrame = CGRect(x: outterGap, y: outterGap, width: bounds.width - outterGap * 2, height: lineWidth)
                break
            case 1:
                lineFrame = CGRect(x: bounds.width - lineWidth - outterGap, y: outterGap, width: lineWidth, height: bounds.height - outterGap * 2)
                break
            case 2:
                lineFrame = CGRect(x: outterGap, y: bounds.height - lineWidth - outterGap, width: bounds.width - outterGap * 2, height: lineWidth)
                break
            case 3:
                lineFrame = CGRect(x: outterGap, y: outterGap, width: lineWidth, height: bounds.height - outterGap * 2)
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
			var buttonFrame: CGRect
			let buttonSize = CGSize(width: cornerButtonWidth, height: cornerButtonWidth)
			
            switch (i) {
			case 0:	// Top Left
				verticalFrame = CGRect(x: outterGap, y: outterGap, width: cornerLineDepth, height: cornerLineWidth)
				horizontalFrame = CGRect(x: outterGap, y: outterGap, width: cornerLineWidth, height: cornerLineDepth)
				buttonFrame = CGRect(origin: CGPoint(x: 0, y: 0), size: buttonSize)
			case 1:	// Top Right
				verticalFrame = CGRect(x: bounds.width - cornerLineDepth - outterGap, y: outterGap, width: cornerLineDepth, height: cornerLineWidth)
				horizontalFrame = CGRect(x: bounds.width - cornerLineWidth - outterGap, y: outterGap, width: cornerLineWidth, height: cornerLineDepth)
				buttonFrame = CGRect(origin: CGPoint(x: bounds.width - cornerButtonWidth, y: 0), size: buttonSize)
			case 2:	// Bottom Left
				verticalFrame = CGRect(x: outterGap, y:  bounds.height - cornerLineWidth - outterGap, width: cornerLineDepth, height: cornerLineWidth)
				horizontalFrame = CGRect(x: outterGap, y:  bounds.height - cornerLineDepth - outterGap, width: cornerLineWidth, height: cornerLineDepth)
				buttonFrame = CGRect(origin: CGPoint(x: 0, y: bounds.height - cornerButtonWidth), size: buttonSize)
			case 3:	// Bottom Right
				verticalFrame = CGRect(x: bounds.width - cornerLineDepth - outterGap, y: bounds.height - cornerLineWidth - outterGap, width: cornerLineDepth, height: cornerLineWidth)
				horizontalFrame = CGRect(x: bounds.width - cornerLineWidth - outterGap, y: bounds.height - cornerLineDepth - outterGap, width: cornerLineWidth, height: cornerLineDepth)
				buttonFrame = CGRect(origin: CGPoint(x: bounds.width - cornerButtonWidth, y: bounds.height - cornerButtonWidth), size: buttonSize)

            default:
                verticalFrame = CGRect.zero
                horizontalFrame = CGRect.zero
				buttonFrame = CGRect.zero
            }
			
            corner[0].frame = verticalFrame
            corner[1].frame = horizontalFrame
			cornerButtons[i].frame = buttonFrame
        }
		
		let lineThickness = lineWidth / UIScreen.main.scale
		let vPadding = (bounds.height - outterGap * 2 - (lineThickness * CGFloat(horizontalLines.count))) / CGFloat(horizontalLines.count + 1)
		let hPadding = (bounds.width - outterGap * 2 - (lineThickness * CGFloat(verticalLines.count))) / CGFloat(verticalLines.count + 1)
		
        for i in 0..<horizontalLines.count {
            let hLine = horizontalLines[i]
            let vLine = verticalLines[i]
			
			let vSpacing = (vPadding * CGFloat(i + 1)) + (lineThickness * CGFloat(i))
			let hSpacing = (hPadding * CGFloat(i + 1)) + (lineThickness * CGFloat(i))
			
			hLine.frame = CGRect(x: outterGap, y: vSpacing + outterGap, width: bounds.width - outterGap * 2, height:  lineThickness)
			vLine.frame = CGRect(x: hSpacing + outterGap, y: outterGap, width: lineThickness, height: bounds.height - outterGap * 2)
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
        
		cornerButtons = [createButton(), createButton(), createButton(), createButton()]
		
		let dragGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(moveCropOverlay))
		addGestureRecognizer(dragGestureRecognizer)
    }
    
    func createLine() -> UIView {
        let line = UIView()
        line.backgroundColor = UIColor.white
        addSubview(line)
        return line
    }
	
	func createButton() -> UIButton {
		let button = UIButton()
		button.backgroundColor = UIColor.clear
		
		let dragGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(moveCropOverlay))
		button.addGestureRecognizer(dragGestureRecognizer)

		addSubview(button)
		return button
	}
	
	func moveCropOverlay(gestureRecognizer: UIPanGestureRecognizer) {
		if isResizable, let button = gestureRecognizer.view as? UIButton {
			if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
				let translation = gestureRecognizer.translation(in: self)
				
				var newFrame: CGRect
				
				switch button {
				case cornerButtons[0]:	// Top Left
                    newFrame = CGRect(x: frame.origin.x + translation.x, y: frame.origin.y + translation.y, width: frame.size.width - translation.x, height: frame.size.height - translation.y)
				case cornerButtons[1]:	// Top Right
					newFrame = CGRect(x: frame.origin.x, y: frame.origin.y + translation.y, width: frame.size.width + translation.x, height: frame.size.height - translation.y)
				case cornerButtons[2]:	// Bottom Left
					newFrame = CGRect(x: frame.origin.x + translation.x, y: frame.origin.y, width: frame.size.width - translation.x, height: frame.size.height + translation.y)
				case cornerButtons[3]:	// Bottom Right
					newFrame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width + translation.x, height: frame.size.height + translation.y)
				default:
					newFrame = CGRect.zero
				}

                let minimumFrame = CGRect(x: newFrame.origin.x, y: newFrame.origin.y, width: max(newFrame.size.width, minimumSize.width + 2 * outterGap), height: max(newFrame.size.height, minimumSize.height + 2 * outterGap))
				frame = minimumFrame
				layoutSubviews()

				gestureRecognizer.setTranslation(CGPoint.zero, in: self)
			}
		} else if isMovable {
			if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
				let translation = gestureRecognizer.translation(in: self)
				
				gestureRecognizer.view!.center = CGPoint(x: gestureRecognizer.view!.center.x + translation.x, y: gestureRecognizer.view!.center.y + translation.y)
				gestureRecognizer.setTranslation(CGPoint(x: 0, y: 0), in: self)
			}
		}
	}
}

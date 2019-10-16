//
//  NewCropOverlay.swift
//  ALCameraViewController
//
//  Created by Guillaume Bellut on 12/10/2019.
//  Copyright © 2019 zero. All rights reserved.
//

import UIKit

protocol CropOverlayDelegate: class {
    func didMoveCropOverlay(newFrame: CGRect)
}

internal class CropOverlay: UIView {

    private let buttons = [UIButton(),  // top left
                           UIButton(),  // top right
                           UIButton(),  // bottom left
                           UIButton()]  // bottom right
    private let precisionView = UIView()    // view containing lines

    private var cornerButtonWidth: CGFloat = 45

    private let cornerLineDepth: CGFloat = 3
    private var cornerLineLength: CGFloat {
        return cornerButtonWidth / 2
    }

    private let lineDepth: CGFloat = 1

    private let outterGapRatio: CGFloat = 1/3
    private var outterGap: CGFloat {
        return cornerButtonWidth * self.outterGapRatio
    }

    var isResizable: Bool = false
    var isMovable: Bool = false
    var minimumSize: CGSize = CGSize.zero
    weak var delegate: CropOverlayDelegate?

    var croppedRect: CGRect {
        return CGRect(x: frame.origin.x + outterGap,
                      y: frame.origin.y + outterGap,
                      width: frame.size.width - 2 * outterGap,
                      height: frame.size.height - 2 * outterGap)
    }

    internal override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    internal required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)

        if !isMovable && isResizable {
            let isButton = buttons.reduce(false) { $1.hitTest(convert(point, to: $1), with: event) != nil || $0 }
            if !isButton {
                return nil
            }
        }

        return view
    }

    private func setup() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(move(gestureRecognizer:)))
        addGestureRecognizer(panGesture)

        loadButtons()
        loadPrecisionView()
    }

    private func loadButtons() {
        buttons.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)

            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(move(gestureRecognizer:)))
            $0.addGestureRecognizer(panGesture)
        }

        buttons[0].topAnchor.constraint(equalTo: topAnchor).isActive = true
        buttons[0].leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        buttons[0].widthAnchor.constraint(equalToConstant: cornerButtonWidth).isActive = true
        buttons[0].heightAnchor.constraint(equalTo: buttons[0].widthAnchor).isActive = true

        buttons[1].topAnchor.constraint(equalTo: topAnchor).isActive = true
        buttons[1].rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        buttons[1].widthAnchor.constraint(equalToConstant: cornerButtonWidth).isActive = true
        buttons[1].heightAnchor.constraint(equalTo: buttons[1].widthAnchor).isActive = true

        buttons[2].bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        buttons[2].leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        buttons[2].widthAnchor.constraint(equalToConstant: cornerButtonWidth).isActive = true
        buttons[2].heightAnchor.constraint(equalTo: buttons[2].widthAnchor).isActive = true

        buttons[3].bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        buttons[3].rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        buttons[3].widthAnchor.constraint(equalToConstant: cornerButtonWidth).isActive = true
        buttons[3].heightAnchor.constraint(equalTo: buttons[3].widthAnchor).isActive = true
    }

    private func loadPrecisionView() {
        precisionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(precisionView)

        precisionView.isUserInteractionEnabled = false
        precisionView.layer.borderWidth = 1
        precisionView.layer.borderColor = UIColor.white.cgColor

        precisionView.topAnchor.constraint(equalTo: topAnchor, constant: outterGap).isActive = true
        precisionView.leftAnchor.constraint(equalTo: leftAnchor, constant: outterGap).isActive = true
        precisionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -outterGap).isActive = true
        precisionView.rightAnchor.constraint(equalTo: rightAnchor, constant: -outterGap).isActive = true

        loadCornerLines()
        loadPrecisionLines()
    }

    private func loadCornerLines() {
        let cornerLines = [UIView(), UIView(),  // top left
            UIView(), UIView(),  // top right
            UIView(), UIView(),  // bottom left
            UIView(), UIView()]  // bottom right

        cornerLines.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            precisionView.addSubview($0)

            $0.isUserInteractionEnabled = false
            $0.backgroundColor = .white

            let index = cornerLines.firstIndex(of: $0)!

            if index % 2 == 0 {
                $0.widthAnchor.constraint(equalToConstant: cornerLineDepth).isActive = true
                $0.heightAnchor.constraint(equalToConstant: cornerLineLength).isActive = true

                if index <= 3 {
                    $0.topAnchor.constraint(equalTo: precisionView.topAnchor, constant: -cornerLineDepth).isActive = true
                } else {
                    $0.bottomAnchor.constraint(equalTo: precisionView.bottomAnchor, constant: cornerLineDepth).isActive = true
                }

                if index % 4 == 0 {
                    $0.rightAnchor.constraint(equalTo: precisionView.leftAnchor).isActive = true
                } else {
                    $0.leftAnchor.constraint(equalTo: precisionView.rightAnchor).isActive = true
                }
            } else {
                $0.widthAnchor.constraint(equalToConstant: cornerLineLength).isActive = true
                $0.heightAnchor.constraint(equalToConstant: cornerLineDepth).isActive = true

                if index <= 3 {
                    $0.leftAnchor.constraint(equalTo: precisionView.leftAnchor, constant: -cornerLineDepth).isActive = true
                } else {
                    $0.rightAnchor.constraint(equalTo: precisionView.rightAnchor, constant: cornerLineDepth).isActive = true
                }

                if index % 4 == 1 {
                    $0.bottomAnchor.constraint(equalTo: precisionView.topAnchor).isActive = true
                } else {
                    $0.topAnchor.constraint(equalTo: precisionView.bottomAnchor).isActive = true
                }
            }
        }
    }

    private func loadPrecisionLines() {
        let centeredViews = [UIView(), UIView()]

        centeredViews.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            precisionView.addSubview($0)

            $0.isUserInteractionEnabled = false

            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.white.cgColor
        }

        // Horizontal view
        centeredViews[0].leftAnchor.constraint(equalTo: precisionView.leftAnchor).isActive = true
        centeredViews[0].rightAnchor.constraint(equalTo: precisionView.rightAnchor).isActive = true
        centeredViews[0].heightAnchor.constraint(equalTo: precisionView.heightAnchor, multiplier: 1/3).isActive = true
        centeredViews[0].centerYAnchor.constraint(equalTo: precisionView.centerYAnchor).isActive = true

        // Vertical view
        centeredViews[1].topAnchor.constraint(equalTo: precisionView.topAnchor).isActive = true
        centeredViews[1].bottomAnchor.constraint(equalTo: precisionView.bottomAnchor).isActive = true
        centeredViews[1].widthAnchor.constraint(equalTo: precisionView.widthAnchor, multiplier: 1/3).isActive = true
        centeredViews[1].centerXAnchor.constraint(equalTo: precisionView.centerXAnchor).isActive = true
    }

    @objc func move(gestureRecognizer: UIPanGestureRecognizer) {
        if isResizable, let button = gestureRecognizer.view as? UIButton {
            if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
                let translation = gestureRecognizer.translation(in: self)
                let realMinimumSize = CGSize(width: minimumSize.width + 2 * outterGap,
                                             height: minimumSize.height + 2 * outterGap)

                var newFrame: CGRect

                switch button {
                case buttons[0]:    // Top Left
                    let hasEnoughWidth = frame.size.width - translation.x >= realMinimumSize.width
                    let hasEnoughHeight = frame.size.height - translation.y >= realMinimumSize.height

                    let xPossibleTranslation = hasEnoughWidth ? translation.x : 0
                    let yPossibleTranslation = hasEnoughHeight ? translation.y : 0

                    newFrame = CGRect(x: frame.origin.x + xPossibleTranslation,
                                      y: frame.origin.y + yPossibleTranslation,
                                      width: frame.size.width - xPossibleTranslation,
                                      height: frame.size.height - yPossibleTranslation)
                case buttons[1]:    // Top Right
                    let hasEnoughWidth = frame.size.width + translation.x >= realMinimumSize.width
                    let hasEnoughHeight = frame.size.height - translation.y >= realMinimumSize.height

                    let xPossibleTranslation = hasEnoughWidth ? translation.x : 0
                    let yPossibleTranslation = hasEnoughHeight ? translation.y : 0

                    newFrame = CGRect(x: frame.origin.x,
                                      y: frame.origin.y + yPossibleTranslation,
                                      width: frame.size.width + xPossibleTranslation,
                                      height: frame.size.height - yPossibleTranslation)
                case buttons[2]:    // Bottom Left
                    let hasEnoughWidth = frame.size.width - translation.x >= realMinimumSize.width
                    let hasEnoughHeight = frame.size.height + translation.y >= realMinimumSize.height

                    let xPossibleTranslation = hasEnoughWidth ? translation.x : 0
                    let yPossibleTranslation = hasEnoughHeight ? translation.y : 0

                    newFrame = CGRect(x: frame.origin.x + xPossibleTranslation,
                                      y: frame.origin.y,
                                      width: frame.size.width - xPossibleTranslation,
                                      height: frame.size.height + yPossibleTranslation)
                case buttons[3]:    // Bottom Right
                    let hasEnoughWidth = frame.size.width + translation.x >= realMinimumSize.width
                    let hasEnoughHeight = frame.size.height + translation.y >= realMinimumSize.height

                    let xPossibleTranslation = hasEnoughWidth ? translation.x : 0
                    let yPossibleTranslation = hasEnoughHeight ? translation.y : 0

                    newFrame = CGRect(x: frame.origin.x,
                                      y: frame.origin.y,
                                      width: frame.size.width + xPossibleTranslation,
                                      height: frame.size.height + yPossibleTranslation)
                default:
                    newFrame = CGRect.zero
                }

                let minimumFrame = CGRect(x: newFrame.origin.x,
                                          y: newFrame.origin.y,
                                          width: max(newFrame.size.width,
                                                     minimumSize.width + 2 * outterGap),
                                          height: max(newFrame.size.height,
                                                      minimumSize.height + 2 * outterGap))

                gestureRecognizer.setTranslation(CGPoint.zero, in: self)
                
                delegate?.didMoveCropOverlay(newFrame: minimumFrame)
            }
        } else if isMovable {
            if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
                let translation = gestureRecognizer.translation(in: self)

                let newFrame = CGRect(x: frame.origin.x + translation.x,
                                      y: frame.origin.y + translation.y,
                                      width: frame.size.width,
                                      height: frame.size.height)

                gestureRecognizer.setTranslation(CGPoint.zero, in: self)

                delegate?.didMoveCropOverlay(newFrame: newFrame)
            }
        }
    }
}

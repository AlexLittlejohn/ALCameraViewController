//
//  ViewController.swift
//  ALCameraViewController
//
//  Created by Alex Littlejohn on 2015/06/17.
//  Copyright (c) 2015 zero. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var minimumSize: CGSize = CGSize(width: 60, height: 60)

    var croppingParameters: CroppingParameters {
        return CroppingParameters(isEnabled: croppingSwitch.isOn, allowResizing: resizableSwitch.isOn, allowMoving: movableSwitch.isOn, minimumSize: minimumSize)
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var croppingParametersView: UIView!
    @IBOutlet weak var minimumSizeLabel: UILabel!
    @IBOutlet weak var librarySwitch: UISwitch!
    @IBOutlet weak var croppingSwitch: UISwitch!
    @IBOutlet weak var resizableSwitch: UISwitch!
    @IBOutlet weak var movableSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.imageView.contentMode = .scaleAspectFit
        croppingParametersView.isHidden = !croppingSwitch.isOn
    }
    
    @IBAction func openCamera(_ sender: Any) {
        let cameraViewController = CameraViewController(croppingParameters: croppingParameters, allowsLibraryAccess: librarySwitch.isOn) { [weak self] image, asset in
            self?.imageView.image = image
            self?.dismiss(animated: true, completion: nil)
        }
        
        present(cameraViewController, animated: true, completion: nil)
    }
    
    @IBAction func openLibrary(_ sender: Any) {
        let libraryViewController = CameraViewController.imagePickerViewController(croppingParameters: croppingParameters) { [weak self] image, asset in
            self?.imageView.image = image
            self?.dismiss(animated: true, completion: nil)
        }
        
        present(libraryViewController, animated: true, completion: nil)
    }
    
    @IBAction func croppingChanged(_ sender: UISwitch) {
        croppingParametersView.isHidden = !sender.isOn
    }

    @IBAction func minimumSizeChanged(_ sender: UISlider) {
        let newValue = sender.value
        minimumSize = CGSize(width: CGFloat(newValue), height: CGFloat(newValue))
        minimumSizeLabel.text = "Minimum size: \(newValue.rounded())"
    }
}


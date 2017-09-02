//
//  ViewController.swift
//  ALCameraViewController
//
//  Created by Alex Littlejohn on 2015/06/17.
//  Copyright (c) 2015 zero. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var libraryEnabled: Bool = true
    var croppingEnabled: Bool = false
    var allowResizing: Bool = true
    var minimumSize: CGSize = CGSize(width: 60, height: 60)

    var croppingParameters: CroppingParameters {
        return CroppingParameters(isEnabled: croppingEnabled, allowResizing: allowResizing, minimumSize: minimumSize)
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var croppingParametersView: UIView!
    @IBOutlet weak var minimumSizeLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.imageView.contentMode = .scaleAspectFit
    }
    
    @IBAction func openCamera(_ sender: Any) {
        let cameraViewController = CameraViewController(croppingParameters: croppingParameters, allowsLibraryAccess: libraryEnabled) { [weak self] image, asset in
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
    
    @IBAction func libraryChanged(_ sender: Any) {
        libraryEnabled = !libraryEnabled
    }
    
    @IBAction func croppingChanged(_ sender: Any) {
        guard let switchButton = sender as? UISwitch else {
            return
        }

        croppingEnabled = switchButton.isOn
        croppingParametersView.isHidden = !switchButton.isOn
    }

    @IBAction func resizingChanged(_ sender: Any) {
        guard let switchButton = sender as? UISwitch else {
            return
        }

        allowResizing = switchButton.isOn
    }

    @IBAction func minimumSizeChanged(_ sender: Any) {
        guard let sliderButton = sender as? UISlider else {
            return
        }

        let newValue = sliderButton.value
        minimumSize = CGSize(width: CGFloat(newValue), height: CGFloat(newValue))
        minimumSizeLabel.text = "Minimum size: \(newValue.rounded())"
    }

}


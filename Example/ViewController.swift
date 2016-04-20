//
//  ViewController.swift
//  ALCameraViewController
//
//  Created by Alex Littlejohn on 2015/06/17.
//  Copyright (c) 2015 zero. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var croppingEnabled: Bool = false
    var libraryEnabled: Bool = true
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func openCamera(sender: AnyObject) {
        let cameraViewController = CameraViewController(croppingEnabled: croppingEnabled, allowsLibraryAccess: libraryEnabled) { [weak self] image, asset in
            self?.imageView.image = image
            self?.dismissViewControllerAnimated(true, completion: nil)
        }
        
        presentViewController(cameraViewController, animated: true, completion: nil)
    }
    
    @IBAction func openLibrary(sender: AnyObject) {
        let libraryViewController = CameraViewController.imagePickerViewController(croppingEnabled) { image, asset in
            self.imageView.image = image
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        presentViewController(libraryViewController, animated: true, completion: nil)
    }
    
    @IBAction func libraryChanged(sender: AnyObject) {
        libraryEnabled = !libraryEnabled
    }
    
    @IBAction func croppingChanged(sender: AnyObject) {
        croppingEnabled = !croppingEnabled
    }
}


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
        
        let cameraViewController = ALCameraViewController(croppingEnabled: croppingEnabled, allowsLibraryAccess: libraryEnabled) { (image) -> Void in
            self.imageView.image = image
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        presentViewController(cameraViewController, animated: true, completion: nil)
    }
    
    @IBAction func openLibrary(sender: AnyObject) {
        let libraryViewController = ALCameraViewController.imagePickerViewController(croppingEnabled) { (image) -> Void in
            self.imageView.image = image
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        presentViewController(libraryViewController, animated: true, completion: nil)
    }
    
    @IBAction func openCropper(sender: AnyObject) {
//        let image = UIImage(named: "image.jpg")!
//        let croppingViewController = ALCameraViewController.croppingViewController(image, croppingEnabled: true) { image in
//            self.imageView.image = image
//            self.dismissViewControllerAnimated(true, completion: nil)
//        }
//        
//        presentViewController(croppingViewController, animated: true, completion: nil)
    }
    
    @IBAction func libraryChanged(sender: AnyObject) {
        libraryEnabled = !libraryEnabled
    }
    
    @IBAction func croppingChanged(sender: AnyObject) {
        croppingEnabled = !croppingEnabled
    }
}


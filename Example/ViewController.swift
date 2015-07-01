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
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func openCamera(sender: AnyObject) {
        
        let cameraViewController = ALCameraViewController(croppingEnabled: croppingEnabled) { (image) -> Void in
            self.imageView.image = image
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        presentViewController(cameraViewController, animated: true, completion: nil)
    }
    
    @IBAction func croppingChanged(sender: AnyObject) {
        croppingEnabled = !croppingEnabled
    }
}


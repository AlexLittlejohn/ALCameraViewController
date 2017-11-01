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

    @IBAction func openCamera(_: AnyObject) {
        let cameraViewController = CameraViewController(scale: 3.0, croppingEnabled: croppingEnabled, allowsLibraryAccess: libraryEnabled, allowsAudio: false) { [weak self] _, image, _, _, _ in
            self?.imageView.image = image
            self?.dismiss(animated: true, completion: nil)
        }

        present(cameraViewController, animated: true, completion: nil)
    }

    @IBAction func openLibrary(_: AnyObject) {
        let libraryViewController = CameraViewController.imagePickerViewController(croppingEnabled: croppingEnabled) { [weak self] _, image, _, _, _ in
            self?.imageView.image = image
            self?.dismiss(animated: true, completion: nil)
        }

        present(libraryViewController, animated: true, completion: nil)
    }

    @IBAction func libraryChanged(_: AnyObject) {
        libraryEnabled = !libraryEnabled
    }

    @IBAction func croppingChanged(_: AnyObject) {
        croppingEnabled = !croppingEnabled
    }
}

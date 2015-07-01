//
//  AppDelegate.swift
//  ALCameraViewController
//
//  Created by Alex Littlejohn on 2015/06/17.
//  Copyright (c) 2015 zero. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        let viewController = ViewController(nibName: "ViewController", bundle: NSBundle.mainBundle())
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window!.rootViewController = viewController
        window!.makeKeyAndVisible()
        return true
    }
}
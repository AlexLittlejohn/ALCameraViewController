//
//  VolumeControl.swift
//  ALCameraViewController
//
//  Created by Alex Littlejohn on 2016/03/26.
//  Copyright © 2016 zero. All rights reserved.
//

import UIKit
import MediaPlayer

typealias VolumeChangeAction = (Float) -> Void

public class VolumeControl {
    
    let changeKey = "AVSystemController_SystemVolumeDidChangeNotification"
    
    lazy var volumeView: MPVolumeView = {
        let view = MPVolumeView()
        view.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
        view.alpha = 0.01
        return view
    }()
    
    var onVolumeChange: VolumeChangeAction?
    
    init(view: UIView, onVolumeChange: VolumeChangeAction?) {
        
        self.onVolumeChange = onVolumeChange
        configureInView(view)
        
        do {
            try AVAudioSession.sharedInstance().setActive(true)
            NotificationCenter.default.addObserver(self, selector: #selector(volumeChanged), name: NSNotification.Name(rawValue: changeKey), object: nil)
        } catch {
        }
        

    }
    
    deinit {
        try! AVAudioSession.sharedInstance().setActive(false)
        NotificationCenter.default.removeObserver(self)
        onVolumeChange = nil
        volumeView.removeFromSuperview()
    }
    
    func configureInView(_ view: UIView) {
        view.addSubview(volumeView)
        view.sendSubview(toBack: volumeView)
    }
    
    @objc func volumeChanged() {
        guard let slider = volumeView.subviews.filter({ $0 is UISlider }).first as? UISlider else { return }
        let volume = AVAudioSession.sharedInstance().outputVolume
        slider.setValue(volume, animated: false)
        onVolumeChange?(volume)
    }
}

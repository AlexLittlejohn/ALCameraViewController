//
//  ALPermissionsView.swift
//  ALCameraViewController
//
//  Created by Alex Littlejohn on 2015/06/24.
//  Copyright (c) 2015 zero. All rights reserved.
//

import UIKit

internal class ALPermissionsView: UIView {
   
    let iconView = UIImageView()
    let titleLabel = UILabel()
    let descriptionLabel = UILabel()
    let settingsButton = UIButton()
    
    let horizontalPadding: CGFloat = 50
    let verticalPadding: CGFloat = 20
    let verticalSpacing: CGFloat = 10
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    func commonInit() {
        
        backgroundColor = UIColor(white: 0.2, alpha: 1)
        
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.font = UIFont(name: "AppleSDGothicNeo-Light", size: 22)
        titleLabel.text = LocalizedString("permissions.title")
        
        descriptionLabel.textColor = UIColor.lightGrayColor()
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = NSTextAlignment.Center
        descriptionLabel.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 16)
        descriptionLabel.text = LocalizedString("permissions.description")
        
        let icon = UIImage(named: "permissionsIcon", inBundle: NSBundle(forClass: ALCameraViewController.self), compatibleWithTraitCollection: nil)!
        iconView.image = icon
        
        settingsButton.contentEdgeInsets = UIEdgeInsetsMake(6, 12, 6, 12)
        settingsButton.setTitle(LocalizedString("permissions.settings"), forState: UIControlState.Normal)
        settingsButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        settingsButton.layer.cornerRadius = 4
        settingsButton.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 14)
        settingsButton.backgroundColor = UIColor(red: 52.0/255.0, green: 183.0/255.0, blue: 250.0/255.0, alpha: 1)
        settingsButton.addTarget(self, action: "openSettings", forControlEvents: UIControlEvents.TouchUpInside)
        
        addSubview(iconView)
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        addSubview(settingsButton)
    }
    
    func openSettings() {
        if let appSettings = NSURL(string: UIApplicationOpenSettingsURLString) {
            UIApplication.sharedApplication().openURL(appSettings)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let size = frame.size
        let maxLabelWidth = size.width - horizontalPadding * 2
        
        let iconSize = iconView.image!.size
        let titleSize = titleLabel.sizeThatFits(CGSizeMake(maxLabelWidth, CGFloat.max))
        let descriptionSize = descriptionLabel.sizeThatFits(CGSizeMake(maxLabelWidth, CGFloat.max))
        let settingsSize = settingsButton.sizeThatFits(CGSizeMake(maxLabelWidth, CGFloat.max))
        
        let iconX = size.width/2 - iconSize.width/2
        let iconY: CGFloat = size.height/2 - (iconSize.height + verticalSpacing + verticalSpacing + titleSize.height + verticalSpacing + descriptionSize.height)/2;
        
        iconView.frame = CGRectMake(iconX, iconY, iconSize.width, iconSize.height)
        
        let titleX = size.width/2 - titleSize.width/2
        let titleY = iconY + iconSize.height + verticalSpacing + verticalSpacing
        
        titleLabel.frame = CGRectMake(titleX, titleY, titleSize.width, titleSize.height)
        
        let descriptionX = size.width/2 - descriptionSize.width/2
        let descriptionY = titleY + titleSize.height + verticalSpacing
        
        descriptionLabel.frame = CGRectMake(descriptionX, descriptionY, descriptionSize.width, descriptionSize.height)
        
        let settingsX = size.width/2 - settingsSize.width/2
        let settingsY = descriptionY + descriptionSize.height + verticalSpacing
        
        settingsButton.frame = CGRectMake(settingsX, settingsY, settingsSize.width, settingsSize.height)
    }
}

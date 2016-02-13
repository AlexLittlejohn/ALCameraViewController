//
//  ALImagePickerViewController.swift
//  ALImagePickerViewController
//
//  Created by Alex Littlejohn on 2015/06/09.
//  Copyright (c) 2015 zero. All rights reserved.
//

import UIKit
import Photos

internal let StringsTableName = "ALImagePickerStrings"
internal let ImageCellIdentifier = "ImageCellIdentifier"

internal let defaultItemSpacing: CGFloat = 1
internal let defaultPortraitColumns: CGFloat = 4
internal let defaultLandscapeColumns: CGFloat = 4

internal enum ALSelectionType {
    case SingleSelection, MultipleSelection, NoSelection
}

internal class ALImagePickerViewController: UIViewController {
    
    /// Number of columns
    private var columns: CGFloat {
        get {
            var _columns = defaultPortraitColumns
            if UIDevice.currentDevice().orientation == .LandscapeLeft || UIDevice.currentDevice().orientation == .LandscapeRight {
                _columns = defaultLandscapeColumns
            }
            return _columns
        }
    }
    
    internal var onSelectionComplete: ALCameraViewCompletion?
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cellWidth = (UIScreen.mainScreen().bounds.size.width - ((self.columns * defaultItemSpacing) - defaultItemSpacing))/self.columns
        let cellSize = CGSizeMake(cellWidth, cellWidth)
        
        layout.itemSize = cellSize
        layout.minimumInteritemSpacing = defaultItemSpacing
        layout.minimumLineSpacing = defaultItemSpacing
        layout.sectionInset = UIEdgeInsetsZero
        
        return UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        }()
    
    private var assets: PHFetchResult!
    
    internal override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        
        setNeedsStatusBarAppearanceUpdate()
        view.backgroundColor = UIColor(white: 0.2, alpha: 1)
        view.addSubview(collectionView)

        collectionView.backgroundColor = UIColor.clearColor()
        
        ALImageFetchingInteractor()
            .onFailure(onFailure)
            .onSuccess(onSuccess)
            .fetch()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.userInteractionEnabled = true
    }

    internal override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.frame = view.frame
    }
    
    internal func dismiss() {
        onSelectionComplete?(nil)
    }
    
    private func onSuccess(photos: PHFetchResult) {
        assets = photos
        configureCollectionView()
    }
    
    private func onFailure(error: NSError) {
        let permissionsView = ALPermissionsView(frame: view.bounds)
        
        
        permissionsView.titleLabel.text = LocalizedString("permissions.library.title")
        permissionsView.descriptionLabel.text = LocalizedString("permissions.library.description")
        
        view.addSubview(permissionsView)
    }
    
    private func configureCollectionView() {
        collectionView.registerClass(ALImageCell.self, forCellWithReuseIdentifier: ImageCellIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func itemAtIndexPath(indexPath: NSIndexPath) -> PHAsset {
        return assets[indexPath.row] as! PHAsset
    }
}

// MARK: - UICollectionViewDataSource -
extension ALImagePickerViewController : UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let model = itemAtIndexPath(indexPath)
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ImageCellIdentifier, forIndexPath: indexPath) as! ALImageCell
        
        cell.configureWithModel(model)
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate -
extension ALImagePickerViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let item = itemAtIndexPath(indexPath)
        let options = PHImageRequestOptions()
        options.deliveryMode = .HighQualityFormat
        
        collectionView.userInteractionEnabled = false
        
        PHImageManager.defaultManager().requestImageForAsset(item, targetSize: PHImageManagerMaximumSize, contentMode: .AspectFit, options: options, resultHandler: { [weak self] image, info in
            if let i = image {
                self?.onSelectionComplete?(i)
            }
        })
    }
}

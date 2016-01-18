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

internal typealias ALLibraryImageSelection = (ALImageModel) -> Void

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
    
    private var imageManager = PHCachingImageManager()
    private var selectedItems = [ALImageModel]()
    
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
    
    private var collectionViewDelegate: ALImagePickerViewDelegate?
    
    private var assets: [PHAsset] = []
    
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

    internal override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.frame = view.frame
    }
    
    internal func dismiss() {
        onSelectionComplete?(nil)
    }
    
    private func onSuccess(photos: [PHAsset]) {
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
        let items = assets.map({ asset in
            return ALImageModel(imageAsset: asset, imageManager: self.imageManager)
        })
        
        collectionViewDelegate = ALImagePickerViewDelegate(items: items) { item in
            
            let options = PHImageRequestOptions()
            options.deliveryMode = .HighQualityFormat
            
            self.imageManager.requestImageForAsset(item.imageAsset, targetSize: PHImageManagerMaximumSize, contentMode: .AspectFill, options: options, resultHandler: { image, info in
                if let i = image {
                    self.onSelectionComplete?(i)
                }
            })
        }

        collectionView.registerClass(ALImageCell.self, forCellWithReuseIdentifier: ImageCellIdentifier)
        collectionView.delegate = collectionViewDelegate
        collectionView.dataSource = collectionViewDelegate
    }
}

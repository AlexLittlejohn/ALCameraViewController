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
internal let defaultColumns: CGFloat = 4
internal let defaultCellWidth = (UIScreen.mainScreen().bounds.size.width - ((defaultColumns * defaultItemSpacing) - defaultItemSpacing))/defaultColumns
internal let defaultCellSize = CGSizeMake(defaultCellWidth, defaultCellWidth)

internal typealias ALLibraryImageSelection = (ALImageModel) -> Void

internal enum ALSelectionType {
    case SingleSelection, MultipleSelection, NoSelection
}

internal class ALImagePickerViewController: UIViewController {
    
    /// Horizontal and vertical cell spacing
    internal var itemSpacing: CGFloat = defaultItemSpacing {
        didSet {
            updateLayout()
        }
    }
    
    /// Number of columns
    internal var columns: CGFloat = defaultColumns {
        didSet {
            updateLayout()
        }
    }
    
    private var cellSize: CGSize = defaultCellSize
    
    internal var onSelectionComplete: ALCameraViewCompletion?
    
    private var imageManager = PHCachingImageManager()
    private var selectedItems = [ALImageModel]()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = defaultCellSize
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
    
    private func updateLayout() {
        let cellWidth = (UIScreen.mainScreen().bounds.size.width - ((defaultColumns * itemSpacing) - itemSpacing))/defaultColumns
        cellSize = CGSizeMake(cellWidth, cellWidth)
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = cellSize
        layout.minimumInteritemSpacing = itemSpacing
        layout.minimumLineSpacing = itemSpacing
        layout.sectionInset = UIEdgeInsetsZero
        
        collectionView.setCollectionViewLayout(layout, animated: true)
        collectionView.reloadData()
    }
    
    private func configureCollectionView() {
        imageManager.stopCachingImagesForAllAssets()
        let scale = UIScreen.mainScreen().scale
        let thumbnailSize = CGSizeMake(cellSize.width * scale, cellSize.height * scale)
        imageManager.startCachingImagesForAssets(assets, targetSize: thumbnailSize, contentMode: .AspectFill, options: nil)
        
        let items = assets.map({ asset in
            return ALImageModel(imageAsset: asset, imageManager: self.imageManager)
        })
        
        collectionViewDelegate = ALImagePickerViewDelegate(items: items) { item in
            self.imageManager.requestImageForAsset(item.imageAsset, targetSize: PHImageManagerMaximumSize, contentMode: .AspectFill, options: nil, resultHandler: { image, info in
                if let i = image {
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.onSelectionComplete?(i)
                    }
                }
            })
        }

        collectionView.registerClass(ALImageCell.self, forCellWithReuseIdentifier: ImageCellIdentifier)
        collectionView.delegate = collectionViewDelegate
        collectionView.dataSource = collectionViewDelegate
        
        dispatch_after(1, dispatch_get_main_queue()) {
            self.collectionView.reloadData()
        }
    }
}

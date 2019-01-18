//
//  ALImagePickerViewController.swift
//  ALImagePickerViewController
//
//  Created by Alex Littlejohn on 2015/06/09.
//  Copyright (c) 2015 zero. All rights reserved.
//

import UIKit
import Photos

internal let ImageCellIdentifier = "ImageCell"

internal let defaultItemSpacing: CGFloat = 1

public typealias PhotoLibraryViewSelectionComplete = (PHAsset?) -> Void

public class PhotoLibraryViewController: UIViewController {
    
    internal var assets: PHFetchResult<PHAsset>? = nil
    
    public var onSelectionComplete: PhotoLibraryViewSelectionComplete?
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        
        layout.itemSize = CameraGlobals.shared.photoLibraryThumbnailSize
        layout.minimumInteritemSpacing = defaultItemSpacing
        layout.minimumLineSpacing = defaultItemSpacing
        layout.sectionInset = UIEdgeInsets.zero
      
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = UIColor.clear
        return collectionView
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setNeedsStatusBarAppearanceUpdate()
        
        let buttonImage = UIImage(named: "libraryCancel", in: CameraGlobals.shared.bundle, compatibleWith: nil)?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: buttonImage,
                                                           style: UIBarButtonItem.Style.plain,
                                                           target: self,
                                                           action: #selector(dismissLibrary))
        
        view.backgroundColor = UIColor(white: 0.2, alpha: 1)
        view.addSubview(collectionView)
        
        _ = ImageFetcher()
            .onFailure(onFailure)
            .onSuccess(onSuccess)
            .fetch()
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    public func present(_ inViewController: UIViewController, animated: Bool) {
        let navigationController = UINavigationController(rootViewController: self)
        navigationController.navigationBar.barTintColor = UIColor.black
        navigationController.navigationBar.barStyle = UIBarStyle.black
        inViewController.present(navigationController, animated: animated, completion: nil)
    }
    
    @objc public func dismissLibrary() {
        onSelectionComplete?(nil)
    }
    
    private func onSuccess(_ photos: PHFetchResult<PHAsset>) {
        assets = photos
        configureCollectionView()
    }
    
    private func onFailure(_ error: NSError) {
        let permissionsView = PermissionsView(frame: view.bounds)
        permissionsView.titleLabel.text = localizedString("permissions.library.title")
        permissionsView.descriptionLabel.text = localizedString("permissions.library.description")
        
        view.addSubview(permissionsView)
    }
    
    private func configureCollectionView() {
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: ImageCellIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    internal func itemAtIndexPath(_ indexPath: IndexPath) -> PHAsset? {
        return assets?[(indexPath as NSIndexPath).row]
    }
}

// MARK: - UICollectionViewDataSource -
extension PhotoLibraryViewController : UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets?.count ?? 0
    }

    @objc(collectionView:willDisplayCell:forItemAtIndexPath:) public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if cell is ImageCell {
            if let model = itemAtIndexPath(indexPath) {
                (cell as! ImageCell).configureWithModel(model)
            }
        }
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: ImageCellIdentifier, for: indexPath)
    }
}

// MARK: - UICollectionViewDelegate -
extension PhotoLibraryViewController : UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onSelectionComplete?(itemAtIndexPath(indexPath))
    }
}

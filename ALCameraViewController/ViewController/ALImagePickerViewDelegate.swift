//
//  ALImagePickerViewDelegate.swift
//  ALImagePickerViewController
//
//  Created by Alex Littlejohn on 2015/06/09.
//  Copyright (c) 2015 zero. All rights reserved.
//

import UIKit

internal class ALImagePickerViewDelegate: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    internal let onSelection: ALLibraryImageSelection
    internal let items: [ALImageModel]
    
    internal init(items: [ALImageModel], selection: ALLibraryImageSelection) {
        self.onSelection = selection
        self.items = items
        super.init()
    }
    
    func itemAtIndexPath(indexPath: NSIndexPath) -> ALImageModel {
        return items[indexPath.row]
    }
    
    // MARK: - UICollectionViewDelegate -
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let model = itemAtIndexPath(indexPath)
        onSelection(model)
    }
    
    // MARK: - UICollectionViewDataSource -
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let model = itemAtIndexPath(indexPath)
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ImageCellIdentifier, forIndexPath: indexPath) as! ALImageCell
        
        cell.configureWithModel(model)
        
        model.view = cell
        
        return cell
    }
}

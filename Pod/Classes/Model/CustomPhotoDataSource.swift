//
//  CustomPhotoDataSource.swift
//  Pods
//
//  Created by Tatsuya Hotta on 2017/04/12.
//
//

import Foundation
import UIKit

open class CustomPhotoDataSource<T: NSObject>: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var selections = [T]()
    var items: [T]!
    var viewController: UIViewController
    var settings: Settings = Settings()
    let rowHandler: ((T) -> UIImage)
    
    fileprivate let photoCellIdentifier = "photoCellIdentifier"
    //    fileprivate let imageContentMode: PHImageContentMode = .aspectFill
    
    let bundle: Bundle = Bundle(path: Bundle(for: PhotosViewController.self).path(forResource: "BSImagePicker", ofType: "bundle")!)!
    
    public init(_ items: [T], viewController: UIViewController, rowHandler: @escaping ((T) -> UIImage), selections: [T]? = nil) {
        self.items = items
        self.viewController = viewController
        //        self.settings = settings
        self.rowHandler = rowHandler
        if let selections = selections {
            self.selections = selections
        }
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        UIView.setAnimationsEnabled(false)
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: photoCellIdentifier, for: indexPath) as! PhotoCell
        cell.accessibilityIdentifier = "photo_cell_\(indexPath.item)"
        cell.settings = settings
        let item = self.items[indexPath.row]
        cell.imageView.image = rowHandler(item)
        
        // Set selection number
        if let index = selections.index(of: item) {
            if let character = settings.selectionCharacter {
                cell.selectionString = String(character)
            } else {
                cell.selectionString = String(index+1)
            }
            cell.photoSelected = true
        } else {
            cell.photoSelected = false
        }
        UIView.setAnimationsEnabled(true)
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let cell = collectionView.cellForItem(at: indexPath) as? PhotoCell else { return false }
        
        let item = self.items[indexPath.row]
        if let index = self.selections.index(of: item) {
            // Deselect asset
            self.selections.remove(at: index)
            
            // Get indexPaths of selected items
            let selectedIndexPaths = self.selections.flatMap({ (item) -> IndexPath? in
                let index = self.items.index(of: item)
                guard index != NSNotFound else { return nil }
                return IndexPath(item: index!, section: 1)
            })
            
            // Reload selected cells to update their selection number
            UIView.setAnimationsEnabled(false)
            collectionView.reloadItems(at: selectedIndexPaths)
            UIView.setAnimationsEnabled(true)
            
            cell.photoSelected = false
        } else {
            self.selections.append(item)
            
            if let selectionCharacter = self.settings.selectionCharacter {
                cell.selectionString = String(selectionCharacter)
            } else {
                cell.selectionString = String(self.selections.count)
            }
            
            cell.photoSelected = true
        }
        
        // Update done button
        self.viewController.navigationItem.rightBarButtonItem?.isEnabled = !self.selections.isEmpty
        
        return false
    }
    
    public func registerCellIdentifiersForCollectionView(_ collectionView: UICollectionView?) {
        collectionView?.register(UINib(nibName: "PhotoCell", bundle: nil), forCellWithReuseIdentifier: photoCellIdentifier)
    }
    
}

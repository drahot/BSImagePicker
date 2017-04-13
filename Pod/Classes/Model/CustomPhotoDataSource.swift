//
//  CustomPhotoDataSource.swift
//  Pods
//
//  Created by Tatsuya Hotta on 2017/04/12.
//
//

import UIKit
import BSGridCollectionViewLayout

open class CustomPhotoDataSource<T: NSObject>: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
    
    public var selections = [T]()
    public var items: [T]!
    public var changeSelections: (([T]) -> Void)? = nil
    
    var collectionView: UICollectionView!
    
    var settings: Settings = Settings()
    let rowHandler: ((T) -> UIImage)
    
    fileprivate let photoCellIdentifier = "photoCellIdentifier"
    
    let bundle: Bundle = Bundle(path: Bundle(for: PhotosViewController.self).path(forResource: "BSImagePicker", ofType: "bundle")!)!
    
    public init(_ items: [T], collectionView: UICollectionView!, rowHandler: @escaping ((T) -> UIImage), selections: [T]? = nil) {
        self.items = items
        self.collectionView = collectionView
        self.rowHandler = rowHandler
        if let selections = selections {
            self.selections = selections
        }
        super.init()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.collectionViewLayout = GridCollectionViewLayout()
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
        cell.imageView.contentMode = .scaleAspectFill
        cell.imageView.sizeToFit()
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
        if let index = self.selections.index(of: item) { // DeSelect
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
        } else if selections.count < settings.maxNumberOfSelections { // Select
            self.selections.append(item)
            
            if let selectionCharacter = self.settings.selectionCharacter {
                cell.selectionString = String(selectionCharacter)
            } else {
                cell.selectionString = String(self.selections.count)
            }
            
            cell.photoSelected = true
        }
        
        if let changeSelectionsHandler = self.changeSelections {
            changeSelectionsHandler(self.selections)
        }
        
        return false
    }
    
    public func registerCellIdentifiersForCollectionView(_ collectionView: UICollectionView?) {
        collectionView?.register(UINib(nibName: "PhotoCell", bundle: self.bundle), forCellWithReuseIdentifier: photoCellIdentifier)
    }
    
    
}

// MARK: CustomPhotoDataSource proxy
extension CustomPhotoDataSource: BSImagePickerSettings {
    
    public var maxNumberOfSelections: Int {
        get {
            return settings.maxNumberOfSelections
        }
        set {
            settings.maxNumberOfSelections = newValue
        }
    }
    
    public var selectionCharacter: Character? {
        get {
            return settings.selectionCharacter
        }
        set {
            settings.selectionCharacter = newValue
        }
    }
    
    public var selectionFillColor: UIColor {
        get {
            return settings.selectionFillColor
        }
        set {
            settings.selectionFillColor = newValue
        }
    }
    
    public var selectionStrokeColor: UIColor {
        get {
            return settings.selectionStrokeColor
        }
        set {
            settings.selectionStrokeColor = newValue
        }
    }
    
    public var selectionShadowColor: UIColor {
        get {
            return settings.selectionShadowColor
        }
        set {
            settings.selectionShadowColor = newValue
        }
    }
    
    public var selectionTextAttributes: [String: AnyObject] {
        get {
            return settings.selectionTextAttributes
        }
        set {
            settings.selectionTextAttributes = newValue
        }
    }
    
    public var backgroundColor: UIColor {
        get {
            return settings.backgroundColor
        }
        set {
            settings.backgroundColor = newValue
        }
    }
    
    public var cellsPerRow: (_ verticalSize: UIUserInterfaceSizeClass, _ horizontalSize: UIUserInterfaceSizeClass) -> Int {
        get {
            return settings.cellsPerRow
        }
        set {
            settings.cellsPerRow = newValue
        }
    }
    
    public var takePhotos: Bool {
        get {
            return settings.takePhotos
        }
        set {
            settings.takePhotos = newValue
        }
    }
    
    public var takePhotoIcon: UIImage? {
        get {
            return settings.takePhotoIcon
        }
        set {
            settings.takePhotoIcon = newValue
        }
    }
    
}


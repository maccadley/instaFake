//
//  PhotoSelectorController.swift
//  InstaFake
//
//  Created by Admin on 29.08.2018.
//  Copyright © 2018 MaximMasov. All rights reserved.
//

import UIKit
import Photos

class PhotoSelectorController: UICollectionViewController, UICollectionViewDelegateFlowLayout{
    
    let cellId = "cellId"
    let headerId = "headerId"
    var assets = [PHAsset]()
    var headerImage: PhotoSelectorHeader?
    
    var selectedImage: UIImage?
    var images = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = .white
        setupNavigationButtons()
        collectionView?.register(PhotoSelectorCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.register(PhotoSelectorHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerId)
        fetchPhotos()
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedImage = images[indexPath.item]
        self.collectionView?.reloadData()
        let indexPathDuple = IndexPath(item: 0, section: 0)
        collectionView.scrollToItem(at: indexPathDuple, at: .bottom, animated: true)
    }
    
    //Fetching photoes from library and adding them to image[] array, so it can displays
    //our photoes in Collection views
    //DispatchQueue - need to reduce loading time as well
    
    fileprivate func fetchPhotos(){
        let allPhotos = PHAsset.fetchAssets(with: .image, options: assetsFetchOptions())
        DispatchQueue.global(qos: .background).async {
            allPhotos.enumerateObjects { (asset, count, stop) in
                
                let imageManager = PHImageManager.default()
                let targetSize = CGSize(width: 200, height: 200)
                let options = PHImageRequestOptions()
                options.isSynchronous = true
                imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options, resultHandler: { (image, info) in
                    if let image = image{
                        self.images.append(image)
                        self.assets.append(asset)
                        if self.selectedImage == nil{
                            self.selectedImage = image
                        }
                    }
                    if count == allPhotos.count - 1 {
                        DispatchQueue.main.async {
                            self.collectionView?.reloadData()
                        }
                    }
                })
            }
        }
        
    }
    
    fileprivate func assetsFetchOptions() -> PHFetchOptions{
        let fetchOptions = PHFetchOptions()
        fetchOptions.fetchLimit = 30
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchOptions.sortDescriptors = [sortDescriptor]
        return fetchOptions
    }
    
    //Adding 1 pixel after header
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 1, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = view.frame.width
        return CGSize(width: width, height: width)
    }
    
    
    
    //Header method
    //MARK: - Chosen image set as header
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! PhotoSelectorHeader
        self.headerImage = header
        header.photoImageView.image = selectedImage
        if let selectedImage = selectedImage{
            if let index = self.images.index(of: selectedImage){ //index is optional
                let selectedAsset = self.assets[index] //index is optional
                let imageManager = PHImageManager.default()
                let targetSize = CGSize(width: 600, height: 600)
                //Set chosen image with special target size
                imageManager.requestImage(for: selectedAsset, targetSize: targetSize, contentMode: .aspectFit, options: nil) { (image, info) in
                    header.photoImageView.image = image
                }
            }
        }
        return header
    }
    
    // Minimum spacing in VERTICAL columns in collection view
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    //Minimum spacing in HORIZONTAL axis in collection view
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 3) / 4
        
        return CGSize(width: width, height: width)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! PhotoSelectorCell
        cell.photoImageView.image = images[indexPath.item]
        return cell
    }
 
    override var prefersStatusBarHidden: Bool{
        return true
    }
   
    fileprivate func  setupNavigationButtons(){
        navigationController?.navigationBar.tintColor = .black
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(handleNext))
    }
    
    @objc func handleNext(){
        let sharePhotoController = SharePhotoController()
        sharePhotoController.selectedImage = headerImage?.photoImageView.image
        navigationController?.pushViewController(sharePhotoController, animated: true)
      
    }
    
    @objc func handleCancel(){
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
    
}

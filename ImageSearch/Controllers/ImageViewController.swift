//
//  ImageViewController.swift
//  ImageSearch
//
//  Created by Rakshit Singh on 12/08/22.
//

import UIKit

class ImageViewController: UICollectionViewController {
    
    var photosManager: PhotosManager?
    var currIndexPath : IndexPath?
    var searchTerm: String?
    var pagingAttempts = 0
    let activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(UINib(nibName: "ImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ImageCell")
        // setup the scroll view here to allow image sliding.
        
        navigationController?.navigationBar.addSubview(activityIndicator)
        activityIndicator.frame = (navigationController?.navigationBar.bounds)!
        activityIndicator.color = .red
        
        
        guard let photosManager = photosManager,
        let currIndexPath = currIndexPath
        else {
            return
        }
        
        collectionView.delegate = self
        
        collectionView.isPagingEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout{
            layout.scrollDirection = .horizontal
        }
        
        collectionView.contentOffset.x = collectionView.frame.width * CGFloat(currIndexPath.row)
        
    }
    
// MARK: CollectionView Data Source Methods
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let photosManager = photosManager else {
            return 0
        }

        return photosManager.countDownloadedImages()}


    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath)
        
        guard let cell = cell as? ImageCollectionViewCell,
        let photosManager = photosManager
        else{ return cell}
        
        let imgData = photosManager.imageDataForCellAt(indexPath: indexPath)
        
        
        // Look at the case when the data is not nil but the image is not able to be loaded from the data and the cellImage becomws nil
        cell.cellImage.image = UIImage(data: imgData)
        
        return cell
    }
    
}


// MARK: CollectionViewFlowLayoutDelegate Methods
extension ImageViewController: UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        let paddingSpace = CGFloat(2)*StaticContent.sectionInsets.left
        let frameWidth = collectionView.frame.width - paddingSpace
        
        return CGSize(width: collectionView.frame.width, height: collectionView.bounds.height - ((navigationController?.navigationBar.frame.height ?? 0) + 3*StaticContent.sectionInsets.top))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    // Downloads more images when we each the end of the downloaded Images in the
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard let photosManager = photosManager,
        let searchTerm = searchTerm
        else { return }
                
        // Add Activity indiciator here to Animate the loading of Images
        if !photosManager.areAllImagesDownloaded() && pagingAttempts < 2 && photosManager.countDownloadedImages() - 1 == indexPath.row{
            
            
            activityIndicator.startAnimating()
            
            photosManager.fetchImages(searchParam: searchTerm) {[weak self] searchString, error in
                
                guard let self = self else {return}
                
                if error != nil && self.pagingAttempts < 2{
                    self.pagingAttempts += 1
                    print(error?.localizedDescription)
                    self.showAlertForError(CustomError.serverError(error!.localizedDescription))
                }
                
                
                    print("Reloading the view")
                    self.collectionView.reloadData()
                    print("Reloading completed!")
                    self.activityIndicator.stopAnimating()
                    print("Animation of the activity indicator stopped")
                
                
            }
        }
        
    }
    
}


// MARK: - ActivityIndicator Methods for showing errors
extension ImageViewController{
    
    func showAlertForError(_ error: CustomError){

        var errorMessage: String = ""
        switch error{
        case .internalError(let err):
            errorMessage = err
        case .serverError(let err):
            errorMessage = err
        }

        let alertController = UIAlertController(title: errorMessage, message: "", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        
        present(alertController, animated: true)
    }
    
}

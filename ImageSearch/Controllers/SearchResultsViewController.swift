//
//  SearchResultsViewController.swift
//  ImageSearch
//
//  Created by Rakshit Singh on 10/08/22.
//

import UIKit


class SearchResultsViewController: UICollectionViewController {
    
    var searchTerm: String! = ""
    let animationObj = ImageSelectionAnimator()
    var selectedIndexPath: IndexPath?
    
    var pagingAttempts = 0
    
    let activityIndicator = UIActivityIndicatorView(style: .large)
    
    let photosManager = PhotosManager()
    
    var imagesPerGridRow : Int = 2 // Has a default value of 2 but it can be 3 or 4 also
    var pageNumber: Int = 1
    var totalPages = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Register cell classes
        collectionView.register(UINib(nibName: "ImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ImageCell")

        navigationController?.delegate = self
        

        navigationController?.navigationBar.addSubview(activityIndicator)
        activityIndicator.frame = (navigationController?.navigationBar.bounds)!
        activityIndicator.color = .red
    
        activityIndicator.startAnimating()
        
        
        photosManager.fetchImages(searchParam: self.searchTerm) {[weak self] searchString, error in
            
            guard let self = self else {return}
            if error != nil{
                self.showAlertForError(CustomError.serverError(error!.localizedDescription))
                print(error?.localizedDescription)
            }
            
            
                print("Reloading the view")
                self.collectionView.reloadData()
                print("Reloading completed!")
                self.activityIndicator.stopAnimating()
                
            
        }
        
    }


// MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photosManager.countDownloadedImages()
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath)
        
        guard let cell = cell as? ImageCollectionViewCell else{ return cell}
        
        let imgData = photosManager.imageDataForCellAt(indexPath: indexPath)
        
        // Look at the case when the data is not nil but the image is not able to be loaded from the data and the cellImage becomws nil
        cell.cellImage.image = UIImage(data: imgData)
        
        return cell
    }

    // MARK: UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        selectedIndexPath = indexPath
        let destinationVC = storyboard?.instantiateViewController(withIdentifier: "ImageVC") as! ImageViewController
        
        destinationVC.currIndexPath = indexPath
        destinationVC.photosManager = photosManager
        destinationVC.searchTerm = searchTerm
        destinationVC.transitioningDelegate = self
        
        navigationController?.pushViewController(destinationVC, animated: true)
        
    }
    
    
}

//MARK: - CollectionView FlowLayout Delegate Methods
extension SearchResultsViewController: UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return StaticContent.sectionInsets
    }
    
    // Used for paging
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        // Add Activity indiciator here to Animate the loading of Images
        if !photosManager.areAllImagesDownloaded() && self.pagingAttempts < 2 && photosManager.countDownloadedImages() - 1 == indexPath.row{
            
            activityIndicator.startAnimating()
            
            photosManager.fetchImages(searchParam: self.searchTerm) {[weak self] searchString, error in
                
                guard let self = self else{ return }
                
                if error != nil && self.pagingAttempts < 2{
                    print(error?.localizedDescription)
                    self.pagingAttempts += 1
                    self.showAlertForError(CustomError.serverError(error!.localizedDescription))
                }
                
                
                    self.collectionView.reloadData()
                    self.activityIndicator.stopAnimating()
                
                
            }
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let paddingSpace = CGFloat(imagesPerGridRow + 1)*StaticContent.sectionInsets.left
        let frameWidth = collectionView.frame.width - paddingSpace
        let imageCellSize = (frameWidth)/CGFloat(imagesPerGridRow)
        
        return CGSize(width: imageCellSize, height: imageCellSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return StaticContent.sectionInsets.left
    }
    
}


// MARK: - Transitioning Delegate Methods
extension SearchResultsViewController: UIViewControllerTransitioningDelegate{
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        print("In the Delegate Method")
        return animationObj
    }
    
    
}

extension SearchResultsViewController: UINavigationControllerDelegate{
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if operation == .pop{
            if let toVC = toVC as? SearchViewController{
                return nil
            }
            
            animationObj.presenting = false
        }else{

            //Calculate the frame of the cell that the user has selected to use it as the starting frame for the animation
            guard let selectedCell = collectionView.cellForItem(at: selectedIndexPath!) as? ImageCollectionViewCell
            else {
                return nil
            }
            
            guard let frame = selectedCell.superview?.convert(selectedCell.frame, to: nil) else{ return nil }
            
            animationObj.originFrame = frame
            animationObj.presenting = true
        }
        
        
        
        
        
        return animationObj
    }
    
}

// MARK: - ActivityIndicator Methods for showing errors
extension SearchResultsViewController{
    
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

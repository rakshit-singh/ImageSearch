//
//  ImageCollectionViewCell.swift
//  FlickrImageApp
//
//  Created by Rakshit Singh on 07/08/22.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {

    
    @IBOutlet weak var cellImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.layer.cornerRadius = 5.0
        self.layer.cornerRadius = 15.0

        self.layer.shadowRadius = 20.0
        self.layer.shadowOpacity = 0.10
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 5.0)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(userDidUsePinchGesture(_:)))
        cellImage.isUserInteractionEnabled = true
        cellImage.addGestureRecognizer(pinchGesture)
        
        
    }
    
    
    @objc func userDidUsePinchGesture(_ sender: UIPinchGestureRecognizer){
       
        print("Inside the pinch Gesture Function with scale \(sender.scale)")
        if sender.state == .changed{
            let scale = sender.scale
            print("The scale is: \(scale)")
            
            cellImage.frame = CGRect(x:0, y:0, width: 200*scale, height: 200*scale)
            cellImage.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }
    
    
}

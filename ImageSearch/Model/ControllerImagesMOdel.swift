//
//  ControllerImagesModel.swift
//  ImageSearch
//
//  Created by Rakshit Singh on 10/08/22.
//

import Foundation

// Should UIImage type be added in this to store the data here or should it be stored as a Data Object ??
struct ControllerImagesModel{
    
    let imageURL: String
    var imageData: Data
    
    // See if there is actually any use for these 2 parameters to be part of this struct??
//    let currPage: Int
//    let totalPages: Int
    
}

//
//  Result.swift
//  ImageSearch
//
//  Created by Rakshit Singh on 10/08/22.
//

import Foundation

//THis struct represents the response object that is received when making a request to the Flickr Search API
struct Result: Codable{
    private enum CodingKeys: String, CodingKey{
        case photosData = "photos"
        case stat
    }
    
    let photosData: PhotosData
    let stat: String
    
    
    
}

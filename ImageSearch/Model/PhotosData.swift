//
//  PhotosData.swift
//  ImageSearch
//
//  Created by Rakshit Singh on 11/08/22.
//

import Foundation

struct PhotosData: Codable{
    private enum CodingKeys: String, CodingKey{
        case photos = "photo", perPage = "perpage", page, pages, total
    }
    
    
    let page: Int
    let pages: Int
    let perPage: Int
    let total: Int
    let photos: [Photo]
    
}

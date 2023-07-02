//
//  Photo.swift
//  ImageSearch
//
//  Created by Rakshit Singh on 10/08/22.
//

import Foundation

struct Photo: Codable{
    
    var searchString: String?
    let id: String
    let farm: Int
    let secret: String
    let server: String
    var totalPages: Int? // Is this parameter even required??
    var url : String{
        return "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_m.png"
    }
    
    init(searchString: String, id: String, farm:Int, secret: String, server: String){
        
        self.searchString = searchString
        self.id = id
        self.farm = farm
        self.secret = secret
        self.server = server
        
    }

}

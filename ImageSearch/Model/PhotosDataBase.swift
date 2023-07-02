//
//  PhotosDataBase.swift
//  ImageSearch
//
//  Created by Rakshit Singh on 11/08/22.
//

import Foundation
import UIKit
import CoreData

// Handles the saving and retrieving of photos from Core Data or file storage
class PhotosDataBase{
    
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func saveData(searchTerm: String, data: [ControllerImagesModel]){
        
        print("Saving the data")
        
        let dbSearchObj = Search(context: context)
        dbSearchObj.searchTerm = searchTerm
        
        let objectsToSave: [SearchResult] = data.map { photos in
            let dbSearchResultObj = SearchResult(context: context)
            dbSearchResultObj.searchQuery = dbSearchObj
            dbSearchResultObj.imageData = photos.imageData
            dbSearchResultObj.imageURL = photos.imageURL
            return dbSearchResultObj
        }
        
        print("Saving \(objectsToSave.count) objects to the DB!!")
        
        do{
            try context.save()
        }catch{
            print("The error encountered during saving the Images is \(error)")
        }
        
        print("Successfully saved the data")
    }
    
    
    func loadData(searchTerm: String) -> [ControllerImagesModel]{
        
        let request: NSFetchRequest<SearchResult> = SearchResult.fetchRequest()
        let predicate = NSPredicate(format: "searchQuery.searchTerm MATCHES[cd] %@", searchTerm)
        request.predicate = predicate
        
        var dataForPhotosManager = [ControllerImagesModel]()
        var dbSearchResults = [SearchResult]()
        do {
           dbSearchResults  = try context.fetch(request)
        } catch  {
            print("The error encountered during loading the ImageData is \(error)")
        }
        
        dataForPhotosManager = dbSearchResults.map { searchResult in
            return ControllerImagesModel(imageURL: searchResult.imageURL!, imageData: searchResult.imageData!)
        }
        
        return dataForPhotosManager
    }
    
}

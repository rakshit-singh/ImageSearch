//
//  PhotosManager.swift
//  ImageSearch
//
//  Created by Rakshit Singh on 10/08/22.
//

import Foundation

// Call PhotosDataBase in the initialiser to load the data from core data and call the save function everytime the fetch request is completed
class PhotosManager{
    
    let dataBase = PhotosDataBase()
    
    let urlSession = URLSession(configuration: .default)
    var urlComponents = URLComponents()
    
    var currPage = 1
    var searchResults : [ControllerImagesModel] = []
    var images : [Photo]?
    var imagesPerPage = 10
    var totalPages = -1
    
    let api_key = "1cd2f8d2558d88732511f3e50aeeb67a"
    let format = "json"
    let method = "flickr.photos.search"
    
    init(){
        
        urlComponents.scheme = "https"
        urlComponents.host = "flickr.com"
        urlComponents.path = "/services/rest"
        
        
        urlComponents.queryItems = [URLQueryItem(name: "method", value: method), URLQueryItem(name: "api_key", value: api_key),
                                    URLQueryItem(name: "format", value: format), URLQueryItem(name: "per_page", value: String(imagesPerPage)), URLQueryItem(name: "nojsoncallback", value: "1")]
        
    }
    
    
    
    // Called by the Controller to get the image data for the cell defined by indexPath
    func imageDataForCellAt(indexPath: IndexPath) -> Data{
        
        return searchResults[indexPath.row].imageData
    }
    
    
    // makes a call to the API to fetch the Images from the API
    func fetchImages(searchParam searchString: String, completion: @escaping (_ searchString: String, _ error: Error?) -> ()){
        
        var queryItemsMap: [String:String] = ["method": method, "api_key":api_key, "format": format, "per_page":String(imagesPerPage), "nojsoncallback" : "1",
                                              "text": searchString, "page": String(currPage)
        ]
        
        
        urlComponents.queryItems = queryItemsMap.map{URLQueryItem(name: $0, value: $1)}
        
        
        // In case the data has been loaded previously and is present in core data then no API request is made
        if currPage == 1{
            let temp = dataBase.loadData(searchTerm: searchString)
            if temp.count != 0{
                searchResults = temp
                currPage = Int(ceil((Float(temp.count))/Float(imagesPerPage))) + 1
                print("After reloading the data, the current page is: \(currPage)")
                print("Loaded the data from database now calling completion handler and returning with the data")
                completion(searchString, nil)
                return
            }
        }
        
        guard let url = urlComponents.url else{
            print("Unable to create the URL for the API request")
            DispatchQueue.main.async {
                completion(searchString, nil) // Add an error object here
            }
            
            return
        }
        
        print("The url is: ")
        print(url)
        print("The current page is: \(currPage)")
        
        let task = urlSession.dataTask(with: url) { data, urlResponse, error in
            
            
            if error != nil{
                print("Unable to get make the API call")
                DispatchQueue.main.async {
                    completion(searchString, CustomError.serverError("Not able to contact the server. Check your internet connection!"))// pass in the error object here
                }
                
                return
            }
            
            guard let data = data else {
                print("No data returned by the API")
                DispatchQueue.main.async {
                    completion(searchString, CustomError.serverError("No data received from the API request."))// Pass an error to the completion Handler instead of nil
                }
                return
            }
            
            let photos = self.parseJson(data: data)
            
            guard let photos = photos else {
                DispatchQueue.main.async {
                    completion(searchString, CustomError.serverError("Internal error occured."))// Pass an error to the completion Handler instead of nil
                }
                return
            }
            
            if photos.photosData.photos.count == 0{
                print("The number of images received from the API is zero")
                DispatchQueue.main.async {
                    completion(searchString, CustomError.serverError("Could not Fetch the data from the server. Check your internet connection or try restarting the app.r"))
                }
            }
            
            if (self.totalPages == -1){
                self.totalPages = photos.photosData.pages
            }
            
            self.currPage += 1
            
            var newImgData = [ControllerImagesModel]()
            for img in photos.photosData.photos{
                
                let imgURLString = img.url
                guard let imgURL = URL(string: imgURLString) else {return}
                
                do{
                    let imgData = try Data(contentsOf: imgURL)
                    newImgData.append(ControllerImagesModel(imageURL: imgURLString, imageData: imgData))
                }catch{
                    print("Unable to get the image for the specified URL")
                }
            }
            
            // Call the dataBase save function here to save the downloaded Data
            self.dataBase.saveData(searchTerm: searchString, data: newImgData)
            self.searchResults.append(contentsOf: newImgData)
            
            DispatchQueue.main.async {
                // Call the save method here to save the downloaded API Response to the CoreData DB
                completion(searchString, nil)
            }
            
        
        }
        
        task.resume()
        
    }
    
    
    func parseJson(data: Data) -> Result? {
        
        let decoder = JSONDecoder()
    
        do{
            let result = try decoder.decode(Result.self, from: data)
            return result
        }catch{
            print(error)
            return nil
        }
        
    }
    
    // Helper method that checks if the images for all the pages have been downloaded
    func areAllImagesDownloaded() -> Bool{

        if totalPages != -1 && currPage > totalPages{
            return true
        }
        return false
    }
    
    
    func countDownloadedImages() -> Int{
        return searchResults.count
    }
    
}

enum CustomError: Error{
    case serverError(String)// represents error received while querying to the API server
    case internalError(String)// represents error that happened due to issues in the app
}


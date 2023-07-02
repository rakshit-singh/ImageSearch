//
//  SearchViewController.swift
//  ImageSearch
//
//  Created by Rakshit Singh on 11/08/22.
//

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchLabel: UILabel!
    
    
    var imagesPerRow = (UserDefaults.standard.object(forKey: "ImagesPerRow") == nil) ? 2 : UserDefaults.standard.integer(forKey: "ImagesPerRow")
    
    override func viewDidLoad(){
        
        searchBar.delegate = self
        
        UserDefaults.standard.set(imagesPerRow, forKey: "ImagesPerRow")
        print("The value for ImagesPerRow is: \(imagesPerRow) and boolean is \(UserDefaults.standard.object(forKey: "ImagesPerRow") == nil))")
        
    }
    
    
    @IBAction func settingButtonPressed(_ sender: UIBarButtonItem) {
        
        guard let destinationVC = storyboard?.instantiateViewController(withIdentifier: "SettingViewController") as? SettingsViewController else{ return }
        destinationVC.delegate = self
        
        navigationController?.pushViewController(destinationVC, animated: false)
        
    }
    
}

// MARK: - UISearchBarDelegate Functions
extension SearchViewController: UISearchBarDelegate{
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let searchTerm = searchBar.text
        
        let destinationVC = storyboard?.instantiateViewController(withIdentifier: "SearchResultsVC") as! SearchResultsViewController
        destinationVC.searchTerm = searchTerm
        destinationVC.imagesPerGridRow = imagesPerRow
        navigationController?.pushViewController(destinationVC, animated: true)
        
        searchBar.resignFirstResponder()
    }
    
    
}

extension SearchViewController: SettingsViewControllerDelegate{
    
    func imagesPerRowDidChange(newStepperValue: Int) {
        print("Changed the value of Images Per Row to \(newStepperValue)")
        imagesPerRow = newStepperValue
    }
    
}



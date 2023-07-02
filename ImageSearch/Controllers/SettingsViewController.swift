//
//  SettingsViewController.swift
//  ImageSearch
//
//  Created by Rakshit Singh on 16/08/22.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController{
    
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var stepper: UIStepper!

    
    let defaults = UserDefaults.standard
    weak var delegate: SettingsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if (defaults.object(forKey: "ImagesPerRow")) == nil{
            stepper.value = 2.0
            label.text = "2"
        }else{
            stepper.value = Double(defaults.integer(forKey: "ImagesPerRow"))
        }
        
        stepper.minimumValue = 1
        stepper.maximumValue = 3
        
        stepper.stepValue = 1.0
        stepper.autorepeat = true
        
        
        label.text = Int(stepper.value).description
        
        
    }
    
    
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        let newValue: Int =  Int(sender.value)
        label.text = newValue.description
        
        print("Setting the new Value to \(newValue)")
        defaults.set(newValue, forKey: "ImagesPerRow")
        
        
        delegate?.imagesPerRowDidChange(newStepperValue: newValue)
    }
    
}

protocol SettingsViewControllerDelegate: AnyObject{
    
    func imagesPerRowDidChange(newStepperValue: Int)
    
}

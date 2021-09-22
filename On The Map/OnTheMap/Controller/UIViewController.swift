//
//  UIViewController.swift
//  OnTheMap
//
//  Created by Anmol on 08/04/21.
//

import UIKit

extension UIViewController {
    
    
    @IBAction func addPinLocation(sender: UIBarButtonItem) {
        performSegue(withIdentifier: "addLocation", sender: sender)
    }
    
    
    func buttonEnabled(_ enabled: Bool, button: UIButton) {
        if enabled {
            button.isEnabled = true
            button.alpha = 1.0
        } else {
            button.isEnabled = false
            button.alpha = 0.5
        }
    }
    
    
    func showAlertMessage(message: String, title: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertVC, animated: true)
    }
    
    
    func openLink(_ url: String) {
        guard let url = URL(string: url), UIApplication.shared.canOpenURL(url) else {
            showAlertMessage(message: "Cannot open link.", title: "Invalid Link")
            return
        }
        UIApplication.shared.open(url, options: [:])
    }

}

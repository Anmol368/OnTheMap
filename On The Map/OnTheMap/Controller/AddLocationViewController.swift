//
//  AddLocationViewController.swift
//  OnTheMap
//
//  Created by Anmol on 08/04/21.
//

import UIKit
import MapKit

class AddLocationViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var findLocationButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var objectId: String?
    
    var locationTextFieldIsEmpty = true
    var linkTextFieldIsEmpty = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationTextField.delegate = self
        linkTextField.delegate = self
        buttonEnabled(false, button: findLocationButton)
    }
    
    
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func findLocationPressed(sender: UIButton) {
        self.setLoad(true)
        let newLocation = locationTextField.text
        
        guard let url = URL(string: self.linkTextField.text!), UIApplication.shared.canOpenURL(url) else {
            self.showAlertMessage(message: "Please include 'http://' in your link.", title: "Invalid URL")
            setLoad(false)
            return
        }

        geocodePosition(newLocation: newLocation ?? "")
    }
    
    
    private func geocodePosition(newLocation: String) {
        CLGeocoder().geocodeAddressString(newLocation) { (newMarker, error) in
            if let error = error {
                self.showAlertMessage(message: error.localizedDescription, title: "Location Not Found")
                self.setLoad(false)
                print("Location not found.")
            } else {
                var location: CLLocation?
                
                if let marker = newMarker, marker.count > 0 {
                    location = marker.first?.location
                }
                
                if let location = location {
                    self.loadNewLocation(location.coordinate)
                } else {
                    self.showAlertMessage(message: "Please try again later.", title: "Error")
                    self.setLoad(false)
                    print("There was an error.")
                }
            }
        }
    }
    
    
    private func loadNewLocation(_ coordinate: CLLocationCoordinate2D) {
        let controller = storyboard?.instantiateViewController(withIdentifier: "FinishAddLocationViewController") as! FinishAddLocationViewController
        controller.studentInformation = createStudentInfo(coordinate)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    
    private func createStudentInfo(_ coordinate: CLLocationCoordinate2D) -> StudentInformation {
        
        var studentInfo = [
            "uniqueKey": UdacityClient.Auth.key,
            "firstName": UdacityClient.Auth.firstName,
            "lastName": UdacityClient.Auth.lastName,
            "mapString": locationTextField.text!,
            "mediaURL": linkTextField.text!,
            "latitude": coordinate.latitude,
            "longitude": coordinate.longitude,
            ] as [String: AnyObject]
        
        if let objectId = objectId {
            studentInfo["objectId"] = objectId as AnyObject
            print(objectId)
        }

        return StudentInformation(studentInfo)

    }
    
    func setLoad(_ loading: Bool) {
        if loading {
            DispatchQueue.main.async {
                self.activityIndicator.startAnimating()
                self.buttonEnabled(false, button: self.findLocationButton)
            }
        } else {
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.buttonEnabled(true, button: self.findLocationButton)
            }
        }
        DispatchQueue.main.async {
            self.locationTextField.isEnabled = !loading
            self.linkTextField.isEnabled = !loading
            self.findLocationButton.isEnabled = !loading
        }
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == locationTextField {
            let currenText = locationTextField.text ?? ""
            guard let stringRange = Range(range, in: currenText) else { return false }
            let updatedText = currenText.replacingCharacters(in: stringRange, with: string)
            
            if updatedText.isEmpty && updatedText == "" {
                locationTextFieldIsEmpty = true
            } else {
                locationTextFieldIsEmpty = false
            }
        }
        
        if textField == linkTextField {
            let currenText = linkTextField.text ?? ""
            guard let stringRange = Range(range, in: currenText) else { return false }
            let updatedText = currenText.replacingCharacters(in: stringRange, with: string)
            
            if updatedText.isEmpty && updatedText == "" {
                linkTextFieldIsEmpty = true
            } else {
                linkTextFieldIsEmpty = false
            }
        }
        
        if locationTextFieldIsEmpty == false && linkTextFieldIsEmpty == false {
            buttonEnabled(true, button: findLocationButton)
        } else {
            buttonEnabled(false, button: findLocationButton)
        }
        
        return true
        
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        buttonEnabled(false, button: findLocationButton)
        if textField == locationTextField {
            locationTextFieldIsEmpty = true
        }
        if textField == linkTextField {
            linkTextFieldIsEmpty = true
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            findLocationPressed(sender: findLocationButton)
            
        }
        return true
    }
   
}

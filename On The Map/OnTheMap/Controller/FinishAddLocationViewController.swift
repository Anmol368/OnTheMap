//
//  FinishAddLocationViewController.swift
//  OnTheMap
//
//  Created by Anmol on 08/04/21.
//

import UIKit
import MapKit

class FinishAddLocationViewController: UIViewController {
    
    // MARK: Outlets and properties
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var finishAddLocationButton: UIButton!
    
    var studentInformation: StudentInformation?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let studentLocation = studentInformation {
            let studentLocation = Location(
                objectId: studentLocation.objectId ?? "",
                uniqueKey: studentLocation.uniqueKey,
                firstName: studentLocation.firstName,
                lastName: studentLocation.lastName,
                mapString: studentLocation.mapString,
                mediaURL: studentLocation.mediaURL,
                latitude: studentLocation.latitude,
                longitude: studentLocation.longitude,
                createdAt: studentLocation.createdAt ?? "",
                updatedAt: studentLocation.updatedAt ?? ""
            )
            showLocations(location: studentLocation)
        }
    }
    
    @IBAction func finishAddPinLocation(_ sender: UIButton) {
        self.setLoad(true)
        if let studentLocation = studentInformation {
            if UdacityClient.Auth.objectId == "" {
                    UdacityClient.addStudentLocation(information: studentLocation) { (success, error) in
                        if success {
                            DispatchQueue.main.async {
                                self.setLoad(true)
                                self.dismiss(animated: true, completion: nil)
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.showAlertMessage(message: error?.localizedDescription ?? "", title: "Error")
                                self.setLoad(false)
                            }
                        }
                    }
            } else {
                let alertVC = UIAlertController(title: "", message: "This student has already posted. Would you like to overwrite this location?", preferredStyle: .alert)
                alertVC.addAction(UIAlertAction(title: "Overwrite", style: .default, handler: { (action: UIAlertAction) in
                    UdacityClient.updateStudentLocation(information: studentLocation) { (success, error) in
                        if success {
                            DispatchQueue.main.async {
                                self.setLoad(true)
                                self.dismiss(animated: true, completion: nil)
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.showAlertMessage(message: error?.localizedDescription ?? "", title: "Error")
                                self.setLoad(false)
                            }
                        }
                    }
                }))
                alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction) in
                    DispatchQueue.main.async {
                        self.setLoad(false)
                        alertVC.dismiss(animated: true, completion: nil)
                    }
                }))
                self.present(alertVC, animated: true)
            }
        }
    }
    
    
    private func showLocations(location: Location) {
        mapView.removeAnnotations(mapView.annotations)
        if let coordinate = withdrawCoordinate(location: location) {
            let annotation = MKPointAnnotation()
            annotation.title = location.locationLabel
            annotation.subtitle = location.mediaURL ?? ""
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
            mapView.showAnnotations(mapView.annotations, animated: true)
        }
    }
    
    private func withdrawCoordinate(location: Location) -> CLLocationCoordinate2D? {
        if let lat = location.latitude, let lon = location.longitude {
            return CLLocationCoordinate2DMake(lat, lon)
        }
        return nil
    }
    
    
    func setLoad(_ loading: Bool) {
        if loading {
            DispatchQueue.main.async {
                self.activityIndicator.startAnimating()
                self.buttonEnabled(false, button: self.finishAddLocationButton)
            }
        } else {
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.buttonEnabled(true, button: self.finishAddLocationButton)
            }
        }
        DispatchQueue.main.async {
            self.finishAddLocationButton.isEnabled = !loading
        }
    }
    
}

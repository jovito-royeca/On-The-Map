//
//  LocationFinderViewController.swift
//  On the Map
//
//  Created by Jovit Royeca on 3/9/16.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class LocationFinderViewController: UIViewController {

    // MARK: Properties
    @IBOutlet weak var submitButton: UIBarButtonItem!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var linkTextField: UITextField!
    var currentLocation:CLLocationCoordinate2D?
    var searchResults:[CLPlacemark]?
    
    // MARK: Actions
    @IBAction func cancelAction(sender: UIBarButtonItem) {
        self.navigationController!.popToRootViewControllerAnimated(true)
    }
    
    @IBAction func submitAction(sender: UIBarButtonItem) {
        let message = "Submit the Location: (\(currentLocation!.latitude), \(currentLocation!.longitude)) and the Link: \(self.linkTextField.text!)?"
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil);
        alertController.addAction(cancelAction)
        
        let submitAction = UIAlertAction(title: "Submit", style: .Destructive) { (action) in
            MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            
            NetworkManager.sharedInstance().parseUpdateStudentLocation(self.currentLocation!, mediaURL: self.linkTextField.text!, success: { (results) in
                performUIUpdatesOnMain {
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                    self.navigationController!.popToRootViewControllerAnimated(true)
                }}, failure:  { (error) in
                    performUIUpdatesOnMain {
                        MBProgressHUD.hideHUDForView(self.view, animated: true)
                        JJJUtil.alertWithTitle("Error", andMessage:"\(error!.userInfo[NSLocalizedDescriptionKey]!)")
                    }
            })
        }
        alertController.addAction(submitAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        mapView.delegate = self
        linkTextField.delegate = self
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let currentStudent = NetworkManager.sharedInstance().currentStudent {
            if let latitude = currentStudent.latitude, let longitude = currentStudent.longitude {
                currentLocation = CLLocationCoordinate2DMake(latitude, longitude)
                
                var subtitle:String?
                if let mediaURL = currentStudent.mediaURL {
                    subtitle = mediaURL.absoluteString
                }
                
                addPinToMap(currentLocation!, title: "\(currentStudent.firstName!) \(currentStudent.lastName!)", subtitle:subtitle)
            }
        }
        
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    //MARK: un/subscription to notifications
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    // MARK: Custom methods
    func addPinToMap(location: CLLocationCoordinate2D, title: String, subtitle: String?) {
        let point = MKPointAnnotation()
        point.coordinate = location
        point.title = title
        point.subtitle = subtitle
        mapView.addAnnotation(point)
        mapView.selectAnnotation(point, animated: false)
        
        mapView.centerCoordinate = location
        currentLocation = location
    }
    
    func showSearchResults() {
        if let searchResults = searchResults {
            let alertController = UIAlertController(title: nil, message: "Select", preferredStyle: .Alert)
            
            for placemark in searchResults {
                let title = "\(placemark.name!), \(placemark.country!)"
                let action = UIAlertAction(title: title, style: .Default) { (action) in
                    self.addPinToMap(placemark.location!.coordinate, title: title, subtitle: nil)
                }
                alertController.addAction(action)
            }
            
            self.presentViewController(alertController, animated: true, completion: nil)
        } else {
            JJJUtil.alertWithTitle("Message", andMessage:"No results found.")
        }
    }
    
    //MARK: Keyboard
    func keyboardWillShow(notification: NSNotification) {
        if linkTextField.isFirstResponder() {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if linkTextField.isFirstResponder() {
            view.frame.origin.y = 0.0
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
}

// MARK: UISearchBarDelegate
extension LocationFinderViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if let address = searchBar.text {
            if address.isEmpty {
                return
            }
            
            searchBar.resignFirstResponder()
            MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            
            CLGeocoder().geocodeAddressString(address, completionHandler: { (placemarks, error) in
                
                performUIUpdatesOnMain {
                    // remove previous pins
                    for ann in self.mapView.annotations {
                        self.mapView.removeAnnotation(ann)
                    }
                    
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                    
                    if error != nil {
                        JJJUtil.alertWithTitle("Error", andMessage:"\(error!.userInfo[NSLocalizedDescriptionKey]!)")
                    } else {
                        self.searchResults = placemarks
                        
                        if placemarks?.count == 1 {
                            let placemark = placemarks?.first
                            let title = "\(placemark!.name!), \(placemark!.country!)"
                            self.addPinToMap(placemark!.location!.coordinate, title: title, subtitle: nil)
                            
                        } else {
                            self.showSearchResults()
                        }
                    }
                }
            })
        }
    }
    
    func searchBarResultsListButtonClicked(searchBar: UISearchBar) {
        showSearchResults()
    }
}

// MARK: MKMapViewDelegate
extension LocationFinderViewController : MKMapViewDelegate {
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        annotationView.canShowCallout = true
        annotationView.draggable = true
        
        return annotationView;
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        
        if newState == .Ending {
            let location = view.annotation!.coordinate

            // remove previous pins
            for ann in self.mapView.annotations {
                self.mapView.removeAnnotation(ann)
            }
            
            addPinToMap(location, title: "(\(location.latitude), \(location.longitude))", subtitle: nil)
            currentLocation = location
        }
    }
}

// MARK: UITextFieldDelegate
extension LocationFinderViewController : UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if let link = textField.text {
            if link.isEmpty {
                submitButton.enabled = false
                return false
            }
            
            textField.resignFirstResponder()
            
            if let _ = NSURL(string: link) {
                submitButton.enabled = true
            } else {
                submitButton.enabled = false
                JJJUtil.alertWithTitle("Error", andMessage:"Invalid link.")
            }
            
            return true
        }
        
        return false
    }
}

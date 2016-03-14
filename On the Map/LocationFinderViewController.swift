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
import JJJUtils
import MBProgressHUD

class LocationFinderViewController: UIViewController {

    // MARK: Properties
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var submitButton: UIBarButtonItem!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var linkTextField: UITextField!
    var currentLocation:CLLocationCoordinate2D?
    var currentMapString:String?
    var searchResults:[CLPlacemark]?
    
    // MARK: Actions
    @IBAction func cancelAction(sender: UIBarButtonItem) {
        self.navigationController!.popToRootViewControllerAnimated(true)
    }
    
    @IBAction func submitAction(sender: UIBarButtonItem) {
        guard let link = NSURL(string: linkTextField.text!) else {
            JJJUtil.alertWithTitle("Error", andMessage:"Invalid link.")
            return
        }
        
        let message = "Submit the Location: (\(currentLocation!.latitude), \(currentLocation!.longitude)) and the Link: \(link.absoluteString)?"
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil);
        alertController.addAction(cancelAction)
        
        let submitAction = UIAlertAction(title: "Submit", style: .Destructive) { (action) in
            let success = { (results: AnyObject!) in
                performUIUpdatesOnMain {
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                    self.navigationController!.popToRootViewControllerAnimated(true)
                }
            }
            let failure = { (error: NSError?) in
                performUIUpdatesOnMain {
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                    JJJUtil.alertWithTitle("Error", andMessage:"\(error!.userInfo[NSLocalizedDescriptionKey]!)")
                }
            }
            
            MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            if let _ = DataManager.sharedInstance().currentStudent {
                NetworkManager.sharedInstance().parseUpdateStudentLocation(self.currentLocation!, mapString: self.currentMapString!, mediaURL: link.absoluteString, success: success, failure: failure)
            } else {
                NetworkManager.sharedInstance().parseCreateStudentLocation(self.currentLocation!, mapString: self.currentMapString!, mediaURL: link.absoluteString, success: success, failure: failure)
            }
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
        linkTextField.addTarget(self, action: "checkLinkTextField", forControlEvents: .EditingChanged)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let currentStudent = DataManager.sharedInstance().currentStudent {
            if let latitude = currentStudent.latitude, let longitude = currentStudent.longitude {
                currentLocation = CLLocationCoordinate2DMake(latitude, longitude)
                
                addPinToMap(currentLocation!, title: "(\(latitude), \(longitude))", subtitle: currentStudent.mapString)
                
                if let mediaURL = currentStudent.mediaURL {
                    linkTextField.text = mediaURL.absoluteString
                }
            }
        } else {
            title = "Add Location and Link"
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
        // remove previous pins
        for ann in self.mapView.annotations {
            self.mapView.removeAnnotation(ann)
        }
        
        // make a pin
        let point = MKPointAnnotation()
        point.coordinate = location
        point.title = title
        point.subtitle = subtitle
        mapView.addAnnotation(point)
        mapView.selectAnnotation(point, animated: false)
        mapView.centerCoordinate = location
        
        // zoom the map
        let span = MKCoordinateSpanMake(0.5, 0.5)
        let region = MKCoordinateRegionMake(location, span)
        mapView.region = region
        
        currentLocation = location
        currentMapString = subtitle == nil ? "" : subtitle
    }
    
    func showSearchResults() {
        if let searchResults = searchResults {
            let alertController = UIAlertController(title: nil, message: "Select", preferredStyle: .Alert)
            
            for placemark in searchResults {
                let title = "\(placemark.location!.coordinate.latitude), \(placemark.location!.coordinate.longitude)"
                var subtitle:String?
                
                if let locality = placemark.locality, let country = placemark.country {
                    subtitle = "\(locality), \(country)"
                } else {
                    subtitle = placemark.country
                }
                let action = UIAlertAction(title: subtitle, style: .Default) { (action) in
                    self.addPinToMap(placemark.location!.coordinate, title: title, subtitle: subtitle)
                    self.checkLinkTextField()
                }
                alertController.addAction(action)
            }
            alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
            
        } else {
            JJJUtil.alertWithTitle("Message", andMessage:"No results found.")
        }
    }
    
    /**
        Reverse geocode the location using Apple Maps
     */
    func reverseGeocodeLocation() {
        let location = CLLocation(latitude: currentLocation!.latitude, longitude: currentLocation!.longitude)
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        setUIEnabled(false)
        
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            let title = "\(location.coordinate.latitude), \(location.coordinate.longitude)"
            var subtitle:String?
            
            performUIUpdatesOnMain {
                self.setUIEnabled(true)
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                
                if let error = error {
                    JJJUtil.alertWithTitle("Error", andMessage:"Error in geocoding the location.\(error)")
                } else {
                    if let placemarks = placemarks {
                        if let pm = placemarks.first {
                            if let locality = pm.locality, let country = pm.country {
                                subtitle = "\(locality), \(country)"
                            } else {
                                subtitle = pm.country
                            }
                        }
                    }
                    
                    self.addPinToMap(self.currentLocation!, title: title, subtitle: subtitle)
                }
            }
        })
    }
    
    func checkLinkTextField() {
        if let text = linkTextField.text {
            submitButton.enabled = !text.isEmpty
        } else {
            submitButton.enabled = false
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

// MARK: UI Updates
extension LocationFinderViewController {
    private func setUIEnabled(enabled: Bool) {
        let alpha:CGFloat = enabled ? 1.0 : 0.5
        
        cancelButton.enabled = enabled
        searchBar.userInteractionEnabled = enabled
        mapView.userInteractionEnabled = enabled
        linkTextField.enabled = enabled
        
        searchBar.alpha = alpha
        mapView.alpha = alpha
        linkTextField.alpha = alpha
        view.alpha = alpha
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
            setUIEnabled(false)
            
            CLGeocoder().geocodeAddressString(address, completionHandler: { (placemarks, error) in
                
                performUIUpdatesOnMain {
                    self.setUIEnabled(true)
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                    
                    if let error = error {
                        JJJUtil.alertWithTitle("Error", andMessage:"Error in geocoding the address.\n\(error)")
                        
                    } else {
                        if let placemarks = placemarks {
                            self.searchResults = placemarks
                            
                            if placemarks.count == 1 {
                                if let pm = placemarks.first {
                                    let title = "\(pm.location!.coordinate.latitude), \(pm.location!.coordinate.longitude)"
                                    var subtitle:String?
                                    
                                    if let locality = pm.locality, let country = pm.country {
                                        subtitle = "\(locality), \(country)"
                                    } else {
                                        subtitle = pm.country
                                    }
                                    self.addPinToMap(pm.location!.coordinate, title: title, subtitle: subtitle)
                                }
                                
                            } else {
                                self.showSearchResults()
                            }
                            
                        } else {
                            JJJUtil.alertWithTitle("Message", andMessage:"No results found.")
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
            currentLocation = view.annotation!.coordinate
            checkLinkTextField()
            reverseGeocodeLocation()
        }
    }
}

// MARK: UITextFieldDelegate
extension LocationFinderViewController : UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

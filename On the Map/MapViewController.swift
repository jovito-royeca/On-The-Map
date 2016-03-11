//
//  MapViewController.swift
//  On the Map
//
//  Created by Jovit Royeca on 3/8/16.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {

    // Mark: Properties
    @IBOutlet weak var mapView: MKMapView!
    var students:[StudentInformation]?
    
    // MARK: Actions
    @IBAction func logoutAction(sender: UIBarButtonItem) {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        NetworkManager.sharedInstance().udacityLogout({ (results) in
            performUIUpdatesOnMain {
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                self.dismissViewControllerAnimated(true, completion: nil)
            }}, failure:  { (error) in
                performUIUpdatesOnMain {
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
        })
    }
    
    @IBAction func pinAction(sender: UIBarButtonItem) {
        if let currentStudent = NetworkManager.sharedInstance().currentStudent {
            let message = "User \"\(currentStudent.firstName!) \(currentStudent.lastName!)\" Has Already Posted a Student Location. Would You Like to Overwrite Their Location?"
            
            let alertController = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil);
            alertController.addAction(cancelAction)
            
            let overwriteAction = UIAlertAction(title: "Overwrite", style: .Destructive) { (action) in
                let controller = self.storyboard!.instantiateViewControllerWithIdentifier("LocationFinderViewController") as! LocationFinderViewController
                self.navigationController!.pushViewController(controller, animated: true)
            }
            alertController.addAction(overwriteAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        
        } else {
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("LocationFinderViewController") as! LocationFinderViewController
            self.navigationController!.pushViewController(controller, animated: true)
        }
    }
    
    @IBAction func refreshAction(sender: UIBarButtonItem) {
        
    }
    
    
    // MARK: Overrides
    override func viewDidLoad() {
        mapView.delegate = self
        
        if NetworkManager.sharedInstance().students.isEmpty {
            getStudentLocations()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        students = NetworkManager.sharedInstance().students
        addPinsToMap()
    }
    
    // MARK: Custom methods
    func addPinsToMap() {
        // remove previous pins
        for ann in mapView.annotations {
            mapView.removeAnnotation(ann)
        }
        
        for student in students! {
            if let latitude = student.latitude, let longitude = student.longitude {
                let location = CLLocationCoordinate2DMake(latitude, longitude)
                let point = MKPointAnnotation()
                point.coordinate = location
                point.title = "\(student.firstName!) \(student.lastName!)"
                if let mediaURL = student.mediaURL {
                    point.subtitle = mediaURL.absoluteString
                }
                mapView.addAnnotation(point)
                
                if student.uniqueKey == NetworkManager.sharedInstance().currentStudent?.uniqueKey {
                    mapView.selectAnnotation(point, animated: false)
                }
            }
        }
    }
    
    func getStudentLocations() {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        NetworkManager.sharedInstance().parseGetStudentLocations({ (results) in
            performUIUpdatesOnMain {
                self.students = NetworkManager.sharedInstance().students
                self.addPinsToMap()
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                
            }}, failure: { (error) in
                performUIUpdatesOnMain {
                    self.students = NetworkManager.sharedInstance().students
                    self.addPinsToMap()
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                    JJJUtil.alertWithTitle("Error", andMessage:"\(error!.userInfo[NSLocalizedDescriptionKey]!)")
                }
        })
    }
}

// MARK: MKMapViewDelegate
extension MapViewController : MKMapViewDelegate {
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        annotationView.canShowCallout = true
        annotationView.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        
        return annotationView;
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let point = view.annotation
        var validLink = false
        
        if let urlString = point!.subtitle {
            if let newURL = NSURL(string: urlString!) {
                if let _ = urlString!.rangeOfString(".") {
                    validLink = true
                    
                    if newURL.scheme.isEmpty {
                        UIApplication.sharedApplication().openURL(NSURL(string: "http://\(urlString)")!)
                        
                    } else {
                        UIApplication.sharedApplication().openURL(newURL)
                    }
                }
            }
        } else {
            // to supress error message below, but we will not open the link because there is none
            validLink = true
        }
        
        if !validLink {
            JJJUtil.alertWithTitle("Error", andMessage:"Invalid link.")
        }
    }
}
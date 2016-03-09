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
        
    }
    
    @IBAction func refreshAction(sender: UIBarButtonItem) {
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        // remove previous pins
        for ann in mapView.annotations {
            mapView.removeAnnotation(ann)
        }
        
        for (_,value) in NetworkManager.sharedInstance().students {
            let location = CLLocationCoordinate2DMake(value.latitude!, value.longitude!)
            let point = MKPointAnnotation()
            point.coordinate = location
            point.title = "\(value.firstName!) \(value.lastName!)"
            mapView.addAnnotation(point)
//            mapView.selectAnnotation(point, animated: false)
            
            print("\(value.firstName!) \(value.lastName!) (\(value.latitude!),\(value.longitude!))")
        }
    }
}

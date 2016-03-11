//
//  ListViewController.swift
//  On the Map
//
//  Created by Jovit Royeca on 3/8/16.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import UIKit

class ListViewController: UIViewController {

    // MARK: Properties
    @IBOutlet weak var tabeView: UITableView!
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
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        NetworkManager.sharedInstance().parseGetStudentLocations({ (results) in
            performUIUpdatesOnMain {
                self.students = NetworkManager.sharedInstance().students
                self.tabeView.reloadData()
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                
            }}, failure: { (error) in
                performUIUpdatesOnMain {
                    self.students = NetworkManager.sharedInstance().students
                    self.tabeView.reloadData()
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                    JJJUtil.alertWithTitle("Error", andMessage:"\(error!.userInfo[NSLocalizedDescriptionKey]!)")
                }
        })
    }
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabeView!.dataSource = self
        tabeView!.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        students = NetworkManager.sharedInstance().students
        tabeView.reloadData()
    }
    
    // MARK: Custom methods
    func deleteLocation() {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        NetworkManager.sharedInstance().parseDeleteStudentLocation({ (results) in
            performUIUpdatesOnMain {
                self.students = NetworkManager.sharedInstance().students
                self.tabeView.reloadData()
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                
            }}, failure: { (error) in
                performUIUpdatesOnMain {
                    self.students = NetworkManager.sharedInstance().students
                    self.tabeView.reloadData()
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                    JJJUtil.alertWithTitle("Error", andMessage:"\(error!.userInfo[NSLocalizedDescriptionKey]!)")
                }
        })
    }
}

// MARK: UITableViewDataSource
extension ListViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let student = students![indexPath.row]

        let cell = tableView.dequeueReusableCellWithIdentifier("listTableViewCell", forIndexPath: indexPath) as! ListTableViewCell
        cell.nameLabel.text = "\(student.firstName!) \(student.lastName!)"
        cell.locationLabel.text = student.mapString!
        if let mediaURL = student.mediaURL {
            cell.urlLabel.text = mediaURL.absoluteString
            cell.urlLabel.textColor = UIColor.blackColor()
            
            if let _ = NSURL(string: mediaURL.absoluteString) {
                if let _ = mediaURL.absoluteString.rangeOfString(".") {
                    cell.urlLabel.textColor = UIColor.blueColor()
                }
            }
            
        } else {
            cell.urlLabel.text = "[No URL]"
            cell.urlLabel.textColor = UIColor.blackColor()
        }

        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students!.count
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        let student = students![indexPath.row]
        
        if student.uniqueKey! == NetworkManager.sharedInstance().currentStudent?.uniqueKey {
            return true
        }
        
        return false
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let message = "Delete your Location and Link?"
        
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil);
        alertController.addAction(cancelAction)
        
        let overwriteAction = UIAlertAction(title: "Delete", style: .Destructive) { (action) in
            self.deleteLocation()
        }
        alertController.addAction(overwriteAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}

extension ListViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let student = students![indexPath.row]
        var validLink = false
        
        if let mediaURL = student.mediaURL {
            let urlString = mediaURL.absoluteString
            
            if let newURL = NSURL(string: urlString) {
                if let _ = urlString.rangeOfString(".") {
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
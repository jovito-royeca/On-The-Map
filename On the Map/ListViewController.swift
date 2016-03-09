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
}

// MARK: UITableViewDataSource
extension ListViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let student = students![indexPath.row]
        
        /* Get cell type */
        let cellReuseIdentifier = "ListTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as UITableViewCell!
        
        /* Set cell defaults */
        cell.textLabel!.text = "\(student.firstName!) \(student.lastName!)"
        if let mediaURL = student.mediaURL {
            cell.detailTextLabel!.text = mediaURL.absoluteString
        } else {
            cell.detailTextLabel!.text = nil
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students!.count
    }
}

extension ListViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let student = students![indexPath.row]
        
        if let url = student.mediaURL {
            if let newUrl = NSURL(string: url.absoluteString) {
                UIApplication.sharedApplication().openURL(newUrl)
            } else {
                JJJUtil.alertWithTitle("Error", andMessage:"Invalid URL: \(url.absoluteString)")
            }
        }
    }
}
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
        
    }
    
    
    @IBAction func refreshAction(sender: UIBarButtonItem) {
        
    }
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        tabeView!.dataSource = self
        tabeView!.delegate = self
        
        students = [StudentInformation]()
        for (_,value) in NetworkManager.sharedInstance().students {
            students!.append(value)
        }
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
            cell.detailTextLabel!.text = "\(mediaURL)"
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
            UIApplication.sharedApplication().openURL(url)
        }
    }
}
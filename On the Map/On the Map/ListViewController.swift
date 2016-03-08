//
//  ListViewController.swift
//  On the Map
//
//  Created by Jovit Royeca on 3/8/16.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import UIKit

class ListViewController: UIViewController {

    
    @IBAction func logoutAction(sender: UIBarButtonItem) {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        NetworkManager.sharedInstance().logoutUdacity({ (results) in
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
    
}

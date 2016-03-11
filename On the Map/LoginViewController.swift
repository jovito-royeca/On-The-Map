//
//  LoginViewController.swift
//  On the Map
//
//  Created by Jovit Royeca on 3/8/16.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupLabel: UILabel!
    @IBOutlet weak var facebookButton: UIButton!

    
    @IBAction func loginButtonAction(sender: UIButton) {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        NetworkManager.sharedInstance().udacityLogin(usernameText.text!, password: passwordText.text!, success: { (results) in
            performUIUpdatesOnMain {
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                let controller = self.storyboard!.instantiateViewControllerWithIdentifier("MainTabBarController") as! UITabBarController
                self.presentViewController(controller, animated: true, completion: nil)
            }}, failure:  { (error) in
                performUIUpdatesOnMain {
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                JJJUtil.alertWithTitle("Error", andMessage:"\(error!.userInfo[NSLocalizedDescriptionKey]!)")
            }
        })
    }
    
    @IBAction func facebookButtonAction(sender: UIButton) {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        NetworkManager.sharedInstance().facebookLogin(self, success: { (results) in
            performUIUpdatesOnMain {
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                let controller = self.storyboard!.instantiateViewControllerWithIdentifier("MainTabBarController") as! UITabBarController
                self.presentViewController(controller, animated: true, completion: nil)
            }}, failure:  { (error) in
                performUIUpdatesOnMain {
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                    JJJUtil.alertWithTitle("Error", andMessage:"\(error!.userInfo[NSLocalizedDescriptionKey]!)")
                }
        })
    }
    
    
    @IBAction func signupLabelAction(sender: UITapGestureRecognizer) {
        UIApplication.sharedApplication().openURL(NSURL(string: Constants.Udacity.SignupPage)!)
    }
}


//
//  LoginViewController.swift
//  Scantact
//
//  Created by Hassan Abid on 3/13/16.
//  Copyright © 2016 Hassan Abid. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON


class LoginViewController: UIViewController,UITextFieldDelegate {
    
    
    // MARK:  properties
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var signupButton: UIButton!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!

    

    let BASE_LOGIN_URL_LOCAL = "http://localhost:8000/rest-auth/login/"
    let BASE_LOGIN_URL = "https://scantact.pythonanywhere.com/rest-auth/login/"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
    }
    
    override func viewWillAppear(animated: Bool) {
    
        super.viewWillAppear(animated)
        
        // Listen for changes to keyboard visibility so that we can adjust the text view accordingly.
        let notificationCenter = NSNotificationCenter.defaultCenter()
        
        notificationCenter.addObserver(self, selector: "handleKeyboardNotification:", name: UIKeyboardWillShowNotification, object: nil)
        
        notificationCenter.addObserver(self, selector: "handleKeyboardNotification:", name: UIKeyboardWillHideNotification, object: nil)
        
        self.spinner.hidden = true
       
    }
    
    override func viewDidAppear(animated: Bool) {
        
         configureNavigationButton()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        
        notificationCenter.removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        
        notificationCenter.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    // MARK: View methods
    
    func setupView() {
        
        loginButton.backgroundColor = UIColor.applicationAccentColor
        signupButton.backgroundColor = UIColor.applicationAccentColor
        configuredTextFields()
    }

    func configureNavigationButton() {
       
        
    }
    
    @IBAction func dismissLoginViewController(sender: UIBarButtonItem) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    

    func configuredTextFields() {
        usernameTextField.tintColor = UIColor.blueColor()
        usernameTextField.textColor = UIColor.blackColor()
        passwordTextField.tintColor = UIColor.blueColor()
        passwordTextField.textColor = UIColor.blackColor()
        
        
        usernameTextField.returnKeyType = .Next
        usernameTextField.clearButtonMode = .Never
        
        passwordTextField.secureTextEntry = true
        passwordTextField.returnKeyType = .Done
        passwordTextField.clearButtonMode = .Never
        
    }
    
    func handleKeyboardNotification(notification: NSNotification) {
        let userInfo = notification.userInfo!
        
        // Get information about the animation.
        let animationDuration: NSTimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        let rawAnimationCurveValue = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).unsignedLongValue
        let animationCurve = UIViewAnimationOptions(rawValue: rawAnimationCurveValue)
        
        // Convert the keyboard frame from screen to view coordinates.
//        let keyboardScreenBeginFrame = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
//        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
//        let keyboardViewBeginFrame = view.convertRect(keyboardScreenBeginFrame, fromView: view.window)
//        let keyboardViewEndFrame = view.convertRect(keyboardScreenEndFrame, fromView: view.window)
        
        // Determine how far the keyboard has moved up or down.
//        let originDelta = keyboardViewEndFrame.origin.y - keyboardViewBeginFrame.origin.y
        
        // Adjust the table view's scroll indicator and content insets.
//        tableView.scrollIndicatorInsets.bottom -= originDelta
//        tableView.contentInset.bottom -= originDelta
        
        // Inform the view that its the layout should be updated.
//        tableView.setNeedsLayout()
        
        // Animate updating the view's layout by calling layoutIfNeeded inside a UIView animation block.
        let animationOptions: UIViewAnimationOptions = [animationCurve, .BeginFromCurrentState]
        UIView.animateWithDuration(animationDuration, delay: 0, options: animationOptions, animations: {
            self.view.layoutIfNeeded()
            }, completion: nil)
    }
    
    // MARK:
    
    
    @IBAction func loginUser(sender: UIButton) {
        
        self.spinner.hidden = false
        
        if let username = usernameTextField.text, password = passwordTextField.text {
            
              print("username: \(username) password: \(password)")
        
        Alamofire.request(.POST, BASE_LOGIN_URL, parameters: ["username": username,
            "password": password])
            .responseJSON { response in
                print(response.request)  // original URL request
                print(response.response) // URL response
                print(response.data)     // server data
                print(response.result)   // result of response serialization
                
                if let loginStatus = response.result.value {
                   let json = JSON(loginStatus)
                    if let strToken = json["key"].string {
                        print("token: \(strToken)")
                         self.spinner.hidden = true
                        self.saveTokenInUserDefaults(strToken)
                        self.startHomeController()
                    } else {
                        self.showLoginAlert()
                         self.spinner.hidden = true
                        print("login failed \(loginStatus)")
                    }

                }
            }
        }
        
        
    }
    
    func startHomeController() {
        let homeViewController = self.storyboard?.instantiateViewControllerWithIdentifier("HomeTabBarViewController") as! HomeTabBarViewController

        let navigationViewController = UINavigationController(rootViewController: homeViewController)
        let logoutButton = UIBarButtonItem(title: "Log out", style: UIBarButtonItemStyle.Plain, target: nil, action: "actionLogoutUser:")
        logoutButton.tintColor = UIColor.blackColor()
        navigationViewController.navigationItem.leftBarButtonItem = logoutButton
        self.presentViewController(navigationViewController, animated: true, completion: nil)
        
        
    
    }
    
    @IBAction func handleForgetPassword(sender: UIButton) {
        
        print("forgetpassword")
    }
    
    func actionLogoutUser(sender:UIBarButtonItem) {
        print("logout")
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true

    }
    
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
    }
    
    // MARK: Helper methods
    
    /// Show an alert with an "Okay" button.
    func showLoginAlert() {
        let title = NSLocalizedString(":(", comment: "")
        let message = NSLocalizedString("We could not find an account with this username and password", comment: "")
        let cancelButtonTitle = NSLocalizedString("OK", comment: "")
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        // Create the action.
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .Cancel) { action in
            NSLog("cancel button clicked")
        }
        
        // Add the action.
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func saveTokenInUserDefaults(strToken : String)  {
    
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(strToken, forKey: "userToken")
        userDefaults.synchronize()
        
    }
    

}

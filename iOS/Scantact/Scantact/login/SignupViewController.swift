//
//  SignupViewController.swift
//  Scantact
//
//  Created by Hassan Abid on 3/14/16.
//  Copyright © 2016 Hassan Abid. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON


class SingupViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: properties 
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    
    @IBOutlet weak var signupUserButton: UIButton!
    
    let BASE_SIGNUP_URL_LOCAL = "http://localhost:8000/rest-auth/registration/"
    let BASE_SIGNUP_URL = "https://scantact.pythonanywhere.com/rest-auth/registration/"
    
    // MARK: Viewcontroller methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Listen for changes to keyboard visibility so that we can adjust the text view accordingly.
        let notificationCenter = NSNotificationCenter.defaultCenter()
        
        notificationCenter.addObserver(self, selector: "handleKeyboardNotification:", name: UIKeyboardWillShowNotification, object: nil)
        
        notificationCenter.addObserver(self, selector: "handleKeyboardNotification:", name: UIKeyboardWillHideNotification, object: nil)

    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        
        notificationCenter.removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        
        notificationCenter.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    
    // MARK:  IBAction methods
    
    @IBAction func dismissSignupViewController(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func signupUser(sender: UIButton) {
        
        
        if let username = usernameTextField.text, password = passwordTextField.text,confirmPassword = confirmPasswordTextField.text,
        email = emailTextField.text{
            
            print("username: \(username) password: \(password)")
            if ( password != confirmPassword) {
                
            }
            Alamofire.request(.POST, BASE_SIGNUP_URL, parameters: ["username": username,
                "password1": password,"password2": confirmPassword,"email": email])
                .responseJSON { response in
                    print(response.request)  // original URL request
                    print(response.response) // URL response
                    print(response.data)     // server data
                    print(response.result)   // result of response serialization
                    
                    if let signupStatus = response.result.value {
                        let json = JSON(signupStatus)
                        if let strToken = json["key"].string {
                            print("token: \(strToken)")
                            self.saveTokenInUserDefaults(strToken)
                            self.startHomeController()
                        } else {
                            self.showSingupAlert()
                            print("login failed \(signupStatus)")
                        }
                        
                    }
            }
        }
        

    }
    
    // MARK: Helper methods
    
    
    func setupViews() {
        signupUserButton.backgroundColor = UIColor.applicationAccentColor
        configuredTextFields()
    
    }
    
    func configuredTextFields() {
        
        emailTextField.tintColor = UIColor.blueColor()
        emailTextField.textColor = UIColor.blackColor()
        usernameTextField.tintColor = UIColor.blueColor()
        usernameTextField.textColor = UIColor.blackColor()
        passwordTextField.tintColor = UIColor.blueColor()
        passwordTextField.textColor = UIColor.blackColor()
        confirmPasswordTextField.tintColor = UIColor.blueColor()
        confirmPasswordTextField.textColor = UIColor.blackColor()
        
        emailTextField.returnKeyType = .Next
        usernameTextField.returnKeyType = .Next
        passwordTextField.returnKeyType = .Next
        confirmPasswordTextField.returnKeyType = .Next
        
        emailTextField.clearButtonMode = .WhileEditing
        usernameTextField.clearButtonMode = .WhileEditing
        
        passwordTextField.secureTextEntry = true
        confirmPasswordTextField.secureTextEntry = true
        passwordTextField.clearButtonMode = .WhileEditing
        confirmPasswordTextField.clearButtonMode = .WhileEditing
        
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
//        
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
    
    /// Show an alert with an "Okay" button.
    func showSingupAlert() {
        let title = NSLocalizedString("Could not sign up", comment: "")
        let message = NSLocalizedString("Please fill in all the fields", comment: "")
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

    func startHomeController() {
        let homeViewController = self.storyboard?.instantiateViewControllerWithIdentifier("HomeTabBarViewController") as! HomeTabBarViewController
        
        let navigationViewController = UINavigationController(rootViewController: homeViewController)
        let logoutButton = UIBarButtonItem(title: "Log out", style: UIBarButtonItemStyle.Plain, target: nil, action: "actionLogoutUser:")
        logoutButton.tintColor = UIColor.blackColor()
        navigationViewController.navigationItem.leftBarButtonItem = logoutButton
        self.presentViewController(navigationViewController, animated: true, completion: nil)
        
        
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
    
}

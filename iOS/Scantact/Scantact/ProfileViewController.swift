//
//  ProfileViewController.swift
//  Scantact
//
//  Created by Hassan Abid on 2/16/16.
//  Copyright © 2016 Hassan Abid. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ProfileViewController: UIViewController, UITextFieldDelegate {

    // MARK: properties 
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var firstNameTextField: UITextField!
    
    @IBOutlet weak var lastNameTextField: UITextField!
    
    @IBOutlet weak var saveButton: UIButton!
    var userToken:String?
    
    let BASE_USER_URL_LOCAL = "http://localhost:8000/rest-auth/user/"
    let BASE_USER_URL = "https://scantact.pythonanywhere.com/rest-auth/user/"
    
    let BASE_LOGOUT_URL_LOCAL = "http://localhost:8000/rest-auth/logout/"
    let BASE_LOGOUT_URL = "https://scantact.pythonanywhere.com/rest-auth/logout/"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.backgroundColor = UIColor.applicationAccentColor
        getUserDetails()
    }
    
    override func viewWillAppear(animated: Bool) {
        // Listen for changes to keyboard visibility so that we can adjust the text view accordingly.
        let notificationCenter = NSNotificationCenter.defaultCenter()
        
        notificationCenter.addObserver(self, selector: "handleKeyboardNotification:", name: UIKeyboardWillShowNotification, object: nil)
        
        notificationCenter.addObserver(self, selector: "handleKeyboardNotification:", name: UIKeyboardWillHideNotification, object: nil)

    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        
        notificationCenter.removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        
        notificationCenter.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK:  helper methods
    
    func getUserDetails()  {
        let strToken = NSUserDefaults.standardUserDefaults().stringForKey("userToken")
        userToken = strToken
        if let strToken = strToken {
            
            let first_name = NSUserDefaults.standardUserDefaults().stringForKey("first_name")
            let last_name = NSUserDefaults.standardUserDefaults().stringForKey("last_name")
            if let firstName = first_name , last_name = last_name{
                self.textView.text = "Welcome \(firstName) \(last_name)"
                self.textView.editable = false
                self.firstNameTextField.text = first_name
                self.lastNameTextField.text = last_name
                return
            }
            
            let authToken = "Token \(strToken)"
            print("get userDetails with token: \(authToken)")
            let headers = [
                "Authorization": authToken
            ]
        
            Alamofire.request(.GET,BASE_USER_URL, headers: headers, encoding: .JSON)
                .responseJSON { response in
                    
                    debugPrint(response)
                
                
                    if let userDetails = response.result.value {
                        let json = JSON(userDetails)
                        if let first_name = json["first_name"].string,last_name = json["last_name"].string,username = json["username"].string,
                        email = json["email"].string {
                
                            print("token: \(json) with firstName: \(first_name)")
                            self.saveUser(username,email: email)
//                            self.configureTextView(first_name,last_name: last_name)
                            self.textView.text = "Welcome \(first_name) \(last_name)"
                            self.textView.editable = false
                            self.firstNameTextField.text = first_name
                            self.lastNameTextField.text = last_name

                        } else {
                            print("login failed \(userDetails)")
                    }
                    
                }
                
            }
        }
    
    }
    
    func setupView(first_name:String, last_name:String) {
        
        
    
    }
    
    func saveUser(username:String, email:String) {
    
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(username, forKey: "username")
        userDefaults.setObject(email, forKey: "email")
    }
    
    func saveUserName(first_name:String, last_name:String) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(first_name, forKey: "first_name")
        userDefaults.setObject(last_name, forKey: "last_name")
    }
    
    func resetUser() {
    
        NSUserDefaults.standardUserDefaults().removeObjectForKey("userToken")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("first_name")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("last_name")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("username")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("email")
    }
    
    // MARK: IBActions
    
    
    @IBAction func logoutTapped(sender: UIButton) {
        
        //TODO: Logout User 
        if let strToken = userToken {
            Alamofire.request(.POST, BASE_LOGOUT_URL, parameters: ["token": strToken]).responseJSON { response in
                
//                debugPrint(response)
                print("logout user")
                
                self.resetUser()
                let mainController = self.storyboard?.instantiateViewControllerWithIdentifier("MainViewController") as! MainViewController
                let appDelegate = UIApplication.sharedApplication().delegate
                appDelegate?.window??.rootViewController = mainController

            }
        }
        
    }
    
    
    @IBAction func saveUserTapped(sender: UIButton) {
        
        
        if let first_name = firstNameTextField.text, last_name = lastNameTextField.text {
            if let strToken = userToken {
                let authToken = "Token \(strToken)"
                let headers = [
                    "Authorization": authToken
                ]

                Alamofire.request(.PATCH, BASE_USER_URL, parameters: ["first_name": first_name, "last_name": last_name],headers:headers)
                    .responseJSON { response in
                        print(response.request)  // original URL request
                        print(response.response) // URL response
                        print(response.data)     // server data
                        print(response.result)   // result of response serialization
                        
                        if let updateUser = response.result.value {
                            let json = JSON(updateUser)
                            if let first_name = json["first_name"].string,last_name = json["last_name"].string{
                                self.saveUserName(first_name,last_name: last_name)
                                 self.textView.text = "Welcome \(first_name) \(last_name)"
//                                self.configureTextView(first_name, last_name: last_name)
                                self.textView.editable = false
                                self.firstNameTextField.text = first_name
                                self.lastNameTextField.text = last_name
                                
                            } else {
                                print("user update failed \(updateUser)")
                            }
                            
                        }
                }
            }
        }

    }
    
    // MARK: Configuration
    
    func configureTextView(first_name: String, last_name:String) {
        
        let bodyFontDescriptor = UIFontDescriptor.preferredFontDescriptorWithTextStyle(UIFontTextStyleBody)
        self.textView.font = UIFont(descriptor: bodyFontDescriptor, size: 0)
        
        self.textView.textColor = UIColor.blackColor()
        self.textView.backgroundColor = UIColor.whiteColor()
        self.textView.scrollEnabled = true
        
        /*
        Let's modify some of the attributes of the attributed string.
        You can modify these attributes yourself to get a better feel for what they do.
        Note that the initial text is visible in the storyboard.
        */
        let attributedText = NSMutableAttributedString(attributedString: self.textView.attributedText!)
        
        /*
        Use NSString so the result of rangeOfString is an NSRange, not Range<String.Index>.
        This will then be the correct type to then pass to the addAttribute method of
        NSMutableAttributedString.
        */
        let text = "Welcome \(first_name) \(last_name)" as NSString
        
        // Find the range of each element to modify.
        let boldRange = text.rangeOfString(NSLocalizedString(first_name, comment: ""))
//        let highlightedRange = text.rangeOfString(NSLocalizedString("highlighted", comment: ""))
//        let underlinedRange = text.rangeOfString(NSLocalizedString("underlined", comment: ""))
//        let tintedRange = text.rangeOfString(NSLocalizedString("tinted", comment: ""))
        
        /*
        Add bold. Take the current font descriptor and create a new font descriptor
        with an additional bold trait.
        */
        let boldFontDescriptor = self.textView.font!.fontDescriptor().fontDescriptorWithSymbolicTraits(.TraitBold)
        let boldFont = UIFont(descriptor: boldFontDescriptor, size: 0)
        attributedText.addAttribute(NSFontAttributeName, value: boldFont, range: boldRange)
        
        // Add highlight.
//        attributedText.addAttribute(NSBackgroundColorAttributeName, value: UIColor.applicationGreenColor, range: highlightedRange)
        
        // Add underline.
//        attributedText.addAttribute(NSUnderlineStyleAttributeName, value: NSUnderlineStyle.StyleSingle.rawValue, range: underlinedRange)
        
        // Add tint.
//        attributedText.addAttribute(NSForegroundColorAttributeName, value: UIColor.applicationBlueColor, range: tintedRange)
        
        // Add image attachment.
//        let textAttachment = NSTextAttachment()
//        let image = UIImage(named: "text_view_attachment")!
//        textAttachment.image = image
//        textAttachment.bounds = CGRect(origin: CGPointZero, size: image.size)
//        
//        let textAttachmentString = NSAttributedString(attachment: textAttachment)
//        attributedText.appendAttributedString(textAttachmentString)
        
        self.textView.attributedText = attributedText
            
    }
    
    func configuredTextFields() {
        
        firstNameTextField.tintColor = UIColor.blueColor()
        firstNameTextField.textColor = UIColor.blackColor()
        lastNameTextField.tintColor = UIColor.blueColor()
        lastNameTextField.textColor = UIColor.blackColor()
        
        firstNameTextField.returnKeyType = .Next
        lastNameTextField.returnKeyType = .Go
        
        firstNameTextField.clearButtonMode = .Never
        lastNameTextField.clearButtonMode = .Never
        
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
}

